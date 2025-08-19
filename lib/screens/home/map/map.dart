import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:protect_our_forest/models/user.dart';
import 'package:protect_our_forest/screens/home/farmland/farmland_detail.dart';
import 'package:protect_our_forest/screens/home/map/forest_detail.dart';
import '../../../../config/calculate_intersection.dart';
import 'dart:math' as math;

import '../../../services/forest_service.dart';
import '../../../services/farmland_service.dart';
import '../../../models/forest.dart';
import '../../../models/farmland.dart';

class MapScreen extends StatefulWidget {
  final User? user;
  const MapScreen({super.key, this.user});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  bool _isMapReady = false; // Kiểm soát trạng thái bản đồ

  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _hasPermission = false;
  // Lưu danh sách ForestModels
  List<Farmland> farmlands = [];

  late List<Forest> forestAreas;
  late List<Polygon<Object>> forestPolygons = [];
  late List<Polygon<Object>> farmlandPolygons = [];
  late List<Polygon<Object>> intersectionPolygons = [];

  // Cấu hình LocationSettings cho độ chính xác cao
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Khoảng cách thay đổi vị trí để cập nhật (mét)
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _loadFarmlandData() async {
    try {
      // Giả sử user có thuộc tính province và district
      final province = widget.user?.province ?? '';
      final district = widget.user?.district ?? '';

      final data = await FarmlandDataService.getFarmlandByAddress(
        province,
        district,
      );

      if (mounted) {
        setState(() {
          farmlands = data;
        });
      }
      farmlandPolygons = farmlands.map((farmland) {
        Color fillColor;
        if (farmland.userId == widget.user!.userId) {
          switch (farmland.state) {
            case FarmlandState.approved:
              fillColor = const Color.fromARGB(150, 0, 0, 255); // Xanh dương
              break;
            case FarmlandState.pending:
              fillColor = const Color.fromARGB(150, 255, 255, 0); // Vàng
              break;
            default:
              fillColor = const Color.fromARGB(150, 128, 128, 128); // Xám
          }
        } else {
          fillColor = const Color.fromARGB(148, 0, 238, 255); // Xanh lá nhạt
        }
        return Polygon<Object>(
          points: farmland.toLatLng(),
          color: fillColor,
          borderColor: Colors.orange.shade800,
          borderStrokeWidth: 1.0,
          hitValue: farmland,
        );
      }).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải farmland: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _hasPermission = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lấy vị trí: $e')));
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quyền vị trí'),
        content: const Text(
          'Vui lòng cấp quyền vị trí trong cài đặt để sử dụng tính năng này.',
        ),
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

  Future<void> _moveToCurrentLocationSmooth() async {
    if (!_isMapReady || _currentPosition == null || !mounted) return;
    final latlng.LatLng target = latlng.LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    _mapController.move(target, 13.0);
    await Future.delayed(const Duration(milliseconds: 200));
    _mapController.move(target, 14.5);
    await Future.delayed(const Duration(milliseconds: 200));
    _mapController.move(target, 16.0);
  }

  // Future<void> _updateCurrentPosition() async {
  //   if (!_hasPermission || !mounted) return;
  //   try {
  //     final position = await Geolocator.getCurrentPosition(
  //       locationSettings: locationSettings,
  //     );
  //     if (mounted) {
  //       setState(() {
  //         _currentPosition = position;
  //       });
  //       if (_isMapReady) _moveToCurrentLocationSmooth();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật vị trí: $e')));
  //     }
  //   }
  // }

  Future<void> _loadForestData() async {
    try {
      final areas = await ForestDataService.loadAllForestData();
      if (mounted) {
        setState(() {
          forestAreas = areas;
        });
      }
      forestPolygons = forestAreas.expand((area) {
        final polygons = area.geojson.geometry.toListOfPolygons();
        return polygons.map((points) {
          final fixedPoints = points
              .map((p) => latlng.LatLng(p.latitude, p.longitude))
              .toList();
          return Polygon<Object>(
            points: fixedPoints,
            color: const Color.fromARGB(84, 71, 148, 146),
            borderColor: Colors.black,
            borderStrokeWidth: 1.0,
            hitValue: area,
          );
        });
      }).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu rừng: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double calculateAngle(latlng.LatLng center, latlng.LatLng point) {
    double deltaY = point.latitude - center.latitude;
    double deltaX = point.longitude - center.longitude;
    double angle = math.atan2(deltaY, deltaX) * 180 / math.pi;
    return (angle < 0) ? angle + 360 : angle;
  }

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
      sortedPoints.add(sortedPoints.first);
    }
    return sortedPoints;
  }

  // List<Polygon> _buildFarmlandPolygons() {
  //   final List<Polygon> polygons = [];

  //   for (final farmland in farmlands) {
  //     if (farmland.locations == null || farmland.locations!.isEmpty) continue;

  //     final coords = farmland.locations!
  //         .map((loc) => latlng.LatLng(loc.latitude, loc.longitude))
  //         .toList();

  //     // Sắp xếp toạ độ
  //     final sortedCoords = sortCoordinates(coords);

  //     // Kiểm tra xâm lấn
  //     bool hasIntersection = false;
  //     if (forestAreas != null) {
  //       for (final forest in forestAreas!) {
  //         final forestPolygons = forest.geojson.geometry.toListOfPolygons();
  //         for (final forestPolygon in forestPolygons) {
  //           final intersection = calculateIntersectionPolygon(
  //             latLngListToCoordinates(sortedCoords),
  //             latLngListToCoordinates(forestPolygon),
  //           );
  //           if (intersection.isNotEmpty) {
  //             hasIntersection = true;
  //             break;
  //           }
  //         }
  //         if (hasIntersection) break;
  //       }
  //     }

  //     // Xác định màu
  //     Color fillColor;
  //     if (farmland.userId == widget.user?.userId) {
  //       if (hasIntersection) {
  //         fillColor = const Color.fromARGB(150, 255, 0, 0); // Đỏ cảnh báo
  //       } else {
  //         switch (farmland.state) {
  //           case FarmlandState.approved:
  //             fillColor = const Color.fromARGB(150, 0, 0, 255); // Xanh dương
  //             break;
  //           case FarmlandState.pending:
  //             fillColor = const Color.fromARGB(150, 255, 255, 0); // Vàng
  //             break;
  //           default:
  //             fillColor = const Color.fromARGB(150, 128, 128, 128); // Xám
  //         }
  //       }
  //     } else {
  //       fillColor = const Color.fromARGB(150, 0, 255, 0); // Xanh lá nhạt
  //     }

  //     polygons.add(
  //       Polygon(
  //         points: sortedCoords,
  //         color: fillColor,
  //         borderColor: Colors.black,
  //         borderStrokeWidth: 1.0,
  //       ),
  //     );
  //   }

  //   return polygons;
  // }

  void _zoomIn() {
    if (!_isMapReady) return;
    final center = _mapController.camera.center;
    final zoom = _mapController.camera.zoom;
    if (zoom < 18.0) {
      _mapController.move(center, zoom + 1);
    }
  }

  void _zoomOut() {
    if (!_isMapReady) return;
    final center = _mapController.camera.center;
    final zoom = _mapController.camera.zoom;
    if (zoom > 5.0) {
      _mapController.move(center, zoom - 1);
    }
  }

  void _loadIntersection() {
    intersectionPolygons = [];
    for (final farmland in farmlands) {
      final sortedFarmlandCoords = farmland.toLatLng(); 
      for (final area in forestAreas) {
        final forestPolys = area.geojson.geometry.toListOfPolygons();
        for (final forestPoly in forestPolys) {
          final intersections = calculateIntersectionPolygon(
            latLngListToCoordinates(sortedFarmlandCoords),
            latLngListToCoordinates(forestPoly),
          );
          if (intersections.isNotEmpty) {
            for (final intersection in intersections) {
              intersectionPolygons.add(
                Polygon<Object>(
                  points: intersection,
                  color: const Color.fromARGB(150, 255, 0, 0),
                  borderColor: Colors.red,
                  borderStrokeWidth: 2.0,
                ),
              );
            }
          }
        }
      }
    }
  }

  bool _isPointInPolygon(latlng.LatLng point, List<latlng.LatLng> polygon) {
    bool isInside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  @override
  Widget build(BuildContext context) {
    final latlng.LatLng initialCenter = _currentPosition != null
        ? latlng.LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const latlng.LatLng(10.762622, 106.660172); // HCM

    // Kiểm tra dữ liệu trước khi render FlutterMap
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff1b3b3a),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Xin chào, ${widget.user?.userName ?? 'N/A'}.',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.notifications, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Zoom In
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _zoomIn,
            child: const Icon(Icons.zoom_in, color: Colors.black),
          ),

          // Zoom Out
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _zoomOut,
            child: const Icon(Icons.zoom_out, color: Colors.black),
          ),

          FloatingActionButton(
            heroTag: 'location',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _isMapReady
                ? () async {
                    await _moveToCurrentLocationSmooth();
                  }
                : null,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            onTap: (tapPosition, point) {
              // Check click farmland
              for (final farmland in farmlands) {
                if (_isPointInPolygon(point, farmland.toLatLng())) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FarmlandDetailScreen(farmland: farmland),
                    ),
                  );
                  return;
                }
              }
              // Check click forest
              for (final area in forestAreas) {
                final polygons = area.geojson.geometry.toListOfPolygons();
                for (final polygon in polygons) {
                  if (_isPointInPolygon(point, polygon)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForestDetailScreen(forestModel: area),
                      ),
                    );
                    return;
                  }
                }
              }
            },
            crs: const Epsg3857(),
            initialCenter: initialCenter,
            initialZoom: 10.0, // Zoom ban đầu thấp hơn để bao quát Việt Nam
            minZoom: 5.0,
            maxZoom: 18.0,
            backgroundColor: Colors.grey, // Màu nền để che mảng trắng
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
              scrollWheelVelocity: 0.003,
            ),
            onMapReady: () async {
              if (mounted) {
                setState(() {
                  _isMapReady = true;
                });
                if (_currentPosition != null) _moveToCurrentLocationSmooth();
                await Future.wait([_loadForestData(), _loadFarmlandData()]);
                _loadIntersection();

                if (mounted) setState(() {});
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.protect_our_forest',
              errorTileCallback: (tile, error, stackTrace) {
                debugPrint('Error loading tile ${tile.coordinates}: $error');
              },
            ),
            // if (!_isLoading &&
            //     forestAreas != null &&
            //     farmlands.isNotEmpty &&
            //     widget.user != null)
            //   LayerMapScreen(
            //     forestJsonData: jsonData,
            //     farmlands: farmlands,
            //     user: widget.user,
            //   ),
            PolygonLayer(polygons: farmlandPolygons),
            // Layer forest
            PolygonLayer(polygons: forestPolygons),
            PolygonLayer(polygons: intersectionPolygons),
            
          ],
        ),
      ),
    );
  }
}
