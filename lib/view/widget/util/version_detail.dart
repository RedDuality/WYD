import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionDetail extends StatefulWidget {
  const VersionDetail({super.key});

  @override
  State<VersionDetail> createState() => _VersionDetailState();
}

class _VersionDetailState extends State<VersionDetail> {
  String _version = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = "${packageInfo.version}+${packageInfo.buildNumber}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 3.0),
      child: Text(
        _version,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}
