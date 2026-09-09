class CustomSectionModel {
  final String id;
  final String title;
  final List<String> productIds;
  final bool isActive;
  final int sortOrder;

  CustomSectionModel({
    required this.id,
    required this.title,
    required this.productIds,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory CustomSectionModel.fromJson(Map<String, dynamic> json) {
    return CustomSectionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      productIds: json['productIds'] != null
          ? List<String>.from(json['productIds'])
          : [],
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
