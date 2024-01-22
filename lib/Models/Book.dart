import 'package:flutter/material.dart';

class Book{
  @required int id;
  @required String title;
  @required String? image;
  @required String sinopsis;
  @required String pengarang;
  @required String penerbit;
  @required String terbit;
  @required int jumlah;
  @required int dipinjam;
  @required int halaman;
  Book(this.id, this.title, this.image,this.sinopsis, this.pengarang, this.penerbit, this.terbit, this.jumlah, this.dipinjam, this.halaman);
}