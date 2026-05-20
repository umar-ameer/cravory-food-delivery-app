class AddressModel {
  final String id;
  final String title;
  final String fullAddress;
  final String phoneNumber;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.phoneNumber,
    required this.isDefault,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AddressModel(
      id: documentId,
      title: (map['title'] ?? '') as String,
      fullAddress: (map['fullAddress'] ?? '') as String,
      phoneNumber: (map['phoneNumber'] ?? '') as String,
      isDefault: (map['isDefault'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fullAddress': fullAddress,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  AddressModel copyWith({
    String? id,
    String? title,
    String? fullAddress,
    String? phoneNumber,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}