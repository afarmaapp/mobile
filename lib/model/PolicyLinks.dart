class PolicyLinks {
  PolicyLinks({
    required this.about,
    required this.privacyPolicy,
    required this.toU,
  });

  final String about;
  final String privacyPolicy;
  final String toU;

  factory PolicyLinks.fromJSON(Map<String, dynamic> json) {
    return PolicyLinks(
      about: json['about'] as String,
      privacyPolicy: json['privacy_policy'] as String,
      toU: json['terms_of_use'] as String,
    );
  }

  Map<String, String> toMap() {
    return {
      'about': about,
      'pp': privacyPolicy,
      'tou': toU,
    };
  }
}
