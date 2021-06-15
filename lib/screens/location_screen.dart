import 'package:cached_network_image/cached_network_image.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/location_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:latlng/latlng.dart';
import 'package:location/location.dart';
import 'package:map/map.dart';
import 'dart:ui' as ui;
import '../locator.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final repaintBoundaryKey = GlobalKey();

  LatLng defaultLocation = LatLng(53.07516, 8.80777);
  late MapController controller;
  Future<LocationData?>? findLocation;
  late Offset _dragStart;
  double _scaleStart = 1.0;

  void _gotoDefault() {
    controller.center = defaultLocation;
  }

  void _onDoubleTap() {
    controller.zoom += 0.5;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart;
      _dragStart = now;
      controller.drag(diff.dx, diff.dy);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = MapController(location: defaultLocation);
    findLocation = locator<LocationService>().getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Base.buildAppChrome(
      context,
      title: localizations.attachTypeLocation,
      appBarActions: [
        PlatformIconButton(
          icon: Icon(Icons.check),
          onPressed: onLocationSelected,
        ),
      ],
      content: FutureBuilder<LocationData?>(
        future: findLocation,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(child: PlatformProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasData) {
                defaultLocation =
                    LatLng(snapshot.data!.latitude!, snapshot.data!.longitude!);
                controller.center = defaultLocation;
                return buildMap();
              }
          }
          return buildMap();
        },
      ),
    );
  }

  void onLocationSelected() async {
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();
    locator<NavigationService>().pop(pngBytes);
  }

  Widget buildMap() {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: (details) {
        print(
            "Location: ${controller.center.latitude}, ${controller.center.longitude}");
      },
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: RepaintBoundary(
          key: repaintBoundaryKey,
          child: Stack(
            children: [
              Map(
                controller: controller,
                builder: (context, x, y, z) {
                  final url =
                      'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Center(
                child: Icon(Icons.close, color: Colors.red),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformIconButton(
                    icon: Icon(
                      Icons.location_searching,
                      color: Colors.grey,
                    ),
                    onPressed: _gotoDefault,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
