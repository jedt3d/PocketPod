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
import 'package:serverpod/serverpod.dart' as _i1;
import '../admin/admin_auth_endpoint.dart' as _i2;
import '../admin/admin_endpoint.dart' as _i3;
import '../benchmarks/benchmark_endpoint.dart' as _i4;
import '../greetings/greeting_endpoint.dart' as _i5;
import 'package:pocketpod_server/src/generated/admin/admin_record_cell.dart'
    as _i6;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i7;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i8;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'adminAuth': _i2.AdminAuthEndpoint()
        ..initialize(
          server,
          'adminAuth',
          null,
        ),
      'admin': _i3.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          null,
        ),
      'benchmark': _i4.BenchmarkEndpoint()
        ..initialize(
          server,
          'benchmark',
          null,
        ),
      'greeting': _i5.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['adminAuth'] = _i1.EndpointConnector(
      name: 'adminAuth',
      endpoint: endpoints['adminAuth']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminAuth'] as _i2.AdminAuthEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
      },
    );
    connectors['admin'] = _i1.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'dashboard': _i1.MethodConnector(
          name: 'dashboard',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i3.AdminEndpoint).dashboard(session),
        ),
        'listCollections': _i1.MethodConnector(
          name: 'listCollections',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i3.AdminEndpoint)
                  .listCollections(session),
        ),
        'listRecords': _i1.MethodConnector(
          name: 'listRecords',
          params: {
            'collectionKey': _i1.ParameterDescription(
              name: 'collectionKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i3.AdminEndpoint).listRecords(
                session,
                params['collectionKey'],
                params['offset'],
                params['limit'],
                params['query'],
              ),
        ),
        'relationOptions': _i1.MethodConnector(
          name: 'relationOptions',
          params: {
            'collectionKey': _i1.ParameterDescription(
              name: 'collectionKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fieldName': _i1.ParameterDescription(
              name: 'fieldName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i3.AdminEndpoint).relationOptions(
                    session,
                    params['collectionKey'],
                    params['fieldName'],
                  ),
        ),
        'getRecord': _i1.MethodConnector(
          name: 'getRecord',
          params: {
            'collectionKey': _i1.ParameterDescription(
              name: 'collectionKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i3.AdminEndpoint).getRecord(
                session,
                params['collectionKey'],
                params['id'],
              ),
        ),
        'updateRecord': _i1.MethodConnector(
          name: 'updateRecord',
          params: {
            'collectionKey': _i1.ParameterDescription(
              name: 'collectionKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'cells': _i1.ParameterDescription(
              name: 'cells',
              type: _i1.getType<List<_i6.AdminRecordCell>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i3.AdminEndpoint).updateRecord(
                session,
                params['collectionKey'],
                params['id'],
                params['cells'],
              ),
        ),
        'createRecord': _i1.MethodConnector(
          name: 'createRecord',
          params: {
            'collectionKey': _i1.ParameterDescription(
              name: 'collectionKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'cells': _i1.ParameterDescription(
              name: 'cells',
              type: _i1.getType<List<_i6.AdminRecordCell>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i3.AdminEndpoint).createRecord(
                session,
                params['collectionKey'],
                params['cells'],
              ),
        ),
        'deleteRecord': _i1.MethodConnector(
          name: 'deleteRecord',
          params: {
            'collectionKey': _i1.ParameterDescription(
              name: 'collectionKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i3.AdminEndpoint).deleteRecord(
                session,
                params['collectionKey'],
                params['id'],
              ),
        ),
      },
    );
    connectors['benchmark'] = _i1.EndpointConnector(
      name: 'benchmark',
      endpoint: endpoints['benchmark']!,
      methodConnectors: {
        'reset': _i1.MethodConnector(
          name: 'reset',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['benchmark'] as _i4.BenchmarkEndpoint)
                  .reset(session),
        ),
        'seed': _i1.MethodConnector(
          name: 'seed',
          params: {
            'count': _i1.ParameterDescription(
              name: 'count',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['benchmark'] as _i4.BenchmarkEndpoint).seed(
                session,
                params['count'],
              ),
        ),
        'readOne': _i1.MethodConnector(
          name: 'readOne',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['benchmark'] as _i4.BenchmarkEndpoint).readOne(
                    session,
                    params['id'],
                  ),
        ),
        'readList': _i1.MethodConnector(
          name: 'readList',
          params: {
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['benchmark'] as _i4.BenchmarkEndpoint).readList(
                    session,
                    params['limit'],
                  ),
        ),
        'writeOne': _i1.MethodConnector(
          name: 'writeOne',
          params: {
            'value': _i1.ParameterDescription(
              name: 'value',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['benchmark'] as _i4.BenchmarkEndpoint).writeOne(
                    session,
                    params['value'],
                    params['payload'],
                  ),
        ),
        'count': _i1.MethodConnector(
          name: 'count',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['benchmark'] as _i4.BenchmarkEndpoint)
                  .count(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i5.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i7.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i8.Endpoints()
      ..initializeEndpoints(server);
  }
}
