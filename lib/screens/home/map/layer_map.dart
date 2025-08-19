import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:protect_our_forest/models/forest.dart';
import 'package:protect_our_forest/screens/home/map/forest_detail.dart';
import '../farmland/farmland_detail.dart';
import '../../../models/farmland.dart';
import '../../../../config/calculate_intersection.dart';
import '../../../models/user.dart';
import 'dart:math' as math;

class LayerMapScreen extends StatefulWidget {
  final String forestJsonData;
  final List<Farmland> farmlands;
  final User? user;

  const LayerMapScreen({
    super.key,
    required this.forestJsonData,
    required this.farmlands,
    this.user,
  });

  @override
  State<LayerMapScreen> createState() => _LayerMapScreenState();
}

class _LayerMapScreenState extends State<LayerMapScreen> {
  final MapController _mapController = MapController();

  late List<Forest> forestAreas;
  late List<Polygon<Object>> forestPolygons;
  late List<Polygon<Object>> farmlandPolygons;
  late List<Polygon<Object>> intersectionPolygons;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      sortedPoints.add(sortedPoints.first); // Đóng đa giác
    }
    return sortedPoints;
  }

  void _loadData() {
    // Parse dữ liệu rừng
    final Map<String, dynamic> parsedJson = json.decode(widget.forestJsonData);
    forestAreas = (parsedJson['protected_areas'] as List)
        .map((json) => Forest.fromJson(json))
        .toList();

    // Tạo polygons rừng
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

    farmlandPolygons = widget.farmlands.map((farmland) {
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
        points: sortCoordinates(farmland.toLatLng()),
        color: fillColor,
        borderColor: Colors.orange.shade800,
        borderStrokeWidth: 1.0,
        hitValue: farmland,
      );
    }).toList();

    // Tính vùng giao cắt
    intersectionPolygons = [];
    for (final farmland in widget.farmlands) {
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

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const latlng.LatLng(10.7769, 106.7009),
        initialZoom: 10.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onTap: (tapPosition, point) {
          // Check click farmland
          for (final farmland in widget.farmlands) {
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
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.protect_our_forest',
        ),
        // Layer giao cắt (trên cùng)

        // Layer farmland
        PolygonLayer(polygons: farmlandPolygons),
        // Layer forest
        PolygonLayer(polygons: forestPolygons),
        PolygonLayer(polygons: intersectionPolygons),
      ],
    );
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
}
