import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:neulibrary/Models/SharedPref.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tes.dart';
import 'package:neulibrary/Models/Book.dart';
import 'form_detail.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Form_Main extends StatefulWidget {
  const Form_Main({super.key});

  @override
  State<Form_Main> createState() => _Form_MainState();
}

class _Form_MainState extends State<Form_Main> {
  String? emailprefs = "";
  Future<void> getPreferences() async {
    final simpanan = await SharedPreferences.getInstance();

    String? tesShared = simpanan.getString('email');
    print(tesShared);
    emailprefs = tesShared;
    print("isi data variabel string : $emailprefs");

  }
  int selected_index = 0;
  String search = "";
  String resultBarcode ="";
  TextEditingController searchController = TextEditingController();
  PageController _pageController = PageController();
  void onItemTapped(int index){
    setState(() {
      selected_index = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void initState(){
    super.initState();
    searchController.addListener(() {
      search = searchController.text;
    });

      Provider.of<HttpProvider>(context, listen: false).connectAPISearchBook(search);

  }
  @override
  Widget build(BuildContext context) {
    String barcode = '';

    Future<void> scanBarcode() async {

      try{
        barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.BARCODE);
        print(barcode);
      }on PlatformException{

      }
      if(!mounted) return;
      setState(() {
        resultBarcode = barcode;
        // // Pindahkan logika pengecekan barcode ke sini
        // if (resultBarcode == "9786026486578") {
        //   judul = "Psychology of Money";
        //   Author = "Morgan Housel";
        // } else {
        //   judul = ""; // Atau nilai default lainnya
        //   Author = ""; // Atau nilai default lainnya
        // }
      });
    }
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
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
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                    onPressed: () async {
                      print(emailprefs);
                      var snackBar = SnackBar(
                        content:SnackBar(content: Text(emailprefs ??"Email tidak ada"),

                        ),
                        duration: Duration(seconds: 1),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Form_Detail()),
                      );
                    },
                    icon: Icon(Icons.arrow_forward_ios)

                );
              },

            ),
            IconButton(
                onPressed:
                scanBarcode,
                icon: Icon(Icons.document_scanner_outlined, color: Colors.white,))
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index){
            setState(() {
              selected_index = index;
            });
          },
          children: [
            Container(
              color: Color(0xFFF5CCA0),
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
                        search = cari;
                        dataProvider.connectAPISearchBook(search);
                      },

                      keyboardType: TextInputType.text,
                      cursorColor: Colors.brown,
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
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(top: 10, left: 20,right: 20, bottom: 10),
                      child: Container(
                          // color: Colors.red,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: selected_index == 0 ? dataProvider.connectAPISearchBook(search) : null,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator()); // Menampilkan spinner saat data sedang dimuat
                                } else if (snapshot.hasError) {
                                  return Center(child: Text("Error: ${snapshot
                                      .error}")); // Menampilkan pesan error
                                } else if (snapshot.hasData) {
                                  // Mengecek apakah data tersedia

                                    // List<Map<String, dynamic>> data = snapshot.data!;
                                  List<dynamic> books = snapshot.data as List<dynamic>;
                                  print(books);
                                  print(books.length);
                                  return Expanded(child:
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 25,
                                          mainAxisSpacing: 25,
                                        ),
                                        itemCount: books.length,
                                    
                                        itemBuilder: (context, index) {
                                       //   Book buku = Book(books[index]["id"],books[index]["title"],books[index]["image"],books[index]["sinposis"],books[index]["pengarang"],books[index]["penerbit"],books[index]["terbit"],books[index]["jumlah"],books[index]["dipinjam"],books[index]["halaman"] );
                                       //    print(buku);
                                          // var book = books[index];
                                          // print("hasil index $book");
                                          // var buku = provider.bukudata['books'][index]; // Sesuaikan dengan struktur data API
                                    
                                          return Card(child: Container(
                                            height: 50,
                                            width: 50,

                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                    height: 110,
                                                    width: 110,
                                                    child: Image(
                                                        image: NetworkImage("${books[index]["image"]}")
                                                    )
                                                ),
                                                Text(books[index]["title"]??"tes",textAlign: TextAlign.center,style: TextStyle(color: Colors.black),),
                                                Text(books[index]["pengarang"]??"sinopsis", textAlign: TextAlign.center,style: TextStyle(color: Colors.black)),
                                              ],
                                            ),
                                          )
                                          );
                                        }
                                    ),
                                  )
                                  );

                                  } else {
                                    return Center(
                                      child: Text("No data available"),
                                    );
                                  }

                                // }else {
                                //   // If there's no data and no error, and not loading, display a default message
                                //   return Center(
                                //       child: Text("No data to display"));
                                // }
                              }

                           )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Color(0xFFF5CCA0),
              child: Column(
                children: [
                  Text(
                    "Your Cart",

                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xFFF5CCA0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20,right: 10, top: 5,bottom: 10),
                          child: ElevatedButton(
                              onPressed: (){},
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                              ),

                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_outlined, color: Colors.white,),
                                  SizedBox(width: 10),
                                  Text(
                                    "History",
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
                        Padding(
                          padding: const EdgeInsets.only(left: 70,right: 10, top: 5,bottom: 10),
                          child: ElevatedButton(
                              onPressed: (){

                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                              ),

                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_outlined, color: Colors.white,),
                                  SizedBox(width: 10),
                                  Text(
                                    "Logout",
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
                      ],
                    ),

                    Text(
                      "Profile",

                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        // autocorrect: false,
                        // autofocus: false,
                        // enableSuggestions: false,
                        // enableInteractiveSelection: true,
                        // obscureText: false,

                        onChanged: (name){
                          setState(() {

                          });
                        },
                        style: TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.name,
                        cursorColor:Color(0xff994D1C),
                        decoration: InputDecoration(
                            isDense: true,
                            // icon: Icon(Icons.person, size: 30,color: Colors.black,),
                            // hintText: "Fullname",
                            labelText: "Nama Lengkap",
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
                        // obscuringCharacter: '₯',
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        // autocorrect: false,
                        // autofocus: false,
                        // enableSuggestions: false,
                        // enableInteractiveSelection: true,
                        // obscureText: false,

                        onChanged: (phone){
                          setState(() {

                          });
                        },
                        style: TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor:Color(0xff994D1C),
                        decoration: InputDecoration(
                            isDense: true,
                            // icon: Icon(Icons.phone, size: 30,color: Colors.black,),
                            // hintText: "Phone Number",
                            labelText: "Nomor Telepon",
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
                        // obscuringCharacter: '₯',
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        // autocorrect: false,
                        // autofocus: false,
                        // enableSuggestions: false,
                        // enableInteractiveSelection: true,
                        // obscureText: false,

                        onChanged: (email){
                          setState(() {

                          });
                        },
                        style: TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor:Color(0xff994D1C),
                        decoration: InputDecoration(
                            isDense: true,
                            // icon: Icon(Icons.email, size: 30,color: Colors.black,),
                            // hintText: "Email",
                            labelText: "Email",
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
                        // obscuringCharacter: '₯',
                      ),
                    ),

                    Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        // autocorrect: false,
                        // autofocus: false,
                        // enableSuggestions: false,
                        // enableInteractiveSelection: true,

                        onChanged: (password){
                          setState(() {

                          });
                        },
                        style: TextStyle(
                            color: Colors.black
                        ),

                        keyboardType: TextInputType.text,
                        cursorColor:Color(0xff994D1C),
                        decoration: InputDecoration(
                            isDense: true,

                            // icon: Icon(Icons.lock, size: 30,color: Colors.black,),
                            // hintText: "Password",
                            labelText: "Alamat",
                            border: OutlineInputBorder(

                            ),
                            labelStyle: TextStyle(color: Color(0xff6B240C)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xff994D1C)
                                )
                            )

                        ),
                        // obscuringCharacter: '₯',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 80.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                        ),
                        onPressed: () {
                          getPreferences();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Ini akan membuat Row hanya sebesar kontennya
                          children: <Widget>[
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 4), // Menambahkan sedikit ruang antara ikon dan teks
                            Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Container(
            //   color: Color(0xFFF5CCA0),
            //   child: Column(
            //     children: [
            //       Text(
            //         "History",
            //
            //         style: TextStyle(
            //             color: Colors.black,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 25
            //         ),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff6B240C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,

          currentIndex: selected_index,
          onTap: onItemTapped,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, color: Colors.white,),
                label: "Home"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined,color: Colors.white,),
                label: "Cart"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined,color: Colors.white,),
                label: "Profile"
            ),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.history_outlined, color: Colors.white,),
            //     label: "History"
            // )
          ],
        ),
    );
  }
}
