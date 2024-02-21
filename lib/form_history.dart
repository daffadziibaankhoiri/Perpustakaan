import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';

class Form_History extends StatefulWidget {
  const Form_History({super.key});

  @override
  State<Form_History> createState() => _Form_HistoryState();
}

class _Form_HistoryState extends State<Form_History> {

  late Future<List<dynamic>> _historyFuture;
   late Future<List<dynamic>> _historyDipinjamFuture;

  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    _historyFuture = dataProvider.connectAPIgetHistoryDikembalikan();
    _historyDipinjamFuture =  dataProvider.connectAPIgetHistoryDipinjam();
  }

  void refresh (){
    if (mounted) {
      setState(() {
        final dataProvider = Provider.of<HttpProvider>(context, listen: false);
        _historyFuture = dataProvider.connectAPIgetHistoryDikembalikan();
      });
    }
  }
  void refreshdipinjam () {
    if (mounted) {
      setState(() {
        final dataProvider = Provider.of<HttpProvider>(context, listen: false);
        _historyDipinjamFuture = dataProvider.connectAPIgetHistoryDipinjam();
      });
    }
  }
  List<Tab> mytab =  [
    const Tab(
      text: "Dipinjam",
      icon: Icon(Icons.bookmark_added_outlined),
    ),
    const Tab(
      text: "Dikembalikan",
      icon: Icon(Icons.assignment_return_outlined),
       ),
    ];
    @override
    Widget build(BuildContext context) {
    return DefaultTabController(
        length: mytab.length,
        child: Scaffold(
      appBar: AppBar(

        backgroundColor: const Color(0xff6B240C),
        title: const Text(
          "NeuLibrary",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Caveat',
              fontSize: 30
          ),
        ),
        bottom: TabBar(
          labelColor: const Color(0xFFF5CCA0),
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
          ),
          unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.normal
          ),
          indicatorColor:const Color(0xFFF5CCA0),
          indicatorPadding: const EdgeInsets.all(5),
          onTap: (index) async {
            if(index == 0){
              setState(() {
                final dataProvider = Provider.of<HttpProvider>(context, listen: false);
                _historyDipinjamFuture = dataProvider.connectAPIgetHistoryDipinjam();
              });
              print("Dipinjam");
            }else if(index == 1){
              setState(() {
                final dataProvider = Provider.of<HttpProvider>(context, listen: false);
                _historyFuture = dataProvider.connectAPIgetHistoryDikembalikan();
              });
              print("dikembalikan");
            }
          },
          tabs: mytab,
        ),

      ),
      body:   TabBarView(
        children: [


         Container(
          height: double.maxFinite,
          width: double.maxFinite,
          color: const Color(0xFFF5CCA0),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10,right: 10, bottom: 10),
                  child: Container(
                    // color: Colors.red,
                    child: Column(
                      children: [
                        FutureBuilder(
                            future: _historyDipinjamFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 200),
                                    child: CircularProgressIndicator( color: Color(0xff6B240C),
                                      backgroundColor: Color(0xFFF5CCA0),),
                                  ),
                                ); // Menampilkan spinner saat data sedang dimuat
                              } else if (snapshot.hasError) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 180),
                                  child: Center(child: Text("Tidak ada Koneksi Internet", style: TextStyle(color: Colors.black),)),
                                ); // Meampilkan pesan error
                              } else if (snapshot.hasData) {
                                // Mengecek apakah data tersedia

                                // List<Map<String, dynamic>> data = snapshot.data!;
                                List<dynamic> historydipinjam = snapshot.data as List<dynamic>;
                                // print(history);
                                // print(history.length);
                                return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: RefreshIndicator(
                                        color: const Color(0xff6B240C),
                                        backgroundColor: const Color(0xFFF5CCA0),
                                        onRefresh: () async {
                                          refreshdipinjam();
                                        },
                                        child: GridView.builder(
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                crossAxisSpacing: 0,
                                                mainAxisSpacing: 0,
                                                childAspectRatio: (120 / 45  )
                                            ),
                                            itemCount: historydipinjam.length,

                                            itemBuilder: (context, index) {

                                              return Card(child: Container(
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
                                                                imageUrl: "${historydipinjam[index]["buku"]["image"]}",
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
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              const SizedBox(
                                                                height: 5,
                                                              ),

                                                              Text(
                                                                historydipinjam[index]['buku']["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                                textAlign: TextAlign.left,style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                              Text("By "+historydipinjam[index]['buku']["pengarang"],maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                              Text(
                                                                historydipinjam[index]['buku']["sinopsis"]??"sinopsis",
                                                                textAlign: TextAlign.left,
                                                                style: const TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 11
                                                                )
                                                                ,overflow: TextOverflow.ellipsis,
                                                                maxLines: 2,
                                                                softWrap: true,),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 0),
                                                                child: Row(
                                                                  children: [
                                                                    Text("${historydipinjam[index]['start_at']} sampai ${historydipinjam[index]['end_at']} ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),),
                                                                    // Padding(
                                                                    //   padding: const EdgeInsets.only(),
                                                                    //   child: Text("End : ${history[index]['end_at']}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                                    // )
                                                                  ],
                                                                ),
                                                              )

                                                            ],
                                                          ),
                                                        ),
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


                            }

                        )
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
                 ),
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: const Color(0xFFF5CCA0),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10,right: 10, bottom: 10),
                    child: Container(
                      // color: Colors.red,
                      child: Column(
                        children: [
                          FutureBuilder(
                              future: _historyFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 200),
                                      child: CircularProgressIndicator( color: Color(0xff6B240C),
                                        backgroundColor: Color(0xFFF5CCA0),),
                                    ),
                                  ); // Menampilkan spinner saat data sedang dimuat
                                } else if (snapshot.hasError) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 180),
                                    child: Center(child: Text("Tidak ada Koneksi Internet", style: TextStyle(color: Colors.black),)),
                                  ); // Meampilkan pesan error
                                } else if (snapshot.hasData) {
                                  // Mengecek apakah data tersedia

                                  // List<Map<String, dynamic>> data = snapshot.data!;
                                  List<dynamic> history = snapshot.data as List<dynamic>;
                                  // print(history);
                                  // print(history.length);
                                  return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: RefreshIndicator(
                                          color: const Color(0xff6B240C),
                                          backgroundColor: const Color(0xFFF5CCA0),
                                          onRefresh: () async {
                                            refresh();
                                          },
                                          child: GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1,
                                                  crossAxisSpacing: 0,
                                                  mainAxisSpacing: 0,
                                                  childAspectRatio: (120 / 45  )
                                              ),
                                              itemCount: history.length,

                                              itemBuilder: (context, index) {

                                                return Card(child: Container(
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
                                                                  imageUrl: "${history[index]["buku"]["image"]}",
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
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),

                                                                Text(
                                                                  history[index]['buku']["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                                  textAlign: TextAlign.left,style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                                Text("By "+history[index]['buku']["pengarang"],maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                                Text(
                                                                  history[index]['buku']["sinopsis"]??"sinopsis",
                                                                  textAlign: TextAlign.left,
                                                                  style: const TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 11
                                                                  )
                                                                  ,overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  softWrap: true,),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 0),
                                                                  child: Row(
                                                                    children: [
                                                                      Text("${history[index]['start_at']} sampai ${history[index]['end_at']} ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),),
                                                                      // Padding(
                                                                      //   padding: const EdgeInsets.only(),
                                                                      //   child: Text("End : ${history[index]['end_at']}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                                      // )
                                                                    ],
                                                                  ),
                                                                )

                                                              ],
                                                            ),
                                                          ),
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


                              }

                          )
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
        )
    );
  }
  }



