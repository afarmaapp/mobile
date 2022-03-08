class DrugStoreEmployee {

  DrugStoreEmployee({
    this.id,
    this.name,
    this.documentID,
    this.documents
  });

  final String? id;
  final String? name;
  final String? documentID;
  final List<String>? documents;

  static List<DrugStoreEmployee> fromJSONList(List? json) {
    if (json == null) return [];
    List<DrugStoreEmployee> ret = [];
    json.forEach((element) => ret.add(DrugStoreEmployee.fromJSON(element)));
    return ret;
  }

  factory DrugStoreEmployee.fromJSON(Map<String, dynamic>? json) {
    if (json == null) return DrugStoreEmployee();
    return DrugStoreEmployee(
      id: json['id'],
      name: json['nome'],
      documentID: json['documentoIdentidade'],
      documents: _documentsFromJSON(json)
    );
  }

  static List<String> _documentsFromJSON(Map<String, dynamic> json) {
    List? docs = json['documentos'];
    List<String> ret = [];
    if (docs != null) {
      docs.forEach((doc) => ret.add(doc));
    }
    return ret;
  }

}