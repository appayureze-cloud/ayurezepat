import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme.dart';
import '../../documents/domain/entities/remote_document.dart';

/// Matches the Stitch "Document Viewer" screen
/// (ayureze_document_viewer/code.html): a minimal top bar, pinch-zoom
/// image view, and a bottom Share/Download action.
///
/// The download endpoint (`/api/v1/documents/download/{id}`) carries no
/// file-extension hint, and this app has no PDF renderer dependency, so
/// this tries to render the document as an image (the common case for
/// scanned lab reports) and falls back to "open externally" - which also
/// covers real PDFs - rather than guessing the content type.
class DocumentViewerScreen extends StatelessWidget {
  final RemoteDocument document;

  const DocumentViewerScreen({required this.document, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(document.title),
      ),
      body: Stack(
        children: [
          Center(
            child: PhotoView.customChild(
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              child: CachedNetworkImage(
                imageUrl: document.downloadUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SpinnerPlaceholder(),
                errorWidget: (context, url, error) => _OpenExternallyFallback(
                  downloadUrl: document.downloadUrl,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: Colors.black54,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => launchUrl(
                          Uri.parse(document.downloadUrl),
                          mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text('Download',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpinnerPlaceholder extends StatelessWidget {
  const SpinnerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.sagePrimary),
    );
  }
}

class _OpenExternallyFallback extends StatelessWidget {
  final String downloadUrl;

  const _OpenExternallyFallback({required this.downloadUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 56, color: Colors.white54),
          const SizedBox(height: 14),
          const Text("Can't preview this file here",
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            onPressed: () => launchUrl(Uri.parse(downloadUrl),
                mode: LaunchMode.externalApplication),
            child: const Text('Open externally'),
          ),
        ],
      ),
    );
  }
}
