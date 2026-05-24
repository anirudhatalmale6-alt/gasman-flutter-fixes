/*
class CompanySettings {
  final String businessName;
  final String engineerName;
  final String gasSafeNumber;
  final String phone;
  final String email;
  final String address;
  final String vatNumber;
  final String postalCode;
  final String logoPath;
  final String paymentDetails;

  const CompanySettings({
    required this.businessName,
    required this.engineerName,
    required this.gasSafeNumber,
    required this.phone,
    required this.email,
    required this.address,
    required this.vatNumber,
    required this.postalCode,
    required this.logoPath,
    required this.paymentDetails,
  });

  factory CompanySettings.empty() => const CompanySettings(
    businessName: '',
    engineerName: '',
    gasSafeNumber: '',
    phone: '',
    email: '',
    address: '',
    vatNumber: '',
    postalCode: '',
    logoPath: '',
    paymentDetails: '',
  );

  /// Convert JSON → CompanySettings
  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      businessName: json['businessName'] ?? '',
      engineerName: json['engineerName'] ?? '',
      gasSafeNumber: json['gasSafeNumber'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      vatNumber: json['vatNumber'] ?? '',
      postalCode: json['postalCode'] ?? '',
      logoPath: json['logoPath'] ?? '',
      paymentDetails: json['paymentDetails'] ?? '',
    );
  }

  /// Convert CompanySettings → JSON
  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'engineerName': engineerName,
      'gasSafeNumber': gasSafeNumber,
      'phone': phone,
      'email': email,
      'address': address,
      'vatNumber': vatNumber,
      'postalCode': postalCode,
      'logoPath': logoPath,
      'paymentDetails': paymentDetails,
    };
  }

  CompanySettings copyWith({
    String? businessName,
    String? engineerName,
    String? gasSafeNumber,
    String? phone,
    String? email,
    String? address,
    String? vatNumber,
    String? postalCode,
    String? logoPath,
    String? paymentDetails,
  }) {
    return CompanySettings(
      businessName: businessName ?? this.businessName,
      engineerName: engineerName ?? this.engineerName,
      gasSafeNumber: gasSafeNumber ?? this.gasSafeNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      vatNumber: vatNumber ?? this.vatNumber,
      postalCode: postalCode ?? this.postalCode,
      logoPath: logoPath ?? this.logoPath,
      paymentDetails: paymentDetails ?? this.paymentDetails
    );
  }
}*/
