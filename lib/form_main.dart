import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tes.dart';
import 'package:neulibrary/Models/Book.dart';
import 'form_detail.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'form_history.dart';
import 'form_login.dart';
import 'dart:async';
import 'Models/Kategori.dart';
import 'package:cached_network_image/cached_network_image.dart';
class Form_Main extends StatefulWidget {
  const Form_Main({super.key});

  @override
  State<Form_Main> createState() => _Form_MainState();
}

class _Form_MainState extends State<Form_Main> {
  Timer? searchDebounce;
  Future<List>? _futureBooks;
  Future<List>? _futureCarts;
  String? emailprefs = "";
  Future<void> getPreferences() async {
    final simpanan = await SharedPreferences.getInstance();

    String? tesShared = simpanan.getString('token');
    print(tesShared);
    emailprefs = tesShared;
    print("isi data variabel string : $tesShared");

  }
  Future<void> removetoken() async {
    final simpanan = await SharedPreferences.getInstance();
    simpanan.remove('token');
    print("isi token : ${simpanan.getString('token')}");
    simpanan.remove('user_id');
    print("isi id user : "+simpanan.getInt('id').toString());
    simpanan.remove('id_anggota');
  }
  String? dropdownValue;
  String? KategoriStr;
  int kategoriValue = 0;
  int selected_index = 0;
  String search = "";
  String resultBarcode ="";
  String nama = "";
  String telepon = "";
  String email = "";
  String alamat = "";
  String tanggal_lahir = "";
  int id_anggota = 0;
  TextEditingController searchController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController tanggallahirController = TextEditingController();
  PageController _pageController = PageController();
  void onItemTapped(int index){
    setState(() {
      selected_index = index;
    });
    _pageController.jumpToPage(index);
  }
  @override
  void dispose() {
    searchDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _futureBooks = Provider.of<HttpProvider>(context, listen: false).connectAPISearchBook(search, kategoriValue);
    Provider.of<HttpProvider>(context, listen: false).connectAPIkategori();
  }
  void _updateSearchResults(String cari) {
    setState(() {
      search = cari;
      _futureBooks = Provider.of<HttpProvider>(context, listen: false).connectAPISearchBook(search, kategoriValue);
    });
  }
  void onSearchChanged(String search) {
    if (searchDebounce?.isActive ?? false) searchDebounce!.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 500), () {
    _updateSearchResults(search);
    });
  }
  void setPrefs() async {
    final simpanan = await SharedPreferences.getInstance();
    simpanan.setInt('id_anggota', id_anggota);
    int? tesShared = simpanan.getInt('id_anggota');
    print("isi id anggota $tesShared");
  }
  void _reloadBooks() {
    // Perbarui state _futureBooks dengan data terbaru
    setState(() {
      _futureBooks = Provider.of<HttpProvider>(context, listen: false).connectAPISearchBook(search, kategoriValue);
      Provider.of<HttpProvider>(context, listen: false).connectAPIkategori();
    });
  }
  void _precacheImages(List<dynamic> books) {
    for (var book in books) {
      precacheImage(NetworkImage(book['image']), context);
    }
  }
  Future<void> _reloadCarts() async {
    // Perbarui state _futureBooks dengan data terbaru
    setState(() {
      _futureCarts = Provider.of<HttpProvider>(context, listen: false).connectAPIgetCart();
    });
  }
  void getCart(){
    setState(() {
      _futureCarts = Provider.of<HttpProvider>(context, listen: false).connectAPIgetCart();
    });
  }
  @override
  Widget build(BuildContext context) {
    String barcode = '';
    void callApiAndNavigate(String barcode) async {
      bool isSuccess = await Provider.of<HttpProvider>(context, listen: false).connectAPIBarcode(barcode);
      if (isSuccess) {
        int id = Provider.of<HttpProvider>(context, listen: false).barcodedata['id_buku'];
        // Pastikan 'id' ada dalam respons dan valid sebelum navigasi
        if (id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Form_Detail(bookId: id)),
          );
        } else {
          // Handle ketika 'id' tidak ditemukan atau tidak valid
        }
      } else {
        // Handle kegagalan pemanggilan API
      }
    }
    Future<void> scanBarcode() async {
      try{
        barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.BARCODE);
        print(barcode);
      }on PlatformException{

      }
      if (barcode != '-1') {
        callApiAndNavigate(barcode);
      }
      if(!mounted) return;
      setState(() {
        resultBarcode = barcode;
        print(resultBarcode);

      });
    }

    final List<String> kelamin =[
      "laki-laki",
      "perempuan"
    ];

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
            IconButton(
                onPressed:
                scanBarcode,
                icon: Icon(Icons.document_scanner_outlined, color: Colors.white,))
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) async {
            setState(() {
              selected_index = index;
            });
            print("hasil barcode : "+resultBarcode);
            if(index == 0){
              dataProvider.connectAPISearchBook(search,kategoriValue);
              await dataProvider.connectAPIkategori();
              bool get = await dataProvider.connectAPIGetAnggota();
              if(get){

                id_anggota = dataProvider.getanggotadata['id'];
                setPrefs();

              }else{
                print("isi data anggota"+dataProvider.getanggotadata['message'].toString());
                if(dataProvider.getanggotadata['message']=="Anggota not found"){
                  index = 2;
                  setState(() {
                    selected_index = index;
                    _pageController.jumpToPage(index);
                    var snackbar = SnackBar(content: Text("Silahkan isi profile anda terlebih dahulu lalu simpan"), duration: Duration(seconds: 1),);
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  });
                  print("anggota tidak ada");
                }
                id_anggota = 0;
                setPrefs();
              }
            }else if (index == 1){
              getCart();
            }
            else if(index == 2){

             bool get = await dataProvider.connectAPIGetAnggota();
             if(get){
               print(dataProvider.getanggotadata);
               id_anggota = dataProvider.getanggotadata['id'];
               setPrefs();
               namaController.text = dataProvider.getanggotadata['nama'];
               nama = dataProvider.getanggotadata['nama'];
               String TeleponMentah = dataProvider.getanggotadata['telpon'];
               String ModifTelpon =TeleponMentah.substring(2);

               teleponController.text = ModifTelpon;
               telepon = ModifTelpon;

               emailController.text = dataProvider.getanggotadata['email'];
               email = dataProvider.getanggotadata['email'];
               alamatController.text = dataProvider.getanggotadata['alamat'];
               alamat = dataProvider.getanggotadata['alamat'];
               tanggallahirController.text = dataProvider.getanggotadata['tanggal_lahir'];
               tanggal_lahir = dataProvider.getanggotadata['tanggal_lahir'];
               String kelamin= dataProvider.getanggotadata['jenis_kelamin'];
               setState(() {
                 dropdownValue = kelamin;
               });
             }

            }

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
                      onChanged: onSearchChanged,

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
                          // label: Text(resultBarcode),
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
                  Consumer <HttpProvider>(
                    builder: (context, dataProvider, child){
                      return Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                              canvasColor: Color(0xFFF5CCA0)
                          ),
                          child: Container(
                            color: Color(0xFFF5CCA0),
                            width: double.maxFinite,
                            height: 56,
                            child: DropdownButtonFormField<int>(
                                value: kategoriValue,
                                icon:  Icon(Icons.arrow_drop_down_outlined, color: Colors.black,),
                                elevation: 16,
                                style: const TextStyle(color: Color(0xff994D1C)),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor:  Color(0xFFF5CCA0),
                                    border: OutlineInputBorder(

                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: Color(0xff994D1C) )
                                    ),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff994D1C)),borderRadius: BorderRadius.circular(15),)
                                ),
                                focusColor: Color(0xFFF5CCA0),


                                onChanged: (int? newValue) {
                                  setState(() {
                                    kategoriValue = newValue!;
                                      // KategoriStr = newValue;
                                    _updateSearchResults(search);
                                  });
                                },

                                items: [
                                    DropdownMenuItem<int>(
                                      value: 0, // Nilai untuk "Pilih Kategori"
                                        child: Text("Semua Kategori", style: TextStyle(color: Colors.black)),
                                        )
                                        ]..addAll(
                                        dataProvider.kategoridata.map<DropdownMenuItem<int>>((dynamic value) {
                                        Kategori kategori = value as Kategori;
                                        return DropdownMenuItem<int>(
                                        value: kategori.id,
                                        child: Text(kategori.nama, style: TextStyle(color: Colors.black)),
                                    );
                                }).toList(),
                            ),
                          ),
                        ),
                        )
                      );
                     },

                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(top: 4, left: 10,right: 10, bottom: 10),
                      child: Container(
                          // color: Colors.red,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: _futureBooks,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 200),
                                        child: CircularProgressIndicator( color: Color(0xff6B240C),
                                          backgroundColor: Color(0xFFF5CCA0),),
                                      )); // Menampilkan spinner saat data sedang dimuat
                                } else if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 180),
                                    child: Center(child: Text("Tidak ada Koneksi Internet", style: TextStyle(color: Colors.black),)),
                                  ); // Menampilkan pesan error
                                } else if (snapshot.hasData) {
                                  // Mengecek apakah data tersedia

                                    // List<Map<String, dynamic>> data = snapshot.data!;
                                  List<dynamic> books = snapshot.data as List<dynamic>;
                                  _precacheImages(books);
                                  print(books);
                                  print(books.length);
                                  return Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: RefreshIndicator(
                                      color: Color(0xff6B240C),
                                      backgroundColor: Color(0xFFF5CCA0),
                                      onRefresh: () async {
                                         _reloadBooks();
                                      },
                                      child: GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 1,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                            childAspectRatio: (120 / 45  )
                                          ),
                                          itemCount: books.length,

                                          itemBuilder: (context, index) {

                                            return InkWell(
                                              onTap: (){
                                                var selectedBookId = books[index]["id"];

                                                // Lakukan navigasi ke halaman detail dengan mengirimkan ID buku
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Form_Detail(bookId: selectedBookId,)),
                                                );
                                              },
                                              child: Card(child: Container(
                                                // height: 10,
                                                // width: 50,

                                                color: Colors.white,
                                                child: AspectRatio(
                                                  aspectRatio: (120/45),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,

                                                    children:[
                                                      Padding(
                                                        padding: const EdgeInsets.all(6.0),
                                                        child: Container(
                                                            height: 120,
                                                            width: 80,
                                                            child: Image(
                                                                image: NetworkImage("${books[index]["image"]}")
                                                            )
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,

                                                        children: [
                                                          SizedBox(
                                                            height: 5,
                                                          ),

                                                          Text(
                                                            books[index]["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                            textAlign: TextAlign.left,style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                          Text("By "+books[index]["pengarang"]??"pengarang", maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                          Text(
                                                            books[index]["sinopsis"]??"sinopsis",
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 11
                                                            )
                                                            ,overflow: TextOverflow.ellipsis,
                                                            maxLines: 3,
                                                            softWrap: true,),
                                                           ],
                                                        ),
                                                      ),
                                                  ]
                                                  ),
                                                ),
                                              )
                                              ),
                                            );
                                          }
                                      ),
                                    ),
                                  )
                                  );

                                  } else {
                                    return Center(
                                      child: Text("No data available", style: TextStyle(color: Colors.black),),
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 1, left: 7,right: 7, bottom: 0),
                      child: Container(
                        // color: Colors.red,
                        child: Column(
                          children: [
                            FutureBuilder(
                                future: _futureCarts,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 200),
                                          child: CircularProgressIndicator( color: Color(0xff6B240C),
                                            backgroundColor: Color(0xFFF5CCA0),),
                                        )); // Menampilkan spinner saat data sedang dimuat
                                  } else if (snapshot.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 180),
                                      child: Center(child: Text("Tidak ada Koneksi Internet", style: TextStyle(color: Colors.black),)),
                                    ); // Mempilkan pesan error
                                  } else if (snapshot.hasData) {
                                    // Mengecek apakah data tersedia

                                    // List<Map<String, dynamic>> data = snapshot.data!;
                                    List<dynamic> books = snapshot.data as List<dynamic>;
                                    print(books);
                                    // print("id dari buku pertama : "+books[0]["id"].toString());
                                    // print(books[0]["buku"]["image"]);
                                    print(books.length);

                                    return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.5),
                                          child: RefreshIndicator(
                                            color: Color(0xff6B240C),
                                            backgroundColor: Color(0xFFF5CCA0),
                                            onRefresh: () async {
                                              getCart();
                                            },
                                            child: GridView.builder(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 1,
                                                    crossAxisSpacing: 0,
                                                    mainAxisSpacing: 0,
                                                    childAspectRatio: (120 / 45  )
                                                ),
                                                itemCount: books.length,

                                                itemBuilder: (context, index) {
                                                  DateFormat dateFormat = DateFormat("yyyy-MM-dd | HH:mm");
                                                  String formattedDate = dateFormat.format(DateTime.parse(books[index]['created_at']));
                                                  return Card(child: Container(
                                                    // height: 10,
                                                    // width: 50,

                                                    color: Colors.white,
                                                    child: AspectRatio(
                                                      aspectRatio: (120/45),
                                                      child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center
                                                          ,
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children:[
                                                            Padding(
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Container(
                                                                  height: 120,
                                                                  width: 80,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(20)), // Ini akan memberikan border radius pada container
                                                                    // Tambahkan properti lain seperti color, border, boxShadow, dll, jika diperlukan
                                                                  ),
                                                                  child: Image(
                                                                      image: NetworkImage("${books[index]["buku"]["image"]??""}")
                                                                  )
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),

                                                                  Text(
                                                                    books[index]["buku"]["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                                    textAlign: TextAlign.left,style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                                  Text("By "+books[index]["buku"]["pengarang"]??"pengarang",maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                                  Text(
                                                                    books[index]["buku"]["sinopsis"]??"sinopsis",
                                                                    textAlign: TextAlign.left,
                                                                    style: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 11
                                                                    )
                                                                    ,overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                                    softWrap: true,),
                                                                  Text("Ditambahkan : ${formattedDate} ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),),

                                                                ],
                                                              ),
                                                            ),
                                                            Consumer<HttpProvider>(
                                                              builder: (context, dataProvider, child){
                                                                final responseHapusCart = dataProvider.hapuscartdata;
                                                                return IconButton(onPressed: (){
                                                                  showDialog(context: context, builder: (context){
                                                                    return AlertDialog(
                                                                      backgroundColor: Color(0xFFF5CCA0),
                                                                      title: Text("Hapus", style: TextStyle(
                                                                          color: Colors.black
                                                                      ),
                                                                      ),
                                                                      content: Text("Hapus Buku \"${books[index]["buku"]["judul"]}\" dari Keranjang anda ?",style: TextStyle(
                                                                          color: Colors.black,
                                                                          fontSize: 16
                                                                      ),
                                                                      ),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                          style: ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                                                          ),
                                                                          onPressed: (){
                                                                            Navigator.of(context).pop();
                                                                          },

                                                                          child: Text(
                                                                            "NO",
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold
                                                                            ),
                                                                          ),

                                                                        ), ElevatedButton(
                                                                            style: ButtonStyle(
                                                                                backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                                                            ),
                                                                            onPressed: () async {
                                                                              bool hapus = await dataProvider.connectAPIHapusItemCart(books[index]['id']);
                                                                              if(hapus == true){
                                                                                var snackBar = SnackBar(
                                                                                  content: Text(responseHapusCart["message"]),
                                                                                  duration: Duration(seconds: 1),
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                Navigator.of(context).pop();
                                                                                getCart();
                                                                              }else{
                                                                                var snackBar = SnackBar(
                                                                                  content: Text(responseHapusCart["message"]?? "Error menghapus item"),
                                                                                  duration: Duration(seconds: 1),
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                Navigator.of(context).pop();
                                                                              }
                                                                            }, child: Text(
                                                                          "YES",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold
                                                                          ),
                                                                        )
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                                  ;
                                                                }, icon: Icon(Icons.delete_outline_outlined, color: Colors.red,size: 25,));
                                                              },
                                                            )
                                                          ]
                                                      ),
                                                    ),
                                                  )
                                                  );
                                                }
                                            ),
                                          ),
                                        )
                                    );

                                  } else {
                                    return Center(
                                      child: Text("No data available", style: TextStyle(color: Colors.black),),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 80.0),
                    child: Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final responsePost = dataProvider.postcartdata;
                        final isiCart = dataProvider.keranjangdata;
                        print(responsePost['message']);
                        return  ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                          ),
                          onPressed: () async {
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                backgroundColor: Color(0xFFF5CCA0),
                                title: Text("Pinjam", style: TextStyle(
                                    color: Colors.black
                                ),
                                ),
                                content: Text("Pinjam Semua buku yang ada dikeranjang?",style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16
                                ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },

                                    child: Text(
                                      "NO",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),

                                  ), ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                      ),
                                      onPressed: () async {
                                        if(isiCart.isNotEmpty){
                                          bool pinjam = await dataProvider.connectAPIProsesCart();
                                          if(pinjam == true){
                                            var snackBar = SnackBar(
                                              content: Text(responsePost["message"]),
                                              duration: Duration(seconds: 1),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            getCart();
                                            Navigator.of(context).pop();

                                          }else{
                                            var snackBar = SnackBar(
                                              content: Text(responsePost["message"]?? "Error saat peminjaman"),
                                              duration: Duration(seconds: 1),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            getCart();
                                            Navigator.of(context).pop();
                                          }
                                        }else{
                                          var snackBar = SnackBar(
                                            content: Text("Tidak ada buku di keranjang anda"),
                                            duration: Duration(seconds: 1),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          Navigator.of(context).pop();
                                        }

                                      }, child: Text(
                                    "YES",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                                  ),
                                ],
                              );
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Ini akan membuat Row hanya sebesar kontennya
                            children: <Widget>[
                              Icon(Icons.shopping_cart_checkout_outlined, color: Colors.white),
                              SizedBox(width: 4), // Menambahkan sedikit ruang antara ikon dan teks
                              Text(
                                "Pinjam",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15,right: 20, top: 5,bottom: 10),
                          child: ElevatedButton(
                              onPressed: (){
                                // removetoken();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)=> Form_History())
                                );
                              },
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
                          padding: const EdgeInsets.only(left: 20,right: 15, top: 5,bottom: 10),
                          child: ElevatedButton(
                              onPressed: (){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    backgroundColor: Color(0xFFF5CCA0),
                                    title: Text("Logout", style: TextStyle(color: Colors.black),),
                                    content: Text("Logout dari akun ini?",style: TextStyle(color: Colors.black)),
                                    actions: [
                                      ElevatedButton(onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                        ),

                                        child: Text(
                                          "NO",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),

                                      ), ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                          ),
                                          onPressed: () async {
                                        bool logout = await dataProvider.connectAPILogout();
                                        print("loading...");
                                        if(logout == true){
                                          print("berhasil logout");
                                          var snackBar = SnackBar(
                                            content: Consumer<HttpProvider>(
                                                builder: (context, value, child) =>
                                                    Text(value.logoutdata["message"] ?? "")),
                                            duration: Duration(seconds: 1),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          removetoken();
                                          Navigator.of(context).pop();
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => Form_Login())
                                          );
                                        }else{
                                          // var snackBar = SnackBar(
                                          //   content: Consumer<HttpProvider>(
                                          //       builder: (context, value, child) =>
                                          //           Text(value.logoutdata["message"]?? "User Unauthorizad")),
                                          //   duration: Duration(seconds: 1),
                                          // );
                                          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          print("gagal logout");
                                          Navigator.of(context).pop();
                                        }
                                      }, child: Text(
                                        "YES",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                      ),
                                    ],
                                  );
                                });
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
                        controller: namaController,
                        onChanged: (name){
                          setState(() {
                              nama = name;
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
                        controller: teleponController,
                        onChanged: (txtphone){
                          setState(() {
                              telepon = txtphone;
                          });
                        },
                        style: TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.number,
                        cursorColor:Color(0xff994D1C),

                        decoration: InputDecoration(
                            isDense: true,
                            // icon: Icon(Icons.phone, size: 30,color: Colors.black,),
                            // hintText: "Phone Number",
                            prefixText: '08',
                            prefixStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16
                            ),
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
                        controller: emailController,
                        onChanged: (txtemail){
                          setState(() {
                            email = txtemail;
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
                        controller: alamatController,
                        onChanged: (txtalamat){
                          setState(() {
                            alamat = txtalamat;
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
                      padding: EdgeInsets.only(left: 30, right: 30, top: 7, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            // TextField untuk menampilkan tanggal lahir
                            child: TextField(
                              style: TextStyle(
                                  color: Colors.black
                              ),
                              controller: tanggallahirController, // Controller untuk tanggal lahir
                              decoration: InputDecoration(
                                labelText: 'Tanggal Lahir',
                                border: OutlineInputBorder(),

                                  labelStyle: TextStyle(color: Color(0xff6B240C)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xff994D1C)
                                      )
                                  )
                              ),
                              readOnly: true, // Membuat TextField tidak dapat diedit secara langsung
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today, color: Color(0xff994D1C),), // Ikon kalender
                            onPressed: () async {
                              // Fungsi untuk memicu date picker
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                initialEntryMode: DatePickerEntryMode.calendar,
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Color(0xff6B240C), // warna header
                                        onPrimary: Colors.white, // warna tulisan di header
                                        surface:  Color(0xFFF5CCA0), // warna latar kalender
                                        onSurface: Colors.black, // warna teks tanggal

                                      ),
                                      dialogBackgroundColor: Colors.white, // warna latar dialog

                                    ),
                                    child: child!,
                                  );
                                },


                              );
                              if (pickedDate != null) {
                                // Format dan tampilkan tanggal yang dipilih di TextField
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                tanggallahirController.text = formattedDate; // Menggunakan controller untuk mengatur teks
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30, top: 7),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Color(0xFFF5CCA0)
                        ),
                        child: Container(
                          color: Color(0xFFF5CCA0),
                          width: double.maxFinite,
                          child: DropdownButtonFormField<String>(
                            value: dropdownValue,
                            icon:  Icon(Icons.arrow_drop_down_outlined, color: Colors.black,),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:  Color(0xFFF5CCA0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.black )
                              ),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff994D1C)),borderRadius: BorderRadius.circular(15),)
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                        
                            items: kelamin.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(color: Colors.black),),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 80.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                        ),
                        onPressed: () async {
                          bool SimpanAnggota = await dataProvider.connectAPIIsiDataAnggota(nama, telepon, email, alamat, tanggal_lahir, dropdownValue??"");
                          if(SimpanAnggota){
                            var snackBar = SnackBar(
                              content: Text("Berhasil disimpan"),
                              duration: Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            print(dataProvider.anggotadata);

                          }else{
                            var snackBar = SnackBar(
                              content: Text("gagal disimpan"),
                              duration: Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            print(dataProvider.anggotadata);
                          }
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
