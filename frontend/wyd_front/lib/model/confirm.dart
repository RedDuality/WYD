

class Confirm{
  int id = -1;
  bool confirmed = false;

  Confirm(int id, bool confirmed){
    id = id;
    confirmed = confirmed;
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