import 'package:equatable/equatable.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<ProductModel> products;
  final List<CartItemModel> items;
  final String errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.products = const [],
    this.items = const [],
    this.errorMessage = '',
  });



  // tổng slg 
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  int quantityOf(int productId) {
    for (final item in items) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }




  CartState copyWith({
    CartStatus? status,
    List<ProductModel>? products,
    List<CartItemModel>? items,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      products: products ?? this.products,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, items, errorMessage];
}