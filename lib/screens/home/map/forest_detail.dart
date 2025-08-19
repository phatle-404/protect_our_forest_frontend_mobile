import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:protect_our_forest/models/forest.dart';

class ForestDetailScreen extends StatefulWidget {
  final Forest forestModel;

  const ForestDetailScreen({super.key, required this.forestModel});

  @override
  ForestDetailScreenState createState() => ForestDetailScreenState();
}

class ForestDetailScreenState extends State<ForestDetailScreen> {
  // List<Map<String, dynamic>> imageData = [
  //   {
  //     'lat': '21.0278° N',
  //     'lng': '105.8342° E',
  //     'time': '13:00 12/1/2025',
  //     'image': 'assets/image_location/forest_result.png',
  //   },
  //   // ... (các mục khác)
  // ];

  @override
  Widget build(BuildContext context) {
    final Forest forestModel = widget.forestModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đất rừng',
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
      ),
      backgroundColor: homeBackgroundColor,
      body: ForestBackground(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              child: Column(
                children: [
                  _locationDetailInfo(
                    icon: LucideIcons.trees400,
                    iconColor: const Color(0xff3E8381),
                    title: forestModel.forestOriginalName.isNotEmpty
                        ? forestModel.forestOriginalName
                        : 'Chưa có thông tin',
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.landPlot,
                    iconColor: const Color(0xffF50000),
                    title: 'Diện tích được báo cáo',
                    subtitle:
                        '${forestModel.reportedArea.toStringAsFixed(1)} ha', // Giả sử đơn vị ha
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Colors.black,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.building2400,
                    iconColor: const Color(0xff000000),
                    title: 'Cơ quan quản lý',
                    subtitle: forestModel.managementAuthority.isNotEmpty
                        ? forestModel.managementAuthority
                        : 'Chưa có thông tin',
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.alarmClockPlus,
                    iconColor: const Color(0xff00D5FF),
                    title: 'Cập nhật gần nhất',
                    subtitle: forestModel.yearLastUpdated.toString(),
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.mapPin400,
                    iconColor: const Color.fromARGB(255, 246, 1, 1),
                    title: 'Vị trí',
                    subtitle: '${forestModel.province}, ${forestModel.countries}',
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.squaresIntersect400,
                    iconColor: const Color(0xff047F16),
                    title: 'Diện tích bị xâm lấn',
                    subtitle: 'Chưa có thông tin', // Cần tính toán nếu có dữ liệu
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.circlePercent,
                    iconColor: Colors.green,
                    title: 'Độ che phủ rừng',
                    subtitle: 'Chưa có thông tin', // Cần tính toán nếu có dữ liệu
                  ),
                  const SizedBox(height: 10),
                  _locationDetailInfo(
                    icon: LucideIcons.shieldX,
                    iconColor: Colors.red,
                    title: 'Trạng thái',
                    subtitle: forestModel.designation.isNotEmpty
                        ? forestModel.designation
                        : 'Chưa có thông tin',
                  ),
                ],
              ),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    softWrap: true,
                  ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    softWrap: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}