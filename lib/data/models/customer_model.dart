// lib/domain/models/customer_model.dart
class CustomerModel {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final Map<String, dynamic>? defaultAddress;
  final bool? acceptsMarketing;

  CustomerModel({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.defaultAddress,
    this.acceptsMarketing,
  });

  factory CustomerModel.fromGraphQL(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      phone: map['phone'] as String?,
      defaultAddress: map['defaultAddress'] as Map<String, dynamic>?,
      acceptsMarketing: map['acceptsMarketing'] as bool?,
    );
  }
}
