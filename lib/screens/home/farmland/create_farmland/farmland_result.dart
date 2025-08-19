import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:protect_our_forest/config/colors.dart';
import 'package:intl/intl.dart';
import 'package:protect_our_forest/models/farmland.dart';
import 'package:protect_our_forest/models/forest.dart';
import 'package:protect_our_forest/models/location.dart';
import 'package:protect_our_forest/models/request.dart';
import 'package:protect_our_forest/models/user.dart';
import 'package:protect_our_forest/models/notification.dart';
import '../../../../config/calculate_intersection.dart';
import 'package:protect_our_forest/screens/home/farmland/create_farmland/farmland_map.dart';
import 'package:protect_our_forest/screens/home/farmland/create_farmland/image_result.dart';
import 'package:protect_our_forest/screens/home/home.dart';
import 'package:protect_our_forest/services/camera_service.dart';
import 'package:protect_our_forest/services/farmland_service.dart';
import 'package:protect_our_forest/services/forest_service.dart';
import 'package:protect_our_forest/services/notification_service.dart';
import 'package:protect_our_forest/services/request_service.dart';
import 'package:protect_our_forest/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FarmlandResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? photoData;

  const FarmlandResultScreen({super.key, this.photoData});

  @override
  FarmlandResultScreenState createState() => FarmlandResultScreenState();
}

class FarmlandResultScreenState extends State<FarmlandResultScreen> {
  bool _isLoading = true;

  late List<Map<String, dynamic>> imageData;
  Set<int> selectedIndexes = {};
  bool isSelectionMode = false;

  List<Forest>? forests;

  NotificationModels newNotification = NotificationModels(
    notificationId: '',
    userId: '',
    title: '',
    body: '',
    createAt: DateTime.now(),
  );

  Request req = Request(
    userId: '',
    farmlandId: '',
    action: '',
    newFarmland: Farmland.fromJson({}),
    oldFarmland: Farmland.fromJson({}),
    message: '',
  );

  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    imageData =
        widget.photoData
            ?.map((data) {
              final latitude = data['latitude'] as double? ?? 0.0;
              final longitude = data['longitude'] as double? ?? 0.0;
              final imageFile = data['imageFile'] as XFile?;
              final time = DateFormat('HH:mm dd/MM/yyyy').format(data['time']);
              return {
                'lat': '$latitude° N',
                'lng': '$longitude° E',
                'time': time,
                'image': imageFile?.path ?? '', // Đảm bảo là chuỗi hợp lệ
              };
            })
            .cast<Map<String, String>>()
            .toList() ??
        [];
    _loadForestData();
  }

  Future<void> _loadForestData() async {
    try {
      forests = await ForestDataService.loadAllForestData();
      if (mounted) _findForestIntersectionandArea();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu rừng: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void enterSelectionMode(int index) {
    setState(() {
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

  // Hàm sắp xếp tọa độ thành đa giác
  List<latlng.LatLng> sortCoordinates(List<latlng.LatLng> points) {
    if (points.length < 3) return points;
    latlng.LatLng referencePoint = points[0];
    List<latlng.LatLng> sortedPoints = List.from(points);
    sortedPoints.sort((a, b) {
      double angleA = calculateAngle(referencePoint, a);
      double angleB = calculateAngle(referencePoint, b);
      return angleA.compareTo(angleB);
    });
    if (sortedPoints.last != sortedPoints.first) {
      sortedPoints.add(sortedPoints.first); // Đóng đa giác
    }
    return sortedPoints;
  }

  // Hàm tính góc giữa hai điểm
  double calculateAngle(latlng.LatLng center, latlng.LatLng point) {
    double deltaY = point.latitude - center.latitude;
    double deltaX = point.longitude - center.longitude;
    double angle = math.atan2(deltaY, deltaX) * 180 / math.pi;
    return (angle < 0) ? angle + 360 : angle;
  }

  // Hàm tính diện tích đa giác (Shoelace Formula)
  double calculateArea(List<latlng.LatLng> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    int j = points.length - 1;

    for (int i = 0; i < points.length; i++) {
      area +=
          (points[j].longitude + points[i].longitude) *
          (points[j].latitude - points[i].latitude);
      j = i;
    }

    // Chuyển đổi sang mét vuông (gần đúng)
    area = area > 0 ? area / 2 : -area / 2;
    const double metersPerDegree = 111000; // 1 độ latitude ≈ 111 km
    area *= metersPerDegree * metersPerDegree;
    return area;
  }

  // Hàm lấy danh sách tọa độ từ imageData
  List<latlng.LatLng> getCoordinates() {
    return imageData.map((data) {
      final latString = data['lat'] ?? '0.0';
      final lngString = data['lng'] ?? '0.0';
      final lat = double.parse(latString.replaceAll('° N', ''));
      final lng = double.parse(lngString.replaceAll('° E', ''));
      return latlng.LatLng(lat, lng);
    }).toList();
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

  Future<void> _showCancelConfirmation(BuildContext context) async {
    User? currentUser = await UserDataService.loadUserData();
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn hủy tạo vùng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Hủy
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              CameraDataService().clear(); // Xóa dữ liệu photoData
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(user: currentUser),
                ), // Chuyển về HomeScreen
              );
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  String intersectionForest = '';
  double intersectionArea = 0.0;

  Future<void> _findForestIntersectionandArea() async {
    final sortedFarmlandCoords = sortCoordinates(getCoordinates());

    // Nếu chưa đủ điểm để tạo đa giác thì bỏ qua
    if (sortedFarmlandCoords.length < 3 ||
        forests == null ||
        forests!.isEmpty) {
      setState(() {
        intersectionForest = '';
        intersectionArea = 0.0;
      });
      return;
    }
    List<List<latlng.LatLng>> intersections = [];

    for (final forest in forests!) {
      // Lấy list polygon của forest (mỗi polygon là List<LatLng>)
      final forestPolygons = forest.geojson.geometry.toListOfPolygons();
      for (final forestPolygon in forestPolygons) {
        // 2) Chỉ khi bounding box có khả năng giao nhau mới tính toán giao polygon thực tế
        intersections = calculateIntersectionPolygon(
          latLngListToCoordinates(sortedFarmlandCoords),
          latLngListToCoordinates(forestPolygon),
        );
        if (intersections.isNotEmpty) {
          intersectionForest = forest.forestOriginalName;
          for (final intersection in intersections) {
            final area = calculateArea(intersection);
            intersectionArea += area;
          }
          // Nếu chỉ cần tên rừng đầu tiên thì break ra khỏi vòng lặp
          // break;
        }
      }
    }
  }

  Future<void> _onSaveFarmland() async {
    final storage = FlutterSecureStorage();
    String userId = await storage.read(key: 'userId') ?? '';
    // Lấy tọa độ
    final sortedFarmlandCoords = sortCoordinates(getCoordinates());
    final area = calculateArea(sortedFarmlandCoords);

    final List<Location> imageLocations = imageData.map((data) {
      final latitude =
          double.tryParse(data['lat']?.replaceAll('° N', '') ?? '') ?? 0.0;
      final longitude =
          double.tryParse(data['lng']?.replaceAll('° E', '') ?? '') ?? 0.0;
      final imagePath = data['image'] ?? '';
      final imageFile = imagePath.isNotEmpty ? XFile(imagePath) : null;
      final dateTime = DateFormat('HH:mm dd/MM/yyyy').parse(data['time']!);

      return Location(
        latitude: latitude,
        longitude: longitude,
        timeTakeLocation: dateTime,
        imageFile: imageFile,
      );
    }).toList();

    // Tạo object Farmland (pending)
    Farmland newFarmland = Farmland(
      farmlandName: nameController.text.trim(), // Hoặc lấy từ TextField tên
      area: area,
      registerDate: DateTime.now(),
      startDate: null,
      exprDate: null,
      intersectionArea: intersectionArea,
      intersectionForest: intersectionForest,
      createByCamera: true,
      state: FarmlandState.pending,
      locations: imageLocations,
    );

    // final requestService = RequestService();
    final userInfo = await UserDataService.loadUserData();

    try {
      // 1️⃣ Tạo vùng pending
      String farmlandPendingId =
          await FarmlandDataService.createFarmlandAsPending(newFarmland);
      Farmland farmlandPending = await FarmlandDataService.getFarmlandById(
        farmlandPendingId,
      );

      // 2️⃣ Tạo notification
      newNotification = NotificationModels(
        notificationId: '', // backend sẽ tự tạo
        userId: userId,
        title: 'Yêu cầu tạo vùng canh tác',
        body: 'Bạn đã gửi yêu cầu tạo vùng ${farmlandPending.farmlandName}.',
        createAt: DateTime.now(),
      );
      await NotificationService.createNotification(newNotification);

      // Tạo request
      // req = Request.create(
      //   userId: userId,
      //   farmlandId: '',
      //   newFarmland: farmlandPending,
      //   message: 'Yêu cầu tạo mới vùng canh tác.',
      // );
      // await requestService.createRequest(req.toJson());

      // Hiển thị thông báo thành công

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tạo vùng canh tác thành công!')));

      CameraDataService().clear();

      // Quay về Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: userInfo)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCoords = sortCoordinates(getCoordinates());
    final area = calculateArea(sortedCoords);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => _showCancelConfirmation(context),
        ),
        title: const Text(
          'Tạo vùng canh tác',
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Row(
                      spacing: 15.0,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  fontSize: 14,
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
                                  fontSize: 14,
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
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FarmlandMapScreen(imageData: imageData),
                            ),
                          );
                        },
                        child: const Icon(
                          LucideIcons.map,
                          color: Colors.white,
                          size: 35,
                        ), // Thay IconButton bằng GestureDetector
                      ),
                      const Text(
                        "Kết quả",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ), // Giảm font size từ 14 xuống 12
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Xác nhận'),
                              content: Text(
                                'Bạn có chắc chắn tạo vùng canh tác này không?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _onSaveFarmland();
                                  },
                                  child: Text('Có'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          LucideIcons.save,
                          color: Colors.white,
                          size: 35,
                        ), // Thay IconButton bằng GestureDetector
                      ),
                      const Text(
                        "Lưu",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ), // Giảm font size từ 14 xuống 12
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
                controller: nameController,
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
              if (imageData.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Chưa có ảnh nào được chụp.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              else
                ...imageData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final displayIndex = index + 1;
                  final data = entry.value;

                  final lat = double.parse(data['lat']!.replaceAll('° N', ''));
                  final lng = double.parse(data['lng']!.replaceAll('° E', ''));
                  final formattedLat = lat.toStringAsFixed(4) + '° N';
                  final formattedLng = lng.toStringAsFixed(4) + '° E';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: data['image']!.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(data['image']!)),
                              fit: BoxFit.cover,
                              colorFilter: const ColorFilter.mode(
                                Colors.black38,
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                    child: ListTile(
                      onLongPress: () {
                        if (imageData.length > 3) enterSelectionMode(index);
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          toggleSelection(index);
                        } else {
                          // Chuyển đến image_result.dart khi nhấn ảnh
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageResultScreen(
                                imagePath: data['image']!,
                                latitude: lat,
                                longitude: lng,
                                time: data['time']!,
                              ),
                            ),
                          );
                        }
                      },
                      trailing: isSelectionMode
                          ? selectedIndexes.contains(index)
                                ? Image.asset(
                                    'assets/image/location/circle-check.png',
                                    height: 25,
                                  )
                                : Icon(
                                    LucideIcons.circle,
                                    color: Colors.white,
                                    size: 25,
                                  )
                          : const Icon(LucideIcons.mapPin, color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Text(
                        "$displayIndex.",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        "$formattedLat, $formattedLng",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
                      children: [
                        const Text(
                          'Diện tích dự kiến',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formatArea(area),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                if (intersectionArea > 0.0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.layers,
                        color: Color(0xff4CAF50),
                        size: 35,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diện tích giao cắt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatArea(intersectionArea),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.treePine,
                        color: Color(0xff2E7D32),
                        size: 35,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rừng giao cắt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            intersectionForest,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
