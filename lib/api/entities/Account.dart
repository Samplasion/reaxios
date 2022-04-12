import 'package:reaxios/api/utils/Encrypter.dart';

class AxiosAccount {
  final String schoolID;
  final String userID;
  final String userPassword;

  const AxiosAccount(this.schoolID, this.userID, this.userPassword);

  toString() {
    return "AxiosInstance(school: ${this.schoolID}, uid: ${this.userID}, password: ${this.userPassword})";
  }

  Map<String, dynamic> toJson() {
    return {
      "schoolID": this.schoolID,
      "userID": this.userID,
      "userPassword": Encrypter.encrypt(this.userPassword),
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
