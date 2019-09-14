library aad_oauth;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/auth_storage.dart';
import 'model/config.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';

class AadOAuth {
  static Config _config;
  AuthStorage _authStorage;
  Token _token;
  RequestCode _requestCode;
  RequestToken _requestToken;

  factory AadOAuth(config) {
    if (AadOAuth._instance == null)
      AadOAuth._instance = AadOAuth._internal(config);
    return _instance;
  }

  static AadOAuth _instance;

  AadOAuth._internal(config) {
    AadOAuth._config = config;
    _authStorage = _authStorage ?? AuthStorage();
    _requestCode = RequestCode(_config);
    _requestToken = RequestToken(_config);
  }

  void setWebViewScreenSize(Rect screenSize) {
    _config.screenSize = screenSize;
  }

  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  Future<Token> getToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token;
  }

  Future<String> getAccessToken() async {
    final token = await getToken();

    return token.accessToken;
  }

  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = null;
    AadOAuth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage.loadTokenToCache();

    //still have refresh token / try to get access token with refresh token
    if (_token != null)
      await _performRefreshAuthFlow();

    // if we have no refresh token try to perform full request code oauth flow
    else {
      await _performFullAuthFlow();
    }

    //save token to cache
    await _authStorage.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    String code = await _requestCode.requestCode();
    _token = await _requestToken.requestToken(code);
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token.refreshToken);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = "freshInstall";
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
