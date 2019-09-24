import 'package:flutter/widgets.dart';

class Config {
  final String azureTennantId;
  final String authorizationUrl;
  final String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String scope;
  final String resource;
  final bool enableLogging;
  Rect screenSize;

  Config({
    @required this.azureTennantId,
    @required this.clientId,
    @required this.scope,
    @required this.redirectUri,
    this.clientSecret,
    this.resource,
    this.responseType = "code",
    this.contentType = "application/x-www-form-urlencoded",
    this.enableLogging = false,
    this.screenSize,
  })  : assert(azureTennantId != null && azureTennantId.isNotEmpty),
        assert(clientId != null && clientId.isNotEmpty),
        assert(scope != null && scope.isNotEmpty),
        assert(redirectUri != null && redirectUri.isNotEmpty),
        this.authorizationUrl =
            "https://login.microsoftonline.com/$azureTennantId/oauth2/v2.0/authorize",
        this.tokenUrl =
            "https://login.microsoftonline.com/$azureTennantId/oauth2/v2.0/token";
}
