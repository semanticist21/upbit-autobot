import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Expanded(
              flex: 2,
              child: SizedBox(
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            opacity: 0.8,
                            image: AssetImage(
                                'lib/assets/login_background_left.png'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Color.fromRGBO(227, 242, 253, 0.6),
                        Color.fromRGBO(227, 242, 253, 0.1)
                      ], begin: Alignment.topCenter, end: Alignment.center)),
                    )
                  ],
                ),
              )),
          Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Color.fromRGBO(117, 117, 117, 0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      SizedBox(width: 5),
                      Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w900,
                            fontSize: 25),
                      )
                    ]),
                    SizedBox(height: 20),
                    TextField(
                      style: TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                          hintText: "Public Key",
                          prefixIcon: Icon(FontAwesomeIcons.user),
                          filled: true,
                          fillColor: Color.fromARGB(31, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      obscureText: true,
                      style: TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        hintText: "Secret Key",
                        prefixIcon: Icon(FontAwesomeIcons.lock),
                        filled: true,
                        fillColor: Color.fromARGB(31, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Login"),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(18.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor:
                                Color.fromRGBO(100, 181, 246, 0.7)),
                      ),
                      SizedBox(
                        width: 5,
                      )
                    ])
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
