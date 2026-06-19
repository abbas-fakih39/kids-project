import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Certificate pinning for native platforms (Android/iOS).
void configureCertPinning(Dio dio) {
  if (kReleaseMode) {
    const certSha256 = String.fromEnvironment('CERT_SHA256', defaultValue: '');
    if (certSha256.isNotEmpty) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
          HttpClient()
            ..badCertificateCallback = (cert, host, port) =>
                sha256.convert(cert.der).toString() == certSha256;
    }
  }
}
