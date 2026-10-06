import 'package:flutter/widgets.dart';

/// Punto de corte entre telefono y escritorio/tablet.
const double kMobileBreakpoint = 600;

bool isNarrow(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kMobileBreakpoint;
