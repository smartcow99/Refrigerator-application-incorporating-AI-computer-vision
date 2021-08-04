import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // key: scaffoldKey,
        theme: ThemeData(primaryColor: Colors.white),
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Setting"),
            actions: [
              Builder(builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    print("button pressed");
                    // final snackBar = SnackBar(content: const Text("Save Done!"));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text("Save Done!")));
                    //Todo save all 구현
                  },
                  icon: Icon(Icons.save_alt),
                );
              })
            ],
          ),
        ));
  }
}
