import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Form_Detail extends StatefulWidget {
  final int bookId;
   const Form_Detail({super.key, required this.bookId});

  @override
  State<Form_Detail> createState() => _Form_DetailState();
}

class _Form_DetailState extends State<Form_Detail> {
  @override
  void initState() {
    super.initState();
    // Memanggil method untuk mengambil detail buku
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HttpProvider>(context, listen: false);
      provider.resetDetailData();
      provider.connectAPIDetailBuku(widget.bookId).then((_) {
        // Setelah data di-fetch, beritahu framework untuk rebuild widget
        if (mounted) {
          setState(() {});
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    print(widget.bookId);
    return Scaffold(
        appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff6B240C),
            title: const Text(
            "NeuLibrary",
              style: TextStyle(
              color: Colors.white,
              fontFamily: 'Caveat',
              fontSize: 30
              ),
            ),
        ),
      body: Container(
        color: const Color(0xFFF5CCA0),
        height: double.maxFinite,
        width: double.maxFinite,
        child: SingleChildScrollView( // Menggunakan SingleChildScrollView untuk mengizinkan scroll
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.maxFinite,
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 253,
                      width: 162,

                      child: Consumer<HttpProvider> (
                        builder: (context, dataProvider, child) {
                          final bukuDetail = dataProvider.bukudetaildata;
                          return CachedNetworkImage(
                          imageUrl: "${bukuDetail["image"]}",
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                                width: 50, // Atur lebar
                                height: 50, // Atur tinggi
                                child: CircularProgressIndicator(color: Color(0xff6B240C)),
                                ),
                            ),
                          errorWidget: (context, url, error) => const Icon(Icons.image_outlined, color: Color(0xff6B240C),),
                          // fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Consumer<HttpProvider>(

                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return  Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            bukuDetail["judul"]??"Loading ...",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        );
                      },
                    ),
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return Text(
                          "by ${bukuDetail["pengarang"]??"Loading ..."}",
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        );
                      },
                    ),
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return Text(
                          "Tersedia : ${bukuDetail["jumlah"]??"Loading ..."}",
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        );
                      },
                    ),




                    Consumer<HttpProvider>(
                        builder: (context, dataProvider, child){
                          final bukuDetail = dataProvider.bukudetaildata;
                          // print("buku tersedia : "+bukuDetail['jumlah']);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 70.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                              ),
                              onPressed: () async {
                                final simpanan = await SharedPreferences.getInstance();
                                int idAnggota = simpanan.getInt('id_anggota')??0;
                                if(idAnggota != 0){
                                  int? tersedia = int.tryParse(bukuDetail['jumlah'] ?? '0'); // '0' adalah nilai default jika `null`
                                  if(tersedia! > 0){
                                    bool add = await dataProvider.connectAPIAddToCart(widget.bookId);
                                    if(add){
                                      var snackBar = SnackBar(
                                        content: Consumer<HttpProvider>(
                                            builder: (context, value, child) =>
                                                Text(value.postbukudata["message"]?? "tidak ada pesan")),
                                        duration: const Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else{
                                      var snackBar = SnackBar(
                                        content: Consumer<HttpProvider>(
                                            builder: (context, value, child) =>
                                                Text(value.postbukudata["message"]?? "tidak ada pesan")),
                                        duration: const Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  }else{
                                    var snackBar = const SnackBar(
                                      content: Text("Buku tidak tersedia"),
                                      duration: Duration(seconds: 1),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                }else{
                                  var snackBar = const SnackBar(
                                    content: Text("Lengkapi Profile kamu terlebih dahulu"),
                                    duration: Duration(seconds: 1),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }


                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min, // Ini akan membuat Row hanya sebesar kontennya
                                children: <Widget>[
                                  Icon(Icons.add_shopping_cart_outlined, color: Colors.white),
                                  SizedBox(width: 4), // Menambahkan sedikit ruang antara ikon dan teks
                                  Text(
                                    "Add to Cart",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },

                    ),
                  ],
                ),
              ),
              // Column(
              //   children: [
              //
              //   ],
              // ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return Text(
                          "Halaman : ${bukuDetail["halaman"]??"Loading ..."}",
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        );
                      },
                    ),
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return  Text(
                          "Kategori : ${bukuDetail["kategori"]??"Loading ..."}",
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        );
                      },
                    ),
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return Text(
                          "Penerbit : ${bukuDetail["penerbit"]??"Loading ..."}",
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        );
                      },
                    ),
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return Text(
                          "Tahun Terbit : ${bukuDetail["tahun_terbit"]??"Loading ..."}",
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        );
                      },
                    ),
                    Consumer<HttpProvider>(
                      builder: (context, dataProvider, child){
                        final bukuDetail = dataProvider.bukudetaildata;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Sinopsis : ${bukuDetail["sinopsis"]??"Loading ..."}",
                            softWrap: true,
                            style: const TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        );
                      },
                    ),





                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );

  }
}
