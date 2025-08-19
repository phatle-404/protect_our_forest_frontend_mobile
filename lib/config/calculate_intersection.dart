import 'package:polybool/polybool.dart';
import 'package:latlong2/latlong.dart' as latlng;

List<Coordinate> latLngListToCoordinates(List<latlng.LatLng> latLngList) {
  return latLngList
      .map((p) => Coordinate(p.longitude, p.latitude)) // x = lon, y = lat
      .toList();
}

List<List<latlng.LatLng>> calculateIntersectionPolygon(
  List<Coordinate> poly1, // Vùng canh tác
  List<Coordinate> poly2, // Vùng rừng
) {
  // Bọc lại thành regions
  final firstPoly = Polygon(regions: [poly1]);
  final secondPoly = Polygon(regions: [poly2]);

  // Tính giao nhau
  final intersection = firstPoly.intersect(secondPoly); // Kiểu Polygon
  // Kiểm tra rỗng
  if (intersection.regions.isEmpty) {
    return [];
  }

  return intersection.regions.map((region) {
    return region.map((c) => latlng.LatLng(c.y, c.x)).toList();
  }).toList();
}
