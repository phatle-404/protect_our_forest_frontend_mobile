import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'image_map.dart'; // Thêm import

class ImageResultScreen extends StatelessWidget {
  final String imagePath;
  final double latitude;
  final double longitude;
  final String time;

  const ImageResultScreen({
    super.key,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffFFF8E1),
        title: const Text(
          'Kết quả ảnh chụp',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ForestBackground(
        child: Column(
          children: [
            // Hiển thị ảnh
            Expanded(child: Image.file(File(imagePath), fit: BoxFit.cover)),
            // Thông tin ảnh
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Vị trí: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Chữ "Vĩ độ" đậm
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E', // Thay "nội dung" bằng giá trị thực tế
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .w500, // Chữ "nội dung" nhạt (light)
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Thời gian: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Chữ "Vĩ độ" đậm
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  time, // Thay "nội dung" bằng giá trị thực tế
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .w500, // Chữ "nội dung" nhạt (light)
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Nút "Xem trên bản đồ" nằm dưới phần text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xff1b3b3a), // Nền màu #1b3b3a
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton.icon(
                  icon: const Icon(LucideIcons.map, color: Colors.white, size: 30.0),
                  label: const Text(
                    'Xem trên bản đồ',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageMapScreen(
                          latitude: latitude,
                          longitude: longitude,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}