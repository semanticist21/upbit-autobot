import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbit_autobot/client/client.dart';
import 'package:upbit_autobot/model/account.dart';
import 'package:window_manager/window_manager.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _publicField = TextEditingController();
  final TextEditingController _secretField = TextEditingController();
  late final SharedPreferences _prefs;

  String _warningText = '';
  String _loadingText = '로딩 중..';
  bool _isIndicatorVisible = false;
  bool _isSave = false;
  final _isSaveKey = 'isSave';

  @override
  void initState() {
    super.initState();
    _publicField.removeListener(_checkPublicString);
    _secretField.removeListener(_checkSecretString);
    _publicField.addListener(_checkPublicString);
    _secretField.addListener(_checkSecretString);
    _getSavePreferences();
  }

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
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: const Color.fromRGBO(117, 117, 117, 0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      const SizedBox(width: 5),
                      const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w900,
                            fontSize: 25),
                      ),
                      const Spacer(),
                      const Text('ID / PW 저장',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400)),
                      Checkbox(
                        value: _isSave,
                        onChanged: (value) {
                          setState(() {
                            _isSave = !_isSave;
                            _prefs.setBool(_isSaveKey, _isSave);
                          });
                        },
                        checkColor: ThemeData.dark().primaryColor,
                        activeColor: ThemeData.light().canvasColor,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    TextField(
                      enabled: !_isIndicatorVisible,
                      controller: _publicField,
                      cursorColor: Colors.grey,
                      style: const TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        hintText: "Public Key",
                        hintStyle: const TextStyle(
                            color: Color.fromRGBO(66, 66, 66, 0.3),
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        prefixIcon: const Icon(
                          FontAwesomeIcons.user,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(31, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _secretField,
                      enabled: !_isIndicatorVisible,
                      cursorColor: Colors.grey,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        hintText: "Secret Key",
                        hintStyle: const TextStyle(
                          color: Color.fromRGBO(66, 66, 66, 0.3),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(FontAwesomeIcons.lock),
                        filled: true,
                        fillColor: const Color.fromARGB(31, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                              visible: _isIndicatorVisible,
                              child: Row(children: [
                                const SizedBox(
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
                                const SizedBox(width: 15),
                                Text(
                                  _loadingText,
                                  style: const TextStyle(
                                      color:
                                          Color.fromRGBO(220, 219, 219, 0.69),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                )
                              ])),
                          Text(
                            _warningText,
                            style: const TextStyle(
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
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(18.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor: const Color.fromRGBO(
                                          100, 181, 246, 0.7),
                                      splashFactory: InkRipple.splashFactory),
                                  child: const Text("Login"),
                                ),
                                const SizedBox(
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

    if (_warningText.contains("불가능")) {
      return;
    }
    _warningText = '';

    if (_publicField.text == '' || _secretField.text == '') {
      setState(() {
        _warningText = '키 값을 입력하세요.';
      });
      return;
    }

    _loadingText = '로딩 중입니다..';
    _isIndicatorVisible = true;

    setState(() {});

    var acc =
        Account(publicKey: _publicField.text, secretKey: _secretField.text);
    var data = acc.toJson();
    var client = RestApiClient();

    var params = {'isSave': _isSave.toString()};

    var response = await client.requestPostWithParamas(
        'login', RestApiClient.encodeData(data), params);

    // login fail case
    if (response == null || response.statusCode != HttpStatus.ok) {
      _loadingText = '';
      _warningText = '로그인에 실패했습니다.';
      _isIndicatorVisible = false;
      setState(() {});
      return;
    }

    //login success
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Home()));
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

  Future<void> _getSavePreferences() async {
    setState(() => _isIndicatorVisible = true);
    try {
      _prefs = await SharedPreferences.getInstance();
      var flag = _prefs.getBool(_isSaveKey);

      if (flag != null) {
        setState(() {
          _isSave = flag;
        });
      }

      if (_isSave) {
        await _getSavedloginData();
      }
    } catch (_) {
    } finally {
      setState(() => _isIndicatorVisible = false);
    }
    setState(() => _isIndicatorVisible = false);
  }

  Future<void> _getSavedloginData() async {
    var response = await RestApiClient().requestGet('login');

    var keyMap = RestApiClient.parseResponseData(response);
    var publicKey = 'publicKey';
    var secretKey = 'secretKey';

    if (keyMap.isEmpty) {
      return;
    }

    if (keyMap.containsKey(publicKey)) {
      _publicField.text = keyMap[publicKey];
    }

    if (keyMap.containsKey(secretKey)) {
      _secretField.text = keyMap[secretKey];
    }
  }
}
