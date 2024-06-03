import 'package:bumpo/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/app_drawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bumpo Home")),
      drawer: const AppDrawer(),
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (_, c) => c is GoogleMapCreatedSuccess,
        builder: (context, state) {
          return GoogleMap(
            onMapCreated: (mapController) => context
                .read<HomeBloc>()
                .add(GoogleMapCreatedEvent(mapController)),
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 18.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}
