import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Kategori.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HttpProvider extends ChangeNotifier{
  Map<String, dynamic> _dataanggota = {};
  Map<String, dynamic> _getdataanggota = {};
  Map<String, dynamic> _datalogout = {};
  Map<String, dynamic> _datalogin = {};
  List< dynamic> _databuku = [];
  List<dynamic> _datakategori = [];
  Map<String, dynamic> _databarcode = {};
  Map<String, dynamic> _datadetailbuku = {};
  Map<String, dynamic> _datapostbuku = {};
  Map<String, dynamic> _datahapuscart = {};
  Map<String, dynamic> _datapostcart = {};
  List<dynamic> _datakeranjang = [];
  List<dynamic> _datahistory = [];
  List<dynamic> _datahistorydipinjam = [];



  Map<String, dynamic> get anggotadata => _dataanggota;
  Map<String, dynamic> get getanggotadata => _getdataanggota;
  Map<String, dynamic> get logoutdata => _datalogout;
  Map<String, dynamic> get logindata => _datalogin;
  List<dynamic> get bukudata => _databuku;
  List<dynamic> get kategoridata => _datakategori;
  List<dynamic> get keranjangdata => _datakeranjang;
  List<dynamic> get historydata => _datahistory;
  List<dynamic> get historydipinjamdata => _datahistorydipinjam;
  Map<String, dynamic> get barcodedata => _databarcode;
  Map<String, dynamic> get bukudetaildata => _datadetailbuku;
  Map<String, dynamic> get postbukudata => _datapostbuku;
  Map<String, dynamic> get postcartdata => _datapostcart;
  Map<String, dynamic> get hapuscartdata => _datahapuscart;

  int get jumlahDataAnggota => _dataanggota.length;
  int get jumlahGetDataAnggota => _getdataanggota.length;
  int get jumlahDataregis => _datalogout.length;
  int get jumlahDatalogin => _datalogin.length;
  int get jumlahDatabuku => _databuku.length;
  int get jumlahkategori => _datakategori.length;
  int get jumlahDatabukudetail => _datadetailbuku.length;
  int get jumlahDataKeranjang => _datakeranjang.length;
  int get jumlahDataHistory => _datahistory.length;
  int get jumlahDataHistoryDipinjam => _datahistorydipinjam.length;

  void resetDetailData() {
    _datadetailbuku = {};
    notifyListeners();
  }
  void resetAddCartData(){
    _datapostbuku = {};
    notifyListeners();
  }
  void resetPinjam(){
    _datapostcart = {};
    notifyListeners();
  }
  void resetCartData(){
    _datakeranjang = [];
    notifyListeners();
  }
  void resetHistoryDipinjam(){
    _datahistorydipinjam = [];
    notifyListeners();
  }

  Future<bool> connectAPIGetAnggota() async {
    _getdataanggota = {};
    final simpanan = await SharedPreferences.getInstance();
    int? idUser = simpanan.getInt('user_id');
    // int id_anggota = simpanan.setString(key, value)
    // simpanan.remove('user_id');
    print('user id $idUser');
    Uri Anggotaurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/anggota/$idUser");
    print(Anggotaurl);
    try {
      var response = await http.get(Anggotaurl);
      print(response.statusCode);
      if (response.statusCode == 200) {
        _getdataanggota = json.decode(response.body);
        print(_getdataanggota);
        notifyListeners();
        return true; // Login success
      } else {
        _getdataanggota = json.decode(response.body);
        print(_getdataanggota);
        notifyListeners();
        return false; // Login failed
      }
    } catch (error) {
      print(error);
      return false; // Login failed
    }
  }
  Future<bool> connectAPIIsiDataAnggota(String nama,String telepon, String email, String alamat, String tanggalLahir,String jenisKelamin) async {
    final simpanan = await SharedPreferences.getInstance();
    int? idUser = simpanan.getInt("user_id");
    print(idUser.toString());
    Uri Anggotaurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/anggota/tambah");

    try{
      var response = await http.post(
        Anggotaurl,
        // headers: {
        //   'Content-Type' : 'application/json'
        // },
        body: {
          "id_user" : idUser.toString(),
          "nama" : nama,
          "telpon" : "08$telepon",
          "email" : email,
          "alamat" : alamat,
          "tanggal_lahir" : tanggalLahir,
          "jenis_kelamin" : jenisKelamin,
        },

      );
      print(response.body);

      if(response.statusCode == 201){
        _dataanggota  = json.decode(response.body);
        print(_dataanggota);



        notifyListeners();
        return true;
      }else{
        _dataanggota = json.decode(response.body);
        print(_dataanggota);
        notifyListeners();
        return false;

      }
    }catch (error){
      print("error: $error");
      return false;

    }


  }
  Future<bool> connectAPILogin(String username, String password) async {
    Uri Loginurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/login");

    try {
      var response = await http.post(
        Loginurl,
        body: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        _datalogin = json.decode(response.body);
        print(_datalogin);
        notifyListeners();
        return true; // Login success
      } else {
        _datalogin = json.decode(response.body);
        notifyListeners();
        return false; // Login failed
      }
    } catch (error) {
      print(error);
      return false; // Login failed
    }
  }
  Future<bool> connectAPILogout() async {
    final simpanan = await SharedPreferences.getInstance();
    String? token = simpanan.getString('token');
    Uri logoutUrl = Uri.parse("https://magang-neu.neumediradev.my.id/api/logout");
    try {
      var response = await http.post(
        logoutUrl,
        headers: {
          'Authorization': 'Bearer $token', // Tambahkan token Anda di sini
          // Jika perlu, tambahkan header lain yang diperlukan oleh API
        },
      );

      if (response.statusCode == 200) {
        // Logout sukses
        _datalogout = json.decode(response.body);
        print(_datalogout);
        simpanan.remove('token');
        return true;
      } else {
        // Logout gagal
        return false;
      }
    } catch (error) {
      // Handle error atau gagal koneksi
      return false;
    }
  }

  Future<List> connectAPISearchBook(String search, int? kategori) async {

    Uri searchurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/buku/search?keyword=$search&kategori=$kategori");

    print(searchurl);
      var response = await http.get(searchurl);
      print(response.statusCode);
      if(response.statusCode == 200){
        _databuku = json.decode(response.body);
        // _databuku = booksDynamic.whereType<Map<String, dynamic>>().toList();
        // print(response.body);
        notifyListeners();
        return _databuku;
      }
      else{
       // _databuku = (json.decode(response.body))[""];
        print(response.body);
        notifyListeners();
        return [];
      }
    // }catch (error){
    //   print(error);
    //   return {};
    // }
  }
  Future<bool> connectAPIDetailBuku(int id) async {
    Uri detailUrl = Uri.parse("https://magang-neu.neumediradev.my.id/api/buku/$id");
    try{
      var response = await http.get(detailUrl);
      if(response.statusCode == 200){
        _datadetailbuku = json.decode(response.body);
        print(_datadetailbuku);
        return true;
      }else{
        _datadetailbuku = {};
        print(_datadetailbuku);
        return false;

      }
    }catch(error){
      print("error saat fetch : $error");
      return false;

    }
  }
  Future<bool> connectAPIBarcode(String barcode) async {
    Uri barcodeUrl = Uri.parse("https://magang-neu.neumediradev.my.id/api/buku/barcode");
    try{
        var response = await http.post(barcodeUrl,
            body: {
              'barcode' : barcode
            }
        );
        if(response.statusCode == 200){
          _databarcode = json.decode(response.body);
          print("detail buku baarcode ($barcode): $_databarcode");
          return true;
        }else{
          return false;
        }
    }catch (error){
      return false;
    }
  }

  Future<List> connectAPIkategori() async {
    Uri kategoriurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/buku/kategoriAll");

      var response = await http.get(kategoriurl);
      print(response.statusCode);
      if(response.statusCode == 200){
        List<dynamic> jsonList = json.decode(response.body);
        print(response.body);
        _datakategori = jsonList.map((json) => Kategori.fromJson(json)).toList();
        print(_datakategori);
        notifyListeners();
        return _datakategori;
      }else{
        notifyListeners();
        return [];
      }
  }

  Future<bool> connectAPIAddToCart(int Bukuid) async {
    resetAddCartData();
    Uri addUrl = Uri.parse("https://magang-neu.neumediradev.my.id/api/pinjam/addToCart");
    final simpanan = await SharedPreferences.getInstance();
    int idAnggota = simpanan.getInt('id_anggota')??0;
    try{
      var response = await http.post(
          addUrl,
          body: {
            'id_anggota' : idAnggota.toString(),
            'id_buku' : Bukuid.toString(),
          }

      );
    if(response.statusCode == 200){
      _datapostbuku = json.decode(response.body);
      print(_datapostbuku);
      notifyListeners();
      return true;
    }else{
      _datapostbuku = json.decode(response.body);
      print(response.statusCode);
      return false;
    }
    }catch(error){
      print("error : $error");
      return false;
    }
  
  }
  Future<List> connectAPIgetCart() async {
    resetCartData();
    final simpanan = await SharedPreferences.getInstance();
    int idAnggota = simpanan.getInt('id_anggota')??0;
    Uri searchurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/pinjam/getKeranjang/$idAnggota");

    print(searchurl);
    var response = await http.get(searchurl);
    print(response.statusCode);
    if(response.statusCode == 200){
      _datakeranjang = json.decode(response.body);

      notifyListeners();
      return _datakeranjang;
    }
    else{
      // _databuku = (json.decode(response.body))[""];
      print(response.body);

      notifyListeners();
      return [];
    }

  }
  Future<List> connectAPIgetHistoryDikembalikan() async {
    final simpanan = await SharedPreferences.getInstance();
    int idAnggota = simpanan.getInt('id_anggota')??0;
    Uri searchurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/pinjam/getHistoryDikembalikan/$idAnggota");

    print(searchurl);
    var response = await http.get(searchurl);
    print(response.statusCode);
    if(response.statusCode == 200){
      _datahistory = json.decode(response.body);

      notifyListeners();
      return _datahistory;
    }
    else{
      // _databuku = (json.decode(response.body))[""];
      print(response.body);
      // notifyListeners();
      return [];
    }

  }
  Future<List> connectAPIgetHistoryDipinjam() async {
    resetHistoryDipinjam();
    final simpanan = await SharedPreferences.getInstance();
    int idAnggota = simpanan.getInt('id_anggota')??0;
    Uri searchurl = Uri.parse("https://magang-neu.neumediradev.my.id/api/pinjam/getHistoryDipinjam/$idAnggota");

    print(searchurl);
    var response = await http.get(searchurl);
    print(response.statusCode);
    if(response.statusCode == 200){
      _datahistorydipinjam = json.decode(response.body);

      notifyListeners();
      return _datahistorydipinjam;
    }
    else{
      // _databuku = (json.decode(response.body))[""];
      print(response.body);
      // notifyListeners();
      return [];
    }

  }
  Future<bool> connectAPIHapusItemCart(int idCart) async {
    Uri barcodeUrl = Uri.parse("https://magang-neu.neumediradev.my.id/api/pinjam/hapusBukuFromCart/$idCart");
    try{
      var response = await http.delete(barcodeUrl,
      );
      if(response.statusCode == 200){
        _datahapuscart = json.decode(response.body);
        print(_datahapuscart);
        return true;
      }else{
        return false;
      }
    }catch (error){
      return false;
    }
  }
   Future<bool> connectAPIProsesCart() async {
    resetPinjam();
     List cartIDs = _datakeranjang.map((item) => item['id']).toList();
    Uri pinjamUrl = Uri.parse("https://magang-neu.neumediradev.my.id/api/pinjam/buku");
    try{
      var response = await http.post(pinjamUrl,
          headers: {
            'Content-Type': 'application/json', // Specify the content type as JSON
          },
        body: json.encode({
          'id': cartIDs,
        }),
      );
      if(response.statusCode == 200){
        _datapostcart = json.decode(response.body);
        print(_datapostcart);
        return true;
      }else{
        print(response.body);
        return false;
      }
    }catch (error){
      print(error);
      return false;
    }
  }


}