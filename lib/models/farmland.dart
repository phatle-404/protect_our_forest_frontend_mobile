import 'package:polybool/polybool.dart';
import 'package:protect_our_forest/models/location.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';

enum FarmlandState { pending, approved, rejected, warning }

extension FarmlandStateExtension on FarmlandState {
  String toShortString() => toString().split('.').last;

  static FarmlandState fromString(String value) {
    return FarmlandState.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => FarmlandState.pending,
    );
  }
}

class Farmland {
  final String userId;
  final String farmlandId;
  final String farmlandName;
  final double area;
  final DateTime registerDate;
  final DateTime? startDate; // ✅ Cho phép null khi chưa duyệt
  final DateTime? exprDate; // ✅ Cho phép null khi chưa duyệt
  final int countDown;
  final double intersectionArea;
  final String intersectionForest;
  final bool createByCamera;
  final FarmlandState state;
  final List<Location>? locations;

  Farmland({
    String? userId,
    String? farmlandId,
    required this.farmlandName,
    required this.area,
    required this.registerDate,
    this.startDate,
    this.exprDate,
    this.countDown = 30,
    required this.intersectionArea,
    required this.intersectionForest,
    required this.createByCamera,
    required this.state,
    this.locations,
  }) : farmlandId = farmlandId ?? '',
       userId = userId ?? '';

  /// 🧮 Tự động tính số ngày còn lại (chỉ khi đã duyệt)
  int get countDownNum {
    if (exprDate == null) return 0;
    final now = DateTime.now();
    final remaining = exprDate!.difference(now).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Khi mới tạo
  factory Farmland.newPending({
    required String name,
    required double area,
    required double intersectionArea,
    required String intersectionForest,
    required bool createByCamera,
    required List<Location> locations,
  }) {
    return Farmland(
      farmlandName: name,
      area: area,
      registerDate: DateTime.now(),
      startDate: null,
      exprDate: null,
      intersectionArea: intersectionArea,
      intersectionForest: intersectionForest,
      createByCamera: createByCamera,
      state: FarmlandState.pending,
      locations: locations,
    );
  }

  /// Khi duyệt
  Farmland approve() {
    final now = DateTime.now();
    return Farmland(
      farmlandId: farmlandId,
      farmlandName: farmlandName,
      area: area,
      registerDate: registerDate,
      startDate: now,
      exprDate: now.add(const Duration(days: 30)),
      intersectionArea: intersectionArea,
      intersectionForest: intersectionForest,
      createByCamera: createByCamera,
      state: FarmlandState.approved,
      locations: locations,
    );
  }

  factory Farmland.fromJson(Map<String, dynamic> json) {
    return Farmland(
      userId: json['userId'] ?? '',
      farmlandId: json['farmlandId'] ?? '',
      farmlandName: json['farmlandName'] ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      registerDate: json['registerDate'] != null
          ? DateTime.parse(json['registerDate'])
          : DateTime.now(), // ✅ fallback nếu null
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      exprDate: json['exprDate'] != null
          ? DateTime.parse(json['exprDate'])
          : null,
      countDown: json['countDown'] ?? 30,
      intersectionArea: (json['intersectionArea'] as num?)?.toDouble() ?? 0.0,
      intersectionForest: json['intersectionForest'] ?? '',
      createByCamera: json['createByCamera'] ?? false,
      state: FarmlandStateExtension.fromString(json['state'] ?? 'pending'),
      locations: (json['locations'] as List<dynamic>? ?? [])
          .map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmlandId': farmlandId,
      'farmlandName': farmlandName,
      'area': area,
      'registerDate': registerDate.toIso8601String(),
      'startDate': startDate != null ? startDate!.toIso8601String() : null,
      'exprDate': exprDate != null ? exprDate!.toIso8601String() : null,
      'countDown': countDown,
      'intersectionArea': intersectionArea,
      'intersectionForest': intersectionForest,
      'createByCamera': createByCamera.toString(),
      'state': state.toShortString(),
      'locations': jsonEncode(
        locations?.map((loc) => loc.toJson()).toList() ?? [],
      ),
    };
  }

  List<Coordinate> toCoordinates() {
    return locations
            ?.map((loc) => Coordinate(loc.longitude, loc.latitude))
            .toList() ??
        [];
  }

  List<LatLng> toLatLng() {
    return locations
            ?.map((loc) => LatLng(loc.latitude, loc.longitude))
            .toList() ??
        [];
  }
}
