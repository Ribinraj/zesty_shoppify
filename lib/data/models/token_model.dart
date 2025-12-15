class UserModel {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userMobile; // optional
  final String userToken;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userMobile, // optional
    required this.userToken,
  });

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      userMobile: json['userMobile'], // may be null
      userToken: json['userToken'],
    );
  }

  /// To JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      if (userMobile != null) 'userMobile': userMobile, // send only if present
      'userToken': userToken,
    };
  }
}
