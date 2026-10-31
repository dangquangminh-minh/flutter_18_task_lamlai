import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String title;
  final String body;

  const ProductModel({
    required this.id,
    required this.title,
    required this.body,
  });


  // chuyển một object json thành ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  @override
  List<Object?> get props => [id, title, body];
}