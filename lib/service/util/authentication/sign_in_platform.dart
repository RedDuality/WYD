enum SignInPlatform {
  email,
  google;

  /// Converts a String to a SignInPlatform enum value.
  static SignInPlatform fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'google':
        return SignInPlatform.google;
      case 'email':
        return SignInPlatform.email;
      default:
        // Defaulting to email, or you could throw an ArgumentError
        return SignInPlatform.email;
    }
  }
}
