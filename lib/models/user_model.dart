

class UserDataModel {
  UserDataModel({
    required this.uId,
    required this.username,
    required this.email,
    required this.token,
    required this.phone,
    required this.userKind,
  });

  late final String uId;
  late final String username;
  late final String email;
  late final String token;
  late final String phone;
  late final String userKind;

  factory UserDataModel.fromJson(Map<String, dynamic>? json) {
    return UserDataModel(
      uId: json?['uId'] ?? '',
      username: json?['username'] ?? '',
      email: json?['email'] ?? '',
      token: json?['token'] ?? '',
      phone: json?['phone'] ?? '',
      userKind: json?['userKind'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'username': username,
      'email': email,
      'token': token,
      'phone': phone,
      'userKind': userKind,
    };
  }
}