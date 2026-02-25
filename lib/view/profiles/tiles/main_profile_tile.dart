import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/image_size.dart';
import 'package:wyd_front/model/profiles/external_imports.dart';
import 'package:wyd_front/model/users/detailed_profile.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';
import 'package:wyd_front/service/media/logo_service.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';
import 'package:wyd_front/view/profiles/profile_editor.dart';
import 'package:wyd_front/view/profiles/tiles/main_tile_options.dart';
import 'package:wyd_front/view/widget/view/custom_page.dart';

class MainProfileTile extends StatelessWidget {
  final DetailedProfile? profile;
  final Alignment alignment;
  final double height;
  final double maxWidth;

  const MainProfileTile({
    super.key,
    required this.profile,
    this.alignment = Alignment.center,
    this.height = 100,
    this.maxWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    var exists = profile != null;

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
                child: GestureDetector(
                  onTap: () {
                    if (exists) {
                      showCustomPage(context, ProfileEditor(profile: profile!));
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: profile?.color ?? Colors.green,
                              width: 5.0,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: ImageProviderService.getImageProvider(),
                            radius: 40,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (exists && profile!.imports != null && profile!.imports!.isNotEmpty)
                              _buildImportedLogos(profile!.imports!),
                            Text(
                              exists ? profile!.name : "Loading...",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              exists ? profile!.tag : "Loading...",
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (exists) MainTileOptions(profile: profile!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportedLogos(List<ExternalImports> imports) {
    final filteredImports = imports.where((i) => i.importType != SignInPlatform.email).toList();

    if (filteredImports.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: filteredImports.map((import) {
        if (import.importType == SignInPlatform.google) {
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Image(
              image: LogoService.importProviderLogo(SignInPlatform.google, ImageSize.mini),
              width: 18,
              height: 18,
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
}
