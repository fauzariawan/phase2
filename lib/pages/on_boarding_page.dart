import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/pages/loginscreen.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OnBoardingPageState();
  }
}

class OnBoardingPageState extends State<OnBoardingPage> {
  List<Slide> listSlides = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // exit;
          await showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: new Text('Are you sure?'),
                  content: new Text('Do you want to exit an App'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: new Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: new Text('Yes'),
                    ),
                  ],
                ),
              );
          
          return false;
        },
        child: IntroSlider(
          slides: listSlides,
          onDonePress: onPressedDone,
          onSkipPress: onPressedDone,
          renderSkipBtn: this.renderSkipBtn(),
          renderNextBtn: this.renderNextBtn(),
          renderDoneBtn: this.renderDoneBtn(),
        ));
  }

  @override
  void initState() {
    super.initState();
    listSlides.add(Slide(
      widgetTitle: widgetTitle(),
      pathImage: "images/boarding_1.png",
      widgetDescription: widgetDescription("WrkPln",
          "Merupakan aplikasi untuk pengelolaan kinerja karyawan dalam melakukan perencanaan dan pelaksanaan pekerjaan"),
      backgroundColor: Colors.white,
    ));
    listSlides.add(Slide(
      widgetTitle: widgetTitle(),
      widgetDescription: widgetDescription("GPS & Kamera HP",
          "Aplikasi memerlukan penggunaan lokasi GPS dari Google sebagai bukti kunjungan dilakukan di lokasi yang benar & kamera HP untuk pengambilan photo dokumen pelanggan"),

      pathImage: "images/boarding_2.png",
      backgroundColor: Colors.white,
    ));
    listSlides.add(Slide(
      widgetTitle: widgetTitle(),
      widgetDescription: widgetDescription("Keamanan Data",
          "Data tersimpan dalam sistem cloud dengan tingkat keamanan yang ketat dan tinggi yang hanya bisa diakses oleh pihak yang diijinkan, dan telah memperoleh sertifikasi keamanan dunia"),

      pathImage: "images/boarding_3.png",
      backgroundColor: Colors.white,
    ));
  }

  Widget renderNextBtn() {
    return Text(
      "NEXT",
      style: TextStyle(
          fontSize: 18,
          color: SystemParam.colorCustom,
          fontWeight: FontWeight.bold),
    );
  }

  Widget renderDoneBtn() {
    return Text(
      "DONE",
      style: TextStyle(
          fontSize: 18,
          color: SystemParam.colorCustom,
          fontWeight: FontWeight.bold),
    );
  }

  Widget renderSkipBtn() {
    return Text(
      "SKIP",
      style: TextStyle(
          fontSize: 18,
          color: SystemParam.colorCustom,
          fontWeight: FontWeight.bold),
    );
  }

  onPressedDone() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
  }

  widgetDescription(String title, String desc) {
    return Center(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: SystemParam.colorCustom, fontSize: 25, fontFamily: "calibre"), 
              // GoogleFonts.roboto(
              //   fontSize: 36,
              //   fontWeight: FontWeight.bold,
              //   color: SystemParam.colorCustom
              // )
              // TextStyle(color: SystemParam.colorCustom, fontSize: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style:  
              // GoogleFonts.poppins(fontSize: 13, color: SystemParam.colorCustom)
              TextStyle(color: SystemParam.colorCustom, fontSize: 13, fontFamily: "poppins"),
            ),
          ),
        ],
      ),
    );
  }

  widgetTitle() {
    return new Center(
      child: new Image.asset(
        "images/App_Splash/WrkPln Logo 2.png",
        height: 100.0,
        width: 100.0,
      ),
    );
  }
}
