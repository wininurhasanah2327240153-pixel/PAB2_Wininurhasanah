import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NFCReaderScreen(),
    );
  }
}

class NFCReaderScreen extends StatefulWidget {
  const NFCReaderScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _NFCReaderState();
}

class _NFCReaderState {
}
