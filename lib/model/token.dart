class Token {
  //offset is subtracted from expire time
  final expireOffSet = 5;

  String accessToken;
  String tokenType;
  String refreshToken;
  DateTime issueTimeStamp;
  DateTime expireTimeStamp;
  int expiresIn;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) => Token.fromMap(json);

  factory Token.fromMap(Map map) {
    if (map == null) throw Exception("No token from received");
    //error handling as described in https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow#error-response-1
    if (map["error"] != null)
      throw Exception("Error during token request: " +
          map["error"] +
          ": " +
          map["error_description"]);

    Token token = Token();
    token.accessToken = map["access_token"];
    token.tokenType = map["token_type"];
    token.expiresIn = map["expires_in"] is int
        ? map["expires_in"]
        : int.tryParse(map["expires_in"].toString()) ?? 60;
    token.refreshToken = map["refresh_token"];
    token.issueTimeStamp = DateTime.now().toUtc();
    token.expireTimeStamp = map.containsKey("expire_timestamp")
        ? DateTime.fromMillisecondsSinceEpoch(map["expire_timestamp"])
        : token.issueTimeStamp
            .add(Duration(seconds: token.expiresIn - token.expireOffSet));
    return token;
  }

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (accessToken != null) {
      map["access_token"] = accessToken;
    }
    if (tokenType != null) {
      map["token_type"] = tokenType;
    }
    if (refreshToken != null) {
      map["refresh_token"] = refreshToken;
    }
    if (expiresIn != null) {
      map["expires_in"] = expiresIn;
    }
    if (expireTimeStamp != null) {
      map["expire_timestamp"] = expireTimeStamp.millisecondsSinceEpoch;
    }
    return map;
  }

  @override
  String toString() => toMap().toString();

  bool get isExpired => expireTimeStamp.isBefore(DateTime.now().toUtc());

  static bool tokenIsValid(Token token) {
    return token != null && !token.isExpired && token.accessToken != null;
  }
}
