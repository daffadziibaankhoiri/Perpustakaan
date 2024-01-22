import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SharedPref.dart';

class HttpProvider extends ChangeNotifier{
  Map<String, dynamic> _dataregis = {};
  Map<String, dynamic> _datalogin = {};
  List< dynamic> _databuku = [];

  Map<String, dynamic> get regisdata => _dataregis;
  Map<String, dynamic> get logindata => _datalogin;
  List<dynamic> get bukudata => _databuku;

  int get jumlahDataregis => _dataregis.length;
  int get jumlahDatalogin => _datalogin.length;
  int get jumlahDatabuku => _databuku.length;

  Future<bool> connectAPIRegister(String name,String email, String password, String no_telp) async {
    Uri Regisurl = Uri.parse("http://192.168.1.102:8002/api/auth/register");

    try{
      var response = await http.post(
        Regisurl,
        body: {
          "name" : name,
          "email" : email,
          "password" : password,
          "no_telp" : no_telp,
        },
      );
      if(response.statusCode == 201){
        _dataregis  = json.decode(response.body);
        String accessToken = _datalogin["access_token"];
        int userId = _datalogin["user"]["id"];

        await SharedPref.setIntValue("id", userId);
        await SharedPref.setStringValue("accessToken", accessToken);

        notifyListeners();
        return true;
      }else{
        _dataregis  = json.decode(response.body);
        notifyListeners();
        return false;

      }
    }catch (error){
      return false;
    }


  }
  Future<bool> connectAPILogin(String email, String password) async {
    Uri Loginurl = Uri.parse("http://192.168.1.101:8002/api/auth/login");

    try {
      var response = await http.post(
        Loginurl,
        body: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        _datalogin = json.decode(response.body);
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

  Future<List> connectAPISearchBook(String search) async {
    Uri searchurl = Uri.parse("http://192.168.1.101:8002/api/search?title="+search);


      var response = await http.get(searchurl);
      if(response.statusCode == 200){
        _databuku = json.decode(response.body);
        // _databuku = booksDynamic.whereType<Map<String, dynamic>>().toList();
        // print(response.body);
        return _databuku;
      }
      else{
       // _databuku = (json.decode(response.body))[""];
        print(response.body);
        return [];
      }
    // }catch (error){
    //   print(error);
    //   return {};
    // }
  }

}