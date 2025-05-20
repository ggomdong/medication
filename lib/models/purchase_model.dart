import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String id;
  final String userId;
  final String itemName;
  final int price;
  final String image;
  final DateTime purchasedAt;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.price,
    required this.image,
    required this.purchasedAt,
  });

  /// Firestore에서 불러올 때 (문서 ID 포함)
  factory PurchaseModel.fromJson(Map<String, dynamic> json, String docId) {
    return PurchaseModel(
      id: docId,
      userId: json['userId'] ?? '',
      itemName: json['itemName'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
      purchasedAt: (json['purchasedAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 저장할 때
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'itemName': itemName,
      'price': price,
      'image': image,
      'purchasedAt': purchasedAt,
    };
  }

  /// ID 부여용 copyWith
  PurchaseModel copyWith({String? id}) {
    return PurchaseModel(
      id: id ?? this.id,
      userId: userId,
      itemName: itemName,
      price: price,
      image: image,
      purchasedAt: purchasedAt,
    );
  }
}
