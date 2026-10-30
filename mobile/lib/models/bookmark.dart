class Bookmark {
  final String id;
  final String url;
  final String platform;
  final String? title;
  final String? summary;
  final List<String> keyPoints;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;

  const Bookmark({
    required this.id,
    required this.url,
    required this.platform,
    this.title,
    this.summary,
    this.keyPoints = const [],
    this.tags = const [],
    required this.status,
    required this.createdAt,
    this.processedAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isProcessing => status.toLowerCase() == 'processing';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!;
    }
    if (isProcessing || isPending) {
      return 'Analyzing bookmark content...';
    }
    return url;
  }

  String get platformEmoji {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return '📺';
      case 'twitter':
      case 'x':
        return '🐦';
      case 'instagram':
        return '📷';
      case 'spotify':
        return '🎵';
      case 'reddit':
        return '🔴';
      case 'github':
        return '💻';
      case 'medium':
        return '📝';
      case 'tiktok':
        return '🎬';
      default:
        return '🌐';
    }
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      platform: json['platform'] as String? ?? 'webpage',
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      keyPoints: json['key_points'] != null
          ? List<String>.from(json['key_points'] as List)
          : const [],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'platform': platform,
      'title': title,
      'summary': summary,
      'key_points': keyPoints,
      'tags': tags,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }

  Bookmark copyWith({
    String? id,
    String? url,
    String? platform,
    String? title,
    String? summary,
    List<String>? keyPoints,
    List<String>? tags,
    String? status,
    DateTime? createdAt,
    DateTime? processedAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}

