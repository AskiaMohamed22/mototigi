import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mototigi/Blocs/place_bloc.dart';
import 'package:mototigi/Components/autoRotationMarker.dart' as rm;
import 'package:mototigi/Components/loading.dart';
import 'package:mototigi/Screen/Directions/screens/chat_screen/chat_screen.dart';
import 'package:mototigi/Screen/Directions/widgets/arriving_detail_widget.dart';
import 'package:mototigi/Screen/Directions/widgets/booking_detail_widget.dart';
import 'package:mototigi/app_router.dart';
import 'package:mototigi/data/Model/direction_model.dart';
import 'package:mototigi/theme/style.dart';

import '../../Networking/Apis.dart';
import '../../data/Model/get_routes_request_model.dart';
import '../../google_map_helper.dart';
import 'widgets/select_service_widget.dart';

class DirectionsView extends StatefulWidget {
  final PlaceBloc placeBloc;
  DirectionsView({required this.placeBloc});

  @override
  _DirectionsViewState createState() => _DirectionsViewState();
}

class _DirectionsViewState extends State<DirectionsView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController panelController = PanelController();
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  final Apis apis = Apis();

  GoogleMapController? _mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polyLines = {};

  String? distance, duration;
  bool isLoading = false, isResult = false, isComplete = false;

  List<Routes?>? routesData;
  int _polylineIdCounter = 1;
  double? valueRotation;
  String? selectedService; // variable d'état pour le service

  @override
  void initState() {
    super.initState();
    addMarkers();
    getRoute();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void addMarkers() {
    final from = widget.placeBloc.formLocation;
    final to = widget.placeBloc.locationSelect;

    if (from != null) {
      final idFrom = MarkerId("from_address");
      markers[idFrom] = Marker(
        markerId: idFrom,
        position: LatLng(from.lat ?? 0.0, from.lng ?? 0.0),
        infoWindow: InfoWindow(title: from.name, snippet: from.formattedAddress),
      );
    }

    if (to != null) {
      final idTo = MarkerId("to_address");
      markers[idTo] = Marker(
        markerId: idTo,
        position: LatLng(to.lat ?? 0.0, to.lng ?? 0.0),
        infoWindow: InfoWindow(title: to.name, snippet: to.formattedAddress),
      );
    }

    setState(() {});
  }

  Future<void> getRoute() async {
    final from = widget.placeBloc.formLocation;
    final to = widget.placeBloc.locationSelect;
    if (from == null || to == null) return;

    final pid = 'polyline_id_$_polylineIdCounter';
    final polyId = PolylineId(pid);
    polyLines.clear();

    try {
      final resp = await apis.getRoutes(
        getRoutesRequest: GetRoutesRequestModel(
          fromLocation: LatLng(from.lat ?? 0.0, from.lng ?? 0.0),
          toLocation: LatLng(to.lat ?? 0.0, to.lng ?? 0.0),
          mode: "driving",
          origin: '',
          destination: '',
        ),
      );

      routesData = resp.result?.routes;
      distance = routesData?[0]?.legs?[0]?.distance?.text;
      duration = routesData?[0]?.legs?[0]?.duration?.text;

      final points = resp.result?.routes?[0]?.overviewPolyline?.points;
      polyLines[polyId] = GMapViewHelper.createPolyline(
        polylineIdVal: pid,
        router: points,
        formLocation: LatLng(from.lat ?? 0.0, from.lng ?? 0.0),
        toLocation: LatLng(to.lat ?? 0.0, to.lng ?? 0.0),
      );

      setState(() {});
      _gMapViewHelper.cameraMove(
        fromLocation: LatLng(from.lat ?? 0.0, from.lng ?? 0.0),
        toLocation: LatLng(to.lat ?? 0.0, to.lng ?? 0.0),
        mapController: _mapController!,
      );
    } catch (e) {
      print("Erreur getRoute: $e");
    }
  }

  void runTrackingDriver(List<LatLng> path) {
    int idx = 1;
    Timer.periodic(const Duration(seconds: 2), (t) {
      if (idx >= path.length) {
        t.cancel();
        setState(() => isComplete = true);
        showDialog(context: context, builder: (_) => dialogInfo());
        return;
      }
      final prev = path[idx - 1];
      final curr = path[idx++];
      valueRotation = rm.calculateangle(
        prev.latitude, prev.longitude, curr.latitude, curr.longitude,
      );
      addMarkerDriver(curr);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: curr, zoom: 15.0),
        ),
      );
    });
  }

  void addMarkerDriver(LatLng pos) {
    final mid = MarkerId("driver");
    markers[mid] = Marker(
      markerId: mid,
      position: pos,
      draggable: false,
      rotation: valueRotation ?? 0.0,
      consumeTapEvents: true,
    );
    setState(() {});
  }

  Widget dialogInfo() {
    return AlertDialog(
      title: const Text("Information"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: const Text("Course terminée. Consultez votre trajet !"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(AppRoute.reviewTripScreen);
          },
          child: const Text("Ok"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.placeBloc.formLocation;
    final initial = start != null
        ? LatLng(start.lat ?? 0.0, start.lng ?? 0.0)
        : const LatLng(0.0, 0.0);

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            markers: markers.values.toSet(),
            polylines: polyLines.values.toSet(),
            initialCameraPosition: CameraPosition(target: initial, zoom: 14.0),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Sélecteur de service
          SelectServiceWidget(
            serviceSelected: selectedService ?? '',
            panelController: panelController,
          ),
        ],
      ),
    );
  }
}
