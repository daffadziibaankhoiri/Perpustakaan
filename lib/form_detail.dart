import 'package:flutter/material.dart';

class Form_Detail extends StatelessWidget {
   Form_Detail({super.key});

  @override
  Widget build(BuildContext context) {
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
        ),
      body: Container(
        color: Color(0xFFF5CCA0),
        child: SingleChildScrollView( // Menggunakan SingleChildScrollView untuk mengizinkan scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              Container(
                height: 253,
                width: 162,
                color: Colors.white,
              ),
              Text(
                "Psychology of Money",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Text(
                "by Morgan Housel",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 70.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                  ),
                  onPressed: () {},
                  child: Row(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Jenis : ",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      "Kategori : ",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      "Sinopsis : KESUKSESAN dalam mengelola uang tidak selalu tentang apa yang Anda ketahui. Ini tentang bagaimana Anda berperilaku. Dan perilaku sulit untuk diajarkan, bahkan kepada orang yang sangat pintar sekalipun. Seorang genius yang kehilangan kendali atas emosinya bisa mengalami bencana keuangan. Sebaliknya, orang biasa tanpa pendidikan finansial bisa kaya jika mereka punya sejumlah keahlian terkait perilaku yang tak berhubungan dengan ukuran kecerdasan formal.Uang-investasi, keuangan pribadi, dan keputusan bisnis-biasanya diajarkan sebagai bidang berbasis matematika, dengan data dan rumus memberi tahu kita apa yang harus dilakukan. Namun di dunia nyata, orang tidak membuat keputusan finansial di spreadsheet. Mereka membuatnya di meja makan, atau di ruang rapat, di mana sejarah pribadi, pandangan unik Anda tentang dunia, ego, kebanggaan. pemasaran, dan berbagai insentif bercampur.Dalam The Psychology of Money, penulis pemenang penghargaan. Morgan Housel membagikan 19 cerita pendek yang mengeksplorasi cara-cara aneh orang berpikir tentang uang dan mengajari Anda cara memahami salah satu topik terpenting dalam hidup dengan lebih baik.",
                      softWrap: true,
                      style: TextStyle(color: Colors.black, fontSize: 15),
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
