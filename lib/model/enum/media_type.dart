// these must be the same name as the object storage buckets
enum MediaType {
  events,
  profiles,
}

extension MediaTypesExtension on MediaType {
  int get index {
    return MediaType.values.indexOf(this);
  }
}