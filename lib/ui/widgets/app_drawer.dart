import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/home_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (_, c) => c is AppThemeState,
            builder: (context, state) {
              bool isDarkMode =
                  state is AppThemeState && state.themeMode == ThemeMode.dark;
              return SwitchListTile(
                title: const Text("Theme"),
                value: isDarkMode,
                onChanged: (v) {
                  final mode = v ? ThemeMode.dark : ThemeMode.light;
                  context.read<HomeBloc>().add(ChangeAppThemeEvent(mode));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
