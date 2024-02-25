import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:location/location.dart';
import 'package:map/map.dart' as map;

import '../localization/extension.dart';
import '../logger.dart';
import '../routes/routes.dart';
import '../screens/base.dart';
import 'service.dart';

class LocationScreen extends StatefulHookConsumerWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _repaintBoundaryKey = GlobalKey();

  final _defaultLocation = LatLng.degree(53.07516, 8.80777);
  late map.MapController _controller;
  Future<LocationData?>? _findLocationFuture;
  late Offset _dragStart;
  var _scaleStart = 1.0;

  @override
  void initState() {
    _controller = map.MapController(
      location: _defaultLocation,
    );
    _findLocationFuture = LocationService.instance.getCurrentLocation().then(
      (value) {
        final latitude = value?.latitude;
        final longitude = value?.longitude;
        if (latitude != null && longitude != null) {
          _controller.center = LatLng.degree(latitude, longitude);
        }

        return value;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ref.text;

    return BasePage(
      title: localizations.attachTypeLocation,
      appBarActions: [
        PlatformIconButton(
          icon: const Icon(Icons.check),
          onPressed: _onLocationSelected,
        ),
      ],
      content: FutureBuilder<LocationData?>(
        future: _findLocationFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: PlatformProgressIndicator());
            case ConnectionState.done:
              final latitude = snapshot.data?.latitude;
              final longitude = snapshot.data?.longitude;
              if (latitude != null && longitude != null) {
                return _buildMap(context, latitude, longitude);
              }
          }

          return const Center(child: PlatformProgressIndicator());
        },
      ),
    );
  }

  Future<void> _onLocationSelected() async {
    final context = _repaintBoundaryKey.currentContext;
    if (context == null) {
      final currentContext = Routes.navigatorKey.currentContext;
      if (currentContext != null) {
        currentContext.pop();
      }

      return;
    }
    final boundary = context.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      context.pop();

      return;
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    if (context.mounted) {
      context.pop(pngBytes);
    }
  }

  Widget _buildMap(BuildContext context, double latitude, double longitude) {
    final size = MediaQuery.of(context).size;

    return map.MapLayout(
      controller: _controller,
      builder: (context, transformer) => GestureDetector(
        onDoubleTap: _onDoubleTap,
        onScaleStart: _onScaleStart,
        onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
        onScaleEnd: (details) {
          logger.d(
            'Location: ${_controller.center.latitude}, '
            '${_controller.center.longitude}',
          );
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Stack(
              children: [
                map.TileLayer(
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
                    padding: const EdgeInsets.all(8),
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

  void _onScaleUpdate(
    ScaleUpdateDetails details,
    map.MapTransformer transformer,
  ) {
    final scaleDiff = details.scale - _scaleStart;
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
