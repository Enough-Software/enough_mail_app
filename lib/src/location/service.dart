import 'package:location/location.dart';

/// Allows to query the current location
class LocationService {
  LocationService._();

  static final _instance = LocationService._();

  /// Returns the singleton instance
  static LocationService get instance => _instance;

  Location? _location;
  bool _serviceEnabled = false;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  /// Retrieves the current location
  Future<LocationData?> getCurrentLocation() async {
    final location = _location ?? Location();
    _location = location;
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return null;
      }
    }

    return location.getLocation();
  }
}
