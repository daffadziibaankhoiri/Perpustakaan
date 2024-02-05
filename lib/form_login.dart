import 'package:flutter/material.dart';
import 'package:neulibrary/form-register.dart';
import 'form_main.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
import 'package:neulibrary/Models/SharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_detail.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // bool userIsLoggedIn = await SharedPref.isLoggedIn();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HttpProvider(),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: Form_Login(),
      ),
    );
  }
}


class Form_Login extends StatefulWidget {
  const Form_Login({super.key});

  @override
  State<Form_Login> createState() => _Form_LoginState();
}

class _Form_LoginState extends State<Form_Login> {
  HttpProvider? dataProvider;
  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkLoginStatus());
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Simpan referensi ke provider
    dataProvider = Provider.of<HttpProvider>(context);
  }
  String loginemail = "";
  String loginpassword = "";
  String Token = "";
  int user_id = 0;
  int Id = 0;
  void setPrefs() async {
    final simpanan = await SharedPreferences.getInstance();
    simpanan.setString('token', Token);
    simpanan.setInt('user_id', user_id);
    String? tesShared = simpanan.getString('token');
    int? id_user = simpanan.getInt('user_id');
    print('isi id $id_user');
    print("isi token $tesShared");
  }
  bool show = true;
  final TextEditingController loginemailController = TextEditingController();
  final TextEditingController loginpassController = TextEditingController();
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Cek apakah token ada atau tidak, dan apakah token itu valid.
    // Anda mungkin perlu memeriksa ke server apakah token masih valid jika aplikasi Anda memerlukannya.
    if(token != null){
      print("token untuk auto login : $token");

      // Jika token ada dan tidak kosong, arahkan ke Form_Main
      navigateToMain();
    }
    // Jika tidak ada token, aplikasi akan tetap di halaman login
  }

  void navigateToMain() {
    print("ternavigasi");
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Form_Main())
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();//
    // checkLoginStatus(context);
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home: Scaffold(
        // key: _scaffoldKey,
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
          // centerTitle: true,

        ),

        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('Asset/bg.jpeg'),
              fit: BoxFit.cover
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  color: Colors.white.withOpacity(0.7),
                  elevation: 15,
                  child: Column(
                    children: [
                      // Image(image: AssetImage('Asset/bg.jpeg')),
                      const Padding(
                        padding: EdgeInsets.only(top: 50, bottom: 20),
                        child: Text(

                          'Login',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 20),
                        child: TextField(
                          // autocorrect: false,
                          // autofocus: false,
                          // enableSuggestions: false,
                          // enableInteractiveSelection: true,
                          // obscureText: false,
                          controller: loginemailController,
                          onChanged: (email){
                            setState(() {
                              loginemail = email;
                            });
                          },
                          style: TextStyle(
                            color: Colors.black
                          ),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Color(0xff6B240C),
                          decoration: InputDecoration(
                              isDense: true,
                              icon: Icon(Icons.email, size: 30,color: Colors.black,),
                              // hintText: "Email",
                              labelText: "Username",

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
                      Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 10, bottom: 0),
                        child: TextField(
                          // autocorrect: false,
                          // autofocus: false,
                          // enableSuggestions: false,
                          // enableInteractiveSelection: true,
                          controller: loginpassController,
                          onChanged: (password){
                            setState(() {
                              loginpassword = password;
                            });
                          },
                          style: TextStyle(
                              color: Colors.black
                          ),
                          obscureText: show,
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xff6B240C),
                          decoration: InputDecoration(
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: Icon(show ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                  color: Colors.black,),
                                onPressed: (){
                                  setState(() {
                                    show = !show;
                                  });
                                },
                              ),
                              icon: Icon(Icons.lock, size: 30,color: Colors.black,),
                              // hintText: "Password",
                              labelText: "Password",
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
                        padding: const EdgeInsets.only(left: 110, right: 110, top: 30),
                        child: Builder(
                            builder: (context) {
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                  ),
                                  onPressed: () async {
                                    // Navigator.pushReplacement(context,
                                    //     MaterialPageRoute(builder: (context) => Form_Main())
                                    // );
                                    if(loginemail.isEmpty){
                                      var snackBar = SnackBar(
                                        content: Text("Email is required"),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else if(loginpassword.isEmpty){
                                      var snackBar = SnackBar(
                                        content: Text("Password is required"),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else{
                                      // loginemailController.clear();
                                      // loginpassController.clear();
                                      bool loginSucces = await dataProvider.connectAPILogin(loginemail, loginpassword);
                                      if(loginSucces){
                                        Token = dataProvider.logindata["authorization"]["token"];
                                        user_id = dataProvider.logindata["user"]["id"];
                                        print(Token);
                                        setPrefs();
                                        //
                                        var snackBar = SnackBar(
                                          content: Consumer<HttpProvider>(
                                              builder: (context, value, child) =>
                                                  Text("Berhasil Login")),
                                          duration: Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(builder: (context) => Form_Main())
                                        );
                                      }else{
                                        var snackBar = SnackBar(
                                          content: Consumer<HttpProvider>(
                                              builder: (context, value, child) => Text(value.logindata["error"]?? "Username atau Password Salah")),
                                          duration: Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        // Navigator.pushReplacement(context,
                                        //     MaterialPageRoute(builder: (context) => Form_Home())
                                        // );
                                      }


                                    }

                                  },

                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login_outlined, color: Colors.white,),
                                      SizedBox(width: 10),
                                      Text(
                                        "Login",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20
                                        ),
                                      )
                                    ],
                                  )
                              );
                            }
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

