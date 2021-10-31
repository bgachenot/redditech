class Preview {
  final bool enabled;
  final String source_url;
  final int source_width;
  final int source_height;
  final bool reddit_video_preview;
  final String? reddit_video_url;

  Preview({
    required this.enabled,
    required this.source_url,
    required this.source_width,
    required this.source_height,
    required this.reddit_video_preview,
    required this.reddit_video_url,
  });
}
