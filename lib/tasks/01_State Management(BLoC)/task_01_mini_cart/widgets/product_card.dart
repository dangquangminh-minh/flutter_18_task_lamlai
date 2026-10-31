import 'package:flutter/material.dart';
import '../models/product_model.dart';

// widget h.thị tt và slg sp
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  static const green = Color(0xFF207A55);

  
  // ontap = null thì nút sẽ không thực hiện thao tác
  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool primary = false,
  }) {
    return Material(
      color: primary ? green : const Color(0xFFEEF4F0),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 19,
            color: primary
                ? Colors.white
                : onTap == null ? Colors.grey.shade400 : green,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ktra sp có trong giỏ hàng ch
    final selected = quantity > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),

        border: Border.all(
          color: selected
              ? const Color(0xFFB6DFC8)
              : const Color(0xFFE9EEEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: 72,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F4EB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      size: 30,
                      color: green,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '#${product.id.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SẢN PHẨM MINI SHOP',
                      style: TextStyle(
                        color: green,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF22372C),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF89958D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F2F0)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  selected ? 'Đã chọn $quantity món' : 'Chưa thêm vào giỏ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: selected ? green : Colors.grey.shade500,
                  ),
                ),
              ),
              _quantityButton(
                icon: Icons.remove,
                onTap: selected ? onRemove : null,
              ),
              SizedBox(
                width: 35,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _quantityButton(
                icon: Icons.add,
                onTap: onAdd,
                primary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}