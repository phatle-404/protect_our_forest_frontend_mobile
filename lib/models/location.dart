import 'package:camera/camera.dart';
import 'dart:convert';

class Location {
  final double latitude; //kinh độ
  final double longitude; //vĩ độ
  final DateTime timeTakeLocation; //Thời gian chụp
  final XFile? imageFile; //Đường dẫn hình ảnh, có thể null

  Location({
    required this.latitude,
    required this.longitude,
    required this.timeTakeLocation,
    this.imageFile,
  });

  // Getter để kiểm tra có ảnh hay không, thay thế cho `hasPicture`
  bool get hasPicture => imageFile != null && imageFile!.path.isNotEmpty;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timeTakeLocation: DateTime.parse(json['timeTakeLocation']),
      imageFile: XFile(json['imagePath']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timeTakeLocation': timeTakeLocation.toIso8601String(),
      'imagePath': imageFile?.path,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
