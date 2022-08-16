import 'package:json_annotation/json_annotation.dart';

part 'competitors_model.g.dart';

@JsonSerializable()
class Competitors {
  final String concorrente;
  final double valorConcorrente;

  Competitors({
    required this.concorrente,
    required this.valorConcorrente,
  });

  factory Competitors.fromJson(Map<String, dynamic> json) =>
      _$CompetitorsFromJson(json);

  Map<String, dynamic> toJson() => _$CompetitorsToJson(this);
}
