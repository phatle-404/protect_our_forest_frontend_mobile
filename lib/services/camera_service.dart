import 'package:camera/camera.dart';

class CameraDataService {
  static final CameraDataService _instance = CameraDataService._internal();
  factory CameraDataService() => _instance;
  CameraDataService._internal();

  final List<Map<String, dynamic>> _photoData = [];

  List<Map<String, dynamic>> get photoData => List.unmodifiable(_photoData);

  void addPhoto(XFile imageFile, double latitude, double longitude, DateTime? time) {
    _photoData.add({
      'imageFile': imageFile,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
    });
  }

  void clear() {
    _photoData.clear();
  }

  num count() {
    return _photoData.length;
  }
}
