import 'dart:math';

import 'package:flutter/material.dart';
import 'simple_animations_package.dart';
import 'package:flutter_background_location/flutter_background_location.dart';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:http/http.dart';

// Initialized Variables
String deviceid = null;
var response_body = null;

// Access information
String website_ip = "http://192.168.86.28";
String username = "admin";
String password = 'SuperSecretPwd';


void main() {
runApp(ParticleApp());

print("Starting Location Service");
FlutterBackgroundLocation.startLocationService();
FlutterBackgroundLocation.getLocationUpdates((location) {
  var latitude = location.latitude;
  var longitude = location.longitude;
  var loc = "$latitude, $longitude";
  print("Location Determined: $latitude,$longitude");
  _makeGetRequest("user_Location", loc);
});
}

_makeGetRequest(subdomain, params) async {
  // make GET request
  List userList = await Future.wait([_getId()]);
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  String url = '$website_ip:5000/api/v1/$subdomain?user=${userList[0]}&location=$params';
  try {
    Response response = await get(
        url, headers: <String, String>{'authorization': basicAuth});
    print(response.body);
  }
  catch (e){
    print("Errored");
  }
}

_makeGetRequest_2(params0, params, params2) async {
  // make GET request
  List userList = await Future.wait([_getId()]);
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  String url = '$website_ip:5000/api/v1/contact_Form?user=${userList[0]}'
      '&patient_id=$params0&home_location=$params&email_information=$params2';
  try {
    Response response = await get(
        url, headers: <String, String>{'authorization': basicAuth});
    print(response.body);
  }
  catch (e){
    print("Errored");
  }
}


Future<String> _getId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    deviceid = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    deviceid = androidDeviceInfo.androidId; // unique ID on Android
    print("Android Device Info $deviceid");
    return deviceid;
  }

}


class SecondRoute extends StatelessWidget {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Submit Information"),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.account_circle), onPressed: () {})
        ],
      ),
      body: new Column(

        children: <Widget>[
          SizedBox(height: 10),
          new ListTile(
            leading: const Icon(Icons.person),
            title: new TextField(
              controller: _controller,
              decoration: new InputDecoration(
                hintText: "Patient ID",
              ),
            ),
          ),
          new ListTile(
            leading: const Icon(Icons.add_location),
            title: new TextField(
              controller: _controller1,

              decoration: new InputDecoration(
                hintText: "Home Location",
                suffixIcon: IconButton(
                  onPressed: () async{

                  },
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          new ListTile(
            leading: const Icon(Icons.email),
            title: new TextField(
              controller: _controller2,
              decoration: new InputDecoration(
                hintText: "Email/Phone Number",
              ),
            ),
          ),
          const Divider(
            height: 1.0,
          ),

          SizedBox(height: 30),
         new FlatButton(
            color: Colors.lightBlue,
            textColor: Colors.white,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () {

            _makeGetRequest_2(_controller.text, _controller1.text, _controller2.text);

            print(_controller2.text);
              _controller.clear();
              _controller1.clear();
              _controller2.clear();
            },
            child: Text(
              "Submit Information",
              style: TextStyle(fontSize: 21.0),
            ),

          )
        ],
      ),
    );  }
}

class ParticleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    	debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/second': (context) => SecondRoute(),
        },
        home: Scaffold(
        body: ParticleBackgroundPage(),
        floatingActionButton: changeNavigation(),
      )
    );
  }
}

class changeNavigation extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/second');
      },
      label: Text('Register Contact'),
    );
  }
}

class ParticleBackgroundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: AnimatedBackground()),
        Positioned.fill(child: Particles(30)),
        Positioned.fill(child: CenteredText()),
      ],
    );
  }
}

class Particles extends StatefulWidget {
  final int numberOfParticles;

  Particles(this.numberOfParticles);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(ParticleModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: ParticlePainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}

class ParticleModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  Random random;

  ParticleModel(this.random) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final duration = Duration(milliseconds: 3000 + random.nextInt(6000));

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.2 + random.nextDouble() * 0.4;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(50);

    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position =
      Offset(animation["x"] * size.width, animation["y"] * size.height);
      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff8a113a), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff440216), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class CenteredText extends StatelessWidget {
  const CenteredText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "CoPtracker",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200),
        textScaleFactor: 4,
      ),
    );
  }
}
