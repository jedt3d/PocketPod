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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i3;
import 'package:pocketpod_client/src/protocol/admin/admin_dashboard.dart'
    as _i4;
import 'package:pocketpod_client/src/protocol/benchmarks/benchmark_record.dart'
    as _i5;
import 'package:pocketpod_client/src/protocol/greetings/greeting.dart' as _i6;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i7;
import 'package:http/http.dart' as _i8;
import 'protocol.dart' as _i9;

/// {@category Endpoint}
class EndpointAdminAuth extends _i1.EndpointRef {
  EndpointAdminAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminAuth';

  _i2.Future<_i3.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i3.AuthSuccess>(
    'adminAuth',
    'login',
    {
      'email': email,
      'password': password,
    },
  );
}

/// {@category Endpoint}
class EndpointAdmin extends _i1.EndpointRef {
  EndpointAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  _i2.Future<_i4.AdminDashboard> dashboard() =>
      caller.callServerEndpoint<_i4.AdminDashboard>(
        'admin',
        'dashboard',
        {},
      );
}

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

  _i2.Future<_i5.BenchmarkRecord?> readOne(int id) =>
      caller.callServerEndpoint<_i5.BenchmarkRecord?>(
        'benchmark',
        'readOne',
        {'id': id},
      );

  _i2.Future<List<_i5.BenchmarkRecord>> readList(int limit) =>
      caller.callServerEndpoint<List<_i5.BenchmarkRecord>>(
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
  _i2.Future<_i6.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i6.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i7.Caller(client);
    serverpod_auth_core = _i3.Caller(client);
  }

  late final _i7.Caller serverpod_auth_idp;

  late final _i3.Caller serverpod_auth_core;
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
    _i8.Client? httpClientOverride,
  }) : super(
         host,
         _i9.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    adminAuth = EndpointAdminAuth(this);
    admin = EndpointAdmin(this);
    benchmark = EndpointBenchmark(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointAdminAuth adminAuth;

  late final EndpointAdmin admin;

  late final EndpointBenchmark benchmark;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'adminAuth': adminAuth,
    'admin': admin,
    'benchmark': benchmark,
    'greeting': greeting,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
