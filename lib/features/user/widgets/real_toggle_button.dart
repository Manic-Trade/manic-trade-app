import 'package:finality/core/logger.dart';
import 'package:finality/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RealToggleButton extends StatefulWidget {
  const RealToggleButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<RealToggleButton> createState() => _RealToggleButtonState();
}

class _RealToggleButtonState extends State<RealToggleButton>
    with WidgetsBindingObserver {
  late final VideoPlayerController _videoController;
  final ValueNotifier<bool> _ready = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoController = VideoPlayerController.asset(Assets.videoRealToggleBg);
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      await _videoController.play();
      if (mounted) _ready.value = true;
    } catch (e, st) {
      logger.e('RealToggleButton: video init failed', error: e, stackTrace: st);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 应用回到前台时恢复播放
    if (state == AppLifecycleState.resumed &&
        _ready.value &&
        !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  @override
  void didUpdateWidget(covariant RealToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 父页面被复用 / rebuild 时确保视频继续播放
    if (_ready.value && !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 从其他页面 pop 回来时确保视频继续播放
    if (_ready.value && !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ready.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 86,
        height: 36,
        decoration: widget.isSelected
            ? BoxDecoration(
                // primary-yellow: #db8300
                color: const Color(0xFFDB8300),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFFDB8300), width: 0.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              )
            : const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 视频层：选中时 24% 不透明度，模拟 web mix-blend-mode: plus-lighter
              ValueListenableBuilder<bool>(
                valueListenable: _ready,
                builder: (context, ready, _) {
                  if (!ready) return const SizedBox.shrink();
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: widget.isSelected ? 0.24 : 0,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: Text(
                  'Real',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isSelected
                        ? Colors.black
                        : const Color(0xFF454545),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
