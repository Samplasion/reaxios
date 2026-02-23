import 'package:axios_api/utils/Encrypter.dart';

class AxiosAccount {
  final String schoolID;
  final String userID;
  final String userPassword;

  const AxiosAccount(this.schoolID, this.userID, this.userPassword);

  @override
  toString() {
    return "AxiosInstance(school: $schoolID, uid: $userID, password: $userPassword)";
  }

  Map<String, dynamic> toJson() {
    return {
      "schoolID": schoolID,
      "userID": userID,
      "userPassword": Encrypter.encrypt(userPassword),
    };
  }

  factory AxiosAccount.fromJson(Map<String, dynamic> json) {
    return AxiosAccount(
      json["schoolID"] as String,
      json["userID"] as String,
      Encrypter.decrypt(json["userPassword"] as String),
    );
  }
}
