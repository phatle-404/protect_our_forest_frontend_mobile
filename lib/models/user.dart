class User {
  final String userId;
  final String userName;
  final String email;
  final String phoneNumber;
  final String password;
  final String createdAt;
  final String district;
  final String province;
  final String? role;
  final String? status;

  User({
    required this.userId,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.createdAt,
    required this.district,
    required this.province,
    this.role,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      createdAt: json['createdOn']?.toString() ?? '',
      district: json['address']?['district']?.toString() ?? '',
      province: json['address']?['province']?.toString() ?? '',
      role: json['role']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'createdOn': createdAt,
      'address': {'district': district, 'province': province},
      'role': role,
      'status': status,
    };
  }
}
