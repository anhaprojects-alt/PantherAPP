/// Proyeksi `MemberResource` dari backend untuk member yang sedang login.
class MemberModel {
  final int? id;
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
  final String? companyAddress;
  final String? vehicleType;
  final String? vehicleColor;
  final int? vehicleYear;
  final String? chassisNumber;
  final String? engineNumber;
  final String? taxDueDate;
  final String? profilePhotoUrl;
  final String? rejectedReason;

  MemberModel({
    this.id,
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
    this.companyAddress,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleYear,
    this.chassisNumber,
    this.engineNumber,
    this.taxDueDate,
    this.profilePhotoUrl,
    this.rejectedReason,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as int?,
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
      companyAddress: json['company_address'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      vehicleYear: json['vehicle_year'] as int?,
      chassisNumber: json['chassis_number'] as String?,
      engineNumber: json['engine_number'] as String?,
      taxDueDate: json['tax_due_date'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      rejectedReason: json['rejected_reason'] as String?,
    );
  }
}
