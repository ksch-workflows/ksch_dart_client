import 'dart:convert';

import '../client.dart';
import '../resource.dart';
import 'address/resource.dart';
import 'payload.dart';

class PatientCollectionResource extends CollectionResource {
  final KschApi api;

  PatientCollectionResource({required this.api});

  PatientResource call(String id) {
    return PatientResource(api: api, id: id, parent: this);
  }

  @override
  String get path => 'patients';

  @override
  CollectionResource? get parent => null;

  Future<PatientResponsePayload> create(
      [CreatePatientRequestPayload? patient]) async {
    var response = await api.post(absolutePath, body: patient?.toJson());
    return PatientResponsePayload.fromJson(json.decode(response.body));
  }

  Future<PatientsReponsePayload> list() async {
    var response = await api.get(absolutePath);
    return PatientsReponsePayload.fromJson(json.decode(response.body));
  }

  /// Searches for patients which match the provided query string.
  ///
  /// - If the query string is a valid UUID, it is searched for a patient with
  /// this patient ID.
  /// - If the query string is a valid patient number, it is searched for a
  /// patient with this patient number.
  /// - Otherwise, it is searched for patients with a name matching with the
  /// query string.
  ///
  /// Also see https://ksch-workflows.github.io/backend/#_search_patient
  Future<PatientsReponsePayload> search(String query) async {
    var urlEncodedQuery = Uri.encodeComponent(query);
    var response = await api.get('$absolutePath/search?q=$urlEncodedQuery');
    return PatientsReponsePayload.fromJson(json.decode(response.body));
  }
}

class PatientResource extends IdentityResource {
  final KschApi api;
  late final ResidentialAddressResource residentialAddress;

  PatientResource({
    required this.api,
    required String id,
    required CollectionResource parent,
  }) : super(
          id: id,
          parent: parent,
        ) {
    residentialAddress = ResidentialAddressResource(api: api, parent: this);
  }

  Future<PatientResponsePayload> get() async {
    var getPatientResponse = await api.get(absolutePath);
    var responseBody = json.decode(getPatientResponse.body);
    return PatientResponsePayload.fromJson(responseBody);
  }
}
