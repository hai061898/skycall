import 'package:flutter_dotenv/flutter_dotenv.dart';

String? key = dotenv.env['YOUR AGORA_API_KEY']; //link: https://www.agora.io/en/?utm_source=search-ad&utm_medium=cpc&gclid=CjwKCAjwjtOTBhAvEiwASG4bCPriZOTJCi_ZoWppdwNSM8A5LonojIgymZTKnz5ayNUrDNIWuNSD9BoCC8AQAvD_BwE
// ignore: non_constant_identifier_names
String APP_ID = key!;
