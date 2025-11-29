// these must be the same name as the object storage buckets
enum MyMediaType {
  events,
  profiles,
}

extension MediaTypesExtension on MyMediaType {
  int get index {
    return MyMediaType.values.indexOf(this);
  }
}