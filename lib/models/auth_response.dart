import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final bool? isSuccess;
  final AuthData? data;
  final String? message;
  final User? user;

  AuthResponse({
    this.isSuccess,
    this.data,
    this.message,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle response format: { "success": true, "data": { "access_token": "...", "token_type": "..." }, "message": "..." }
    // or { "isSuccess": true, "data": { "access_token": "...", "token_type": "..." }, "message": "..." }
    if ((json.containsKey('isSuccess') || json.containsKey('success')) && json.containsKey('data')) {
      return AuthResponse(
        isSuccess: (json['isSuccess'] ?? json['success']) as bool?,
        data: json['data'] != null ? AuthData.fromJson(json['data'] as Map<String, dynamic>) : null,
        message: json['message'] as String?,
        user: null, // User will be fetched separately
      );
    }
    
    // Fallback to generated method for other formats
    return _$AuthResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  bool get isAuthSuccess => (isSuccess ?? false) && data?.accessToken != null;
  
  String? get token => data?.accessToken;
  
  String? get tokenType => data?.tokenType;

  @override
  String toString() => 'AuthResponse(isSuccess: $isSuccess, token: ${token != null ? "***" : null}, message: $message)';
}

@JsonSerializable()
class AuthData {
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @JsonKey(name: 'token_type')
  final String? tokenType;

  AuthData({
    this.accessToken,
    this.tokenType,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
