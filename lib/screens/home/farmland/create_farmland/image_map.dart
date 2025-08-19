import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:protect_our_forest/models/forest.dart';
import 'package:protect_our_forest/services/forest_service.dart';

class ImageMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ImageMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  _ImageMapScreenState createState() => _ImageMapScreenState();
}

class _ImageMapScreenState extends State<ImageMapScreen> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu rừng: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF8E1),
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
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: latlng.LatLng(widget.latitude, widget.longitude),
          initialZoom: 10.0,
          minZoom: 5.0,
          maxZoom: 18.0,
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
                  (area) => area.geojson.geometry.toListOfPolygons().map((points) {
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
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: latlng.LatLng(widget.latitude, widget.longitude),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            tooltip: 'Zoom in',
            child: const Icon(Icons.add),
            mini: true,
          ),
          const SizedBox(height: 10), // Khoảng cách giữa hai nút
          FloatingActionButton(
            onPressed: _zoomOut,
            tooltip: 'Zoom out',
            child: const Icon(Icons.remove),
            mini: true,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}