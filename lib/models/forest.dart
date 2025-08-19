import 'package:latlong2/latlong.dart' as latlng;
import 'package:protect_our_forest/models/farmland.dart';
import 'package:polybool/polybool.dart';

double toDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

class Forest {
  final String forestId;
  final String forestName;
  final String forestOriginalName;
  final int yearLastUpdated;
  final String designation;
  final GeoJsonFeature geojson;
  final String managementAuthority; // Giữ nguyên, lấy từ phần tử đầu tiên
  final String countries; // Giữ là String, lấy từ phần tử đầu tiên
  final String province; // Giữ là String, lấy từ phần tử đầu tiên
  final double reportedArea;
  final double intersectionArea;
  final List<Farmland> intersectionFarmlands;

  Forest({
    required this.forestId,
    required this.forestName,
    required this.forestOriginalName,
    required this.yearLastUpdated,
    required this.designation,
    required this.geojson,
    required this.province,
    required this.countries,
    required this.reportedArea,
    required this.managementAuthority,
    this.intersectionArea = 0.0,
    this.intersectionFarmlands = const [],
  });

  factory Forest.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      } else if (value is num) {
        return value.toDouble();
      }
      return 0.0;
    }

    return Forest(
      forestId: json['forestId'] ?? '',
      forestName: json['forestName'] ?? '',
      forestOriginalName: json['forestOriginalName'] ?? '',
      yearLastUpdated: json['yearLastUpdated'] ?? '',
      designation: json['designation'] ?? '',
      managementAuthority: json['managementAuthority'] ?? '',
      reportedArea: parseDouble(json['reportedArea']),
      geojson: GeoJsonFeature.fromJson(json['geojson'] ?? {}),
      province: json['province'] ?? '',
      countries: json['countries'] ?? '',
      intersectionArea: parseDouble(json['intersectionArea']),
      intersectionFarmlands: json['intersectionFarmland'] != null
          ? List<Farmland>.from(json['intersectionFarmland'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forestId': forestId,
      'forestName': forestName,
      'forestOriginalName': forestOriginalName,
      'designation': designation,
      'geojson': geojson.toJson(),
      'province': province,
      'countries': countries,
      'reportedArea': reportedArea,
      'managementAuthority': managementAuthority,
      'yearLastUpdated': yearLastUpdated,
      'intersectionArea': intersectionArea,
      'intersectionFarmlands': intersectionFarmlands
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class GeoJsonFeature {
  final String type;
  final Geometry geometry;

  GeoJsonFeature({required this.type, required this.geometry});

  factory GeoJsonFeature.fromJson(Map<String, dynamic> json) {
    return GeoJsonFeature(
      type: json['type'] ?? 'Feature',
      geometry: Geometry.fromJson(json['geometry'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'geometry': geometry.toJson()};
  }
}

class Geometry {
  final String type;
  final List<dynamic> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    var coords = json['coordinates'];
    if (coords is String) {
      print(
        'Warning: Coordinates is a String: $coords. Defaulting to empty list.',
      );
      coords = [];
    } else if (coords == null) {
      coords = [];
    }
    return Geometry(
      type: json['type'] ?? '',
      coordinates: coords is List ? coords : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }

  List<List<latlng.LatLng>> toListOfPolygons() {
    final List<List<latlng.LatLng>> polygons = [];
    if (type == 'Polygon') {
      final List<dynamic> rings = coordinates;
      for (var ring in rings) {
        if (ring is List<dynamic>) {
          final List<latlng.LatLng> points = ring
              .map(
                (p) => latlng.LatLng(toDouble(p[1]), toDouble(p[0])),
              ) // GeoJSON is [lon, lat]
              .toList();
          polygons.add(points);
        } else {
          print('Warning: Invalid ring format in Polygon: $ring');
        }
      }
    } else if (type == 'MultiPolygon') {
      final List<dynamic> multiPolygons = coordinates;
      for (var polygon in multiPolygons) {
        if (polygon is List<dynamic>) {
          final List<dynamic> rings = polygon;
          final List<dynamic> outerRing = rings.isNotEmpty ? rings.first : [];
          final List<latlng.LatLng> points = outerRing
              .map(
                (p) => latlng.LatLng(toDouble(p[1]), toDouble(p[0])),
              ) // GeoJSON is [lon, lat]
              .toList();
          polygons.add(points);
        } else {
          print('Warning: Invalid polygon format in MultiPolygon: $polygon');
        }
      }
    }
    return polygons;
  }

  List<List<Coordinate>> toListOfPolygonsInCoordinateFormat() {
    final List<List<Coordinate>> polygons = [];

    if (type == 'Polygon') {
      final List<dynamic> rings = coordinates;
      for (var ring in rings) {
        if (ring is List<dynamic>) {
          final List<Coordinate> points = ring
              .map(
                (p) => Coordinate(
                  toDouble(p[0]), // x = longitude
                  toDouble(p[1]), // y = latitude
                ),
              )
              .toList();
          polygons.add(points);
        } else {
          print('Warning: Invalid ring format in Polygon: $ring');
        }
      }
    } else if (type == 'MultiPolygon') {
      final List<dynamic> multiPolygons = coordinates;
      for (var polygon in multiPolygons) {
        if (polygon is List<dynamic>) {
          final List<dynamic> rings = polygon;
          final List<dynamic> outerRing = rings.isNotEmpty ? rings.first : [];
          final List<Coordinate> points = outerRing
              .map(
                (p) => Coordinate(
                  toDouble(p[0]), // x = longitude
                  toDouble(p[1]), // y = latitude
                ),
              )
              .toList();
          polygons.add(points);
        } else {
          print('Warning: Invalid polygon format in MultiPolygon: $polygon');
        }
      }
    }

    return polygons;
  }
}
