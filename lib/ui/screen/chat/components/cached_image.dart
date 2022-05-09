// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final bool isRound;
  final double radius;
  final double? height;
  final double? width;

  final BoxFit fit;

  final String noImageAvailable =
      'https://scontent.fdad3-1.fna.fbcdn.net/v/t39.30808-6/279543022_2095197133973696_23291584916735861_n.jpg?_nc_cat=110&ccb=1-6&_nc_sid=09cbfe&_nc_ohc=CYA4f6M4gwYAX_bmv-X&_nc_ht=scontent.fdad3-1.fna&oh=00_AT9_Cqv2Uc4DiMHm8w6kAoG89OBseDo88rAML1kSIJs_fA&oe=627ABA33';

  // ignore: use_key_in_widget_constructors
  const CachedImage(
    
    this.imageUrl, {
    this.isRound = false,
    this.radius = 0,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isRound ? 50 : radius),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, imageUrl) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, imageUrl, error) =>
                Image.network(noImageAvailable, fit: BoxFit.cover),
          ),
        ),
      );
    } catch (e) {
      print(e);
      return Image.network(noImageAvailable, fit: BoxFit.cover);
    }
  }
}