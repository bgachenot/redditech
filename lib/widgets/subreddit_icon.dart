import 'package:flutter/material.dart';

Widget iconWidget(String? community_icon, String? icon_img) {
  if (community_icon != null) {
    return Image.network(community_icon);
  }
  if (icon_img != null) {
    return Image.network(icon_img);
  }
  return Image.network(
    'https://b.thumbs.redditmedia.com/aUQZr4O4EasbsqrmhZ7JdJUvHGX-mova9SPT2QwlINs.png',
    color: Colors.grey[400],
  );
}
