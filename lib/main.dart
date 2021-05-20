import 'package:background_location/background_location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = '';
  String longitude = '';
  var lat, long;

  @override
  void initState() {
    super.initState();
  }

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Driver'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              locationData('Latitude: ' + latitude),
              locationData('Longitude: ' + longitude),
              ElevatedButton(
                  onPressed: () async {
                    await BackgroundLocation.getPermissions(
                      onGranted: () {
                        // Start location service here or do something else
                        BackgroundLocation.setAndroidNotification(
                          title: 'Location Running',
                          message:
                              'Do not stop the trip until you reach your destination',
                          icon: '@mipmap/ic_launcher',
                        );

                        BackgroundLocation.setAndroidConfiguration(1000);

                        BackgroundLocation.startLocationService(
                            distanceFilter: 20);

                        BackgroundLocation.getLocationUpdates((location) {
                          setState(() {
                            latitude = location.latitude.toString();
                            longitude = location.longitude.toString();

                            databaseReference
                                .child("DriverID")
                                .set({'lat': latitude, 'long': longitude});
                          });
                        });
                      },
                      onDenied: () {
                        print('Please grant permission');
                        // Show a message asking the user to reconsider or do something else
                      },
                    );
                  },
                  child: Text('Start Trip')),
              ElevatedButton(
                  onPressed: () {
                    BackgroundLocation.stopLocationService();
                    databaseReference.child('DriverID').remove();
                  },
                  child: Text('Stop Trip')),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}
