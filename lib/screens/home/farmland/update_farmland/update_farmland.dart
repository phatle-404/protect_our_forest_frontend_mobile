import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/config/colors.dart';

class UpdateLocationScreen extends StatefulWidget {
  const UpdateLocationScreen({super.key});

  @override
  UpdateLocationScreenState createState() => UpdateLocationScreenState();
}

class UpdateLocationScreenState extends State<UpdateLocationScreen> {
  List<Map<String, String>> imageData = [
    {
      'lat': '21.0278° N',
      'lng': '105.8342° E',
      'time': '13:00 12/1/2025',
      'image': 'assets/image_location/forest_result.png',
    },
    {
      'lat': '21.0278° N',
      'lng': '105.8342° E',
      'time': '13:05 12/1/2025',
      'image': 'assets/image_location/forest_result.png',
    },
    {
      'lat': '21.0278° N',
      'lng': '105.8342° E',
      'time': '13:10 12/1/2025',
      'image': 'assets/image_location/forest_result.png',
    },
  ];

  late List<Map<String, String>> originalImageData;
  Set<int> selectedIndexes = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    originalImageData = List.from(imageData);
  }

  void enterSelectionMode(int index) {
    setState(() {
      originalImageData = List.from(imageData); // lưu lại bản sao
      isSelectionMode = true;
      selectedIndexes.add(index);
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void cancelSelection() {
    setState(() {
      imageData = List.from(originalImageData);
      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }

  void deleteSelectedImages() {
    setState(() {
      imageData = imageData
          .asMap()
          .entries
          .where((entry) => !selectedIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();

      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cập nhật vùng canh tác',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: isSelectionMode
          ? BottomAppBar(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              color: const Color(0xFF1B3B3A),
              child: SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Đã chọn ${selectedIndexes.length} ảnh.',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      spacing: 20.0,
                      children: [
                        TextButton(
                          onPressed: cancelSelection,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.x600,
                                size: 35,
                                color: Colors.white,
                              ),
                              Text(
                                "Huỷ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        ),

                        TextButton(
                          onPressed: selectedIndexes.isEmpty
                              ? null
                              : deleteSelectedImages,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.trash2600,
                                size: 35,
                                color: selectedIndexes.isEmpty
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                              Text(
                                "Xoá ảnh",
                                style: TextStyle(
                                  color: selectedIndexes.isEmpty
                                      ? Colors.white54
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14
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
            )
          : BottomAppBar(
              color: const Color(0xFF1B3B3A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Column(
                    children: [
                      Icon(LucideIcons.map, color: Colors.white, size: 35),
                      Text("Kết quả", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(LucideIcons.save, color: Colors.white, size: 35),
                      Text("Lưu", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
      body: ForestBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                "Tên",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập tên',
                  prefixIcon: const Icon(LucideIcons.landPlot, size: 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(LucideIcons.image, size: 31),
                  SizedBox(width: 8),
                  Text(
                    "Danh sách các ảnh",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...imageData.asMap().entries.map((entry) {
                final index = entry.key;
                final displayIndex = index + 1;
                final data = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('assets/image_location/forest_result.png'),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Colors.black38,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: ListTile(
                    onLongPress: () => enterSelectionMode(index),
                    onTap: () {
                      if (isSelectionMode) toggleSelection(index);
                    },
                    trailing: isSelectionMode
                        ? selectedIndexes.contains(index)
                              ? Image.asset('assets/location/circle-check.png', height: 25,)
                              : Icon(LucideIcons.circle, color: Colors.white, size: 25)
                        : const Icon(LucideIcons.mapPin, color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Text(
                      "$displayIndex.",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "${data['lat']}, ${data['lng']}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      data['time'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
              if (!isSelectionMode && imageData.length >= 3) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.chartArea,
                      color: Color(0xffFF0000),
                      size: 40,
                    ),
                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Diện tích dự kiến',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '3500 m2 - 0.35ha',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
