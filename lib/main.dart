import 'package:flutter/material.dart';
import 'package:to_do_list/screen/singleocurringtasklist.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(
        child: SingleOcurringCheckList(),
      ),
    );
  }
}
