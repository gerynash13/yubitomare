import 'package:flutter/material.dart';

/// One navigator key for the whole app, so Android events (like the intercept card)
/// can open screens from anywhere.
final navKey = GlobalKey<NavigatorState>();