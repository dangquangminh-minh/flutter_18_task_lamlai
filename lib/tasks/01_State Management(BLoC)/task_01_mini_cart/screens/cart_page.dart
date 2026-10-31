import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_badge.dart';
import '../widgets/cart_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc(ProductService()) // để các widget dưới sd
        ..add(const LoadProductsEvent()), // tải dssp từ api
      child: const _CartView(),
    );
  }
}


class _CartView extends StatelessWidget {
  const _CartView();

  static const green = Color(0xFF207A55);
  static const dark = Color(0xFF20392B);

  // mở giỏ hàng từ dưới màn hình
  void _openCart(BuildContext context) {
    final bloc = context.read<CartBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      
      // 0 tạo bloc mới để tránh bị mất giỏ hàng đã chọn
      builder: (_) => BlocProvider.value(  // BlocProvider.value truyền CartBloc hiện tại sang bottom sheet.
        value: bloc,
        child: const CartSheet(),
      ),
    );
  }

  // banner g.thiệu sp
  Widget _banner(CartState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF176846), Color(0xFF35A376)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [          
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME TO MINI SHOP',
                      style: TextStyle(
                        
                        color: Color(0xFFD6F3E1),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Khám phá sản phẩm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Thêm những món bạn thích vào giỏ hàng.',
                      style: TextStyle(
                        color: Color(0xFFE2F4E9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 8),

                // lấy slg sp từ state
                Text(
                  '${state.products.length} sản phẩm đang hiển thị',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // giao diện đang chờ khi đợi trả dl
  Widget _loadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: green),
          SizedBox(height: 18),
          Text(
            'Đang tải sản phẩm...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Vui lòng chờ trong giây lát',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // giao diện thông báo lỗi khi api lỗi
  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFDA7469),
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 18),

              // nhấn thử lại thì gửi event để bloc gọi lại api
              FilledButton.icon(
                onPressed: () {

                  context.read<CartBloc>().add(
                    const LoadProductsEvent(),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hiển thị danh sách sản phẩm khi API trả về thành công.
  Widget _productList(CartState state) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),

      // Cộng thêm 1 phần tử vì vị trí đầu tiên dành cho banner.
      itemCount: state.products.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _banner(state),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 15),
                child: Row(
                  children: [
                    Text(
                      'Danh sách sản phẩm',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Nhấn + để thêm',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Vì index = 0 là banner nên lấy sản phẩm ở index - 1.
        final product = state.products[index - 1];

        return ProductCard(
          product: product,

          // Lấy số lượng hiện tại của sản phẩm từ CartState.
          quantity: state.quantityOf(product.id),

          // Khi nhấn +, gửi AddProductEvent đến CartBloc.
          onAdd: () {
            context.read<CartBloc>().add(
              AddProductEvent(product),
            );
          },

          // Khi nhấn -, gửi RemoveProductEvent đến CartBloc.
          onRemove: () {
            context.read<CartBloc>().add(
              RemoveProductEvent(product),
            );
          },
        );
      },
    );
  }

  // Thanh giỏ hàng cố định ở cuối màn hình.
  Widget _cartBottomBar(BuildContext context, int count) {
    // Khi chưa chọn sản phẩm thì ẩn thanh này.
    if (count == 0) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Row(
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: green,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giỏ hàng của bạn',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '$count món đã chọn',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => _openCart(context),
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 19,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xem giỏ hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: dark,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 66,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BÀI 01 · STATE MANAGEMENT',
              style: TextStyle(
                fontSize: 10,
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Mini Cart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Nút tải lại để kiểm tra trạng thái loading/error.
          IconButton(
            tooltip: 'Tải lại sản phẩm',
            onPressed: () {
              context.read<CartBloc>().add(
                const LoadProductsEvent(),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),

          // Badge góc phải hiển thị tổng số sản phẩm đang chọn.
          CartBadge(onPressed: () => _openCart(context)),
          const SizedBox(width: 8),
        ],
      ),

      // BlocBuilder theo dõi CartState và chọn giao diện tương ứng.
      // loading: vòng xoay; failure: thông báo lỗi;
      // success: danh sách 8 sản phẩm lấy từ API.
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.initial ||
              state.status == CartStatus.loading) {
            return _loadingView();
          }

          if (state.status == CartStatus.failure) {
            return _errorView(context, state.errorMessage);
          }

          // Trường hợp API thành công nhưng trả về danh sách rỗng.
          if (state.products.isEmpty) {
            return const Center(
              child: Text('Chưa có sản phẩm nào'),
            );
          }

          return _productList(state);
        },
      ),

      // BlocSelector chỉ lấy totalQuantity từ CartState.
      // Thanh giỏ hàng không cần rebuild nếu chỉ có status
      // hoặc errorMessage thay đổi mà số lượng vẫn như cũ.
      bottomNavigationBar: BlocSelector<CartBloc, CartState, int>(
        selector: (state) => state.totalQuantity,
        builder: (context, count) {
          return _cartBottomBar(context, count);
        },
      ),
    );
  }
}