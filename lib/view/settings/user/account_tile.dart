import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/image_size.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/service/media/logo_service.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

class AccountTile extends StatelessWidget {
  final Account account;
  final Alignment alignment;
  final double height;
  final double maxWidth;

  const AccountTile({
    super.key,
    required this.account,
    this.alignment = Alignment.center,
    this.height = 40,
    this.maxWidth = 700,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minHeight: height,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (account.platform == SignInPlatform.google)
                      SizedBox(
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: LogoService.googleImageProvider(ImageSize.midi),
                          radius: 30,
                        ),
                      ),
                    if (account.platform == SignInPlatform.email)
                      SizedBox(
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: LogoService.wydLogoImageProvider(ImageSize.midi),
                          radius: 30,
                        ),
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.email,
                            style: TextStyle(fontSize: 24),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
