import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';

/// 1x1 şeffaf PNG; NetworkImage testlerinde HTTP yanıtı olarak kullanılır.
final kTestImageBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

/// Test ortamında tüm HTTP isteklerine 200 + [kTestImageBytes] döndüren mock.
HttpClient createMockImageHttpClient(SecurityContext? context) {
  return _MockHttpClient();
}

class _MockHttpClient extends Mock implements HttpClient {
  final _MockHttpClientRequest _request = _MockHttpClientRequest();

  _MockHttpClient() {
    when(() => getUrl(any())).thenAnswer((_) async => _request);
  }
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {
  final _MockHttpClientResponse _response = _MockHttpClientResponse();

  _MockHttpClientRequest() {
    when(() => close()).thenAnswer((_) async => _response);
  }
}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTestImageBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    void Function()? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([kTestImageBytes]).listen(
      onData,
      onDone: onDone,
      onError: onError as void Function(Object, StackTrace)?,
      cancelOnError: cancelOnError,
    );
  }
}
