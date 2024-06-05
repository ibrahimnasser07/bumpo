import 'package:bumpo/ui/widgets/textfield_list_tile.dart';
import 'package:bumpo/utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/home_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: Image.asset("lib/images/bumpo_logo.png"),
                  ),
                  const Text(
                    "Bumpo",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (_, c) => c is AppThemeState,
              builder: (context, state) {
                return SwitchListTile(
                  title: const Text("Theme"),
                  value: getCurrentThemeMode() == ThemeMode.dark,
                  onChanged: (v) {
                    final mode = v ? ThemeMode.dark : ThemeMode.light;
                    context.read<HomeBloc>().add(ChangeAppThemeEvent(mode));
                  },
                );
              },
            ),
            const Divider(),
            TextFieldListTile(
              label: "Threshold (ΔZ)",
              controller: context.read<HomeBloc>().thresholdController,
            ),
            TextFieldListTile(
              label: "Interval (msec)",
              controller: context.read<HomeBloc>().intervalController,
            ),
            // TextFieldListTile(
            //   label: "Min. Speed (km/hr)",
            //   controller: context.read<HomeBloc>().minSpeedController,
            // ),
          ],
        ),
      ),
    );
  }
}
