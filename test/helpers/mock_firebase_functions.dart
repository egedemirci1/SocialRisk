import 'package:cloud_functions/cloud_functions.dart';
import 'package:mocktail/mocktail.dart';

typedef CallableHandler = Future<dynamic> Function(dynamic parameters);

/// Records httpsCallable invocations and runs optional per-function handlers.
class MockFirebaseFunctions extends Fake implements FirebaseFunctions {
  MockFirebaseFunctions({Map<String, CallableHandler>? handlers})
      : handlers = handlers ?? {};

  final Map<String, CallableHandler> handlers;
  final List<({String name, dynamic parameters})> calls = [];

  @override
  HttpsCallable httpsCallable(
    String name, {
    HttpsCallableOptions? options,
  }) {
    return _MockHttpsCallable(functions: this, name: name);
  }
}

class _MockHttpsCallable extends Fake implements HttpsCallable {
  _MockHttpsCallable({required this.functions, required this.name});

  final MockFirebaseFunctions functions;
  final String name;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    functions.calls.add((name: name, parameters: parameters));
    final handler = functions.handlers[name];
    final data = handler != null ? await handler(parameters) : <String, dynamic>{};
    return _FakeHttpsCallableResult<T>(data as T);
  }
}

class _FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  _FakeHttpsCallableResult(this.value);

  final T value;

  @override
  T get data => value;
}
