import 'dart:convert';
import 'package:http/http.dart' as http; 
import '../models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> fetchProducts() async {
    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts?_limit=8',
    );

    final response = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    // Chỉ xử lý dữ liệu khi API trả về thành công.
    if (response.statusCode != 200) {
      throw Exception('API trả về mã ${response.statusCode}');
    }


    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      
      return ProductModel.fromJson(item as Map<String, dynamic>);
    }).toList();
  }
}