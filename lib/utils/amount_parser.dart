double? parseSpendAmount(String rawValue) {
  final amount = _parseAmount(rawValue);
  return amount != null && amount > 0 ? amount : null;
}

double? parseRewardAmount(String rawValue) => _parseAmount(rawValue);

double? _parseAmount(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  const amountPattern = r'^(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d{1,2})?$';
  if (!RegExp(amountPattern).hasMatch(value)) return null;

  final amount = double.tryParse(value.replaceAll(',', ''));
  return amount != null && amount.isFinite && amount >= 0 ? amount : null;
}
