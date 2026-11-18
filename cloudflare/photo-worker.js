// Campus Incident Reporter — evidence photo Worker (Cloudflare R2).
//
// Replaces Firebase Storage for incident photos while keeping the same access
// rules as firebase/storage.rules:
//   - Only verified @alustudent.com Firebase users may use the API.
//   - Users upload only into their own folder: photos/{uid}/{fileName}.
//   - Owners and staff (users/{uid}.role == 'staff' in Firestore) may view
//     and delete a photo.
//   - Only JPEG/PNG/WebP images under 8 MB are accepted.
//
// Required bindings / variables (Worker → Settings):
//   PHOTOS              R2 bucket binding (bucket: incident-photos)
//   FIREBASE_PROJECT_ID plain-text variable, e.g. inzira-498621
//
// Every request must send:  Authorization: Bearer <Firebase ID token>
//
//   PUT    /photos/{uid}/{fileName}   body = image bytes, Content-Type = image/*
//   GET    /photos/{uid}/{fileName}
//   DELETE /photos/{uid}/{fileName}

const MAX_BYTES = 8 * 1024 * 1024;
const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);
const ALU_EMAIL = /^[^@]+@alustudent[.]com$/;
const SAFE_UID = /^[A-Za-z0-9]{1,128}$/;
const SAFE_NAME = /^[A-Za-z0-9._-]{1,128}$/;
const JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

let jwksCache = { keys: null, expiresAt: 0 };

export default {
  async fetch(request, env) {
    try {
      return await handle(request, env);
    } catch (error) {
      if (error instanceof HttpError) {
        return json({ error: error.message }, error.status);
      }
      console.error(error);
      return json({ error: 'Internal error' }, 500);
    }
  },
};

async function handle(request, env) {
  if (!env.PHOTOS || !env.FIREBASE_PROJECT_ID) {
    throw new HttpError(500, 'Worker is missing PHOTOS or FIREBASE_PROJECT_ID');
  }

  const url = new URL(request.url);
  const match = url.pathname.match(/^\/photos\/([^/]+)\/([^/]+)$/);
  if (!match) throw new HttpError(404, 'Not found');

  const [, ownerUid, fileName] = match;
  if (!SAFE_UID.test(ownerUid) || !SAFE_NAME.test(fileName)) {
    throw new HttpError(400, 'Invalid photo path');
  }
  const key = `photos/${ownerUid}/${fileName}`;

  const token = bearerToken(request);
  const claims = await verifyFirebaseToken(token, env.FIREBASE_PROJECT_ID);
  if (
    typeof claims.email !== 'string' ||
    !ALU_EMAIL.test(claims.email) ||
    claims.email_verified !== true
  ) {
    throw new HttpError(403, 'A verified ALU account is required');
  }
  const isOwner = claims.sub === ownerUid;

  switch (request.method) {
    case 'PUT': {
      if (!isOwner) throw new HttpError(403, 'You can only upload your own photos');
      const contentType = (request.headers.get('Content-Type') || '')
        .split(';')[0]
        .trim()
        .toLowerCase();
      if (!ALLOWED_TYPES.has(contentType)) {
        throw new HttpError(415, 'Only JPEG, PNG or WebP images are allowed');
      }
      const declared = Number(request.headers.get('Content-Length') || '0');
      if (declared > MAX_BYTES) throw new HttpError(413, 'Image must be under 8 MB');

      const body = await request.arrayBuffer();
      if (body.byteLength === 0) throw new HttpError(400, 'Empty upload');
      if (body.byteLength >= MAX_BYTES) throw new HttpError(413, 'Image must be under 8 MB');

      await env.PHOTOS.put(key, body, {
        httpMetadata: { contentType },
        customMetadata: { ownerUid },
      });
      return json({ url: `${url.origin}/photos/${ownerUid}/${fileName}` }, 201);
    }

    case 'GET': {
      if (!isOwner && !(await isStaff(claims.sub, token, env.FIREBASE_PROJECT_ID))) {
        throw new HttpError(403, 'Not allowed to view this photo');
      }
      const object = await env.PHOTOS.get(key);
      if (!object) throw new HttpError(404, 'Photo not found');
      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set('ETag', object.httpEtag);
      headers.set('Cache-Control', 'private, max-age=3600');
      return new Response(object.body, { headers });
    }

    case 'DELETE': {
      if (!isOwner && !(await isStaff(claims.sub, token, env.FIREBASE_PROJECT_ID))) {
        throw new HttpError(403, 'Not allowed to delete this photo');
      }
      await env.PHOTOS.delete(key);
      return new Response(null, { status: 204 });
    }

    default:
      throw new HttpError(405, 'Method not allowed');
  }
}

// Staff role lives in Firestore users/{uid}. The Firestore rules let a user
// read their own profile, so the caller's own ID token is enough here.
async function isStaff(uid, token, projectId) {
  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}`,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  if (!response.ok) return false;
  const doc = await response.json();
  return doc?.fields?.role?.stringValue === 'staff';
}

function bearerToken(request) {
  const header = request.headers.get('Authorization') || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) throw new HttpError(401, 'Missing sign-in token');
  return match[1].trim();
}

// Verifies a Firebase Auth ID token (RS256) using Google's public keys,
// following https://firebase.google.com/docs/auth/admin/verify-id-tokens
async function verifyFirebaseToken(token, projectId) {
  const parts = token.split('.');
  if (parts.length !== 3) throw new HttpError(401, 'Malformed token');

  let header;
  let claims;
  try {
    header = JSON.parse(decodeText(parts[0]));
    claims = JSON.parse(decodeText(parts[1]));
  } catch {
    throw new HttpError(401, 'Malformed token');
  }
  if (header.alg !== 'RS256' || !header.kid) throw new HttpError(401, 'Invalid token');

  const jwk = (await getJwks()).find((k) => k.kid === header.kid);
  if (!jwk) throw new HttpError(401, 'Unknown signing key');

  const key = await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );
  const valid = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    base64UrlToBytes(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  );
  if (!valid) throw new HttpError(401, 'Invalid token signature');

  const now = Math.floor(Date.now() / 1000);
  const skew = 60;
  if (
    claims.aud !== projectId ||
    claims.iss !== `https://securetoken.google.com/${projectId}` ||
    typeof claims.sub !== 'string' ||
    claims.sub.length === 0 ||
    !(claims.exp > now - skew) ||
    !(claims.iat <= now + skew) ||
    !(claims.auth_time <= now + skew)
  ) {
    throw new HttpError(401, 'Token expired or not for this project');
  }
  return claims;
}

async function getJwks() {
  if (jwksCache.keys && Date.now() < jwksCache.expiresAt) return jwksCache.keys;
  const response = await fetch(JWKS_URL);
  if (!response.ok) throw new Error(`Could not fetch Firebase keys: ${response.status}`);
  const { keys } = await response.json();
  const maxAge = Number(
    (response.headers.get('Cache-Control') || '').match(/max-age=(\d+)/)?.[1] || 3600,
  );
  jwksCache = { keys, expiresAt: Date.now() + maxAge * 1000 };
  return keys;
}

function base64UrlToBytes(input) {
  const base64 = input.replace(/-/g, '+').replace(/_/g, '/');
  const padded = base64 + '='.repeat((4 - (base64.length % 4)) % 4);
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

function decodeText(input) {
  return new TextDecoder().decode(base64UrlToBytes(input));
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}
