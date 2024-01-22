import 'package:flutter/material.dart';
import 'package:neulibrary/form-register.dart';
import 'form_home.dart';
import 'form_main.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
import 'package:neulibrary/Models/SharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_detail.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // bool userIsLoggedIn = await SharedPref.isLoggedIn();
  runApp( ChangeNotifierProvider(
    create: (context) => HttpProvider(),
    child: Form_Login()
  ));
}

class Form_Login extends StatefulWidget {
  const Form_Login({super.key});

  @override
  State<Form_Login> createState() => _Form_LoginState();
}

class _Form_LoginState extends State<Form_Login> {
  @override
  void initState() {
    super.initState();
    // checkLoginStatus();
  }
  String loginemail = "if@else.co";
  String loginpassword = "123456";
  void setPrefs() async {
    final simpanan = await SharedPreferences.getInstance();
    simpanan.setString('email', loginemail);
    String? tesShared = simpanan.getString('email');
    print(tesShared);
  }
  bool show = true;
  final TextEditingController loginemailController = TextEditingController();
  final TextEditingController loginpassController = TextEditingController();
  // Future<void> checkLoginStatus(BuildContext context) async {
  //   bool userIsLoggedIn = await SharedPref.isLoggedIn();
  //   if (userIsLoggedIn) {
  //     String? token = await SharedPref.getStringValue("accessToken");
  //     var snackBar = SnackBar(
  //       content: Consumer<HttpProvider>(
  //           builder: (context, value, child) => Text(token??" ada token" )),
  //       duration: Duration(seconds: 1),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     print("token ada tapi tidak redirect");
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Form_Main()));
  //   }else{
  //     String? token = await SharedPref.getStringValue("accessToken");
  //     var snackBar = SnackBar(
  //       content: Consumer<HttpProvider>(
  //           builder: (context, value, child) => Text(token??"tidak ada token" )),
  //       duration: Duration(seconds: 1),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     print("gagal login");
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    // checkLoginStatus(context);
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home: Scaffold(

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
                          cursorColor: Colors.blueAccent,
                          decoration: InputDecoration(
                              isDense: true,
                              icon: Icon(Icons.email, size: 30,color: Colors.black,),
                              // hintText: "Email",
                              labelText: "Email",

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
                          cursorColor: Colors.blueAccent,
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
                        padding: const EdgeInsets.only(left: 130, right: 130, top: 30),
                        child: Builder(
                            builder: (context) {
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff994D1C))
                                  ),
                                  onPressed: () async {
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) => Form_Main())
                                    );
                                   setPrefs();
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
                                        var snackBar = SnackBar(
                                          content: Consumer<HttpProvider>(
                                              builder: (context, value, child) => Text(value.logindata["access_token"] ?? "Access token not found")),
                                          duration: Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(builder: (context) => Form_Main())
                                        );
                                      }else{
                                        var snackBar = SnackBar(
                                          content: Consumer<HttpProvider>(
                                              builder: (context, value, child) => Text(value.logindata["error"]?? "error")),
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
                      Builder(
                        builder: (context) {
                          return InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Form_Register())
                              );
                            },
                            child: Text(
                              "Register Now",
                              style: TextStyle(
                                color: Color(0xff994D1C),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xff994D1C)
                              ),

                            ),
                          );
                        }
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

