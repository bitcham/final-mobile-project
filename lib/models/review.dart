class Review {
  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.content,
  });

  final String id;
  final String authorName;
  final double rating;
  final String content;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'rating': rating,
      'content': content,
    };
  }
}
