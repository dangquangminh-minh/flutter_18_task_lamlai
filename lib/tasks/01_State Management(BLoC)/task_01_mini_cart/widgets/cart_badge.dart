import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';

class CartBadge extends StatelessWidget {
  final VoidCallback onPressed;

  const CartBadge({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Chỉ theo dõi tổng số lượng thay vì toàn bộ CartState.
    return BlocSelector<CartBloc, CartState, int>(
      selector: (state) => state.totalQuantity,
      builder: (context, count) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            if (count > 0)
              Positioned(
                top:2,
                right:2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal:5, vertical:2,
                  ),
                  constraints: const BoxConstraints(minWidth:18),
                  decoration: BoxDecoration(
                    color:Colors.red,
                    borderRadius:BorderRadius.circular(12),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign:TextAlign.center,
                    style: const TextStyle(
                      color:Colors.white,
                      fontSize:10,
                      fontWeight:FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}