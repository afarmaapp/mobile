import 'package:json_annotation/json_annotation.dart';

part 'competitor_model.g.dart';

@JsonSerializable()
class Competitor {
  final String concorrente;
  final double valorConcorrente;

  Competitor({
    required this.concorrente,
    required this.valorConcorrente,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) =>
      _$CompetitorFromJson(json);

  Map<String, dynamic> toJson() => _$CompetitorToJson(this);
}
