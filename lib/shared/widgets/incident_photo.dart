import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

/// Displays an incident evidence photo. Photos served by the Cloudflare photo
/// Worker are private, so the signed-in user's Firebase ID token is attached.
class IncidentPhoto extends StatefulWidget {
  const IncidentPhoto({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageErrorWidgetBuilder errorBuilder;

  @override
  State<IncidentPhoto> createState() => _IncidentPhotoState();
}

class _IncidentPhotoState extends State<IncidentPhoto> {
  late Future<Map<String, String>> _headers;

  @override
  void initState() {
    super.initState();
    _headers = StorageService.photoHeaders(widget.url);
  }

  @override
  void didUpdateWidget(IncidentPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _headers = StorageService.photoHeaders(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _headers,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder(
            context,
            snapshot.error!,
            snapshot.stackTrace,
          );
        }
        if (!snapshot.hasData) {
          return SizedBox(width: widget.width, height: widget.height);
        }
        return Image.network(
          widget.url,
          headers: snapshot.data,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: widget.errorBuilder,
        );
      },
    );
  }
}
