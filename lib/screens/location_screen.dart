import 'package:cached_network_image/cached_network_image.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/location_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../l10n/app_localizations.g.dart';
import 'package:latlng/latlng.dart';
import 'package:location/location.dart';
import 'package:map/map.dart';
import 'dart:ui' as ui;
import '../locator.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _repaintBoundaryKey = GlobalKey();

  final _defaultLocation = const LatLng(53.07516, 8.80777);
  late MapController _controller;
  Future<LocationData?>? _findLocation;
  late Offset _dragStart;
  double _scaleStart = 1.0;

  @override
  void initState() {
    _findLocation = locator<LocationService>().getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Base.buildAppChrome(
      context,
      title: localizations.attachTypeLocation,
      appBarActions: [
        PlatformIconButton(
          icon: const Icon(Icons.check),
          onPressed: _onLocationSelected,
        ),
      ],
      content: FutureBuilder<LocationData?>(
        future: _findLocation,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: PlatformProgressIndicator());
            case ConnectionState.done:
              final data = snapshot.data;
              if (data != null) {
                return _buildMap(context, data.latitude!, data.longitude!);
              }
          }
          return const Center(child: PlatformProgressIndicator());
        },
      ),
    );
  }

  void _onLocationSelected() async {
    final context = _repaintBoundaryKey.currentContext;
    if (context == null) {
      locator<NavigationService>().pop();
      return;
    }
    final boundary = context.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();
    locator<NavigationService>().pop(pngBytes);
  }

  Widget _buildMap(BuildContext context, double latitude, double longitude) {
    final size = MediaQuery.of(context).size;
    return MapLayout(
      controller: _controller,
      builder: (context, transformer) => GestureDetector(
        onDoubleTap: _onDoubleTap,
        onScaleStart: _onScaleStart,
        onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
        onScaleEnd: (details) {
          if (kDebugMode) {
            print(
                "Location: ${_controller.center.latitude}, ${_controller.center.longitude}");
          }
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Stack(
              children: [
                Map(
                  controller: _controller,
                  builder: (context, x, y, z) {
                    final url =
                        'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                    return CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                const Center(
                  child: Icon(Icons.close, color: Colors.red),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformIconButton(
                      icon: const Icon(
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
      ),
    );
  }

  void _gotoDefault() {
    _controller.center = _defaultLocation;
    setState(() {});
  }

  void _onDoubleTap() {
    _controller.zoom += 0.5;
    setState(() {});
  }

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - _scaleStart;
    //print('on scale update: scaleDiff=$scaleDiff focal=${details.focalPoint}');
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      _controller.zoom += 0.02;
    } else if (scaleDiff < 0) {
      _controller.zoom -= 0.02;
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart;
      _dragStart = now;
      transformer.drag(diff.dx, diff.dy);
    }
    setState(() {});
  }
}
