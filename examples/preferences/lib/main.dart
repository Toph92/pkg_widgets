import 'package:flutter/material.dart';
import 'package:pkg_widgets/preferences.dart';

enum LocalPrefsEnum { saveAuto, username, fontSize, toto }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late Preferences<LocalPrefsEnum> preferences;

  @override
  void dispose() {
    preferences.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    preferences =
        Preferences<LocalPrefsEnum>(enumValues: LocalPrefsEnum.values);
    preferences.addListener(() => setState(() {}));
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    await preferences.initialize();
    preferences[LocalPrefsEnum.toto] ??= "toto";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paramètres")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...[
              SwitchListTile(
                title: Text("Sauvegarde Automatique"),
                //value: _getPreference(LocalPrefsEnum.saveAuto) ?? false,
                value: preferences[LocalPrefsEnum.saveAuto] ?? false,
                onChanged: (value) =>
                    preferences[LocalPrefsEnum.saveAuto] = value,
                //_updatePreference(LocalPrefsEnum.saveAuto, value),
              ),
              TextFormField(
                initialValue:
                    //_getPreference(LocalPrefsEnum.username) ?? "Guest",
                    preferences[LocalPrefsEnum.username] ?? "Guest",
                decoration: InputDecoration(labelText: "Nom d'utilisateur"),
                onChanged: (value) =>
                    preferences[LocalPrefsEnum.username] = value,
                //_updatePreference(LocalPrefsEnum.username, value),
              ),
              Slider(
                min: 10.0,
                max: 24.0,
                //value: _getPreference(LocalPrefsEnum.fontSize) ?? 14.0,
                value: preferences[LocalPrefsEnum.fontSize] ?? 14.0,
                onChanged: (value) =>
                    preferences[LocalPrefsEnum.fontSize] = value,
                //_updatePreference(LocalPrefsEnum.fontSize, value),
                label:
                    "Taille de police: ${(preferences[LocalPrefsEnum.fontSize] ?? 14.0).toStringAsFixed(1)}",
              ),
              SizedBox(height: 20),
              Text(
                "Aperçu",
                style: TextStyle(
                  fontSize: preferences[LocalPrefsEnum.fontSize] ?? 14.0,
                ),
              ),
              Text(
                "Nom d'utilisateur : ${preferences[LocalPrefsEnum.username] ?? 'Guest'}",
                style: TextStyle(
                  fontSize: preferences[LocalPrefsEnum.fontSize] ?? 14.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsScreen(),
    );
  }
}
