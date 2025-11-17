import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rantipay_app/core/rantipay/gaps.dart';
import 'package:rantipay_app/core/rantipay/sizes.dart';



class VideoButton extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Color? color;

  const VideoButton({
    super.key,
    required this.icon,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaIcon(
          icon,
          color: color ?? Colors.white,
          size: Sizes.size32,
        ),
        Gaps.v5,
        if (text != null)
          Text(
            text!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
          )
        else
          Container(),
      ],
    );
  }
}
