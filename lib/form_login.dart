import 'package:flutter/material.dart';
import 'form_main.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HttpProvider(),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: const Form_Login(),
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
  Future<void> chatAdmin () async {
    var encodedMessage = Uri.encodeComponent("*NeuLibrary*\nKeluhan *Lupa Password*\nUsername : ");
    var whatsappUrl = Uri.parse("https://wa.me/6285174315569?text=$encodedMessage");
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    int? idUser = simpanan.getInt('user_id');
    print('isi id $idUser');
    print("isi token $tesShared");
  }
  bool show = true;
  final TextEditingController loginemailController = TextEditingController();
  final TextEditingController loginpassController = TextEditingController();
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if(token != null){
      print("token untuk auto login : $token");
      navigateToMain();
    }
  }

  void navigateToMain() {
    print("ternavigasi");
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Form_Main())
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home: Scaffold(
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
        ),

        body: Container(
          decoration: const BoxDecoration(
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
                      Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
                        child: TextField(
                          controller: loginemailController,
                          onChanged: (email){
                            setState(() {
                              loginemail = email;
                            });
                          },
                          style: const TextStyle(
                            color: Colors.black
                          ),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: const Color(0xff6B240C),
                          decoration: const InputDecoration(
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
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 10, bottom: 0),
                        child: TextField(
                          controller: loginpassController,
                          onChanged: (password){
                            setState(() {
                              loginpassword = password;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black
                          ),
                          obscureText: show,
                          keyboardType: TextInputType.text,
                          cursorColor: const Color(0xff6B240C),
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
                              icon: const Icon(Icons.lock, size: 30,color: Colors.black,),
                              // hintText: "Password",
                              labelText: "Password",
                              border: const OutlineInputBorder(

                              ),

                              labelStyle: const TextStyle(color: Color(0xff6B240C)),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff994D1C)
                                  )
                              )

                          ),
                          // obscuringCharacter: '₯',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 30),
                        child: InkWell(
                          onTap: () async {
                                chatAdmin();
                          },
                          child: const Text("Lupa Password Akun? Hubungi Admin", style: TextStyle(
                              color: Color(0xff6B240C),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xff6B240C),
                            ),

                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 110, right: 110, top: 10),
                        child: Builder(
                            builder: (context) {
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                  ),
                                  onPressed: () async {

                                    if(loginemail.isEmpty){
                                      var snackBar = const SnackBar(
                                        content: Text("Email is required"),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else if(loginpassword.isEmpty){
                                      var snackBar = const SnackBar(
                                        content: Text("Password is required"),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else{
                                      bool loginSucces = await dataProvider.connectAPILogin(loginemail, loginpassword);
                                      if(loginSucces){
                                        Token = dataProvider.logindata["authorization"]["token"];
                                        user_id = dataProvider.logindata["user"]["id"];
                                        print(Token);
                                        setPrefs();
                                        var snackBar = SnackBar(
                                          content: Consumer<HttpProvider>(
                                              builder: (context, value, child) =>
                                                  const Text("Berhasil Login")),
                                          duration: const Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(builder: (context) => const Form_Main())
                                        );
                                      }else{
                                        var snackBar = SnackBar(
                                          content: Consumer<HttpProvider>(
                                              builder: (context, value, child) => Text(value.logindata["error"]?? "Username atau Password Salah")),
                                          duration: const Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                      const SizedBox(
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

