import 'package:flutter/material.dart';
import 'package:wyd_front/model/users/account.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';

class AccountTile extends StatelessWidget {
  final Account account;
  final Alignment alignment;
  final double height;
  final double maxWidth;

  const AccountTile({
    super.key,
    required this.account,
    this.alignment = Alignment.center,
    this.height = 50,
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
                    SizedBox(
                      child: CircleAvatar(
                        backgroundImage: ImageProviderService.wydLogoImageProvider(ImageSize.midi),
                        radius: 40,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.mail,
                            style: TextStyle(fontSize: 16),
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
