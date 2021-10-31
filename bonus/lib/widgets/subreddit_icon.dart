import 'package:flutter/material.dart';

Widget subredditIcon(String? communityIcon, String? iconImg) {
  if (communityIcon != null || iconImg != null) {
    return CircleAvatar(
      backgroundImage: NetworkImage(communityIcon ?? iconImg!),
      radius: 40.0,
    );
  } else {
    return const CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: NetworkImage(
          'https://www.redditstatic.com/avatars/avatar_default_02_0DD3BB.png'),
      radius: 40.0,
    );
  }
}
