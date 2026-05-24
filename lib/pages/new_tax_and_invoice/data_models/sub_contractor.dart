class Subcontractor {
  final int id;
  final String name;
  final String utr;
  final String? nino;

  final String? phone;
  final String? email;
  final String? addressLine1;
  final String? city;
  final String? postcode;

  final double deductionRate;
  final String verificationStatus;
  final String taxCode;

  Subcontractor({
    required this.id,
    required this.name,
    required this.utr,
    this.nino,
    this.phone,
    this.email,
    this.addressLine1,
    this.city,
    this.postcode,
    required this.taxCode,
    required this.deductionRate,
    required this.verificationStatus,
  });

  factory Subcontractor.fromJson(Map<String, dynamic> json) {
    return Subcontractor(
      id: json['id'],
      name: json['name'] ?? '',
      utr: json['utr'] ?? '',
      nino: json['nino'],
      phone: json['phone'],
      email: json['email'],
      addressLine1: json['address_line1'],
      city: json['city'],
      postcode: json['postcode'],
      taxCode: json['tax_code'] ?? "",
      deductionRate: double.tryParse((json['deduction_rate'] ?? 0).toString()) ?? 0.0,
      verificationStatus: json['verification_status'] ?? '',
    );
  }
}