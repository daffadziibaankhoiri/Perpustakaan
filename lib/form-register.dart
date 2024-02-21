import 'package:flutter/material.dart';
import 'package:neulibrary/Models/Http_provider.dart';
import 'package:provider/provider.dart';
class Form_Register extends StatefulWidget {
  const Form_Register({super.key});

  @override
  State<Form_Register> createState() => _Form_RegisterState();
}

class _Form_RegisterState extends State<Form_Register> {

  String registeremail = "";
  String registerpassword = "";
  String registerphone = "";
  String regsitername = "";
  bool show = true;
  final TextEditingController registeremailController = TextEditingController();
  final TextEditingController registerpassController = TextEditingController();
  final TextEditingController registerphoneController = TextEditingController();
  final TextEditingController registernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<HttpProvider>(context, listen: false);
    precacheImage(const AssetImage('Asset/bg.jpeg'), context);
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
        // centerTitle: true,

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
          children: [

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                color: Colors.white.withOpacity(0.7),
                elevation: 15,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Image(image: AssetImage('Asset/bg.jpeg')),
                      const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 12),
                        child: Text(
                                
                          'Register',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7),
                        child: TextField(
                          // autocorrect: false,
                          // autofocus: false,
                          // enableSuggestions: false,
                          // enableInteractiveSelection: true,
                          // obscureText: false,
                          controller: registernameController,
                          onChanged: (name){
                            setState(() {
                              regsitername = name;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black
                          ),
                          keyboardType: TextInputType.name,
                          cursorColor:const Color(0xff994D1C),
                          decoration: const InputDecoration(
                              isDense: true,
                              icon: Icon(Icons.person, size: 30,color: Colors.black,),
                              // hintText: "Fullname",
                              labelText: "Fullname",
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
                      Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7),
                        child: TextField(
                          // autocorrect: false,
                          // autofocus: false,
                          // enableSuggestions: false,
                          // enableInteractiveSelection: true,
                          // obscureText: false,
                          controller: registerphoneController,
                          onChanged: (phone){
                            setState(() {
                              registerphone = phone;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black
                          ),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor:const Color(0xff994D1C),
                          decoration: const InputDecoration(
                              isDense: true,
                              icon: Icon(Icons.phone, size: 30,color: Colors.black,),
                              // hintText: "Phone Number",
                              labelText: "Phone Number",
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
                      Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7),
                        child: TextField(
                          // autocorrect: false,
                          // autofocus: false,
                          // enableSuggestions: false,
                          // enableInteractiveSelection: true,
                          // obscureText: false,
                          controller: registeremailController,
                          onChanged: (email){
                            setState(() {
                              registeremail = email;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black
                          ),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor:const Color(0xff994D1C),
                          decoration: const InputDecoration(
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
                                
                      Padding(padding: const EdgeInsets.only(left: 30,right: 30,top: 7, bottom: 0),
                        child: TextField(
                          // autocorrect: false,
                          // autofocus: false,
                          // enableSuggestions: false,
                          // enableInteractiveSelection: true,
                          controller: registerpassController,
                          onChanged: (password){
                            setState(() {
                              registerpassword = password;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black
                          ),
                          obscureText: show,
                          keyboardType: TextInputType.text,
                          cursorColor:const Color(0xff994D1C),
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
                        padding: const EdgeInsets.only(left: 110, right: 110, top: 10),
                        child: Builder(
                            builder: (context) {
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff994D1C))
                                  ),
                                  onPressed: () async {
                                    if(registeremail.isEmpty){
                                      var snackBar = const SnackBar(
                                        content: Text("Email is required"),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else if(registerpassword.isEmpty){
                                      var snackBar = const SnackBar(
                                        content: Text("Password is required"),
                                        duration: Duration(seconds: 1),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else{

                                      // bool registerSuccess = await dataProvider.connectAPIRegister(regsitername, registeremail, registerpassword, registerphone);
                                      // if(registerSuccess){
                                      //   registeremailController.clear();
                                      //   registerpassController.clear();
                                      //   registerphoneController.clear();
                                      //   registernameController.clear();
                                      //   var snackBar = SnackBar(
                                      //     content: Consumer<HttpProvider>(
                                      //         builder: (context, value, child) => Text(value.regisdata["message"]?? "message not found")),
                                      //     duration: Duration(seconds: 1),
                                      //   );
                                      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      //   Navigator.pop(context);
                                      // }else{
                                      //   var snackBar = SnackBar(
                                      //     content: Consumer<HttpProvider>(
                                      //         builder: (context, value, child) => Text(value.regisdata[""]?? "error")),
                                      //     duration: Duration(seconds: 1),
                                      //   );
                                      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      // }

                                    }
                                
                                  },
                                
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.app_registration_outlined, color: Colors.white,),
                                      SizedBox(width: 10),
                                      Text(
                                        "Register",
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
                      // Builder(
                      //     builder: (context) {
                      //       return InkWell(
                      //         onTap: (){
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(builder: (context) => Form_Register())
                      //           );
                      //         },
                      //         child: Text(
                      //           "Register Now",
                      //           style: TextStyle(
                      //               color: Color(0xff994D1C),
                      //               decoration: TextDecoration.underline,
                      //               decorationColor: Color(0xff994D1C)
                      //           ),
                      //
                      //         ),
                      //       );
                      //     }
                      // ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
