import 'package:flutter/material.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [ 
          
          
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Background music'),
            value: SoundService.instance.soundEnabled,
            onChanged: (value) async {
              await SoundService.instance.toggleSound(value);
              if (mounted) setState(() {});
            },
          ),

          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Enable or disable vibration'),
            value: SoundService.instance.vibrationEnabled,
            onChanged: (value) async {
              await SoundService.instance.toggleVibration(value);
              if (mounted) setState(() {});
            },
          ),


        ],
      ),
    );
  }
}
