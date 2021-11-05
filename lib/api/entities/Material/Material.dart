import 'dart:convert';

import 'package:html/parser.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/interfaces/AbstractJson.dart';
import 'package:reaxios/api/utils/DateSerializer.dart';

part 'Material.g.dart';

String stripHtml(String str) => parseFragment(str).text ?? "";

@JsonSerializable()
class MaterialData implements AbstractJson {
  @JsonKey(name: 'idContent')
  int id;
  @JsonKey(name: 'descrizione')
  String description;
  @JsonKey(name: 'testo')
  String rawText;
  String get text {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stripHtml(stringToBase64.decode(rawText));
  }

  @JsonKey(name: 'data')
  @DateSerializer()
  DateTime date;
  @JsonKey(name: 'url')
  String url;
  @JsonKey(name: 'file_name')
  String fileName;
  @JsonKey(name: 'file_url')
  String fileUrl;

  bool get isLink => url.isNotEmpty;

  MaterialData({
    required this.id,
    required this.description,
    required this.rawText,
    required this.date,
    required this.url,
    required this.fileName,
    required this.fileUrl,
  });

  factory MaterialData.fromJson(Map<String, dynamic> json) =>
      _$MaterialDataFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialDataToJson(this);

  @override
  String toString() {
    return 'MaterialData{id: $id, description: $description, text: $text, date: $date, url: $url, fileName: $fileName, fileUrl: $fileUrl}';
  }

  static MaterialData test([bool isLink = true]) {
    return MaterialData(
      id: 1,
      description: 'test',
      // The string "test" in base 64
      rawText: 'dGVzdA==',
      date: DateTime.now(),
      url: isLink ? 'https://samplasion.js.org' : '',
      fileName: 'test',
      fileUrl: isLink ? '' : 'https://samplasion.js.org',
    );
  }

  static MaterialData empty() {
    return MaterialData(
      id: 0,
      description: '',
      rawText: '',
      date: DateTime.now(),
      url: '',
      fileName: '',
      fileUrl: '',
    );
  }
}

@JsonSerializable()
class MaterialFolderData implements AbstractJson {
  @JsonKey(name: 'idFolder')
  int id;
  @JsonKey(name: 'descrizione')
  String description;
  @JsonKey(name: 'note')
  String rawNote;
  String get note {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stripHtml(stringToBase64.decode(rawNote));
  }

  @JsonKey(name: 'path')
  String path;

  @JsonKey(ignore: true)
  late Axios session;
  @JsonKey(ignore: true)
  late MaterialTeacherData teacher;

  MaterialFolderData({
    required this.id,
    required this.description,
    required this.rawNote,
    required this.path,
  });

  factory MaterialFolderData.fromJson(Map<String, dynamic> json) =>
      _$MaterialFolderDataFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialFolderDataToJson(this);

  MaterialFolderData setSession(Axios session) {
    this.session = session;
    return this;
  }

  MaterialFolderData setTeacher(MaterialTeacherData teacher) {
    this.teacher = teacher;
    return this;
  }

  Future<List<MaterialData>> getMaterials() async {
    return await session.getMaterialDetails(
        this.teacher.id, this.id.toString());
  }

  @override
  String toString() {
    return 'MaterialFolderData{id: $id, description: $description, note: $note, path: $path}';
  }

  static MaterialFolderData test() {
    return MaterialFolderData(
      id: 1,
      description: 'test',
      // The string "test" in base64
      rawNote: 'dGVzdA==',
      path: 'test',
    );
  }

  static MaterialFolderData empty() {
    return MaterialFolderData(
      id: 0,
      description: '',
      rawNote: '',
      path: '',
    );
  }
}

@JsonSerializable()
class MaterialTeacherData implements AbstractJson {
  @JsonKey(name: 'idDocente')
  String id;
  @JsonKey(name: 'nome')
  String name;
  @JsonKey(name: 'materie')
  String subjects;
  @JsonKey(name: 'folders')
  List<MaterialFolderData> folders;

  MaterialTeacherData({
    required this.id,
    required this.name,
    required this.subjects,
    required this.folders,
  });

  factory MaterialTeacherData.fromJson(Map<String, dynamic> json) =>
      _$MaterialTeacherDataFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialTeacherDataToJson(this);

  @override
  String toString() {
    return 'MaterialFolderData{id: $id, name: $name, subjects: $subjects, folders: $folders}';
  }

  static MaterialTeacherData test() {
    return MaterialTeacherData(
      id: 'c95e625d-edf8-4f86-84a6-d421c27fc445',
      name: 'Giovanni',
      subjects: 'Matematica, Fisica, Chimica',
      folders: [],
    );
  }

  static MaterialTeacherData empty() {
    return MaterialTeacherData(
      id: '',
      name: '',
      subjects: '',
      folders: [],
    );
  }
}

@JsonSerializable()
class APIMaterials {
  String idAlunno;
  List<MaterialTeacherData> docenti;

  APIMaterials({
    required this.idAlunno,
    required this.docenti,
  });

  factory APIMaterials.fromJson(Map<String, dynamic> json) =>
      _$APIMaterialsFromJson(json);

  Map<String, dynamic> toJson() => _$APIMaterialsToJson(this);
}
