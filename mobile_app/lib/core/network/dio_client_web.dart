import 'package:dio/dio.dart';

/// No-op on web — certificate pinning is not supported in browsers.
void configureCertPinning(Dio dio) {
  // Browsers handle TLS/SSL certificates natively.
  // No custom pinning is possible or needed.
}
