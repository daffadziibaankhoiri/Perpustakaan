import 'package:flutter/material.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';

class Form_History extends StatefulWidget {
  Form_History({super.key});

  @override
  State<Form_History> createState() => _Form_HistoryState();
}

class _Form_HistoryState extends State<Form_History> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    _historyFuture = dataProvider.connectAPIgetHistory();
  }

  void refresh (){
    setState(() {
      final dataProvider = Provider.of<HttpProvider>(context, listen: false);
      _historyFuture = dataProvider.connectAPIgetHistory();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Color(0xff6B240C),
        title: Text(
          "NeuLibrary",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Caveat',
              fontSize: 30
          ),
        ),
      ),
      body:   Container(
        height: double.maxFinite,
        width: double.maxFinite,
        color: Color(0xFFF5CCA0),
        child: Column(
          children: [
            Text(
              "History",

              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 1, left: 10,right: 10, bottom: 10),
                child: Container(
                  // color: Colors.red,
                  child: Column(
                    children: [
                      FutureBuilder(
                          future: _historyFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 200),
                                  child: CircularProgressIndicator( color: Color(0xff6B240C),
                                    backgroundColor: Color(0xFFF5CCA0),),
                                ),
                              ); // Menampilkan spinner saat data sedang dimuat
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 180),
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
                                      color: Color(0xff6B240C),
                                      backgroundColor: Color(0xFFF5CCA0),
                                      onRefresh: () async {
                                        refresh();
                                      },
                                      child: GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                                        child: Container(
                                                            height: 120,
                                                            width: 80,
                                                            child: Image(
                                                                image: NetworkImage("${history[index]['buku']["image"]}")
                                                            )
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            SizedBox(
                                                              height: 5,
                                                            ),

                                                            Text(
                                                              history[index]['buku']["judul"]??"judul",maxLines: 2,overflow: TextOverflow.ellipsis,

                                                              textAlign: TextAlign.left,style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, height: 1),),
                                                            Text("By "+history[index]['buku']["pengarang"]??"pengarang",maxLines: 1,overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                            Text(
                                                              history[index]['buku']["sinopsis"]??"sinopsis",
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
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
                                                                  Text("${history[index]['start_at']} sampai ${history[index]['end_at']} ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),),
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

    );
  }
}
