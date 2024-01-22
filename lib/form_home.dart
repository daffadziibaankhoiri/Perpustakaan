// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
class Form_Home extends StatefulWidget {
  const Form_Home({super.key});

  @override
  State<Form_Home> createState() => _Form_HomeState();
}

class _Form_HomeState extends State<Form_Home> {

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    final controller = Get.put(NavigationController(dataProvider: dataProvider));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff6B240C),
        title: Text(
          "NeuLibrary",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Caveat',
              fontSize: 30
          ),
        ),
        // centerTitle: true,

      ),
      bottomNavigationBar: Obx(
          () =>  NavigationBar(
          backgroundColor: Color(0xFF6B240C),
          height: 60,
          elevation: 10,
          selectedIndex: controller.selectedindex.value,
          indicatorColor: Color(0xFF541A08),
          onDestinationSelected: (index) => controller.selectedindex.value = index,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white,), label: "Home",),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined,color: Colors.white,), label: "Cart"),
            NavigationDestination(icon: Icon(Icons.person_2_outlined,color: Colors.white,), label: "Profile"),
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedindex.value])
    );
  }
}
class NavigationController extends GetxController{
  final HttpProvider dataProvider;
  NavigationController({required this.dataProvider});
  final RxInt selectedindex = 0.obs;
  RxString search = "".obs;
  TextEditingController searchController = TextEditingController();
  void updateSearch(String value) {
    search.value = value; // Update the reactive search variable whenever the text changes.
  }
  void updatedata(String value){
    dataProvider.connectAPISearchBook(search.value);
  }
  List<Widget> get screens => [
    Container(
      color: Color(0xFFF5CCA0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(left: 20,right: 20,top: 7),
              child: TextField(
                // autocorrect: false,
                // autofocus: false,
                // enableSuggestions: false,
                // enableInteractiveSelection: true,
                // obscureText: false,
                controller: searchController,
                onChanged: (cari){
                  updateSearch(cari);
                  updateSearch(cari);
                },
        
                keyboardType: TextInputType.text,
                cursorColor: Colors.blueAccent,
                decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search, size: 30,color: Colors.black,),
                    // hintText: "Search . . . ",
                    labelText: "Search Book",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xff994D1C)
                        )
                    ),
                    labelStyle: TextStyle(color: Color(0xff6B240C)),
        
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xff994D1C)
                      ),
        
                    )
                ),
                style: TextStyle(
                    color: Colors.black
                ),
                // obscuringCharacter: '₯',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
              child: Obx(() => SingleChildScrollView(
                child: Expanded(
                  child: Container(

                    color: Colors.red,
                    child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2
                            ),
                            itemCount: dataProvider.jumlahDatabuku,
                            itemBuilder: (context, index){
                              // List<Map<String, dynamic>>? books = dataProvider.bukudata;
                           return GridTile(
                               child: Column(
                                 children: [
                                   Text(
                                     "",
                                     // books[index]["title"],
                                     style: TextStyle(
                                       color: Colors.black
                                     ),
                                   ),
                                 ],
                               ),
                           );

                      },
                    ),
                  ),
                ),
                    ),
              ),
            )
          ],
        ),
      ),
    ),
    Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: Colors.yellow,
      child: Column(

        children: [
          Text("Ini Cart"),
        ],
      ),
    ),
    Container(
      color: Color(0xFFF5CCA0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 265,right: 10, top: 5),
                child: ElevatedButton(
                    onPressed: (){},
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                    ),
                    // child: Text("Logout",
                    //   style: TextStyle(
                    //     color: Colors.white
                    //   ),
                    // ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_outlined, color: Colors.white,),
                        SizedBox(width: 10),
                        Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                          ),
                        )
  ],
                    )

                ),
              ),
            ),
            CircleAvatar(
              radius: 90,
              backgroundImage: AssetImage("Asset/icon.png"),
            ),
            Text(
                "Nama",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ],
        ),
      ),
    )
  ];
}
