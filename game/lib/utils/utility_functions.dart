import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:game/api/game_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform; //at the top

Future<void> showAlert(String message, context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<String?> getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id; // unique ID on Android
  }
}

Future<void> showLeaveConfirmationAlert(
    String message, context, ApiClient client) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Leave Group'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('YES'),
            onPressed: () {
              client.serverApi?.leaveGroup();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('NO'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

int numDigs(int num) {
  return num.toString().length;
}

Color constructColorFromUserName(String userName) {
  var hashCode = userName.hashCode;
  while (numDigs(hashCode) != 9) {
    if (numDigs(hashCode) < 9) {
      hashCode *= 10;
    } else {
      hashCode = hashCode ~/ 10;
    }
  }
  List<int> vals = [];
  for (var i = 0; i < 3; i++) {
    vals.add(((hashCode % 1000) / 1000 * 255).round());
    hashCode = hashCode ~/ 1000;
  }
  return Color.fromRGBO(vals[2], vals[1], vals[0], 1.0);
}

enum Status { error, success, info }

void displayToast(message, Status status) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: status == Status.error
        ? (Colors.red)
        : (status == Status.success ? (Colors.green) : Colors.yellow),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Color RGBComplement(Color col) {
  return Color.fromRGBO(255 - col.red, 255 - col.green, 255 - col.blue, 1);
}

Text LatoText(String text, double fs, Color color, FontWeight fw) {
  return Text(text,
      style: GoogleFonts.lato(
          textStyle: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: fs)));
}
