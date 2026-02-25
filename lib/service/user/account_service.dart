import 'package:wyd_front/API/User/account_dto.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';
import 'package:wyd_front/state/user/account_storage.dart';

class AccountService {
  static void saveAccounts(Set<AccountDto> dtos) {
    var accounts = dtos.map((dto) => Account.fromDto(dto)).toSet();
    AccountStorage().saveAccounts(accounts);
  }

  static Future<Set<Account>> getAccountsThatCanImport() async {
    var accounts = await AccountStorage().getAccounts();

    return accounts.where((a) => a.importedBy == null && a.platform != SignInPlatform.email).toSet();
  }
}
