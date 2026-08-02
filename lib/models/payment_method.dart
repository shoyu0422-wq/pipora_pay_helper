class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.supportedCards,
    required this.icon,
    required this.description,
  });

  final String id;
  final String name;
  final String type;
  final List<String> supportedCards;
  final String icon;
  final String description;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      supportedCards: List<String>.from(json['supportedCards'] as List),
      icon: json['icon'] as String,
      description: json['description'] as String,
    );
  }
}
