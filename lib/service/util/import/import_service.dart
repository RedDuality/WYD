import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wyd_front/API/Profile/profile_api.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/service/util/authentication/google_sing_in_service.dart';

class ImportService {
  static Future<void> importFromGoogleCalendar(Account account) async {
    if (GoogleSignInService.isGoogleSignInInitialized == false) {
      throw "There was an error while initializing google services";
    }

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignInService.signInForAccount(account.email);
    } catch (e) {
      debugPrint('Google Sign-In failed during import: $e');
      rethrow;
    }

    final authClient = googleUser.authorizationClient;

    const scopes = [
      'https://www.googleapis.com/auth/calendar.events',
      'email',
    ];

    try {
      GoogleSignInClientAuthorization? authorization = await authClient.authorizationForScopes(scopes);

      if (authorization == null) {
        // No existing grant — request consent interactively.
        debugPrint(
          'No existing calendar authorization for ${account.email}, requesting...',
        );
        authorization = await authClient.authorizeScopes(scopes);
      }

      final String accessToken = authorization.accessToken;
      debugPrint('Got calendar access token for ${account.email}');

      // ── Step 4: Hand token to backend ──────────────────────────────────────
      // TODO: call your backend API here, e.g.:
      // await CalendarSyncService.syncFromGoogle(account, accessToken);

      await ProfileAPI().importEventsFromPlatform(accessToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('User canceled the calendar authorization.');
        return;
      }
      debugPrint('Google Sign-In error during authorization: ${e.code} — ${e.description}');
      rethrow;
    } catch (e) {
      debugPrint('Failed to get calendar access token for ${account.email}: $e');
      rethrow;
    }
  }
}
