import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';
import './albumSel.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

List<Map> map_stretchlist = <Map>[];

//didpop使う為
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
/*------------------------------------------------------------------
全共通のメソッド
 -------------------------------------------------------------------*/
//初回起動分の処理
Future<void> firstRun() async {
  String dbpath = await getDatabasesPath();
  //設定テーブル作成
  String path = p.join(dbpath, "internal_assets.db");
  //設定テーブルがなければ、最初にassetsから作る
  var exists = await databaseExists(path);
  if (!exists) {
    // Make sure the parent directory exists
    //親ディレクリが存在することを確認
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(p.join("assets", "exOb.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    //print("Opening existing database");
  }
}
void main() async{
  //SQLfliteで必要？
  WidgetsFlutterBinding.ensureInitialized();
  await firstRun();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/album': (context) => const AlbumSelScreen(),
      },
      theme: ThemeData(
        // primaryColor: const Color(0xFF191970),
        primaryColor: Colors.blue,
        hintColor: const Color(0xFF2196f3),
        //canvasColor: Colors.black,
        //  backgroundColor: const Color(0xFF191970),
        canvasColor: const Color(0xFFf8f8ff),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: const Color(0xFF2196f3)),
        fontFamily: 'KosugiMaru',
      ),
      //didipop使うため
      navigatorObservers: [routeObserver],
    );
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> with RouteAware {
  List<XFile>? _imageFileList;
  dynamic _pickImageError;
  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }
  final ImagePicker picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    // 遷移時に呼ばれる関数
    // routeObserverに自身を設定(didPopのため)
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    }
  }

  @override
  void dispose() {
    // routeObserverから自身を外す(didPopのため)
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 再描画
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('らくらく写真観察'),
        backgroundColor: const Color(0xFF6495ed),),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          //  _listHeader(),
          const Padding(padding: EdgeInsets.all(10)),
           ElevatedButton(
               style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 80),),
               onPressed: () async {
                 runCamera();
               },
             child: Text('撮影', style: const TextStyle(fontSize: 35.0, color: Colors.white,),),
           ),
            const Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 80),),
              onPressed: () async {

              },
              child: Text('フォルダ選択', style: const TextStyle(fontSize: 30.0, color: Colors.white,),),
            ),
        ],
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label:'アルバム', icon: Icon(Icons.list)),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/album');
          }
        },
      ),
    );
  }

  /*------------------------------------------------------------------
初期処理
 -------------------------------------------------------------------*/
  void init() async {
    // await  testEditDB();
  }
  void runCamera() async{
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
              // maxWidth: maxWidth,
              // maxHeight: maxHeight,
              // imageQuality: quality,
            );
      if(pickedFile != null) {
        setState(() {_setImageFileListFromFile(pickedFile);});

      }else{

      }

    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }
}
