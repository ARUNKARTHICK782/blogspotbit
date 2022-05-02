import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:blogspotbit/apihandler.dart';
import 'package:blogspotbit/blogmodel.dart';
import 'package:blogspotbit/main.dart';
import 'package:blogspotbit/share.dart';
import 'package:blogspotbit/usermodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'bala.dart';
import 'googleauth.dart';
// bool auth=false;
GoogleSignIn _auth=GoogleSignIn();
String token="";

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  bool alreadylogged=false;
  // final prefs=await SharedPreferences.getInstance();
  // alreadylogged =(await  prefs.getString("token")?.isEmpty)!;
  // if(alreadylogged){
  //   await gettoken(FirebaseAuth.instance.currentUser?.email);
  // }
  // else{
  //   print("token is not empty");
  // }

  // FirebaseAuth.instance
  //     .authStateChanges()
  //     .listen((User? user) {
  //   if (user == null) {
  //     auth=false;
  //     print('User is currently signed out!');
  //   } else {
  //     auth=true;
  //     print('User is signed in!');
  //   }
  // });
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      './loginhome':(context)=>loginhome(),
      './blogdetail':(context)=>blogdetail(new blogmodel.empty(),0),
      './myapp':(context)=>MyApp(),
      './myblogs':(context)=>myblogs()
    },
    theme: ThemeData(
      fontFamily: 'Merriweather',
      scaffoldBackgroundColor:  Color(0xfffaeeeb),
    ),
    home:finalloginpage(), //(auth)?home():  (alreadylogged)?home():
  ));
}


class loginhome extends StatefulWidget {
  const loginhome({Key? key}) : super(key: key);

  @override
  _loginhomeState createState() => _loginhomeState();
}

class _loginhomeState extends State<loginhome> {
  String? useruid = "";
  String email = " ";
  String password = " ";
  late FocusNode passFnode;
  GoogleSignInAccount? _currentUser;
  var bala="";
  bool loading=false;

  authfunc(){

  }

  @override
  void initState() {
    super.initState();
    passFnode = FocusNode();
  }
  @override
  void _launchURL() async {
    const _url = "https://forms.gle/ScqKF8EqBS69LxNCA";
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    passFnode.dispose();

    super.dispose();
  }
  bool _loading=false;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
        child: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage("images/FrontBanner.png")),
              Padding(
                padding: const EdgeInsets.only(top: 130.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading=true;
                    });
                    // await signInWithGoogle().then((value) async =>{
                    //   await returntoken(value.user?.displayName, value.user?.email, "password",value.user?.photoURL).then((value1) async {
                    //     print("nornull"+value1.toString());
                    //     if(value1 != null){
                    //       print(value1);
                    //       await sharedprefFunc(value1);
                    //     }
                    //     else{
                    //       // await gettoken(value.user?.email).then((a) async=>{
                    //       //   await sharedprefFunc(a.toString())
                    //       // });
                    //     }
                    //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>home()),(route) => false);
                    //   })
                    //
                    // });
                    //showblogs();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(image: AssetImage("images/gsibtn.png"),height: 33.5,width: 33.5,),
                        Text("SIGNIN USING GOOGLE",style: TextStyle(color: Color(0xfff50f0f)),),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.white,),
                ),
              ),
              (loading)?CircularProgressIndicator():Text("")
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:home(),

    );
  }

}

class addblog extends StatefulWidget {
  const addblog({Key? key}) : super(key: key);

  @override
  _addblogState createState() => _addblogState();
}

class _addblogState extends State<addblog> {
  var blogtitlecont=new TextEditingController();
  var blogcontentcont=new TextEditingController();
  bool contentvalidate=false;
  bool contentro=true;
  bool titleError=false;
  int len=0;
  String temp="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xfff50f0f),),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
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
                                      print(s.length);
                                      if(s.length>60){
                                        setState(() {
                                          titleError=true;
                                        });
                                      }
                                      else{
                                        setState(() {
                                          titleError=false;
                                        });
                                      }

                                  },
                                  controller: blogtitlecont,
                                  decoration: InputDecoration(
                                    focusColor: Colors.red,
                                    // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                      errorText: titleError?"More than 60":null,
                                      border: UnderlineInputBorder(),
                                      labelText: 'Title',
                                  ),
                                ),
                              ),
                            ),
                            // Expanded(flex:3,child: Container(width: double.infinity,)),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 32.5,
                                child: CircularProgressIndicator(
                                  color: (temp.length>60)?Colors.red:Colors.blue,
                                  value:(temp.length/60 *100)/100,
                                ),
                              ),
                            )
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
                        child: TextField(
                          controller: blogcontentcont,
                          onChanged: (s){
                            len=s.length;
                            if(len>1500){
                              setState(() {
                                contentvalidate=true;
                              });
                            }
                            else{
                              setState(() {
                                contentvalidate=false;
                              });
                            }
                            setState(() {

                            });
                          },
                          maxLines: 20,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                              errorText: contentvalidate?"Content should not be more than 1500 characters":null,
                              border: OutlineInputBorder(),
                              hintText: 'Content'
                          ),
                        )),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Text("")),
              ],

            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Color(0xfff50f0f)),
                onPressed: () async{
                if(blogcontentcont.text.length > 1500 || blogtitlecont.text.length>60){
                  if(blogcontentcont.text.length > 1500)
                  Fluttertoast.showToast(msg: "Content is more than 1500 characters");
                  else
                    Fluttertoast.showToast(msg: "Title is more than 60 characters");
                }
                else{
                  var prefs=await SharedPreferences.getInstance();
                  String? id=await prefs.getString("id");
                  await addblogtodb(blogtitlecont.text,blogcontentcont.text,id!).then((value) {
                    Navigator.pop(context);
                  });
                }

            }, child: Text("PUBLISH POST"))
          ],),
        ),
      )
    );
  }
}

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {

  ScreenshotController scrncont=ScreenshotController();
  bool temp=false;
  bool like=false;
  List<blogmodel> blogs=[];
  List<int> mylikeslist=[];
  List<int> mybookmarkslist=[];
  bool _loading=true;
  blogfunc() async{
    var response=await showblogs();
    if(response == "No Blogs Found"){
      print("BALA NIT");
    }
    else{
      print("DATA HAVING");
      blogs=response;
    }

    setState(() {

    });
  }
  updateblog() async {
    mylikeslist=await mylikes();
    mybookmarkslist=await mybookmarks();
    print("type of mblist");
    print(mybookmarkslist.runtimeType);
    setState(() {
        _loading=false;
    });
    // for (var i in mylikeslist){
    //   for(blogmodel blog in blogs){
    //     if(blog.blogid == i){
    //
    //     }
    //   }
    // }
  }
  mefunc() async{
    var prefs=await SharedPreferences.getInstance();
    String? ftoken=await prefs.getString("token");
    var res=await http.get(
      Uri.parse("https://blog-spot-bit-2022.herokuapp.com/api/users/me"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token':ftoken!,
      },
    );
    var me=json.decode(res.body);
    print(me);
    prefs.setString("id", me["_id"]);
  }
  @override
  void initState() {
    blogfunc();
    updateblog();
    mefunc();
  }
  var _imgfile;
  var scrcont=new ScrollController();
  @override
  Widget build(BuildContext context) {
    PageController pc=PageController(initialPage: 1);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.view_headline,color: Colors.white,),onPressed: (){
          Navigator.push(context,PageTransition(
            type: PageTransitionType.leftToRight,
            child: profile(),
          ),);
        },),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("BLOGSPOT",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
            Text("BIT",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
              ),)
          ],),
        backgroundColor: Color(0xfff50f0f),
      ),
      body:(_loading)?Center(child: CircularProgressIndicator()): Screenshot(
        controller: scrncont,
        child: GestureDetector(
          child: SizedBox(
            child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: blogs.length,
                itemBuilder: (BuildContext context,int index){
                  return Column(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(blogs.elementAt(index).title,
                                          style: TextStyle(fontSize: 27.5,fontWeight: FontWeight.w500,fontFamily: 'Oswald'),
                                        ),
                                      ),
                                      Divider(
                                        thickness: 2,
                                      ),
                                      Expanded(
                                        flex:8,
                                        child: ListView(

                                            children: [
                                            Text(blogs.elementAt(index).content,
                                              style: TextStyle(fontSize: 17.5,fontFamily: 'Oswald-Extra'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //Spacer(),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(flex:1,child: CircleAvatar(
                                                  // backgroundImage: NetworkImage(blogs.elementAt(index).authorurl),
                                                )),
                                                Expanded(
                                                  flex:3,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(blogs.elementAt(index).authorname,overflow: TextOverflow.ellipsis,),
                                                    SizedBox(height: 5,),
                                                  Text(
                                                    "Published On: " +
                                                        blogs
                                                            .elementAt(index)
                                                            .pubdate
                                                            .substring(0, 10),
                                                    style: TextStyle(fontSize: 10),
                                                  )
                                              ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                IconButton(onPressed: () async{
                                                  scrncont.capture().then((image) async {
                                                    await onButtonTap(Share.whatsapp,image!);
                                                    //Capture Done
                                                    setState(() {
                                                      _imgfile = image;
                                                    });
                                                  }).catchError((onError) {
                                                    print(onError);
                                                  });

                                                }, icon: Icon(Icons.share)),
                                                Column(
                                                  children: [
                                                    (mylikeslist.contains(blogs.elementAt(index).blogid))?IconButton(icon:Icon(CupertinoIcons.heart_fill,color: Colors.red,),onPressed: () async {
                                                      await removelike(blogs.elementAt(index).blogid);
                                                      await removefromMylikes(blogs.elementAt(index).blogid);
                                                      setState(() {
                                                        initState();
                                                      });
                                                      // addlike(blogs.elementAt(index).blogid);
                                                      // addtomylikes(FirebaseAuth.instance.currentUser?.email, blogs.elementAt(index).blogid);
                                                      // setState(() {
                                                      //   initState();
                                                      // });
                                                    },):IconButton(icon:Icon(CupertinoIcons.heart,),onPressed: () async {
                                                      await addlike(blogs.elementAt(index).blogid);
                                                      await addtomylikes(blogs.elementAt(index).blogid);
                                                      setState(() {
                                                        initState();
                                                      });
                                                    },),
                                                    Text(blogs.elementAt(index).likes.toString(),style: TextStyle(fontSize: 10),)
                                                  ],
                                                ),
                                                (mybookmarkslist.contains(blogs.elementAt(index).blogid))?IconButton(icon:Icon(Icons.bookmark),color: Color(0xff4f5d75),onPressed: () async{
                                                  await removefromMybookmarks(blogs.elementAt(index).blogid);
                                                  setState(() {
                                                        initState();
                                                      });
                                                },):IconButton(icon:Icon(Icons.bookmark_outline_rounded),onPressed: () async{
                                                  await addtomybookmarks(blogs.elementAt(index).blogid);
                                                  setState(() {
                                                        initState();
                                                      });
                                                },),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  );
                }),
          ),
          onPanUpdate: (details) {

            // Swiping in left direction.
            if (details.delta.dx > 0) {
              Navigator.push(context,PageTransition(
                type: PageTransitionType.leftToRight,
                child: profile(),
              ),);
            }
          },
        ),
      ),
      bottomNavigationBar:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 65,
            width: 65,
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>addblog())).then((value) =>
                {
                  initState()
                });
                // Obtain shared preferences.
              },
              backgroundColor: Color(0xfff50f0f),
                child: Icon(Icons.add),),
            ),
          )
        ],) ,
    );
  }
}

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  String disname="";
  String photourl="";
  userfetchfunc() async{
        setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xfff50f0f),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Container(width: double.infinity,),
            (photourl.isNotEmpty)?CircleAvatar(
              radius: 50,
              child: Text("A"),
            ):CircleAvatar(
              radius: 50,
              backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
              child: Text("A",style: TextStyle(fontSize: 40),),
            ),
            SizedBox(height: 20),
            Text(disname,style: TextStyle(fontSize: 20),),
            SizedBox(height: 20),
            GestureDetector(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width *3/4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("My Blogs",style: TextStyle(fontSize: 25),),
                    ],
                  ),
              ),
                ),),
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>myblogs()));
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: IconButton(icon:Icon(Icons.bookmark,color:Color(0xff4f5d75)),onPressed: () => {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>savedblogs()))
                      },),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                        height: 100,
                        width: 100,
                      child: IconButton(icon:Icon(Icons.logout,color: Color(0xff4f5d75),),onPressed: (){
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(
                            content: Text("Do you want to log out?"),
                            actions: [
                              TextButton(onPressed: () async{
                                //await deleteme();
                                final prefs=await SharedPreferences.getInstance();
                                await prefs.remove("token");
                                _auth.signOut().then((value) {
                                  print("SIGNED OUT");
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>finalloginpage()), (route) => false);
                                });
                              }, child: Text("YES")),
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: Text("NO"))
                            ],
                          );
                        });

                      },),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: Image(image: AssetImage("images/abc.png")))
          ],
        )
      ),
      onPanUpdate: (details){
        if(details.delta.dx<0){
            Navigator.pop(context);
        }
      },
    );
  }

  @override
  void initState() {
    userfetchfunc();
    //usermodel user=new usermodel(disname!, photourl!);
  }

}

class myblogs extends StatefulWidget {
  const myblogs({Key? key}) : super(key: key);

  @override
  _myblogsState createState() => _myblogsState();
}

class _myblogsState extends State<myblogs> {
  bool _loading=true;
  List<blogmodel> mybloglist=[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff50f0f),
      ),
      body:(_loading)?Center(child: CircularProgressIndicator()):(mybloglist.isNotEmpty)?
      SingleChildScrollView(
        child:Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                  itemCount: mybloglist.length,
                  itemBuilder: (BuildContext context,int index){
                return GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: Container(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(mybloglist.elementAt(index).title,style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>blogdetail(mybloglist.elementAt(index),1))).then((value) => {
                        initState()
                      });
                  },
                );
              }),
            ),
          ],
        )
      ):
      Center(
        child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("You have not posted any Blogs"),
                    GestureDetector(
                      child: Card(
                        color: Colors.greenAccent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Add a Blog"),
                              ),
                            ],
                          )),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>addblog())).then((value) => {
                          initState()
                        });
                      },
                    )
                  ],
                ),)
    );
  }
  mybloggetter() async{
    final prefs=await SharedPreferences.getInstance();
    String? uid=prefs.getString("uid");
    // print("lksjflkjsdfljsd"+uid.toString());
    await myblogsfunc(uid.toString()).then((v){
    mybloglist=v;
      setState(() {
        _loading=false;
      });
    });

  }
  @override
  void initState() {
    mybloggetter();
  }
}

class savedblogs extends StatefulWidget {
  const savedblogs({Key? key}) : super(key: key);

  @override
  _savedblogsState createState() => _savedblogsState();
}

class _savedblogsState extends State<savedblogs> {
  List<blogmodel> mysavedblogs=[];
  String banner="";
  bool _loading=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xfff50f0f),
        ),
        body:(_loading)?Center(child: CircularProgressIndicator()):(banner!="No Saved blogs")?
        SingleChildScrollView(
            child:Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: mysavedblogs.length,
                      itemBuilder: (BuildContext context,int index){
                        return GestureDetector(
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 100),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex:4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(mysavedblogs.elementAt(index).title,style: TextStyle(fontSize: 20),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex:1,child: Container(width: double.infinity,),),
                                  Expanded(flex:1,child:IconButton(icon:Icon(Icons.clear),onPressed: (){
                                    showDialog(context: context, builder: (BuildContext context){
                                      return AlertDialog(
                                        content: Text("Do you want to remove from bookmark"),
                                        actions: [
                                          TextButton(onPressed: () async{

                                           await removefromMybookmarks(mysavedblogs.elementAt(index).blogid).then((b){
                                             initState();
                                           });
                                          }, child: Text("Yes")),
                                          TextButton(onPressed: (){
                                            Navigator.pop(context);
                                          }, child: Text('No'))
                                        ],
                                      );
                                    });
                                  },))
                                ],
                              ),
                            ),
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>blogdetail(mysavedblogs.elementAt(index),0))).then((value) => {
                              initState()
                            });
                          },
                        );
                      }),
                ),
              ],
            )
        ):
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("No Bookmarks"),
            ],
          ),)
    );
  }
  savedblogfunc() async{
    await mysavedblogsprofile()
    .then((v){
      if(v!=null) {
        mysavedblogs = v;
        setState(() {
          _loading = false;
        });
      }
      else{
        setState(() {
          banner="No Saved blogs";
          _loading=false;
        });
      }
    });

  }
  @override
  void initState() {
    savedblogfunc();
  }
}


class blogdetail extends StatefulWidget {
  final blogmodel blog;
  final int screen;
  const blogdetail(this.blog,this.screen,{Key? key}) : super(key: key);

  @override
  _blogdetailState createState() => _blogdetailState();
}

class _blogdetailState extends State<blogdetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff50f0f),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ConstrainedBox(
                      constraints:BoxConstraints(minHeight: MediaQuery.of(context).size.height * 3/4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.blog.title,
                            style: TextStyle(fontSize: 25,fontWeight: FontWeight.w500),
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Text(widget.blog.content,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              onDoubleTap: (){
                print(MediaQuery.of(context).padding.bottom);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:(widget.screen==1)?Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 60,
                color: Colors.red,
                child: IconButton(
                  icon:Icon(Icons.delete,color: Colors.white,),
                  onPressed: () async{
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        content: Text("Do you want to delete this blog"),
                        actions: [
                          TextButton(child: Text("Yes"),onPressed: () async {
                            await deletemyblog(widget.blog.blogid).then((value){
                              Navigator.pop(context);
                            });
                          },),
                          TextButton(child: Text("No"),onPressed: () async {
                              Navigator.pop(context);
                          },)
                        ],
                      );
                    });

                },),
              ),
            ),
          )
        ],
      ):null,
    );
  }
}



// class googelsignin extends StatefulWidget {
//   const googelsignin({Key? key}) : super(key: key);
//
//   @override
//   _googelsigninState createState() => _googelsigninState();
// }
//
// class _googelsigninState extends State<googelsignin> {
//
//   GoogleSignInAccount? _user;
//
//   @override
//   Widget build(BuildContext context) {
//     ConfirmationResult? confirmationResult;
//     String mobileno="";
//     String otp="";
//     bool temp=false;
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           ElevatedButton(
//               onPressed: () async {
//                 UserCredential user= await  signInWithGoogle();
//                 print(user.user?.displayName);
//               },
//               child: Text("GOOGLE SIGN IN"),
//             ),
//             ElevatedButton(onPressed: (){
//               GoogleSignIn().signOut().then((value) => print("user signed out"));
//             }, child: Text("SIGN OUT")),
//         ],
//       ),),
//     );
//   }
//
// }