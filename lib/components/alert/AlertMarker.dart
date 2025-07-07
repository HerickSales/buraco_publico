import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AlertMarker extends Marker {
  AlertMarker({
    required LatLng point,
    required Function onTap,
    double size = 40,
    Color color = Colors.red,
  }) : super(
    point: point,
    width: size,
    height: size,
    child: GestureDetector(
      onTap: () => onTap(),
      child: Icon(
        Icons.warning,
        color: color,
        size: size,
      ),
    ),
  );
}

