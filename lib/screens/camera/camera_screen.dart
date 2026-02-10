// external
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/models/value_objects.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'sections/camera_preview_section.dart';
import 'sections/bottom_buttons_section.dart';
import 'services/camera_shoot_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initFuture;
  LastCapturedInfo _lastCapturedInfo = const LastCapturedInfo.empty();
  late AnimationController _flashAnimationController;
  late Animation<double> _flashAnimation;
  Size? _previewDisplaySize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadLastCapturedImage();

    // 플래시 애니메이션 컨트롤러 초기화
    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flashAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // 앱 시작 시 가장 최근 아이템의 이미지 로드
  Future<void> _loadLastCapturedImage() async {
    final items = ref.read(itemRepositoryProvider).getAll();
    if (items.isEmpty) return;

    // 가장 최근에 등록된 아이템 찾기
    final latestItem = items.reduce(
      (a, b) => a.registeredAt.isAfter(b.registeredAt) ? a : b,
    );

    // 이미지가 있으면 설정
    if (latestItem.images.isNotEmpty && mounted) {
      setState(() {
        _lastCapturedInfo = LastCapturedInfo(
          imagePath: latestItem.images.first,
          itemId: latestItem.id,
        );
      });
    }
  }

  // 카메라 초기화 메서드
  void _initializeCamera() {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false, // 사진만 찍을 거면 false 권장
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initFuture = _controller
        .initialize()
        .then((_) {
          // 플래시 자동 켜짐 방지 - 항상 off로 설정
          if (mounted) {
            _controller.setFlashMode(FlashMode.off);
            setState(() {}); // UI 업데이트
          }
        })
        .catchError((error) {
          debugPrint('카메라 초기화 실패: $error');
          // 에러를 다시 throw하여 FutureBuilder가 감지할 수 있도록 함
          throw error;
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 앱 라이프사이클에 따라 프리뷰 정지/재개
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 가거나 비활성화될 때
      if (_controller.value.isInitialized) {
        _controller.pausePreview();
      }
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때
      _onResumed();
    }
  }

  // 앱이 다시 활성화될 때 카메라 복구
  Future<void> _onResumed() async {
    if (!mounted) return;

    // 카메라 상태 확인
    final isInitialized = _controller.value.isInitialized;
    final isStreamingImages = _controller.value.isStreamingImages;

    debugPrint('카메라 상태 - 초기화: $isInitialized, 스트리밍: $isStreamingImages');

    // 카메라가 정상 작동 중인 경우
    if (isInitialized && isStreamingImages) {
      try {
        await _controller.resumePreview();
        debugPrint('카메라 재개 성공');
        return;
      } catch (e) {
        debugPrint('카메라 재개 실패: $e');
      }
    }

    // 카메라를 완전히 재초기화
    debugPrint('카메라 재초기화 시작');
    try {
      await _controller.dispose();
    } catch (e) {
      debugPrint('카메라 dispose 중 에러 (무시): $e');
    }

    if (mounted) {
      setState(() {
        _initializeCamera();
      });
    }
  }

  // 촬영 기능
  Future<void> _shoot() async {
    // 플래시 효과 시작
    _flashAnimationController.forward().then((_) {
      _flashAnimationController.reverse();
    });

    await _initFuture; // 초기화 완료 대기
    // 사진 촬영
    final file = await _controller.takePicture();
    if (!mounted) return;

    // 촬영된 이미지 처리
    final repository = ref.read(itemRepositoryProvider);
    final result = await CameraShootService(
      repository,
    ).processCapture(file.path);

    if (!mounted) return;
    // 마지막 촬영 이미지 정보 즉시 업데이트 (UI에 바로 반영)
    setState(() {
      _lastCapturedInfo = LastCapturedInfo(
        imagePath: result.imagePath,
        itemId: result.itemId,
      );
    });
  }

  Future<void> _pickFromGallery() async {
    // 마지막 촬영한 항목이 있으면 해당 항목으로, 없으면 최근 항목으로 이동
    final items = ref.read(itemRepositoryProvider).getAll();
    if (!mounted) return;
    if (items.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          content: const Text('등록된 아이템이 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    ExpiryItem? targetItem;
    if (_lastCapturedInfo.itemId != null) {
      targetItem = items.firstWhere(
        (item) => item.id == _lastCapturedInfo.itemId,
        orElse: () => items.reduce(
          (a, b) => a.registeredAt.isAfter(b.registeredAt) ? a : b,
        ),
      );
    } else {
      targetItem = items.reduce(
        (a, b) => a.registeredAt.isAfter(b.registeredAt) ? a : b,
      );
    }

    Navigator.of(context).pushNamed('/detail', arguments: targetItem);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTap: () {
          SystemNavigator.pop();
        },
        child: Scaffold(
          // 상단바, 하단바 영역 제외
          body: SafeArea(
            top: true,
            bottom: true,
            child: Stack(
              children: [
                Column(
                  children: [
                    CameraPreviewSection(
                      controller: _controller,
                      initFuture: _initFuture,
                      onPreviewSizeCalculated: (size) {
                        _previewDisplaySize = size;
                      },
                    ),
                    BottomButtonsSection(
                      onShoot: _shoot,
                      onPickFromGallery: _pickFromGallery,
                      onNavigateToList: () =>
                          Navigator.of(context).pushNamed('/list'),
                      lastCapturedImagePath: _lastCapturedInfo.imagePath,
                    ),
                  ],
                ),
                // 촬영 플래시 효과 오버레이
                AnimatedBuilder(
                  animation: _flashAnimation,
                  builder: (context, child) {
                    return IgnorePointer(
                      child: Container(
                        color: Colors.white.withValues(
                          alpha: _flashAnimation.value,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'settings_button',
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            tooltip: '설정',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.settings),
          ),
        ),
      ),
    );
  }
}
