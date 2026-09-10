import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../../core/constants/api_constants.dart';

/// Fetches the hero video config from the backend and plays the video URL
/// if one has been uploaded by the admin. Falls back to the local asset
/// (funfillers_animation.MP4) if no remote video is configured or enabled.
class VideoBackgroundHeader extends StatefulWidget {
  final Widget child;

  const VideoBackgroundHeader({
    super.key,
    required this.child,
  });

  @override
  State<VideoBackgroundHeader> createState() => _VideoBackgroundHeaderState();
}

class _VideoBackgroundHeaderState extends State<VideoBackgroundHeader> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    String? remoteUrl;
    bool isEnabled = true;

    // ── 1. Try to fetch the active hero video config from the backend ────────
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/ui/hero-video'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        isEnabled = data['isEnabled'] as bool? ?? true;
        final url = data['videoUrl']?.toString() ?? '';
        if (url.isNotEmpty) {
          remoteUrl = url;
        }
      }
    } catch (_) {
      // Network unavailable — fall back silently to local asset
    }

    if (!mounted) return;

    // ── 2. If video is disabled by admin, show static gradient, no player ────
    if (!isEnabled) return;

    // ── 3. Pick source: remote URL (uploaded video) OR local bundled asset ───
    final VideoPlayerController controller;
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      // Sanitize localhost URLs to the actual configured server URL
      final sanitized = remoteUrl
          .replaceAll('http://localhost:5050', ApiConstants.serverUrl)
          .replaceAll('http://127.0.0.1:5050', ApiConstants.serverUrl);
      controller = VideoPlayerController.networkUrl(Uri.parse(sanitized));
    } else {
      controller = VideoPlayerController.asset(
        'assets/animation/funfillers_animation.MP4',
      );
    }

    _controller = controller
      ..setLooping(true)
      ..setVolume(0.0);

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        _controller!.play();
      }
    } catch (error) {
      debugPrint('VideoBackgroundHeader init error: $error');
      // If the remote video fails to load, fall back to local asset
      if (remoteUrl != null && mounted) {
        _controller?.dispose();
        _controller = VideoPlayerController.asset(
          'assets/animation/funfillers_animation.MP4',
        )
          ..setLooping(true)
          ..setVolume(0.0);
        try {
          await _controller!.initialize();
          if (mounted) {
            setState(() => _isInitialized = true);
            _controller!.play();
          }
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background Video / Gradient Fallback ──────────────────────────
          Positioned.fill(
            child: ClipRect(
              child: RepaintBoundary(
                child: _isInitialized && _controller != null
                    ? FittedBox(
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: _controller!.value.size.width > 0
                              ? _controller!.value.size.width
                              : 16.0,
                          height: _controller!.value.size.height > 0
                              ? _controller!.value.size.height
                              : 9.0,
                          child: VideoPlayer(_controller!),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE2E8F0), Color(0xFFFFFFFF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // ── Bottom fade gradient — blends 100% seamlessly into page body ───────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x80FFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.40, 0.68, 0.88, 1.0],
                ),
              ),
            ),
          ),

          // ── Solid white bottom cover to eliminate HTML video / GPU subpixel seam ──
          Positioned(
            left: -10,
            right: -10,
            bottom: -5,
            height: 20,
            child: Container(
              color: Colors.white,
            ),
          ),

          // ── Child Content (Greeting, Location, Search) ────────────────────
          widget.child,
        ],
      ),
    );
  }
}
