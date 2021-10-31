import 'package:flutter/material.dart';

Widget subredditBanner(String? mobileBannerImage, String? bannerImg,
    String? bannerBackgroundImage) {
  if (mobileBannerImage != null ||
      bannerImg != null ||
      bannerBackgroundImage != null) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              mobileBannerImage ?? bannerImg ?? bannerBackgroundImage!),
          fit: BoxFit.cover,
        ),
      ),
    );
  } else {
    return Container(
      height: 100,
      color: Colors.blueAccent,
    );
  }
}
