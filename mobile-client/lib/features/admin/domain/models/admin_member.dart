/// Ringkasan satu aplikasi member untuk daftar review admin.
class AdminApplicant {
  final int id;
  final String? memberId;
  final String? status;
  final String? statusLabel;
  final String? phone;
  final String? name;
  final String? email;
  final String? createdAt;

  const AdminApplicant({
    required this.id,
    this.memberId,
    this.status,
    this.statusLabel,
    this.phone,
    this.name,
    this.email,
    this.createdAt,
  });

  factory AdminApplicant.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : const <String, dynamic>{};
    return AdminApplicant(
      id: json['id'] as int,
      memberId: json['member_id'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      phone: json['phone'] as String?,
      name: user['name'] as String?,
      email: user['email'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

/// Detail aplikasi penuh ( MemberDetailResource ) untuk layar review admin.
class AdminMember {
  final int id;
  final String? memberId;
  final String? status;
  final String? statusLabel;
  final String? phone;
  final String? ktpNumber;
  final String? simNumber;
  final String? religion;
  final String? gender;
  final String? maritalStatus;
  final String? address;
  final String? job;
  final String? company;
  final String? vehicleType;
  final String? vehicleColor;
  final int? vehicleYear;
  final String? chassisNumber;
  final String? engineNumber;
  final String? taxDueDate;
  final String? rejectedReason;
  final String? userName;
  final String? userEmail;

  const AdminMember({
    required this.id,
    this.memberId,
    this.status,
    this.statusLabel,
    this.phone,
    this.ktpNumber,
    this.simNumber,
    this.religion,
    this.gender,
    this.maritalStatus,
    this.address,
    this.job,
    this.company,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleYear,
    this.chassisNumber,
    this.engineNumber,
    this.taxDueDate,
    this.rejectedReason,
    this.userName,
    this.userEmail,
  });

  bool get isPending => status == 'pending';

  factory AdminMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : const <String, dynamic>{};
    return AdminMember(
      id: json['id'] as int,
      memberId: json['member_id'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      phone: json['phone'] as String?,
      ktpNumber: json['ktp_number'] as String?,
      simNumber: json['sim_number'] as String?,
      religion: json['religion'] as String?,
      gender: json['gender'] as String?,
      maritalStatus: json['marital_status'] as String?,
      address: json['address'] as String?,
      job: json['job'] as String?,
      company: json['company'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      vehicleYear: json['vehicle_year'] as int?,
      chassisNumber: json['chassis_number'] as String?,
      engineNumber: json['engine_number'] as String?,
      taxDueDate: json['tax_due_date'] as String?,
      rejectedReason: json['rejected_reason'] as String?,
      userName: user['name'] as String?,
      userEmail: user['email'] as String?,
    );
  }
}
