

class Confirm{
  int userId = -1;
  bool confirmed = false;

  Confirm(this.userId, this.confirmed);

  Map<String, dynamic> toJson(){
    return{
      'id': userId,
      'confirmed': confirmed, 
    };
  }

  factory Confirm.fromJson(Map<String, dynamic> json){
    return switch (json) {
      {
        'userId': int userid,
        'confirmed': bool confirmed,
      } => Confirm(
        userid,
        confirmed,
      ), 
      _ => throw const FormatException('Failed to decode confirm')
    };
  }

}