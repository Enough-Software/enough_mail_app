import 'package:location/location.dart';

class LocationService {
  Location? _location;
  bool _serviceEnabled = false;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  Future<LocationData?> getCurrentLocation() async {
    _location ??= Location();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location!.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location!.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return null;
      }
    }
    return await _location!.getLocation();
  }
}
