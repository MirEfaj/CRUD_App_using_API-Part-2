class URLs {
  static final String baseURL = "http://35.73.30.144:2008/api/v1";

  static final String createProduct = "$baseURL/CreateProduct";

  static final String readProduct = "$baseURL/ReadProduct";

  static String readProductById(String id) => "$baseURL/ReadProductById/$id";

  static String updateProduct(String id) => "$baseURL/UpdateProduct/$id";

  static String deleteProduct(String id) => "$baseURL/DeleteProduct/$id";
}
