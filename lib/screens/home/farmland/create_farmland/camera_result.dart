import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/screens/home/farmland/create_farmland/camera.dart';
import 'package:protect_our_forest/screens/home/farmland/create_farmland/farmland_result.dart';
import 'package:protect_our_forest/services/camera_service.dart';

class CameraResultScreen extends StatelessWidget {
  final XFile imageFile;
  final double latitude;
  final double longitude;
  final VoidCallback onFinish;

  const CameraResultScreen({
    super.key,
    required this.imageFile,
    required this.latitude,
    required this.longitude,
    required this.onFinish,
  });

  Future<void> _showFinishConfirmation(BuildContext context) async {
    final cameraDataService = CameraDataService();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận kết thúc'),

        content: const Text(
          'Bạn có chắc chắn kết thúc quá trình chụp ảnh không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Hủy
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              cameraDataService.addPhoto(
                imageFile,
                latitude,
                longitude,
                DateTime.now(),
              ); // Thêm ảnh
              onFinish(); // Dispose camera
              Navigator.pop(context, true); // Đồng ý
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FarmlandResultScreen(photoData: cameraDataService.photoData),
        ),
      );
    }
  }

  Future<void> _showInsufficientPhotosDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Bạn chưa chụp đủ 3 ảnh để tạo 1 vùng canh tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Đóng popup
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraDataService = CameraDataService();

    return PopScope(
      canPop: false, // Ngăn chặn hành vi back mặc định
      onPopInvoked: (didPop) async {
        if (didPop) return; // Nếu đã pop, không làm gì thêm
        // Quay lại CameraScreen khi nhấn back mà không xóa dữ liệu
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Kết quả ảnh chụp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Quay lại CameraScreen mà không xóa dữ liệu trước đó
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraScreen()),
                );
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Image.file(
                File(imageFile.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Tọa độ thu được:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Kinh độ: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Chữ "Vĩ độ" đậm
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${longitude.toStringAsFixed(4)}° E', // Thay "nội dung" bằng giá trị thực tế
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w500, // Chữ "nội dung" nhạt (light)
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Vĩ độ: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Chữ "Vĩ độ" đậm
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${latitude.toStringAsFixed(4)}° N', // Thay "nội dung" bằng giá trị thực tế
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w500, // Chữ "nội dung" nhạt (light)
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(LucideIcons.camera400, size: 24),
                      label: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      onPressed: () {
                        // Lưu hình và tọa độ vào danh sách tạm thời
                        cameraDataService.addPhoto(
                          imageFile,
                          latitude,
                          longitude,
                          DateTime.now(),
                        );
                        // Quay lại CameraScreen để chụp tiếp
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CameraScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade200,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(LucideIcons.circleX400, size: 24),
                      label: const Text('Kết thúc',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      onPressed: () {
                        // Tính số lượng ảnh hiện tại + 1 (ảnh mới)
                        final currentPhotoCount =
                            cameraDataService.photoData.length + 1;

                        if (currentPhotoCount < 3) {
                          _showInsufficientPhotosDialog(context);
                        } else {
                          _showFinishConfirmation(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
