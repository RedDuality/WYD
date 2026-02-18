import 'package:web/web.dart' as web;
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

void applyWebConfigImpl(String name, List<SignInPlatform> platforms, String googleClientId) {
  var meta = web.document.querySelector('meta[name=$name]') as web.HTMLMetaElement?;

  if (meta == null) {
    meta = web.document.createElement('meta') as web.HTMLMetaElement;
    meta.name = name;
    web.document.head?.appendChild(meta);
  }

  meta.content = googleClientId;
}
