import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'helper/logger.dart';
import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final StreamController<String> _onCodeListener = StreamController();
  final FlutterWebviewPlugin _webView = FlutterWebviewPlugin();
  final Config _config;
  AuthorizationRequest _authorizationRequest;

  var _onCodeStream;

  RequestCode(Config config) : _config = config {
    _authorizationRequest = AuthorizationRequest(config);
  }

  Future<String> requestCode() async {
    var code;
    final String urlParams = _constructUrlParams();

    await _webView.launch(
        Uri.encodeFull("${_authorizationRequest.url}?$urlParams"),
        clearCookies: _authorizationRequest.clearCookies,
        hidden: false,
        rect: _config.screenSize);

    _webView.onUrlChanged.listen((String url) {
      if (_config.enableLogging) {
        logPrintWrapped('AAD-OAUTH:URL $url');
      }
      Uri uri = Uri.parse(url);

      final error = uri.queryParameters["error"];
      final errorSubCode = uri.queryParameters["error_subcode"];
      if (error != null || errorSubCode != null) {
        _webView.close();
        if (errorSubCode != null) {
          _onCodeListener.add('ERROR-#-$errorSubCode');
        } else if (error != null) {
          _onCodeListener.add('ERROR-#-$error');
        } else {
          _onCodeListener.add('ERROR');
        }
      }

      if (uri.queryParameters["code"] != null) {
        _webView.close();
        _onCodeListener.add(uri.queryParameters["code"]);
      }
    });

    code = await _onCode.first;
    if (code is String) {
      if (!code.contains('-#-')) {
        throw Exception("access denied or authentation canceled");
      } else {
        final split = code.split('-#-');
        if (split.length == 2) {
          throw Exception(split.last);
        }
      }
    }

    return code;
  }

  Future<void> clearCookies() async {
    await _webView.launch("", hidden: true, clearCookies: true);
    await _webView.close();
  }

  Stream<String> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }
}
