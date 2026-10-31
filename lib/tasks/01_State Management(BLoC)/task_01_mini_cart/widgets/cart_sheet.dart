import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  static const green = Color(0xFF207A55);

  // nút +/- 
  Widget _changeButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFEAF4ED),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: green),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      height: MediaQuery.sizeOf(context).height * 0.74,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        top: false,

        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final items = state.items;

            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFE6E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_rounded, color: green),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Giỏ hàng của tôi',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22372C),
                          ),
                        ),
                      ),

                      // chỉ đc xóa khi giwor hàng có sp
                      TextButton(
                        onPressed: items.isEmpty ? null : () {
                          context.read<CartBloc>().add(
                            const ClearCartEvent(),
                          );
                        },
                        child: const Text('Xóa tất cả'),
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${items.length} loại sản phẩm đã chọn',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF89958D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),


                  // nếu có nh sp thì sẽ cuộn đc
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 68,
                                  color: Color(0xFFBECBC1),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Giỏ hàng đang trống',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Hãy thêm một vài sản phẩm nhé!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) {
                              return const SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final product = item.product;

                              return Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9F7),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFFE8EDE9),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE3F3E9),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: green,
                                          ),
                                        ),
                                        const SizedBox(width: 11),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Mã sản phẩm #${product.id}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _changeButton(Icons.remove, () {
                                          context.read<CartBloc>().add(
                                            RemoveProductEvent(product),
                                          );
                                        }),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _changeButton(Icons.add, () {
                                          context.read<CartBloc>().add(
                                            AddProductEvent(product),
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng số lượng',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${state.totalQuantity} món',
                          style: const TextStyle(
                            color: green,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Tiếp tục chọn sản phẩm'),
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}