import 'package:flutter/material.dart';

Widget iconWidget(String? communityIcon, String? iconImg) {
  if (communityIcon != null) {
    return Image.network(communityIcon);
  }
  if (iconImg != null) {
    return Image.network(iconImg);
  }
  return Image.network(
    'https://b.thumbs.redditmedia.com/aUQZr4O4EasbsqrmhZ7JdJUvHGX-mova9SPT2QwlINs.png',
    color: Colors.grey[400],
  );
}
