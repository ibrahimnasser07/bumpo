import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/home_bloc.dart';
import '../widgets/app_drawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text("Bumpo Home")),
      drawer: const AppDrawer(),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is LocationIsWithinRange) {
            AudioPlayer().play(AssetSource('warning_beep.mp3'));
            EasyLoading.showInfo(
              "Bump is close!",
              dismissOnTap: true,
              duration: const Duration(seconds: 2),
            );
          }
        },
        buildWhen: (_, c) =>
            c is MarkersFetchedSuccessfully ||
            c is BumpSavedSuccessfully ||
            c is LocationPermissionGranted ||
            c is LocationPermissionDenied ||
            c is PermissionCheckInProgress,
        builder: (context, state) {
          if (state is PermissionCheckInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationPermissionDenied) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(child: Text(state.message, textAlign: TextAlign.center)),
                FilledButton(
                  onPressed: () => bloc.add(CheckLocationPermission()),
                  child: const Text("Request Location Permission"),
                )
              ],
            );
          }

          if (state is LocationPermissionGranted ||
              state is MarkersFetchedSuccessfully ||
              state is BumpSavedSuccessfully) {
            return GoogleMap(
              onMapCreated: (mapController) =>
                  bloc.add(GoogleMapCreatedEvent(mapController)),
              initialCameraPosition: const CameraPosition(
                target: LatLng(30.0444, 31.2357),
                zoom: 18.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: bloc.markers,
            );
          }

          return Container();
        },
      ),
    );
  }
}
