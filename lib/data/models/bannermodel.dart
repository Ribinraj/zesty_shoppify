// lib/domain/models/banner_model.dart

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String actionText;
  final String? actionHandle; // Collection handle to navigate to
  final int order; // For sorting banners

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.actionHandle,
    this.order = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      actionText: json['actionText']?.toString() ?? 'Shop Now',
      actionHandle: json['actionHandle']?.toString(),
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'actionText': actionText,
      'actionHandle': actionHandle,
      'order': order,
    };
  }
}