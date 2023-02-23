import 'package:json_annotation/json_annotation.dart';
import 'package:axios_api/interfaces/AbstractJson.dart';
import 'package:axios_api/utils/DateSerializer.dart';

part 'Login.g.dart';

@JsonSerializable()
class Login implements AbstractJson {
  // String authExpire;
  String avatar;
  // Map<String,String> crud;
  @JsonKey(name: "customerId")
  String schoolID;
  @JsonKey(name: "customerName")
  String schoolName;
  @JsonKey(name: "customerTitle")
  String schoolTitle;

  @JsonKey(name: "dataNascita")
  @DateSerializer()
  DateTime birthday;
  // String epDemoURL,
  //     epURL;
  // bool fbPrivacyCustomerSatisfaction,
  //     fbPrivacyReadedPolicy,
  //     fbPrivacyUseMail,
  //     fbPrivacyUseMailTerzeParti,
  //     fbPrivacyUseMobile,
  //     fbPrivacyUseMobileTerzeParti,
  //     fbPubblicitaEsterna,
  //     fbPubblicitaInterna;
  // String jsURL;
  // String loginStatus;
  // Mailbox[] mailboxes;
  @JsonKey(name: "nome")
  String firstName;
  @JsonKey(name: "cognome")
  String lastName;

  int id;
  // String otpKey;
  // bool sidebar;

  @JsonKey(name: "userId")
  String userID;
  @JsonKey(name: "userPassword")
  String password;
  @JsonKey(name: "userPinRe")
  String pin;

  @JsonKey(name: "gruppiAppartenenza")
  String kind;

  @JsonKey(name: "usersession")
  String sessionUUID;

  Login(
      {required this.avatar,
      required this.birthday,
      required this.schoolID,
      required this.schoolName,
      required this.schoolTitle,
      required this.id,
      required this.firstName,
      required this.lastName,
      required this.userID,
      required this.password,
      required this.pin,
      required this.kind,
      required this.sessionUUID});

  static empty() {
    return Login(
      avatar: "",
      birthday: DateTime.now(),
      schoolID: "",
      schoolName: "",
      schoolTitle: "",
      id: 0,
      firstName: "",
      lastName: "",
      userID: "",
      password: "",
      pin: "",
      kind: "",
      sessionUUID: "",
    );
  }

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);

  Map<String, dynamic> toJson() => _$LoginToJson(this);
}
