import 'dart:convert';
import '../models/productModel.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';

class ProductController {

  List<Data> products = [];

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(URLs.readProduct));
     // print(response.statusCode);
      if (response.statusCode == 200) {
        ProductsResponse productsResponse = ProductsResponse.fromJson(
          jsonDecode(response.body),);
        //print(products);
        products = productsResponse.data ?? [];
      } else {
        throw Exception("Failed to load products");
      }
    } catch (err) {
      rethrow;
    }
  }


  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await http.get(Uri.parse(URLs.deleteProduct(productId)));

      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      } else {
        return false;
      }
    } catch (err) {
      rethrow;
    }
  }


  Future<bool> createProduct(Data product) async {
    try {
      final response = await http.post(Uri.parse(URLs.createProduct),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(product.toJson()),
      );
      final products = jsonDecode(response.body);

      if (response.statusCode == 200 && products['status'] == "success") {
        await fetchProducts();
        return true;
      } else {
        return false;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> updateProduct(Data product) async {
    try {
      print("Calling UpdateProduct API...");
      final response = await http.put(
        Uri.parse(URLs.updateProduct(product.sId!)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(product.toJson()),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['status'] == "success") {
        await fetchProducts();
        return true;
      } else {
        print("Update failed: ${decoded['status']}");
        return false;
      }
    } catch (err) {
      print("Error while updating product: $err");
      return false;
    }
  }


}
