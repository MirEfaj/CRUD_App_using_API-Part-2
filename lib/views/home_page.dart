import 'package:e_commerce/models/productModel.dart';
import 'package:flutter/material.dart';
import '../controllers/procuctController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductController productcontroller = ProductController();
  bool isLoading = false;
  _snackBar( String msg){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProduct();
  }


  Future<void> loadProduct() async{
    try{
      isLoading = true;
      setState(() {});
      await productcontroller.fetchProducts();
      if(!mounted) return ;
      setState(() {});
    }catch(err){
      _snackBar("Failed to load products");
    }finally{
      isLoading = false ;
      setState(() {});
    }
  }

Future<void> createProduct(Data uewProduct) async{
    try{
      bool status = await productcontroller.createProduct(uewProduct);
      if(!mounted) return;
      if(status == true){
        _snackBar("Product created successfully");
        await loadProduct();
      }
      else{
        _snackBar("Failed to create product");
      }
    }catch(err){
      _snackBar("Internal server error");
    }
}

  Future<void> updateProduct(Data uewProduct) async{
    try{
      bool status = await productcontroller.updateProduct(uewProduct);
      if(!mounted) return;
      if(status == true){
        _snackBar("Product updated successfully");
        await loadProduct();
      }
      else{
        _snackBar("Failed to update product");
      }
    }catch(err){
      _snackBar("Internal server error");
    }
  }


  Future<void> deleteProduct(String id) async{
    try{
      bool status = await productcontroller.deleteProduct(id);
      if(!mounted) return;
      if(status == true){
        _snackBar("Product deleted successfully");
        await loadProduct();
      }
      else{
        _snackBar("Failed to delete product");
      }
    }catch(err){
      _snackBar("Internal server error");
    }
  }


  void productAddorUpdateDox({Data? selectedProduct}) {
    TextEditingController nameController = TextEditingController(text: selectedProduct?.productName);
    TextEditingController imageController = TextEditingController(text: selectedProduct?.img);
    TextEditingController quantityController = TextEditingController(text: selectedProduct?.qty?.toString());
    TextEditingController unitePriceController = TextEditingController(text: selectedProduct?.unitPrice?.toString());

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(selectedProduct == null ? "Create Product" : "Update Product"),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "Product name"),
                  ),
                  TextFormField(
                    controller: imageController,
                    decoration: InputDecoration(hintText: "Product image"),
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(hintText: "Product quantity"),
                  ),
                  TextFormField(
                    controller: unitePriceController,
                    decoration: InputDecoration(hintText: "Product unit price"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.red))),
              TextButton(
                onPressed: () async {
                  Data newProduct = Data(
                    sId: selectedProduct?.sId,  // important for update
                    productName: nameController.text,
                    productCode: selectedProduct?.productCode ?? DateTime.now().millisecondsSinceEpoch,
                    img: imageController.text,
                    qty: int.parse(quantityController.text),
                    unitPrice: int.parse(unitePriceController.text),
                    totalPrice: int.parse(unitePriceController.text) * int.parse(quantityController.text),
                  );

                  if (selectedProduct == null) {
                    await createProduct(newProduct);
                  } else {
                    await updateProduct(newProduct);
                  }

                  Navigator.of(context).pop();
                },
                child: Text(selectedProduct == null ? "Create" : "Update", style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products App"),foregroundColor: Colors.white,backgroundColor: Colors.blue, centerTitle: true,
      actions: [
        IconButton(onPressed: (){}, icon: Icon(Icons.search)),
        IconButton(onPressed: (){}, icon: Icon(Icons.shopping_cart_outlined)),
      ],),
      body: isLoading
           ? Center( child: CircularProgressIndicator(),)
           : RefreshIndicator(
             onRefresh: loadProduct,
             child: GridView.builder(
               itemCount: productcontroller.products.length,
                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 4/6
                       ),
                       itemBuilder: (context, index){
              return Card(
                color: Colors.blue.shade100,
                child: Column(
                  children: [

                    Expanded(
                        flex: 1,
                        child: Image.network(productcontroller.products[index].img ?? "")),
                    Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("Name : ${productcontroller.products[index].productName}" ?? "No Name"),
                          Text("Price :${productcontroller.products[index].unitPrice}" ?? "Not Given"),
                          Text("unit :${productcontroller.products[index].qty}" ?? "Not Given"),
                          Text("Total :${productcontroller.products[index].totalPrice}" ?? "Not Given"),
                    ],)
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                productAddorUpdateDox(selectedProduct: productcontroller.products[index]);
                              },
                              icon: Icon(Icons.edit),
                            ),

                            IconButton(onPressed: (){}, icon: Icon(Icons.shopping_cart_outlined)),
                          ],
                        ),
                        IconButton(onPressed: (){deleteProduct(productcontroller.products[index].sId!);}, icon: Icon(Icons.delete, color: Colors.red,)),

                      ],
                    )

                  ],
                ),
              );
                       }),
           ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productAddorUpdateDox(); // no selectedProduct means create
        },
        child: Icon(Icons.add),
      ),

    );
  }
}
