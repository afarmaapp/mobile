import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Department.dart';
import 'package:flutter/foundation.dart';

class DepartmentRepository extends ChangeNotifier {
  static final DepartmentRepository _manager =
      DepartmentRepository._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory DepartmentRepository() {
    return _manager;
  }

  DepartmentRepository._initializer();

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  void addDepartment(Department department) {
    if (_departments == null || _departments.length == 0) {
      _departments = [department];
    } else {
      if (!_departments.contains(department)) _departments.add(department);
    }
  }

  Future<List<Department>> fetchDepartments() async {
    if (_departments == null || _departments.length == 0)
      return await refreshDepartments();
    return _departments;
  }

  Future<List<Department>> refreshDepartments() async {
    _departments = [];
    final resp =
        // await _connector.getContent('/api/v1/ServicosView/departamentos');
        await _connector.getContent('/api/v1/Departamento/list');
    Department.fromJSONList(resp.returnBody!);
    // _departments.sort((d1, d2) => d1.name!.compareTo(d2.name!));
    return _departments;
  }
}
