import 'dart:async';
import 'dart:convert';

import 'package:aad_oauth/helper/logger.dart';
import 'package:http/http.dart';

import 'model/config.dart';
import 'model/token.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';

class RequestToken {
  final Config config;
  TokenRequestDetails _tokenRequest;
  TokenRefreshRequestDetails _tokenRefreshRequest;

  RequestToken(this.config);

  Future<Token> requestToken(String code) async {
    _generateTokenRequest(code);
    logPrintWrapped(code, tag: 'TOKEN-CODE');
    return await _sendTokenRequest(
      _tokenRequest.url,
      _tokenRequest.params,
      _tokenRequest.headers,
    );
  }

  Future<Token> requestRefreshToken(String refreshToken) async {
    _generateTokenRefreshRequest(refreshToken);
    logPrintWrapped(refreshToken, tag: 'TOKEN-REFRESH');
    return await _sendTokenRequest(
      _tokenRefreshRequest.url,
      _tokenRefreshRequest.params,
      _tokenRefreshRequest.headers,
    );
  }

  Future<Token> _sendTokenRequest(
    String url,
    Map<String, String> params,
    Map<String, String> headers,
  ) async {
    Response response = await post(url, body: params, headers: headers);
    logPrintWrapped(response.body, tag: 'TOKEN-REQUEST');
    Map<String, dynamic> tokenJson = json.decode(response.body);
    return Token.fromJson(tokenJson);
  }

  void _generateTokenRequest(String code) {
    _tokenRequest = TokenRequestDetails(config, code);
  }

  void _generateTokenRefreshRequest(String refreshToken) {
    _tokenRefreshRequest = TokenRefreshRequestDetails(config, refreshToken);
  }
}
