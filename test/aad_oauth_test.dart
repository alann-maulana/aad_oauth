import 'package:flutter_test/flutter_test.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

void main() {
  test('adds one to input values', () {
    final Config config = new Config(
      azureTennantId: "YOUR TENANT ID",
      clientId: "YOUR CLIENT ID",
      scope: "openid profile offline_access",
      redirectUri: "redirect uri",
    );
    final AadOAuth oauth = new AadOAuth(config);

    //TODO testing
  });
}
