class DrugStoreEmployee {
  DrugStoreEmployee(
      {required this.id,
      required this.name,
      required this.documentID,
      required this.documents});

  final String id;
  final String name;
  final String documentID;
  final List<String> documents;

  static List<DrugStoreEmployee> fromJSONList(List json) {
    List<DrugStoreEmployee> ret = [];
    json.forEach((element) => ret.add(DrugStoreEmployee.fromJSON(element)));
    return ret;
  }

  factory DrugStoreEmployee.fromJSON(Map<String, dynamic> json) {
    return DrugStoreEmployee(
        id: json['id'],
        name: json['nome'],
        documentID: json['documentoIdentidade'],
        documents: _documentsFromJSON(json));
  }

  static List<String> _documentsFromJSON(Map<String, dynamic> json) {
    List docs = json['documentos'];
    List<String> ret = [];
    docs.forEach((doc) => ret.add(doc));
    return ret;
  }
}
