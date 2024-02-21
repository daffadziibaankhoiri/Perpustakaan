import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    print("isi id user : ${simpanan.getInt('id')}");
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
  final PageController _pageController = PageController();
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
  void getCart(){
    setState(() {
      _futureCarts = Provider.of<HttpProvider>(context, listen: false).connectAPIgetCart();
    });
  }
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna tidak bisa menutup dialog secara manual
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Color(0xFFF5CCA0),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xff994D1C),),
                SizedBox(width: 20),
                Text("Loading, Mohon Tunggu...\nJika Terlalu lama...\nKembali dan perbarui keranjang\nDan Konfirmasi ke Admin", style: TextStyle(color: Color(0xff994D1C)),),
              ],
            ),
          ),
        );
      },
    );
  }
  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(); // Menutup dialog
  }
  @override
  Widget build(BuildContext context) {
    String barcode = '';
    void callApiAndNavigate(String barcode) async {
      bool isSuccess = await Provider.of<HttpProvider>(context, listen: false).connectAPIBarcode(barcode);
      if (isSuccess) {
        int id = Provider.of<HttpProvider>(context, listen: false).barcodedata['id_buku'];
        // Pastikan 'id' ada dalam respons dan valid sebelum navigasi
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Form_Detail(bookId: id)),
        );
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
          backgroundColor: const Color(0xff6B240C),
          title: const Text(
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
                icon: const Icon(Icons.document_scanner_outlined, color: Colors.white,))
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) async {
            setState(() {
              selected_index = index;
            });
            print("hasil barcode : $resultBarcode");
            if(index == 0){
              FocusScope.of(context).unfocus();
              dataProvider.connectAPISearchBook(search,kategoriValue);
              await dataProvider.connectAPIkategori();
              bool get = await dataProvider.connectAPIGetAnggota();
              if(get){

                id_anggota = dataProvider.getanggotadata['id'];
                setPrefs();

              }else{
                print("isi data anggota${dataProvider.getanggotadata['message']}");
                if(dataProvider.getanggotadata['message']=="Anggota not found"){
                  index = 2;
                  setState(() {
                    selected_index = index;
                    _pageController.jumpToPage(index);
                    var snackbar = const SnackBar(content: Text("Silahkan isi profile anda terlebih dahulu lalu simpan"), duration: Duration(seconds: 1),);
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  });
                  print("anggota tidak ada");
                }
                id_anggota = 0;
                setPrefs();
              }
            }else if (index == 1){
              getCart();
              FocusScope.of(context).unfocus();
            }
            else if(index == 2){
              FocusScope.of(context).unfocus();
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
              color: const Color(0xFFF5CCA0),
              child: Column(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
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
                      decoration: const InputDecoration(
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
                      style: const TextStyle(
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
                              canvasColor: const Color(0xFFF5CCA0)
                          ),
                          child: Container(
                            color: const Color(0xFFF5CCA0),
                            width: double.maxFinite,
                            height: 56,
                            child: DropdownButtonFormField<int>(
                                value: kategoriValue,
                                icon:  const Icon(Icons.arrow_drop_down_outlined, color: Colors.black,),
                                elevation: 16,
                                style: const TextStyle(color: Color(0xff994D1C)),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor:  const Color(0xFFF5CCA0),
                                    border: OutlineInputBorder(

                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Color(0xff994D1C) )
                                    ),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff994D1C)),borderRadius: BorderRadius.circular(15),)
                                ),
                                focusColor: const Color(0xFFF5CCA0),


                                onChanged: (int? newValue) {
                                  setState(() {
                                    kategoriValue = newValue!;
                                      // KategoriStr = newValue;
                                    _updateSearchResults(search);
                                  });
                                },

                                items: [
                                    const DropdownMenuItem<int>(
                                      value: 0, // Nilai untuk "Pilih Kategori"
                                        child: Text("Semua Kategori", style: TextStyle(color: Colors.black)),
                                        ), ...dataProvider.kategoridata.map<DropdownMenuItem<int>>((dynamic value) {
                                        Kategori kategori = value as Kategori;
                                        return DropdownMenuItem<int>(
                                        value: kategori.id,
                                        child: Text(kategori.nama, style: const TextStyle(color: Colors.black)),
                                    );
                                })
                                        ],
                          ),
                        ),
                        )
                      );
                     },

                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, left: 10,right: 10, bottom: 10),
                      child: Container(
                          // color: Colors.red,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: _futureBooks,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 200),
                                        child: CircularProgressIndicator( color: Color(0xff6B240C),
                                          backgroundColor: Color(0xFFF5CCA0),),
                                      )); // Menampilkan spinner saat data sedang dimuat
                                } else if (snapshot.hasError) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 180),
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
                                      color: const Color(0xff6B240C),
                                      backgroundColor: const Color(0xFFF5CCA0),
                                      onRefresh: () async {
                                         _reloadBooks();
                                      },
                                      child: GridView.builder(
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                FocusScope.of(context).unfocus();
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
                                                        child: SizedBox(
                                                            height: 120,
                                                            width: 80,
                                                            child: CachedNetworkImage(
                                                              imageUrl: "${books[index]["image"]}",
                                                              placeholder: (context, url) => const Center(
                                                                child: SizedBox(
                                                                  width: 30, // Atur lebar
                                                                  height: 30, // Atur tinggi
                                                                  child: CircularProgressIndicator(color: Color(0xff6B240C)),
                                                                ),
                                                              ),
                                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                                              // fit: BoxFit.cover,
                                                            )
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,

                                                        children: [
                                                          const SizedBox(
                                                            height: 5,
                                                          ),

                                                          Text(
                                                            books[index]["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                            textAlign: TextAlign.left,style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                          Text("By "+books[index]["pengarang"], maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                          Text(
                                                            books[index]["sinopsis"]??"sinopsis",
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 11
                                                            )
                                                            ,overflow: TextOverflow.ellipsis,
                                                            maxLines: 3,
                                                            softWrap: true,
                                                          ),
                                                          Text(
                                                            "Dibaca : ${books[index]["dipinjam"]} kali",
                                                              style: const TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 13,
                                                                fontWeight: FontWeight.bold
                                                              )
                                                          )
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
                                    return const Center(
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
              color: const Color(0xFFF5CCA0),
              child: Column(
                children: [
                  const Text(
                    "Your Cart",

                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1, left: 7,right: 7, bottom: 0),
                      child: Container(
                        // color: Colors.red,
                        child: Column(
                          children: [
                            FutureBuilder(
                                future: _futureCarts,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 200),
                                          child: CircularProgressIndicator( color: Color(0xff6B240C),
                                            backgroundColor: Color(0xFFF5CCA0),),
                                        )); // Menampilkan spinner saat data sedang dimuat
                                  } else if (snapshot.hasError) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 180),
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
                                            color: const Color(0xff6B240C),
                                            backgroundColor: const Color(0xFFF5CCA0),
                                            onRefresh: () async {
                                              getCart();
                                            },
                                            child: GridView.builder(
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                                  decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(20)), // Ini akan memberikan border radius pada container
                                                                    // Tambahkan properti lain seperti color, border, boxShadow, dll, jika diperlukan
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    imageUrl: "${books[index]["buku"]["image"]}",
                                                                    placeholder: (context, url) => const Center(
                                                                      child: SizedBox(
                                                                        width: 30, // Atur lebar
                                                                        height: 30, // Atur tinggi
                                                                        child: CircularProgressIndicator(color: Color(0xff6B240C)),
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                    // fit: BoxFit.cover,
                                                                  )
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),

                                                                  Text(
                                                                    books[index]["buku"]["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                                    textAlign: TextAlign.left,style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                                  Text("By "+books[index]["buku"]["pengarang"],maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                                  Text(
                                                                    books[index]["buku"]["sinopsis"]??"sinopsis",
                                                                    textAlign: TextAlign.left,
                                                                    style: const TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 11
                                                                    )
                                                                    ,overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                                    softWrap: true,),
                                                                  Text("Ditambahkan : $formattedDate ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),),

                                                                ],
                                                              ),
                                                            ),
                                                            Consumer<HttpProvider>(
                                                              builder: (context, dataProvider, child){
                                                                final responseHapusCart = dataProvider.hapuscartdata;
                                                                return IconButton(onPressed: (){
                                                                  showDialog(context: context, builder: (context){
                                                                    return AlertDialog(
                                                                      backgroundColor: const Color(0xFFF5CCA0),
                                                                      title: const Text("Hapus", style: TextStyle(
                                                                          color: Colors.black
                                                                      ),
                                                                      ),
                                                                      content: Text("Hapus Buku \"${books[index]["buku"]["judul"]}\" dari Keranjang anda ?",style: const TextStyle(
                                                                          color: Colors.black,
                                                                          fontSize: 16
                                                                      ),
                                                                      ),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                          style: ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                                                          ),
                                                                          onPressed: (){
                                                                            Navigator.of(context).pop();
                                                                          },

                                                                          child: const Text(
                                                                            "NO",
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold
                                                                            ),
                                                                          ),

                                                                        ), ElevatedButton(
                                                                            style: ButtonStyle(
                                                                                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                                                            ),
                                                                            onPressed: () async {
                                                                              bool hapus = await dataProvider.connectAPIHapusItemCart(books[index]['id']);
                                                                              if(hapus == true){
                                                                                var snackBar = SnackBar(
                                                                                  content: Text(responseHapusCart["message"]),
                                                                                  duration: const Duration(seconds: 1),
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                Navigator.of(context).pop();
                                                                                getCart();
                                                                              }else{
                                                                                var snackBar = SnackBar(
                                                                                  content: Text(responseHapusCart["message"]?? "Error menghapus item"),
                                                                                  duration: const Duration(seconds: 1),
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                Navigator.of(context).pop();
                                                                              }
                                                                            }, child: const Text(
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
                                                                }, icon: const Icon(Icons.delete_outline_outlined, color: Colors.red,size: 25,));
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
                                    return const Center(
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
                              backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                          ),
                          onPressed: () async {
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                backgroundColor: const Color(0xFFF5CCA0),
                                title: const Text("Pinjam", style: TextStyle(
                                    color: Colors.black
                                ),
                                ),
                                content: const Text("Pinjam Semua buku yang ada dikeranjang?",style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16
                                ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },

                                    child: const Text(
                                      "NO",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),

                                  ), ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C)),
                                    ),
                                    onPressed: () async {
                                      if (isiCart.isNotEmpty) {
                                        setState(() {
                                          _showLoadingDialog(context);
                                        });

                                        bool pinjam = await dataProvider.connectAPIProsesCart();

                                        if(pinjam) {
                                          // Proses berhasil
                                          var snackBar = SnackBar(
                                            content: Text(responsePost["message"]),
                                            duration: const Duration(seconds: 3),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          setState(() {
                                            _hideLoadingDialog(context);
                                          });
                                          Navigator.of(context).pop();
                                          getCart();
                                        } else {
                                          // Proses gagal
                                          var snackBar = SnackBar(
                                            content: Text(responsePost["message"] ?? "Error saat peminjaman"),
                                            duration: const Duration(seconds: 1),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          setState(() {
                                            _hideLoadingDialog(context);
                                          });
                                          Navigator.of(context).pop();
                                        }


                                      } else {
                                        var snackBar = const SnackBar(
                                          content: Text("Tidak ada buku di keranjang anda"),
                                          duration: Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text(
                                      "YES",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              );
                            });
                          },
                          child: const Row(
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
              color: const Color(0xFFF5CCA0),
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
                                FocusScope.of(context).unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)=> const Form_History())
                                );
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
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
                                    backgroundColor: const Color(0xFFF5CCA0),
                                    title: const Text("Logout", style: TextStyle(color: Colors.black),),
                                    content: const Text("Logout dari akun ini?",style: TextStyle(color: Colors.black)),
                                    actions: [
                                      ElevatedButton(onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                        ),

                                        child: const Text(
                                          "NO",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),

                                      ), ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                          ),
                                          onPressed: () async {
                                        // bool logout = await dataProvider.connectAPILogout();
                                        // print("loading...");
                                        // if(logout == true){
                                        //   print("berhasil logout");
                                        //   var snackBar = SnackBar(
                                        //     content: Consumer<HttpProvider>(
                                        //         builder: (context, value, child) =>
                                        //             Text(value.logoutdata["message"] ?? "")),
                                        //     duration: Duration(seconds: 1),
                                        //   );
                                        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          removetoken();
                                          Navigator.of(context).pop();
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => const Form_Login())
                                          );
                                        // }else{
                                        //   // var snackBar = SnackBar(
                                        //   //   content: Consumer<HttpProvider>(
                                        //   //       builder: (context, value, child) =>
                                        //   //           Text(value.logoutdata["message"]?? "User Unauthorizad")),
                                        //   //   duration: Duration(seconds: 1),
                                        //   // );
                                        //   // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        //   print("gagal logout");
                                        //   Navigator.of(context).pop();
                                        // }
                                      }, child: const Text(
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
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
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

                    const Text(
                      "Profile",

                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        controller: namaController,
                        onChanged: (name){
                          setState(() {
                              nama = name;
                          });
                        },
                        style: const TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.name,
                        cursorColor:const Color(0xff994D1C),
                        decoration: const InputDecoration(
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
                    Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        controller: teleponController,
                        onChanged: (txtphone){
                          setState(() {
                              telepon = txtphone;
                          });
                        },
                        style: const TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.number,
                        cursorColor:const Color(0xff994D1C),

                        decoration: const InputDecoration(
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
                    Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        controller: emailController,
                        onChanged: (txtemail){
                          setState(() {
                            email = txtemail;
                          });
                        },
                        style: const TextStyle(
                            color: Colors.black
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor:const Color(0xff994D1C),
                        decoration: const InputDecoration(
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

                    Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 10),
                      child: TextField(
                        controller: alamatController,
                        onChanged: (txtalamat){
                          setState(() {
                            alamat = txtalamat;
                          });
                        },
                        style: const TextStyle(
                            color: Colors.black
                        ),

                        keyboardType: TextInputType.text,
                        cursorColor:const Color(0xff994D1C),
                        decoration: const InputDecoration(
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
                      padding: const EdgeInsets.only(left: 30, right: 30, top: 7, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            // TextField untuk menampilkan tanggal lahir
                            child: TextField(
                              style: const TextStyle(
                                  color: Colors.black
                              ),
                              controller: tanggallahirController, // Controller untuk tanggal lahir
                              decoration: const InputDecoration(
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
                            icon: const Icon(Icons.calendar_today, color: Color(0xff994D1C),), // Ikon kalender
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
                                      colorScheme: const ColorScheme.light(
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
                          canvasColor: const Color(0xFFF5CCA0)
                        ),
                        child: Container(
                          color: const Color(0xFFF5CCA0),
                          width: double.maxFinite,
                          child: DropdownButtonFormField<String>(
                            value: dropdownValue,
                            icon:  const Icon(Icons.arrow_drop_down_outlined, color: Colors.black,),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:  const Color(0xFFF5CCA0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black )
                              ),
                                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff994D1C)),borderRadius: BorderRadius.circular(15),)
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                        
                            items: kelamin.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(color: Colors.black),),
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
                            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                        ),
                        onPressed: () async {
                          bool SimpanAnggota = await dataProvider.connectAPIIsiDataAnggota(nama, telepon, email, alamat, tanggal_lahir, dropdownValue??"");
                          if(SimpanAnggota){
                            var snackBar = const SnackBar(
                              content: Text("Berhasil disimpan"),
                              duration: Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            print(dataProvider.anggotadata);

                          }else{
                            var snackBar = const SnackBar(
                              content: Text("gagal disimpan"),
                              duration: Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            print(dataProvider.anggotadata);
                          }
                        },
                        child: const Row(
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
          backgroundColor: const Color(0xff6B240C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,

          currentIndex: selected_index,
          onTap: onItemTapped,
          items: const <BottomNavigationBarItem>[
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
