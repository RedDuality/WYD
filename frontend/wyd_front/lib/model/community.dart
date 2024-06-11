import 'package:wyd_front/model/user.dart';

class Community {
  int id = -1;
  String name = "";
  List<User>? users = [];

  Community({
    this.id = -1,
    this.name = "",
    this.users,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id" : int id,
        "name" : String name,
        "users" : List<dynamic>? users,
      } => Community(
        id : id, 
        name : name, 
        users : users != null ? users.map((user) => User.fromJson(user as Map<String,dynamic>)).toList() : <User>[]
        ),
      _ => throw const FormatException('Failed to decode community')
    };
  }
}
