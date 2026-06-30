/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:pocketpod_client/src/protocol/benchmarks/benchmark_record.dart'
    as _i3;
import 'package:pocketpod_client/src/protocol/greetings/greeting.dart' as _i4;
import 'package:http/http.dart' as _i5;
import 'protocol.dart' as _i6;

/// {@category Endpoint}
class EndpointBenchmark extends _i1.EndpointRef {
  EndpointBenchmark(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'benchmark';

  _i2.Future<int> reset() => caller.callServerEndpoint<int>(
    'benchmark',
    'reset',
    {},
  );

  _i2.Future<int> seed(int count) => caller.callServerEndpoint<int>(
    'benchmark',
    'seed',
    {'count': count},
  );

  _i2.Future<_i3.BenchmarkRecord?> readOne(int id) =>
      caller.callServerEndpoint<_i3.BenchmarkRecord?>(
        'benchmark',
        'readOne',
        {'id': id},
      );

  _i2.Future<List<_i3.BenchmarkRecord>> readList(int limit) =>
      caller.callServerEndpoint<List<_i3.BenchmarkRecord>>(
        'benchmark',
        'readList',
        {'limit': limit},
      );

  _i2.Future<int> writeOne(
    int value,
    String payload,
  ) => caller.callServerEndpoint<int>(
    'benchmark',
    'writeOne',
    {
      'value': value,
      'payload': payload,
    },
  );

  _i2.Future<int> count() => caller.callServerEndpoint<int>(
    'benchmark',
    'count',
    {},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i4.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i4.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i5.Client? httpClientOverride,
  }) : super(
         host,
         _i6.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    benchmark = EndpointBenchmark(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointBenchmark benchmark;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'benchmark': benchmark,
    'greeting': greeting,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
