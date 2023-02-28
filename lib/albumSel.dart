import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart' as p;
import './const.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AlbumSelScreen extends StatefulWidget {
  const AlbumSelScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<AlbumSelScreen> createState() =>  _AlbumSelScreenState();
}
class _AlbumSelScreenState extends State<AlbumSelScreen> {
  //バナー広告初期化
  final BannerAd myBanner = BannerAd(
    adUnitId : strCnsBannerID,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print('バナー広告がロードされました'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        //  print('バナー広告の読み込みが次の理由で失敗しました: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('バナー広告が開かれました'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('バナー広告が閉じられました'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  );
  @override
  void initState() {
    super.initState();
    loadSetting();
  }
  @override
  Widget build(BuildContext context) {
    //動画バナーロード
    myBanner.load();
    final AdWidget adWidget = AdWidget(ad: myBanner);
    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('アルバム'),backgroundColor: const Color(0xFF6495ed),),
      body: Column(
        children:  <Widget>[
          Padding(padding: EdgeInsets.all(30)),
          adContainer,
        ],

      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'ホーム', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label:'アルバム', icon: Icon(Icons.list)),
        ],
        onTap: (int index) {
          if (index == 0) {Navigator.pushNamed(context, '/');}
        },
      ),
    );
  }
  /*------------------------------------------------------------------
  ロード処理
 -------------------------------------------------------------------*/
  Future<void> loadSetting() async{

    // String dbPath = await getDatabasesPath();
    // String path = p.join(dbPath, 'internal_assets.db');
    // Database database = await openDatabase(path, version: 1,);
    // List<Map> mapSetting = await database.rawQuery("SELECT * From setting limit 1");
    // for(Map item in mapSetting){
    //   setState(() {   _type = item['notificationsetting'];  });
    // }

  }

}