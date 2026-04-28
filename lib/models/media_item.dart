class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnailAsset,
    required this.url,
  });

  final String id;
  final String title;
  final String type;
  final String thumbnailAsset;
  final String url;

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      thumbnailAsset: json['thumbnailAsset'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'thumbnailAsset': thumbnailAsset,
      'url': url,
    };
  }
}
