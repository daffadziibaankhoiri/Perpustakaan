import 'package:flutter/material.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
class tesAPI extends StatefulWidget {
  const tesAPI({super.key});

  @override
  State<tesAPI> createState() => _tesAPIState();
}

class _tesAPIState extends State<tesAPI> {

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    var search = "";
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
      ),
      body:   Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: null,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator()); // Menampilkan spinner saat data sedang dimuat
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot
                    .error}")); // Menampilkan pesan error
              } else if (snapshot.hasData) {
                // Mengecek apakah data tersedia

                // List<Map<String, dynamic>> data = snapshot.data!;
                List<dynamic> books = snapshot.data as List<dynamic>;
                print(books[0]["title"]);
                print(books.length);
                return
                  GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: books.length,

                      itemBuilder: (context, index) {
                        // Book buku = Book(books[index]["id"],books[index]["title"],books[index]["image"].toString(),books[index]["sinposis"],books[index]["pengarang"],books[index]["penerbit"],books[index]["terbit"],books[index]["jumlah"],books[index]["dipinjam"],books[index]["halaman"] );
                        // print(buku);
                        // var book = books[index];
                        // print("hasil index $book");
                        // var buku = provider.bukudata['books'][index]; // Sesuaikan dengan struktur data API

                        return GridTile(child: Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 130,
                                  width: 120,
                                  child: Image(
                                      image: NetworkImage("${books[index]["image"]}")
                                )
                              ),
                              Text(books[index]["title"]??"tes",textAlign: TextAlign.center,),
                              Text(books[index]["pengarang"]??"sinopsis", textAlign: TextAlign.center,),
                            ],
                          ),
                        )
                        );
                      }
                  );
              } else {
                return const Center(
                  child: Text("No data available"),
                );
              }

              // }else {
              //   // If there's no data and no error, and not loading, display a default message
              //   return Center(
              //       child: Text("No data to display"));
              // }
            }

        ),
      ),


    );
  }
}
