import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewSection extends StatefulWidget {
  const CameraPreviewSection({
    super.key,
    required this.controller,
    required this.initFuture,
    this.onPreviewSizeCalculated,
  });

  final CameraController controller;
  final Future<void> initFuture;
  final void Function(Size displaySize)? onPreviewSizeCalculated;

  @override
  State<CameraPreviewSection> createState() => _CameraPreviewSectionState();
}

class _CameraPreviewSectionState extends State<CameraPreviewSection>
    with SingleTickerProviderStateMixin {
  Offset? _focusPoint;
  late AnimationController _focusAnimationController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _focusAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    super.dispose();
  }

  Future<void> _onTapFocus(TapDownDetails details, BoxConstraints constraints) async {
    if (!widget.controller.value.isInitialized) return;

    final offset = details.localPosition;
    
    // 화면 좌표를 카메라 좌표로 변환 (0.0 ~ 1.0 범위)
    final x = offset.dx / constraints.maxWidth;
    final y = offset.dy / constraints.maxHeight;

    // 포커스 포인트 설정
    setState(() {
      _focusPoint = offset;
    });

    // 포커스 애니메이션 실행
    _focusAnimationController.forward().then((_) {
      _focusAnimationController.reverse();
    });

    try {
      // 카메라 포커스 설정
      await widget.controller.setFocusPoint(Offset(x, y));
      await widget.controller.setExposurePoint(Offset(x, y));
      
      // 2초 후 포커스 인디케이터 제거
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _focusPoint = null;
          });
        }
      });
    } catch (e) {
      debugPrint('포커스 설정 실패: $e');
      // 에러 발생 시 포커스 인디케이터 즉시 제거
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Container(
        color: Colors.black,
        child: FutureBuilder<void>(
          future: widget.initFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget(context, snapshot.error!);
            }

            if (snapshot.connectionState == ConnectionState.done) {
              if (!widget.controller.value.isInitialized) {
                return _buildCameraNotAvailableWidget();
              }
              return _buildCameraPreview(context);
            }

            return _buildLoadingWidget();
          },
        ),
      ),
    );
  }

  /// 에러 발생 시 위젯
  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '카메라 초기화 실패',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 카메라 사용 불가 시 위젯
  Widget _buildCameraNotAvailableWidget() {
    return const Center(
      child: Text(
        '카메라를 사용할 수 없습니다',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// 로딩 중 위젯
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('카메라 초기화 중...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  /// 카메라 프리뷰 위젯
  Widget _buildCameraPreview(BuildContext context) {
    final previewSize = widget.controller.value.previewSize!;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // 카메라 프리뷰의 "현재 방향 기준" 가로/세로 비율 (width / height)
    final camAspect = isPortrait
        ? (previewSize.height / previewSize.width) // portrait 보정
        : (previewSize.width / previewSize.height);

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentAspect = constraints.maxWidth / constraints.maxHeight;

        // 부모 영역을 완전히 덮도록 하는 스케일 계산
        double scale = camAspect / parentAspect;
        if (scale < 1) scale = 1 / scale;

        // 프리뷰 영역의 실제 표시 크기를 콜백으로 전달
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPreviewSizeCalculated?.call(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
        });

        return GestureDetector(
          onTapDown: (details) => _onTapFocus(details, constraints),
          child: Stack(
            children: [
              _buildScaledCameraPreview(scale, camAspect),
              if (_focusPoint != null) _buildFocusIndicator(),
            ],
          ),
        );
      },
    );
  }

  /// 스케일 조정된 카메라 프리뷰
  Widget _buildScaledCameraPreview(double scale, double camAspect) {
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: AspectRatio(
            aspectRatio: camAspect,
            child: CameraPreview(widget.controller),
          ),
        ),
      ),
    );
  }

  /// 포커스 인디케이터
  Widget _buildFocusIndicator() {
    return Positioned(
      left: _focusPoint!.dx - 40,
      top: _focusPoint!.dy - 40,
      child: AnimatedBuilder(
        animation: _focusAnimation,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.yellow.withValues(
                  alpha: _focusAnimation.value,
                ),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
          );
        },
      ),
    );
  }
}
