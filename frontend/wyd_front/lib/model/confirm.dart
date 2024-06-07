

class Confirm{
  int id = -1;
  bool confirmed = false;

  Confirm(int userId, bool confirmd){
    id = userId;
    confirmed = confirmd;
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'confirmed': confirmed, 
    };
  }

  factory Confirm.fromJson(Map<String, dynamic> json){
    return switch (json) {
      {
        'UserId': int userid,
        'confirmed': bool confirmed,
      } => Confirm(
        userid,
        confirmed,
      ), 
      _ => throw const FormatException('Failed to decode confirm')
    };
  }

}