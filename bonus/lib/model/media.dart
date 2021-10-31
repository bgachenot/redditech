class Media {
  final bool reddit_video;
  final bool youtube_video;
  final bool reddit_gif;
  final String? reddit_video_url;
  final int? reddit_video_height;
  final int? reddit_video_width;
  final int? reddit_video_duration;

  Media(
      {required this.reddit_video,
      required this.youtube_video,
      required this.reddit_gif,
      required this.reddit_video_url,
      required this.reddit_video_height,
      required this.reddit_video_width,
      required this.reddit_video_duration});
}
