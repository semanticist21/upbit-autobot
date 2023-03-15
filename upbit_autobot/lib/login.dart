import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:upbit_autobot/model/account.dart';

import 'pages/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _publicField = TextEditingController();
  final TextEditingController _secretField = TextEditingController();

  String _warningText = '';
  String _loadingText = '로딩 중..';
  bool _isIndicatorVisible = false;

  @override
  Widget build(BuildContext context) {
    _publicField.removeListener(_checkPublicString);
    _secretField.removeListener(_checkSecretString);
    _publicField.addListener(_checkPublicString);
    _secretField.addListener(_checkSecretString);

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
                      enabled: !_isIndicatorVisible,
                      controller: _publicField,
                      cursorColor: Colors.grey,
                      style: TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        hintText: "Public Key",
                        hintStyle: TextStyle(
                            color: Color.fromRGBO(66, 66, 66, 0.3),
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        prefixIcon: Icon(
                          FontAwesomeIcons.user,
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(31, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _secretField,
                      enabled: !_isIndicatorVisible,
                      cursorColor: Colors.grey,
                      obscureText: true,
                      style: TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        hintText: "Secret Key",
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(66, 66, 66, 0.3),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
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
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                              visible: _isIndicatorVisible,
                              child: Row(children: [
                                SizedBox(
                                    child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  ],
                                )),
                                SizedBox(width: 15),
                                Text(
                                  _loadingText,
                                  style: TextStyle(
                                      color:
                                          Color.fromRGBO(220, 219, 219, 0.69),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                )
                              ])),
                          Text(
                            _warningText,
                            style: TextStyle(
                                color: Color.fromRGBO(255, 82, 82, 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                          SingleChildScrollView(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                ElevatedButton(
                                  onPressed: _onButtonPressed,
                                  child: Text("Login"),
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.all(18.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor:
                                          Color.fromRGBO(100, 181, 246, 0.7),
                                      splashFactory: InkRipple.splashFactory),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ]))
                        ])
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Future<void> _onButtonPressed() async {
    if (_isIndicatorVisible) {
      return;
    }

    if (_warningText.isNotEmpty) {
      return;
    }

    if (_publicField.text == '' || _secretField.text == '') {
      setState(() {
        _warningText = '키 값을 입력하세요.';
      });
      return;
    }

    setState(() {
      _loadingText = '로딩 중입니다..';
      _isIndicatorVisible = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    var acc =
        Account(publicKey: _publicField.text, secretKey: _secretField.text);

    //login success
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
      setState(() {
        _loadingText = '';
        _isIndicatorVisible = false;
      });
    }
  }

  void _checkSecretString() => _checkString(_secretField.text);
  void _checkPublicString() => _checkString(_publicField.text);

  static String regex = r'[!@#$%^&*(),.?":{}|<>]';
  static String koRegex = r'[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]';
  void _checkString(String text) {
    bool specialChar = text.contains(RegExp(regex));
    if (specialChar) {
      setState(() {
        _warningText = '특수문자는 불가능합니다.';
      });
      return;
    }

    bool kChar = text.contains(RegExp(koRegex));
    if (kChar) {
      setState(() {
        _warningText = '한글은 불가능합니다.';
      });
      return;
    }

    setState(() {
      _warningText = '';
    });
  }
}
