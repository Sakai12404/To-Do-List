import 'package:flutter/material.dart';
import 'package:to_do_list/screen/singleocurringtasklist.dart';
import 'package:to_do_list/screen/recurringtasklist.dart';
import 'package:to_do_list/screen/singleocurringtasklist.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      home:  const SingleOcurringCheckList(),
    );
  }
}
