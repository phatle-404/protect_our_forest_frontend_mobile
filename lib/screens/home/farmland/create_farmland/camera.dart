import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:protect_our_forest/models/user.dart';
import 'package:protect_our_forest/screens/home/home.dart';
import 'package:protect_our_forest/services/user_service.dart';
import 'camera_result.dart';
import 'package:protect_our_forest/services/camera_service.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  FlashMode _flashMode = FlashMode.auto;

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  // Cấu hình LocationSettings với tần suất cập nhật thấp hơn
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50, // Tăng khoảng cách để giảm tần suất cập nhật (mét)
  );

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startPositionUpdates(); // Lắng nghe vị trí theo thời gian thực
  }

  Future<void> _requestPermissions() async {
    // Yêu cầu quyền máy ảnh trước
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted) {
      _showPermissionDialog('Quyền máy ảnh', Permission.camera);
      return;
    }

    // Yêu cầu quyền vị trí sau
    final locationStatus = await Permission.location.request();
    if (locationStatus != PermissionStatus.granted) {
      _showPermissionDialog('Quyền vị trí', Permission.location);
      return;
    }

    await _setupCamera();
    await _getCurrentPosition();
  }

  void _showPermissionDialog(String title, Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Vui lòng cấp quyền để sử dụng tính năng này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Cài đặt'),
          ),
        ],
      ),
    );
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final behindCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        behindCamera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Lỗi setup camera: $e');
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      debugPrint('❌ Lỗi lấy vị trí: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy vị trí hiện tại.')),
        );
      }
    }
  }

  void _startPositionUpdates() {
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .handleError((error) {
              debugPrint('❌ Lỗi stream vị trí: $error');
            })
            .listen((Position position) {
              if (mounted) {
                setState(() {
                  _currentPosition = position;
                  debugPrint(
                    'Vị trí cập nhật: ${position.latitude}, ${position.longitude}',
                  );
                });
              }
            });
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Hủy stream khi dispose
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture || !_isCameraInitialized || _controller == null)
      return;

    setState(() => _isTakingPicture = true);

    try {
      // Chụp ảnh
      final image = await _controller!.takePicture();

      // Lấy vị trí mới nhất từ stream hoặc cập nhật trực tiếp
      final position =
          _currentPosition ??
          await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
            timeLimit: const Duration(seconds: 5),
          );

      debugPrint(
        'Vị trí khi chụp: ${position.latitude}, ${position.longitude}',
      );

      // Đảm bảo buffer được giải phóng trước khi tiếp tục
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Delay ngắn để giải phóng buffer

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraResultScreen(
            imageFile: image,
            latitude: position.latitude,
            longitude: position.longitude,
            onFinish: () {
              _controller?.dispose();
              _controller = null;
              if (mounted) setState(() {});
            },
          ),
        ),
      ).then((_) {
        // Khởi tạo lại camera khi quay lại
        if (mounted) _setupCamera();
      });
    } catch (e) {
      debugPrint('❌ Lỗi chụp ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chụp ảnh: $e')));
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    setState(() {
      _flashMode = _flashMode == FlashMode.auto
          ? FlashMode.off
          : _flashMode == FlashMode.off
          ? FlashMode.always
          : FlashMode.auto;
    });

    await _controller!.setFlashMode(_flashMode);
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.auto:
      default:
        return Icons.flash_auto;
    }
  }

  Future<User> _getUserData() async {
    return await UserDataService.loadUserData();
  }

  Future<void> _showExitConfirmation() async {
    final cameraDataService = CameraDataService();
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thoát'),
        content: const Text(
          'Bạn có chắc chắn thoát không? Dữ liệu các ảnh chụp sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Hủy
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              cameraDataService.clear(); // Xóa dữ liệu
              _controller?.dispose();
              _controller = null;

              User user = await _getUserData(); // lấy dữ liệu user

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
              );
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Ngăn chặn pop mặc định
      onPopInvoked: (didPop) async {
        if (didPop) return; // Nếu đã pop, không làm gì thêm
        final cameraDataService = CameraDataService();
        final photoCount = cameraDataService.photoData.length;

        if (photoCount == 0) {
          // Nếu không có dữ liệu, thoát trực tiếp
          _controller?.dispose();
          _controller = null;
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          // Nếu có dữ liệu, hiển thị popup xác nhận
          await _showExitConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller == null || !_isCameraInitialized
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SizedBox.expand(child: CameraPreview(_controller!)),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        final cameraDataService = CameraDataService();
                        final photoCount = cameraDataService.photoData.length;
                        if (photoCount == 0) {
                          _controller?.dispose();
                          _controller = null;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        } else {
                          _showExitConfirmation();
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        _getFlashIcon(),
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _isTakingPicture ? null : _takePicture,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isTakingPicture)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
      ),
    );
  }
}
