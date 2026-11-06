# Image assets

Store only project-owned or appropriately licensed static image resources used by the interface in this folder.

Typical resources may include a logo, onboarding illustration, or empty-state graphic. User-submitted incident evidence is not bundled here; it is uploaded to Firebase Storage at runtime.

Declare each used asset in the root `pubspec.yaml` before referencing it with `Image.asset`. Do not add temporary screenshots, user incident photos, or unlicensed stock images.
