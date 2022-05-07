import 'package:flutter/material.dart';
import 'package:skype_c/ui/screen/call/pickup/pickup_layout.dart';
import 'package:skype_c/ui/themes/universal_variables.dart';
import 'package:skype_c/ui/widgets/skype_appbar.dart';

import 'components/floating_column.dart';
import 'components/log_list_container.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: 'Calls',
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/search_screen');
              },
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 15),
            child: LogListContainer(),
          ),
        ),
        floatingActionButton: FloatingColumn(),
      ),
    );
  }
}
