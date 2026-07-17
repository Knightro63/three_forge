import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaKitVideoPreview extends StatefulWidget {
  final File file;

  const MediaKitVideoPreview({Key? key, required this.file}) : super(key: key);

  @override
  State<MediaKitVideoPreview> createState() => _MediaKitVideoPreviewState();
}

class _MediaKitVideoPreviewState extends State<MediaKitVideoPreview> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    
    // 1. Instantiate the background controller engine
    _player = Player(
      configuration: const PlayerConfiguration(
        muted: true, // Auto-mute preview loops
      ),
    );

    // 2. Link player instance straight to the native rendering controller layer
    _controller = VideoController(_player);

    // 3. Queue up the local system target path pointer and trigger continuous loops
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.open(Media(widget.file.path), play: true);
  }

  @override
  void dispose() {
    // Release the active hardware controller tracking arrays safely
    _player.stop().then((_){
      _player.dispose();
    });
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Video(
        controller: _controller,
        controls: NoVideoControls, // Prevents showing play/pause/scrub overlay elements
        fit: BoxFit.cover,        // Fits cleanly into fixed square frame metrics
      ),
    );
  }
}
