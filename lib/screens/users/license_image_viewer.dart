import 'package:flutter/material.dart';

class LicenseImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;

  const LicenseImageViewer({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  State<LicenseImageViewer> createState() => _LicenseImageViewerState();
}

class _LicenseImageViewerState extends State<LicenseImageViewer> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Full screen image viewer
          Container(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading license image...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your internet connection',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Header with title and close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset zoom button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _transformationController.value = Matrix4.identity();
                      },
                      icon: const Icon(
                        Icons.zoom_out_map,
                        color: Colors.white,
                      ),
                      tooltip: 'Reset Zoom',
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Zoom in button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () {
                        final Matrix4 matrix = _transformationController.value.clone();
                        matrix.scale(1.2);
                        _transformationController.value = matrix;
                      },
                      icon: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                      ),
                      tooltip: 'Zoom In',
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Zoom out button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () {
                        final Matrix4 matrix = _transformationController.value.clone();
                        matrix.scale(0.8);
                        _transformationController.value = matrix;
                      },
                      icon: const Icon(
                        Icons.zoom_out,
                        color: Colors.white,
                      ),
                      tooltip: 'Zoom Out',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions overlay (shows briefly)
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Pinch to zoom • Double tap to zoom • Drag to pan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
