import 'package:wyd_front/API/User/account_dto.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/state/user/account_storage.dart';

class AccountService {
  static void saveAccounts(Set<AccountDto> dtos){
    var accounts = dtos.map((dto) => Account.fromDto(dto)).toSet();
    AccountStorage().saveAccounts(accounts);
  }
}