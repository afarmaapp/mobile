import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Medication.dart';
import 'package:afarma/model/popularModels/Segment.dart';
import 'package:flutter/foundation.dart';

class MedicationManager extends ChangeNotifier {
  static final MedicationManager _manager = MedicationManager._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory MedicationManager() {
    return _manager;
  }

  MedicationManager._initializer();

  List<Medication> _meds = [];
  List<Medication> get meds => _meds;

  Map<Segment?, List<Medication>> _sortedMeds = {};
  Map<Segment?, List<Medication>> get sortedMeds => _sortedMeds;

  void addMedication(Medication med) {
    if (_meds == null || _meds.length == 0) {
      _meds = [med];
    } else {
      if (!_meds.contains(med)) _meds.add(med);
    }
    _addMedToMap(med);
  }

  Future<List<Medication>> fetchMedications() async {
    if (_meds == null || _meds.length == 0) return await refreshMedications();
    return _meds;
  }

  Future<List<Medication>> refreshMedications() async {
    final resp = await _connector.getContent('/api/v1/Produto/list');
    if (resp.responseCode! < 400) {
      _meds.clear();
      _sortedMeds.clear();
    }
    _meds = Medication.fromJSONList(resp.returnBody!);
    _sortMeds();
    notifyListeners();
    return _meds;
  }

  void _sortMeds() {
    _meds.sort((medA, medB) => medA.compareTo(medB));
    _meds.forEach((med) => _addMedToMap(med));
  }

  void _addMedToMap(Medication med) {
    Segment? seg = med.segment;
    final oldVal = _sortedMeds[seg];
    if (oldVal != null && oldVal.length != 0) {
      if (!oldVal.contains(med)) _sortedMeds[seg] = oldVal + [med];
    } else {
      _sortedMeds[seg] = [med];
    }
  }
}
