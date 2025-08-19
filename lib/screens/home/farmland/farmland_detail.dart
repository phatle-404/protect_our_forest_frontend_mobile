import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:protect_our_forest/screens/home/farmland/update_farmland/update_farmland.dart';
import 'package:protect_our_forest/models/farmland.dart';
import 'package:protect_our_forest/models/location.dart';
import 'package:protect_our_forest/screens/home/farmland/create_farmland/image_result.dart';
import 'package:protect_our_forest/services/farmland_service.dart';
import 'dart:io';

class FarmlandDetailScreen extends StatefulWidget {
  final Farmland? farmland;
  const FarmlandDetailScreen({super.key, this.farmland});

  @override
  FarmlandDetailScreenState createState() => FarmlandDetailScreenState();
}

class FarmlandDetailScreenState extends State<FarmlandDetailScreen> {
  bool _isLoading = false;

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc muốn xoá vùng canh tác này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteFarmland();
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFarmland() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FarmlandDataService.deleteFarmland(widget.farmland!.farmlandId);
      if (!mounted) return;
      
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatArea(double area) {
    // Hàm phụ để định dạng số với khoảng trắng làm phân cách
    String formatNumber(double number) {
      String numStr = number.round().toString();
      String result = '';
      int count = 0;

      for (int i = numStr.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = ' $result'; // Thêm khoảng trắng làm phân cách
          count = 0;
        }
        result = numStr[i] + result;
        count++;
      }
      return result;
    }

    final hectares = area / 10000;
    return '${formatNumber(area)} m² - ${hectares.toStringAsFixed(2)} ha';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vùng canh tác',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: homeBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(LucideIcons.x400, color: Colors.black, size: 27),
        ),
        actions: [
          PopupMenuButton<int>(
            color: Color(0xff1b3b3a),
            shadowColor: Colors.white,
            icon: const Icon(
              LucideIcons.settings400,
              color: Colors.black,
              size: 27,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            offset: const Offset(0, 45), // Đẩy menu xuống dưới icon
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.wrench,
                      size: 25,
                      color: Colors.white,
                    ), // Hoặc dùng LucideIcons.wrench nếu muốn
                    SizedBox(width: 8),
                    Text(
                      "Cập nhật vùng",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuDivider(
                height: 0.2,
                color: Colors.white,
                thickness: 0.5,
              ), // Mặc định màu không trắng => ta sẽ tuỳ chỉnh nó

              PopupMenuItem(
                value: 2,
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.trash2,
                      size: 25,
                      color: Colors.red,
                    ), // Hoặc
                    SizedBox(width: 8),
                    Text(
                      "Xoá vùng",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                // TODO: Navigate đến trang cập nhật
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdateLocationScreen()),
                );
              } else if (value == 2) {
                // TODO: Hiển thị dialog xác nhận xoá
                _showDeleteConfirmationDialog(context);
              }
            },
          ),
          const SizedBox(width: 10),
        ],

        actionsPadding: EdgeInsets.only(right: 10),
      ),
      backgroundColor: homeBackgroundColor,

      body: ForestBackground(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(50, 10, 50, 0),
                  child: Column(
                    children: [
                      _locationDetailInfo(
                        icon: LucideIcons.mapPinned,
                        iconColor: Color(0xffF50000),
                        title:
                            widget.farmland?.farmlandName ?? 'Vùng chưa có tên',
                      ),

                      const SizedBox(height: 10),

                      _locationDetailInfo(
                        icon: LucideIcons.landPlot,
                        iconColor: Color(0xffF50000),
                        title: 'Tổng diện tích vùng',
                        subtitle: formatArea(widget.farmland?.area ?? 0.0),
                      ),

                      const SizedBox(height: 10),

                      Divider(
                        color: Colors.black, // Màu đường kẻ
                        thickness: 0.5, // Độ dày
                      ),

                      const SizedBox(height: 10),

                      _locationDetailInfo(
                        icon: LucideIcons.clock,
                        iconColor: Color(0xff00D5FF),
                        title: 'Cập nhật gần đây',
                        subtitle:
                            widget.farmland?.startDate?.toIso8601String() ??
                            'Chưa được duyệt',
                      ),

                      const SizedBox(height: 10),

                      _locationDetailInfo(
                        icon: LucideIcons.alarmClockPlus,
                        iconColor: Color(0xffFF8F8F),
                        title: 'Cập nhật tiếp theo',
                        subtitle:
                            widget.farmland?.exprDate?.toIso8601String() ??
                            'Chưa được duyệt',
                      ),

                      const SizedBox(height: 10),

                      Text.rich(
                        style: TextStyle(
                          height: 1.2,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        TextSpan(
                          text: 'Còn ',

                          children: [
                            TextSpan(
                              text: widget.farmland?.countDown.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  ' ngày nữa sẽ thông báo cập nhật lại vùng canh tác này.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      if ((widget.farmland?.intersectionArea ?? 0.0) > 0.0) ...[
                        Divider(
                          color: Colors.black, // Màu đường kẻ
                          thickness: 0.5, // Độ dày
                        ),

                        const SizedBox(height: 10),

                        _locationDetailInfo(
                          icon: LucideIcons.squaresIntersect400,
                          iconColor: Color(0xff047F16),
                          title: 'Diện tích xâm lấn',
                          subtitle: formatArea(
                            widget.farmland?.intersectionArea ?? 0.0,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _locationDetailInfo(
                          icon: LucideIcons.trees400,
                          iconColor: Color(0xff3E8381),
                          title: widget.farmland?.intersectionForest ?? '',
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Vùng canh tác có xâm lấn với đất rừng.',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16, height: 1.2),
                        ),

                        const SizedBox(height: 10),
                      ],

                      Divider(
                        color: Colors.black, // Màu đường kẻ
                        thickness: 0.5, // Độ dày
                      ),

                      const SizedBox(height: 10),

                      _locationDetailInfo(
                        icon: LucideIcons.image,
                        iconColor: Color.fromARGB(255, 11, 180, 206),
                        title: 'Danh sách các ảnh',
                      ),

                      const SizedBox(height: 8),
                      Column(
                        children: (widget.farmland?.locations != null
                            ? widget.farmland!.locations!.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final location = entry.value;
                                return _locationCard(location, index);
                              }).toList()
                            : []),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationDetailInfo({
    required IconData icon,
    required Color iconColor,
    String title = '',
    String subtitle = '',
  }) {
    return SizedBox(
      width: 500,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 34),
          const SizedBox(width: 10), // 👉 Khoảng cách ngang giữa icon và text

          Expanded(
            // 👉 Giúp text chiếm phần còn lại và xuống dòng
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    softWrap: true, // 👉 Cho phép xuống dòng
                  ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    softWrap: true, // 👉 Cho phép xuống dòng
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard(Location location, int index) {
    final formatIndex = index + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: location.imageFile != null
              ? FileImage(File(location.imageFile!.path))
              : AssetImage('assets/image/image_location/forest_result.png')
                    as ImageProvider,
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: ListTile(
        onTap: () {
          if (location.imageFile != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageResultScreen(
                  imagePath: location.imageFile!.path,
                  latitude: location.latitude,
                  longitude: location.longitude,
                  time: location.timeTakeLocation.toIso8601String(),
                ),
              ),
            );
          }
        },
        trailing: const Icon(LucideIcons.eye400, color: Colors.white),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Text(
          "$formatIndex.",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        title: Text(
          // Ví dụ: hiển thị kinh độ/vĩ độ với format 6 số thập phân
          "${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          location.timeTakeLocation.toLocal().toString().split('.')[0],
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
  // Widget _regionCard(String id, String title, String time) {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 10),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16),
  //       image: const DecorationImage(
  //         image: AssetImage('assets/location/land_field.png'),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //     padding: const EdgeInsets.all(12),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           spacing: 10.0,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               id,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Text(time, style: const TextStyle(color: Colors.white)),
  //               ],
  //             ),
  //           ],
  //         ),

  //         const Icon(LucideIcons.mapPin600, color: Colors.white, size: 30),
  //       ],
  //     ),
  //   );
  // }


// class ProfileMenuWidget extends StatelessWidget {
//   const ProfileMenuWidget({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.onPress,
//     this.iconColor = const Color(0xFF386EE4),
//     this.textColor = Colors.black,
//   }) : super(key: key);

//   final String title;
//   final IconData icon;
//   final VoidCallback onPress;
//   final Color iconColor;
//   final Color textColor;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: onPress,
//       contentPadding: const EdgeInsets.symmetric(vertical: 1),
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: iconColor.withAlpha(20),
//           borderRadius: BorderRadius.circular(100),
//         ),
//         child: Icon(icon, color: iconColor, size: 22),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           color: textColor,
//           fontWeight: FontWeight.w600,
//           fontSize: 17,
//         ),
//       ),
//       trailing: Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: Colors.grey.withAlpha(30), // 🎨 Màu nền của icon
//           borderRadius: BorderRadius.circular(100), // 🔵 Bo tròn
//         ),
//         child: const Icon(Icons.chevron_right, size: 20.0, color: Colors.grey),
//       ),
//     );
//   }
// }
