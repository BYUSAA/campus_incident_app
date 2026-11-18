import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../core/constants/photo_storage.dart';
import '../core/errors/app_exceptions.dart';

/// Uploads, and deletes incident photos through the Cloudflare photo Worker
/// (`cloudflare/photo-worker.js`), which stores them in R2. Every request
/// carries the signed-in user's Firebase ID token; the Worker enforces the
/// same owner/staff rules the Firebase Storage rules used to.
class StorageService {
  StorageService({http.Client? client, FirebaseAuth? auth})
    : _client = client ?? http.Client(),
      _auth = auth ?? FirebaseAuth.instance;

  final http.Client _client;
  final FirebaseAuth _auth;

  static const _timeout = Duration(seconds: 60);

  /// Headers needed to display a photo with `Image.network`. Returns no
  /// headers for URLs that are not served by the photo Worker.
  static Future<Map<String, String>> photoHeaders(
    String url, {
    FirebaseAuth? auth,
  }) async {
    if (!PhotoStorage.isWorkerUrl(url)) return const {};
    final token = await (auth ?? FirebaseAuth.instance).currentUser
        ?.getIdToken();
    return token == null ? const {} : {'Authorization': 'Bearer $token'};
  }

  Future<String> uploadIncidentPhoto({
    required File file,
    required String uid,
  }) async {
    try {
      final fileSize = await file.length();
      if (fileSize == 0 || fileSize >= PhotoStorage.maxBytes) {
        throw StorageException('Choose an image smaller than 8 MB.');
      }

      final extension = file.path.split('.').last.toLowerCase();
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!allowedExtensions.contains(extension)) {
        throw StorageException(
          'Use a JPG, PNG, or WEBP image. HEIC and other formats are not supported.',
        );
      }

      final contentType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
      final uri = Uri.parse('${PhotoStorage.apiBaseUrl}/photos/$uid/$fileName');
      final bytes = await file.readAsBytes();

      final response = await _sendWithAuth(
        (headers) => _client.put(
          uri,
          headers: {...headers, 'Content-Type': contentType},
          body: bytes,
        ),
      );
      if (response.statusCode != 201) {
        throw StorageException(
          'The photo could not be uploaded: ${_errorMessage(response)}',
        );
      }

      final url = (jsonDecode(response.body) as Map<String, dynamic>)['url'];
      if (url is! String || !PhotoStorage.isWorkerUrl(url)) {
        throw StorageException(
          'The photo service returned an invalid response.',
        );
      }
      return url;
    } on StorageException {
      rethrow;
    } on TimeoutException {
      throw StorageException(
        'Uploading the photo timed out. Check your internet connection and try again.',
      );
    } on SocketException {
      throw StorageException(
        'Could not reach the photo service. Check your internet connection.',
      );
    } catch (error) {
      throw StorageException('Could not upload the incident photo: $error');
    }
  }

  Future<void> deletePhotoByUrl(String url) async {
    // Photos uploaded before the move to Cloudflare are not managed here.
    if (!PhotoStorage.isWorkerUrl(url)) return;

    final response = await _sendWithAuth(
      (headers) => _client.delete(Uri.parse(url), headers: headers),
    );
    if (response.statusCode != 204 && response.statusCode != 404) {
      throw StorageException(
        'The photo could not be deleted: ${_errorMessage(response)}',
      );
    }
  }

  /// Sends a request with the current ID token. If the Worker rejects it as
  /// unauthenticated/unauthorised, retries once with a freshly minted token —
  /// e.g. a cached token issued before the user verified their email.
  Future<http.Response> _sendWithAuth(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StorageException('Sign in again before managing photos.');
    }

    var response = await send(
      _bearer(await user.getIdToken()),
    ).timeout(_timeout);
    if (response.statusCode == 401 || response.statusCode == 403) {
      response = await send(
        _bearer(await user.getIdToken(true)),
      ).timeout(_timeout);
    }
    return response;
  }

  static Map<String, String> _bearer(String? token) {
    if (token == null) {
      throw StorageException('Sign in again before managing photos.');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] is String) {
        return body['error'] as String;
      }
    } catch (_) {
      // Fall through to the status code.
    }
    return 'HTTP ${response.statusCode}';
  }
}
