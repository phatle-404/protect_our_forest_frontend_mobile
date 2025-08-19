import 'package:protect_our_forest/models/farmland.dart';

class Request {
  final String userId;
  final String farmlandId;
  final String action; // create / update / delete
  final Farmland? newFarmland;
  final Farmland? oldFarmland;
  final String message;

  Request({
    required this.userId,
    required this.farmlandId,
    required this.action,
    this.newFarmland,
    this.oldFarmland,
    required this.message,
  });

  /// 📦 Parse từ JSON
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      userId: json['userId'] ?? '',
      farmlandId: json['farmlandId'] ?? '',
      action: json['action'] ?? '',
      newFarmland: json['newFarmland'] != null && json['newFarmland'] is Map
          ? Farmland.fromJson(json['newFarmland'])
          : null,
      oldFarmland: json['oldFarmland'] != null && json['oldFarmland'] is Map
          ? Farmland.fromJson(json['oldFarmland'])
          : null,
      message: json['message'] ?? '',
    );
  }

  /// 📤 Convert sang JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'userId': userId,
      'farmlandId': farmlandId,
      'action': action,
      'message': message,
    };

    if (newFarmland != null) {
      data['newFarmland'] = newFarmland!.toJson();
    }
    if (oldFarmland != null) {
      data['oldFarmland'] = oldFarmland!.toJson();
    }

    return data;
  }

  /// 🔹 Tạo request "Tạo mới"
  factory Request.create({
    required String userId,
    required String farmlandId,
    required Farmland newFarmland,
    String message = '',
  }) {
    return Request(
      userId: userId,
      farmlandId: farmlandId,
      action: 'create',
      newFarmland: newFarmland,
      message: message,
    );
  }

  /// 🔹 Tạo request "Xóa"
  factory Request.delete({
    required String userId,
    required String farmlandId,
    required Farmland oldFarmland,
    String message = '',
  }) {
    return Request(
      userId: userId,
      farmlandId: farmlandId,
      action: 'delete',
      oldFarmland: oldFarmland,
      message: message,
    );
  }

  /// 🔹 Tạo request "Cập nhật"
  factory Request.update({
    required String userId,
    required String farmlandId,
    required Farmland newFarmland,
    required Farmland oldFarmland,
    String message = '',
  }) {
    return Request(
      userId: userId,
      farmlandId: farmlandId,
      action: 'update',
      newFarmland: newFarmland,
      oldFarmland: oldFarmland,
      message: message,
    );
  }
}
