import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart_item_model.dart';
import '../services/product_service.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ProductService _productService;

  CartBloc(this._productService) : super(const CartState()) {
    on<LoadProductsEvent>(_loadProducts);
    on<AddProductEvent>(_addProduct);
    
    on<RemoveProductEvent>(_removeProduct);
    on<ClearCartEvent>(_clearCart);
  }

  Future<void> _loadProducts(
    LoadProductsEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(
      status: CartStatus.loading,
      errorMessage: '',
    ));
    await Future.delayed(const Duration(seconds: 2));

    try {
      final products = await _productService.fetchProducts();

      emit(state.copyWith(
        status: CartStatus.success,
        products: products,
      ));
    } catch (error) {
      debugPrint('Lỗi tải sản phẩm: $error');

      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: 'Không tải được sản phẩm. Vui lòng thử lại.',
      ));
    }
  }

  void _addProduct(
    AddProductEvent event,
    Emitter<CartState> emit,
  ) {
    // Tạo list mới để không sửa trực tiếp dữ liệu của state cũ.
    final items = List<CartItemModel>.from(state.items);

    final index = items.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (index == -1) {
      items.add(CartItemModel(
        product: event.product,
        quantity: 1,
      ));
    } else {
      final oldItem = items[index];
      items[index] = oldItem.copyWith(
        quantity: oldItem.quantity + 1,
      );
    }

    emit(state.copyWith(items: items));
  }

  void _removeProduct(
    RemoveProductEvent event,
    Emitter<CartState> emit,
  ) {
    final items = List<CartItemModel>.from(state.items);

    final index = items.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (index == -1) return;

    final oldItem = items[index];

    if (oldItem.quantity > 1) {
      items[index] = oldItem.copyWith(
        quantity: oldItem.quantity - 1,
      );
    } else {
      // số lượng còn 1 mà tiếp tục giảm thì bỏ sản phẩm khỏi giỏ luôn
      items.removeAt(index);
    }

    emit(state.copyWith(items: items));
  }

  void _clearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) {
    emit(state.copyWith(items: []));
  }
}