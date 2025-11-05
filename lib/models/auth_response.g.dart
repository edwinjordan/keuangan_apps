// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  isSuccess: json['isSuccess'] as bool?,
  data: json['data'] == null
      ? null
      : AuthData.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'data': instance.data,
      'message': instance.message,
      'user': instance.user,
    };

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
  accessToken: json['access_token'] as String?,
  tokenType: json['token_type'] as String?,
);

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'token_type': instance.tokenType,
};
