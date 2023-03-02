import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

List<Widget> itemsAlbumList = <Widget>[];
List<Map> mapAlbumList = <Map>[];

class AlbumSetScreen extends StatefulWidget {
  String mode = '';
  XFile? pickedFile;
  DateTime dtNowTime;
  AlbumSetScreen(this.mode,this.pickedFile,this.dtNowTime);

  @override
  State<AlbumSetScreen> createState() =>  _AlbumSetScreenState(mode,pickedFile,dtNowTime);
}
class _AlbumSetScreenState extends State<AlbumSetScreen> {
  String mode = '';
  XFile? pickedFile;
  DateTime dtNowTime;

  _AlbumSetScreenState(this.mode,this.pickedFile,this.dtNowTime);
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
    int albumNo = 0;
    double titleFont = 25;
    String? listTest ='';
    String listTest1 ='';
    if(pickedFile != null) {
      listTest = pickedFile?.name;
      listTest1 = listTest.toString();
    }
    list.add(
      Card(
      margin: const EdgeInsets.fromLTRB(15,0,15,15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(listTest1, style: TextStyle(color: const Color(0xFF191970) , fontSize: 15),),
        //    isThreeLine: true,
      ),
    ),);
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            title: Text('${item['albumName']}  ', style: TextStyle(color: const Color(0xFF191970) , fontSize: titleFont),),
            selected: albumNo == item['albumNo'],
            onTap: () {
              albumNo = item['albumNo'];
              _tapTile(albumNo);
            },
          ),
        ),
      );
    }
    setState(() {itemsAlbumList = list;});
  }
  void _tapTile(int albumNo ) async{
    final XFile? _pickedFile = pickedFile;
    if(_pickedFile != null) {
      Uint8List buffer = await _pickedFile.readAsBytes();
      await ImageGallerySaver.saveImage(buffer, name: _pickedFile.name);
    }
    // showDialog(
    //   context: context,
    //   builder: (_) {
    //     return AwesomeDialog(listTitle,listTime,listOtherSide,listPreSecond,notificationType);
    //   },
    // );
    savePhotoList(albumNo,_pickedFile);
  }

  void savePhotoList(int albumNo, XFile? imageFile) async{

    int maxPhotoNo = 0;
    maxPhotoNo = await loadPhotoListMaxPhotoNo(albumNo);

    await insPhotoList(albumNo,maxPhotoNo+1,dtNowTime,imageFile);

  }

  Future<int> loadPhotoListMaxPhotoNo(int albumNo) async{
    int maxNo = 0;
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    List<Map> mapSetting = await database.rawQuery("SELECT MAX(photoNo) maxPhotoNo FROM photoList Where albumNo = $albumNo");
    for(Map item in mapSetting){
         maxNo = (item['maxPhotoNo'] != null)?(item['maxPhotoNo']):0;
    }
    return maxNo;
  }
  Future<void> insPhotoList(int albumNo,int photoNo, DateTime dtNowTime ,XFile? imageFile) async{
    String dbPath = await getDatabasesPath();
    String query = '';
    String strLocation = "";
    String path = p.join(dbPath, 'internal_assets.db');
    if(imageFile != null) {
//      strLocation = '${imageFile.path.toString()}\\${imageFile.name.toString()}';
      strLocation = '${imageFile.path.toString()}';

    }
    Database database = await openDatabase(path, version: 1,);
    query = 'INSERT INTO photoList(albumNo,photoNo,datetime,photoLocation,photoName,kaku1,kaku2,kaku3,kaku4) values($albumNo,$photoNo,"${dtNowTime.toString()}","$strLocation","",null,null,null,null) ';
    await database.transaction((txn) async {
      await txn.rawInsert(query);
    });

  }


}

