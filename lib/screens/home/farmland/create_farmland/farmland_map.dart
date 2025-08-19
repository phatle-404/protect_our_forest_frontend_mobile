import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:protect_our_forest/models/forest.dart';
import 'package:protect_our_forest/services/forest_service.dart';
import '../../../../config/calculate_intersection.dart';

class FarmlandMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> imageData;

  const FarmlandMapScreen({super.key, required this.imageData});

  @override
  _FarmlandMapScreenState createState() => _FarmlandMapScreenState();
}

class _FarmlandMapScreenState extends State<FarmlandMapScreen> {
  final MapController _mapController = MapController();
  List<Forest>? forestAreas;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForestData();
  }

  Future<void> _loadForestData() async {
    try {
      final areas = await ForestDataService.loadAllForestData();
      if (mounted) {
        setState(() {
          forestAreas = areas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu rừng: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm tính góc giữa hai điểm
  double calculateAngle(latlng.LatLng center, latlng.LatLng point) {
    double deltaY = (point.latitude - center.latitude).toDouble();
    double deltaX = (point.longitude - center.longitude).toDouble();
    double angle = math.atan2(deltaY, deltaX) * 180 / math.pi;
    return (angle < 0) ? angle + 360 : angle; // Góc từ 0 đến 360 độ
  }

  // Hàm sắp xếp tọa độ thành đa giác dựa trên centroid
  List<latlng.LatLng> sortCoordinates(List<latlng.LatLng> points) {
    if (points.length < 3) return points;

    // Tính centroid
    double centroidLat = 0, centroidLng = 0;
    for (var point in points) {
      centroidLat += point.latitude;
      centroidLng += point.longitude;
    }
    centroidLat = (centroidLat / points.length).toDouble();
    centroidLng = (centroidLng / points.length).toDouble();
    latlng.LatLng centroid = latlng.LatLng(centroidLat, centroidLng);

    // Sắp xếp theo góc quanh centroid
    List<latlng.LatLng> sortedPoints = List.from(points);
    sortedPoints.sort((a, b) {
      double angleA = calculateAngle(centroid, a);
      double angleB = calculateAngle(centroid, b);
      return angleA.compareTo(angleB);
    });

    // Đóng đa giác
    if (sortedPoints.last != sortedPoints.first) {
      sortedPoints.add(sortedPoints.first);
    }

    return sortedPoints;
  }

  // Hàm lấy danh sách tọa độ từ imageData
  List<latlng.LatLng> getFarmlandCoordinates() {
    return widget.imageData.map((data) {
      final latString = data['lat'] ?? '0.0';
      final lngString = data['lng'] ?? '0.0';
      final lat = double.parse(latString.replaceAll('° N', ''));
      final lng = double.parse(lngString.replaceAll('° E', ''));
      return latlng.LatLng(lat, lng);
    }).toList();
  }

  // Hàm kiểm tra điểm có nằm trong đa giác không
  //

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18.0) {
      _mapController.move(_mapController.camera.center, currentZoom + 1);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 5.0) {
      _mapController.move(_mapController.camera.center, currentZoom - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final farmlandCoords = getFarmlandCoordinates();
    final sortedFarmlandCoords = sortCoordinates(farmlandCoords);

    // Tạo Polygon cho vùng canh tác
    final farmlandPolygon = Polygon<Object>(
      points: sortedFarmlandCoords,
      color: const Color.fromARGB(84, 255, 165, 0), // Màu cam trong suốt
      borderColor: Colors.orange,
      borderStrokeWidth: 2.0,
    );

    // Tạo Polygon cho vùng giao cắt
    final List<Polygon<Object>> intersectionPolygons = [];
    if (forestAreas != null) {
      for (final area in forestAreas!) {
        final forestPolygons = area.geojson.geometry.toListOfPolygons();
        for (final forestPolygon in forestPolygons) {
          final intersections = calculateIntersectionPolygon(
            latLngListToCoordinates(sortedFarmlandCoords),
            latLngListToCoordinates(forestPolygon),
          );
          if (intersections.isNotEmpty) {
            for (final polyPoints in intersections) {
              intersectionPolygons.add(
                Polygon<Object>(
                  points: polyPoints,
                  color: const Color.fromARGB(150, 255, 0, 0), // Màu đỏ
                  borderColor: Colors.red,
                  borderStrokeWidth: 2.0,
                ),
              );
            }
          }
        }
      }
    }

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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _zoomIn,
            child: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _zoomOut,
            child: const Icon(Icons.remove, color: Colors.black),
          ),
          const SizedBox(height: 20),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: sortedFarmlandCoords.isNotEmpty
              ? sortedFarmlandCoords[0]
              : const latlng.LatLng(10.7769, 106.7009), // Trung tâm mặc định
          initialZoom: 10.0,
          minZoom: 5.0,
          maxZoom: 18.0,
          onTap: (tapPosition, point) {
            // Xử lý tương tác nếu cần
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.protect_our_forest',
          ),
          PolygonLayer<Object>(
            polygons: [
              if (forestAreas != null)
                ...forestAreas!.expand(
                  (area) =>
                      area.geojson.geometry.toListOfPolygons().map((points) {
                        return Polygon<Object>(
                          points: points,
                          color: const Color.fromARGB(
                            84,
                            71,
                            148,
                            146,
                          ), // Màu xanh lá trong suốt
                          borderColor: Colors.black,
                          borderStrokeWidth: 1.0,
                          hitValue: area,
                        );
                      }),
                ),
              farmlandPolygon,
              ...intersectionPolygons,
            ],
          ),
          MarkerLayer(
            markers: [
              ...sortedFarmlandCoords.map((point) {
                return Marker(
                  point: point,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.orange,
                    size: 30,
                  ),
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
//bool _isPointInPolygon(
  //   latlng.LatLng point,
  //   List<latlng.LatLng> polygon, {
  //   bool includeBoundary = false,
  // }) {
  //   bool isInside = false;
  //   for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
  //     if ((polygon[i].latitude == point.latitude &&
  //             polygon[i].longitude == point.longitude) ||
  //         (polygon[j].latitude == point.latitude &&
  //             polygon[j].longitude == point.longitude)) {
  //       return includeBoundary; // Điểm nằm trên biên
  //     }
  //     if ((polygon[i].latitude > point.latitude) !=
  //             (polygon[j].latitude > point.latitude) &&
  //         point.longitude <
  //             (polygon[j].longitude - polygon[i].longitude) *
  //                     (point.latitude - polygon[i].latitude) /
  //                     (polygon[j].latitude - polygon[i].latitude) +
  //                 polygon[i].longitude) {
  //       isInside = !isInside;
  //     }
  //   }
  //   return isInside;
  // }

  // // Hàm tìm giao điểm giữa hai đoạn thẳng
  // latlng.LatLng? _lineSegmentIntersection(
  //   latlng.LatLng p1,
  //   latlng.LatLng p2,
  //   latlng.LatLng p3,
  //   latlng.LatLng p4,
  // ) {
  //   double denom =
  //       ((p4.latitude - p3.latitude) * (p2.longitude - p1.longitude) -
  //               (p4.longitude - p3.longitude) * (p2.latitude - p1.latitude))
  //           .toDouble();
  //   if (denom.abs() < 1e-10)
  //     return null; // Xử lý trường hợp song song hoặc gần song song

  //   double ua =
  //       (((p4.longitude - p3.longitude) * (p1.latitude - p3.latitude) -
  //                   (p4.latitude - p3.latitude) *
  //                       (p1.longitude - p3.longitude)) /
  //               denom)
  //           .toDouble();
  //   double ub =
  //       (((p2.longitude - p1.longitude) * (p1.latitude - p3.latitude) -
  //                   (p2.latitude - p1.latitude) *
  //                       (p1.longitude - p3.longitude)) /
  //               denom)
  //           .toDouble();

  //   if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
  //     double x = (p1.longitude + ua * (p2.longitude - p1.longitude)).toDouble();
  //     double y = (p1.latitude + ua * (p2.latitude - p1.latitude)).toDouble();
  //     return latlng.LatLng(y, x); // latlong2 dùng (lat, lng)
  //   }
  //   return null;
  // }

  // // Hàm tìm các đoạn ranh giới cắt qua hoặc nằm trên đa giác khác
  // List<latlng.LatLng> findBoundarySegments(
  //   List<latlng.LatLng> sourcePoly, // Đa giác nguồn
  //   List<latlng.LatLng> targetPoly, // Đa giác đích
  // ) {
  //   List<latlng.LatLng> boundaryPoints = [];

  //   for (int i = 0; i < sourcePoly.length; i++) {
  //     latlng.LatLng p1 = sourcePoly[i];
  //     latlng.LatLng p2 = sourcePoly[(i + 1) % sourcePoly.length];
  //     bool p1Inside = _isPointInPolygon(p1, targetPoly, includeBoundary: true);
  //     bool p2Inside = _isPointInPolygon(p2, targetPoly, includeBoundary: true);

  //     // Trường hợp 1: Cả hai điểm nằm trong
  //     if (p1Inside && p2Inside) {
  //       boundaryPoints.add(p1);
  //       boundaryPoints.add(p2);
  //     }
  //     // Trường hợp 2: Một điểm nằm trong, một điểm nằm ngoài - tìm giao điểm
  //     else if (p1Inside != p2Inside) {
  //       for (int j = 0; j < targetPoly.length; j++) {
  //         latlng.LatLng? intersection = _lineSegmentIntersection(
  //           p1,
  //           p2,
  //           targetPoly[j],
  //           targetPoly[(j + 1) % targetPoly.length],
  //         );
  //         if (intersection != null) {
  //           boundaryPoints.add(intersection);
  //         }
  //       }
  //       // Thêm điểm nằm trong (nếu có)
  //       if (p1Inside)
  //         boundaryPoints.add(p1);
  //       else if (p2Inside)
  //         boundaryPoints.add(p2);
  //     }
  //     // Trường hợp 3: Cả hai điểm nằm ngoài nhưng đoạn cắt qua
  //     else {
  //       List<latlng.LatLng> intersections = [];
  //       for (int j = 0; j < targetPoly.length; j++) {
  //         latlng.LatLng? intersection = _lineSegmentIntersection(
  //           p1,
  //           p2,
  //           targetPoly[j],
  //           targetPoly[(j + 1) % targetPoly.length],
  //         );
  //         if (intersection != null) {
  //           intersections.add(intersection);
  //         }
  //       }
  //       if (intersections.length >= 1) {
  //         // Sắp xếp giao điểm theo khoảng cách từ p1 để lấy điểm gần nhất
  //         intersections.sort(
  //           (a, b) => _distance(p1, a).compareTo(_distance(p1, b)),
  //         );
  //         boundaryPoints.addAll(intersections);
  //         // Thêm điểm gần nhất nằm trong (dựa trên số giao điểm lẻ)
  //         if (intersections.length % 2 == 1) {
  //           latlng.LatLng? entryPoint = _interpolatePoint(
  //             p1,
  //             p2,
  //             intersections.first,
  //           );
  //           if (entryPoint != null) boundaryPoints.add(entryPoint);
  //         }
  //       }
  //     }
  //   }

  //   return boundaryPoints.toSet().toList(); // Loại bỏ trùng lặp
  // }

  // // Hàm tính khoảng cách giữa hai điểm
  // double _distance(latlng.LatLng p1, latlng.LatLng p2) {
  //   double dx = p2.longitude - p1.longitude;
  //   double dy = p2.latitude - p1.latitude;
  //   return math.sqrt(dx * dx + dy * dy);
  // }

  // // Hàm nội suy để tìm điểm nhập vào vùng (dựa trên giao điểm đầu tiên)
  // latlng.LatLng? _interpolatePoint(
  //   latlng.LatLng p1,
  //   latlng.LatLng p2,
  //   latlng.LatLng intersection,
  // ) {
  //   double t = _distance(p1, intersection) / _distance(p1, p2);
  //   if (t >= 0 && t <= 1) {
  //     double lat = p1.latitude + t * (p2.latitude - p1.latitude);
  //     double lng = p1.longitude + t * (p2.longitude - p1.longitude);
  //     return latlng.LatLng(lat, lng);
  //   }
  //   return null;
  // }