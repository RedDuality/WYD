// ignore_for_file: non_constant_identifier_names

class LoginDto{
  String mail = "";
  String password = "";

  LoginDto(String m, String p){
    mail = m;
    password = p;
  }

    Map<String, dynamic> toJson(){
    return{
      'Mail': mail,
      'Password': password, 
    };
  }
}