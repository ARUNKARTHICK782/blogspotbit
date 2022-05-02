import 'dart:async';
import 'package:blogspotbit/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

var verify, reg_email, reg_department, reg_name;
var user, token, otpjson;
void _launchURL() async {
  const _url = "https://forms.gle/ScqKF8EqBS69LxNCA";
  if (!await launch(_url)) throw 'Could not launch $_url';
}

void toast(message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

gettoken(String? email, String? password) async {
  print("in get token"+email.toString());
  var b={"email":email,"password":password};
  print(b);
  var res=await http.post(
    Uri.parse("https://blog-spot-bit-2022.herokuapp.com/api/users/check"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(b),
  );
  print(res.body);
  return res.body;
}

getotp(String? email, String? subject) async {

  var b={"email":email,"type":subject};

  var res=await http.post(
    Uri.parse("https://blog-spot-bit-2022.herokuapp.com/api/send/email/otp"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(b),
  );

  if(res.body.toString() =='"email" must be a valid email') return res.body.toString();
  else if (res.body.toString() == "User Already registered") return res.body.toString();
  var finaldetails = json.decode(res.body);
  otpjson = finaldetails;
  return finaldetails;
}

verifyotp(String? key, int? otp, String? check) async {
  var b ={
    "verification_key": key,
    "otp":otp,
    "check": check
  };

  var res = await http.post(
    Uri.parse("https://blog-spot-bit-2022.herokuapp.com/api/send/verify/otp"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(b),
  );
  var finaldetails = json.decode(res.body);
  if(finaldetails['Details'].toString() == 'OTP NOT Matched') return 'OTP NOT Matched';
  verify = finaldetails;
  reg_name = verify['Check'].toString().substring(0,1).toUpperCase()+verify['Check'].toString().substring(1, verify['Check'].toString().indexOf('.'));
  reg_department = verify['Check'].toString().substring(verify['Check'].toString().indexOf('.')+1, verify['Check'].toString().indexOf('.')+3);
  reg_email = verify['Check'].toString();
  return finaldetails;
}

adduser(String? name, String? email, String? password) async {

  var b={"name": name,"email":email,"password":password};
  print(b);
  var res=await http.post(
    Uri.parse("https://blog-spot-bit-2022.herokuapp.com/api/users/add/8979"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(b),
  );
  print(res.body);
  token = res.headers['x-auth-token'];
  return res.body;
}


void main() {
  runApp(const finalloginpage());
}

class finalloginpage extends StatelessWidget {
  const finalloginpage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: const OTPVerified(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  @override
  Widget build(BuildContext context) {
    PageController pc=PageController(initialPage: 1);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff50f0f),
        title: Padding(
          padding: const EdgeInsets.only(left:10.0),
          child: Text("BLOGSPOTBIT"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,10,8),
            child: ElevatedButton(onPressed: () => {
              _launchURL()
            },
              child: Text("Help",style:TextStyle(color: Color(0xfff50f0f))),
              style: ElevatedButton.styleFrom(primary: Colors.white),
            ),
          )
        ],
      ),
      body: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage("images/FrontBanner.png")),

            Padding(
              padding: const EdgeInsets.only(top: 75.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  });

                  //showblogs();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0,top: 8.0, bottom: 8.0),
                      child: Icon(Icons.login, color: Color(0xfff50f0f),size: 35,),
                    ),
                    Text("LOGIN",style: TextStyle(color: Color(0xfff50f0f)),),
                  ],
                ),
                style: ElevatedButton.styleFrom(primary: Colors.white,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:47.5),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0,top: 8.0, bottom: 8.0),
                      child: Icon(Icons.app_registration, color: Color(0xfff50f0f),size: 35,),
                    ),
                    Text("REGISTER",style: TextStyle(color: Color(0xfff50f0f)),),
                  ],
                ),
                style: ElevatedButton.styleFrom(primary: Colors.white,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var username=new TextEditingController();
  var password=new TextEditingController();
  bool contentvalidate=false;
  bool contentro=true;
  bool usernameerror=false;
  bool passworderror=false, password_visible = true;
  int len=0;
  String temp="", token="";

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff50f0f),
        title: Padding(
          padding: const EdgeInsets.only(left:10.0),
          child: Text("BLOGSPOTBIT"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,10,8),
            child: ElevatedButton(onPressed: () => {
              _launchURL()
            },
              child: Text("Help",style:TextStyle(color: Color(0xfff50f0f))),
              style: ElevatedButton.styleFrom(primary: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text("")),
                    Expanded(
                      flex:5,
                      child: Container(
                        child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    child: TextField(
                                      inputFormatters:[FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 .]'))],
                                      onChanged: (s){
                                        setState(() {
                                          temp=s;
                                        });

                                        // if(s.contains("@bitsathy.ac.in")){
                                        //
                                        //   setState(() {
                                        //     usernameerror=false;
                                        //   });
                                        // }
                                        // else{
                                        //   setState(() {
                                        //     usernameerror=true;
                                        //   });
                                        // }

                                      },

                                      controller: username,
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Email',
                                        suffixText: '@bitsathy.ac.in'
                                      ),
                                    ),
                                  ),
                                ),
                                // Expanded(flex:3,child: Container(width: double.infinity,)),

                              ],
                            )),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text("")),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text("")),
                    Expanded(
                      flex:5,
                      child: Container(
                        child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    child: TextField(
                                      obscureText: password_visible,
                                      onChanged: (s){
                                        setState(() {
                                          temp=s;
                                        });

                                        if(s.length<20){
                                          setState(() {
                                            passworderror=false;
                                          });
                                        }
                                        else{
                                          setState(() {
                                            passworderror=true;
                                          });
                                        }

                                      },
                                      controller: password,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                            onPressed: (){
                                              setState(() {
                                                password_visible = !password_visible;
                                              });
                                            },
                                            icon: password_visible?Icon(Icons.remove_red_eye, color: Colors.grey,):Icon(Icons.remove_red_eye)),
                                        errorText: passworderror?"InValid Password":null,
                                        border: UnderlineInputBorder(),
                                        labelText: 'Password',
                                      ),
                                    ),
                                  ),
                                ),
                                // Expanded(flex:3,child: Container(width: double.infinity,)),

                              ],
                            )),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text("")),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(onPressed: () async{
                    if(username.text.isEmpty || password.text.isEmpty){
                      return;
                    }

                    if(!passworderror){
                      await gettoken(username.text.trim()+"@bitsathy.ac.in", password.text.trim()).then((v) async {
                        if(v == "Invalid Email or Password"){
                            toast("Invalid Email or Password");
                        }
                        else if (v == '"email" must be a valid email'){
                          toast("Invalid Email");
                        }
                        else{
                          var prefs= await SharedPreferences.getInstance();
                          prefs.setString("token", v).then((value) {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
                          });
                        }
                      });

                    }
                    else{
                      print("---Error---");
                    }
                  }, child: Text("LOGIN")),
                ),
                Image(image: AssetImage("images/LoginBanner.png")),
              ],),
          ),
        ),
      )
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Timer ?_timer;
  int _min = 01;
  int _sec = 59;
  bool zero = false;
  var username=new TextEditingController();
  var password=new TextEditingController();
  var otp=new TextEditingController();
  bool contentvalidate=false;
  bool contentro=true;
  bool rusernameerror=false;
  bool rpassworderror=false;
  bool rotperror=false;
  int len=0;
  bool check=false, check2 = true;
  String temp="", token="";
  var decodeotp;


  @override
  void dispose() {
    username.dispose();
    password.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_min == 0 && _sec == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          if(_sec == 0){
            setState(() {
              _min--;
              _sec= 60;
              zero = false;
            });
          }
          else{
            if(_sec < 11 && _sec > 0){
              zero = true;
            }
            else{
              zero = false;
            }
          }
          setState(() {
            _sec--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff50f0f),
        title: Padding(
          padding: const EdgeInsets.only(left:10.0),
          child: Text("BLOGSPOTBIT"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,10,8),
            child: ElevatedButton(onPressed: () => {
              _launchURL()
            },
              child: Text("Help",style:TextStyle(color: Color(0xfff50f0f))),
              style: ElevatedButton.styleFrom(primary: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text("")),
                    Expanded(
                      flex:5,
                      child: Container(
                        child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    child: TextField(
                                      onChanged: (s){
                                        setState(() {
                                          temp=s;
                                        });

                                        if(s.contains("@bitsathy.ac.in")){
                                          setState(() {
                                            rusernameerror=false;
                                          });
                                        }
                                        else{
                                          setState(() {
                                           rusernameerror=true;
                                          });
                                        }

                                      },
                                      controller: username,
                                      decoration: InputDecoration(
                                        errorText: rusernameerror?"Invalid Email":null,
                                        border: UnderlineInputBorder(),
                                        labelText: 'Email',
                                      ),
                                    ),
                                  ),
                                ),
                                // Expanded(flex:3,child: Container(width: double.infinity,)),
                              ],
                            )),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text("")),
                  ],
                ),

                check?Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text("")),
                    Expanded(
                      flex:5,
                      child: Column(
                        children: [
                          Container(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Container(
                                        child: TextField(
                                          onChanged: (s){
                                            setState(() {
                                              temp=s;
                                            });

                                            if(s.length<7){
                                              setState(() {
                                                rotperror=false;
                                              });
                                            }
                                            else{
                                              setState(() {
                                                rotperror=true;
                                              });
                                            }

                                          },
                                          controller: otp,
                                          decoration: InputDecoration(
                                            errorText: rotperror?"Valid Password":null,
                                            border: UnderlineInputBorder(),
                                            labelText: 'OTP',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Expanded(flex:3,child: Container(width: double.infinity,)),

                                  ],
                                )),
                          ),
                          zero?Text("0$_min : 0$_sec"):Text("0$_min : $_sec"),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text("")),
                  ],
                ):Text(""),

                check2?Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(onPressed: () async{
                    if(username.text.isEmpty ) return;

                    if(!rusernameerror){
                      await getotp(username.text.trim(), "VERIFICATION").then((v) => {

                        if(v =='"email" must be a valid email'){
                          toast("Invalid Email")
                        }
                        else if (v == "User Already registered"){
                          toast("You have Already Registered")
                        }
                        else{
                          setState(() {
                            check = true;
                            check2 = false;
                            startTimer();
                          })
                        }
                      });

                    }
                    else{
                      print("---Error---");
                    }
                  }, child: Text("SEND OTP")),
                ):Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(onPressed: () async{

                    if(otp.text.length == 0) return;

                    if(!rotperror ){
                      await verifyotp(otpjson['Details'], int.parse(otp.text), username.text).then((v)=> {

                      // print(verify)
                          if(v == 'OTP NOT Matched'){
                             toast('OTP NOT Matched')
                          }
                          else if(v['Status'].toString() == 'Success'){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OTPVerified(),))
                          }
                          else if(_min == 0 && _sec == 0){
                            toast('Timed Out Try Again')
                          }
                      });

                    }
                    else{
                      print("---Error---");
                    }
                  }, child: Text("START REGISTERATION")),
                ),

                Image(image: AssetImage("images/LoginBanner.png")),
              ],),
          ),
        ),
      )
    );
  }
}

class OTPVerified extends StatefulWidget {
  const OTPVerified({Key? key}) : super(key: key);

  @override
  State<OTPVerified> createState() => _OTPVerifiedState();
}

class _OTPVerifiedState extends State<OTPVerified> {

  var username = new TextEditingController();
  var depart = new TextEditingController();
  var password = new TextEditingController();
  var mail = new TextEditingController();
  bool check_password = false, password_visible = true;

  @override
    void dispose() {
      // _timer?.cancel();
      super.dispose();
    }

  @override
  void initState() {
    username.text = reg_name;
    if(reg_department == 'cs'){
      depart.text = "CSE";
    }
    mail.text = reg_email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff50f0f),
        title: Padding(
          padding: const EdgeInsets.only(left:10.0),
          child: Text("BLOGSPOTBIT"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,10,8),
            child: ElevatedButton(onPressed: () => {
              _launchURL()
            },
              child: Text("Help",style:TextStyle(color: Color(0xfff50f0f))),
              style: ElevatedButton.styleFrom(primary: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:35.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text("")),
                  Center(
                    child: Text("REGISTRATION", style: TextStyle(color: Color(0xfff50f0f), fontSize: 20),),
                  ),
                  Expanded(
                      flex: 1,
                      child: Text("")),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text("")),
                Expanded(
                  flex:5,
                  child: Container(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Container(
                                child: TextField(

                                  readOnly:true,
                                  onChanged: (s){
                                    setState(() {

                                    });

                                    // if(s.contains("@bitsathy.ac.in")){
                                    //   setState(() {
                                    //     usernameerror=false;
                                    //   });
                                    // }
                                    // else{
                                    //   setState(() {
                                    //     usernameerror=true;
                                    //   });
                                    // }

                                  },
                                  controller: username,
                                  decoration: InputDecoration(
                                    // errorText: usernameerror?"Invalid Email":null,
                                    border: UnderlineInputBorder(),
                                    labelText: 'Name',
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(flex:3,child: Container(width: double.infinity,)),

                          ],
                        )),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Text("")),
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text("")),
                Expanded(
                  flex:5,
                  child: Container(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Container(
                                child: TextField(
                                  readOnly:true,
                                  onChanged: (s){
                                    setState(() {

                                    });
                                    // if(s.contains("@bitsathy.ac.in")){
                                    //   setState(() {
                                    //     usernameerror=false;
                                    //   });
                                    // }
                                    // else{
                                    //   setState(() {
                                    //     usernameerror=true;
                                    //   });
                                    // }

                                  },
                                  controller: depart,
                                  decoration: InputDecoration(
                                    // errorText: usernameerror?"Invalid Email":null,
                                    border: UnderlineInputBorder(),
                                    labelText: 'Department',
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(flex:3,child: Container(width: double.infinity,)),

                          ],
                        )),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Text("")),
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text("")),
                Expanded(
                  flex:5,
                  child: Container(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Container(
                                child: TextField(
                                  readOnly:true,
                                  onChanged: (s){
                                    setState(() {

                                    });

                                    // if(s.contains("@bitsathy.ac.in")){
                                    //   setState(() {
                                    //     usernameerror=false;
                                    //   });
                                    // }
                                    // else{
                                    //   setState(() {
                                    //     usernameerror=true;
                                    //   });
                                    // }

                                  },
                                  controller: mail,
                                  decoration: InputDecoration(
                                    // errorText: usernameerror?"Invalid Email":null,
                                    border: UnderlineInputBorder(),
                                    labelText: 'Email',
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(flex:3,child: Container(width: double.infinity,)),

                          ],
                        )),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Text("")),
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text("")),
                Expanded(
                  flex:5,
                  child: Container(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Container(
                                child: TextField(

                                  obscureText: password_visible,
                                  onChanged: (s){
                                    setState(() {

                                    });
                                    if(8<=s.length && s.length<=12){
                                      setState(() {
                                        check_password=false;
                                      });
                                    }
                                    else{
                                      setState(() {
                                        check_password=true;
                                      });
                                    }


                                  },
                                  controller: password,
                                  decoration: InputDecoration(
                                    errorText: check_password?"Invalid Password":null,
                                    border: UnderlineInputBorder(),
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            password_visible = !password_visible;
                                          });
                                        },
                                        icon: password_visible?Icon(Icons.remove_red_eye, color: Colors.grey,):Icon(Icons.remove_red_eye))
                                  ),

                                ),
                              ),
                            ),
                            // Expanded(flex:3,child: Container(width: double.infinity,)),

                          ],
                        )),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Text("")),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton(onPressed: () async{
                if(password.text.length == 0 ) return;

                if(!check_password){
                  await adduser(username.text, mail.text, password.text).then((user){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
                  });
                }
                else{
                  print("---Error---");
                }
              }, child: Text("REGISTER")),
            )
          ],
        ),
      )
    );
  }
}


