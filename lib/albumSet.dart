import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

List<Widget> itemsAlbumList = <Widget>[];
List<Map> mapAlbumList = <Map>[];

class AlbumSetScreen extends StatefulWidget {
  String mode = '';
  XFile? pickedFile;
  AlbumSetScreen(this.mode,this.pickedFile);

  @override
  State<AlbumSetScreen> createState() =>  _AlbumSetScreenState(mode,pickedFile);
}
class _AlbumSetScreenState extends State<AlbumSetScreen> {
  String mode = '';
  XFile? pickedFile;

  _AlbumSetScreenState(this.mode,this.pickedFile);
  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アルバム保存画面'), backgroundColor: const Color(0xFF6495ed),),
      body: Column(
            children: itemsAlbumList,
      ),
    );
  }
  void buttonPressed() async {
    Navigator.pop(context);
  }

  Future<void> init() async {
    await loadList();
    await getItems();
  }
  /*------------------------------------------------------------------
第一画面ロード
 -------------------------------------------------------------------*/
  Future<void>  loadList() async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1);
    mapAlbumList = await database.rawQuery("SELECT * From albumList order by albumNo");
  }
  Future<void> getItems() async {
    List<Widget> list = <Widget>[];
    int listNo = 0;
    double titleFont = 25;
    String listTitle ='';
    String listTime ='';

    int index = 0;
    for (Map item in mapAlbumList) {

      if(item['albumName'].toString().length > 10) {
        titleFont = 15;
      }else{
        titleFont = 25;
      }
      list.add(
        Card(
          margin: const EdgeInsets.fromLTRB(15,0,15,15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          key: Key('$index'),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            title: Text('${item['albumName']}  ', style: TextStyle(color: const Color(0xFF191970) , fontSize: titleFont),),
                      //    isThreeLine: true,
            selected: listNo == item['albumNo'],
            onTap: () {
              listNo = item['albumNo'];
              listTitle = item['albumName'];
            },
          ),
        ),
      );
      index++;
    }
    setState(() {itemsAlbumList = list;});
  }
  // void _tapTile(String listTitle ,String listTime, int listOtherSide,int listPreSecond) {
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return AwesomeDialog(listTitle,listTime,listOtherSide,listPreSecond,notificationType);
  //     },
  //   );
  // }
}

