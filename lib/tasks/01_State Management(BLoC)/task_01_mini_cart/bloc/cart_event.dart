import 'package:equatable/equatable.dart';
import '../models/product_model.dart';


abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}


// gửi sk khi lấy dssp 
class LoadProductsEvent extends CartEvent {
  const LoadProductsEvent();
}

// nhấn nút thêm sp
class AddProductEvent extends CartEvent {
  final ProductModel product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}



// nhấn nút giảm slg 
class RemoveProductEvent extends CartEvent {
  final ProductModel product;

  const RemoveProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

// xóa hết sp ra khỏi giỏ
class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}