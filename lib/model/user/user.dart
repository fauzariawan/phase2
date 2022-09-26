// ini untuk nama table
const String tableUsers = 'users';

class UsersFields {
  static final List<String> values = [
    idpk,
    id,
    email,
    encryptedPassword,
    username,
    fullname,
    phone,
    languageType,
    companyCode,
    isBiometrik,
    organizationId,
    functionId,
    structureId,
    employeeStatus,
    userCompanyId,
    packageType,
    roleId,
    isLoginMobile,
    timeoutLogin,
    lastSignInAt,
    resignDate,
    resignFlag,
    deviceId,
    validationFaceType,
    isFaceRecognitionRegistered,
    isFaceRecognitionValidated,
  ];
  static const String idpk = 'id_pk';
  static const String id = '_id';
  static const String email = 'email';
  static const String encryptedPassword = 'encrypted_password';
  static const String username = 'username';
  static const String fullname = 'fullname';
  static const String phone = 'phone';
  static const String languageType = 'language_type';
  static const String companyCode = 'company_code';
  static const String isBiometrik = 'is_biometrik';
  static const String organizationId = 'organization_id';
  static const String functionId = 'function_id';
  static const String structureId = 'structure_id';
  static const String employeeStatus = 'employee_status';
  static const String userCompanyId = 'user_company_id';
  static const String packageType = 'package_type';
  static const String roleId = 'role_id';
  static const String isLoginMobile = 'is_login_mobile';
  static const String timeoutLogin = 'timeout_login';
  static const String lastSignInAt = 'last_sign_in_at';
  static const String resignDate = 'resign_date';
  static const String resignFlag = 'resign_flag';
  static const String deviceId = 'device_id';
  static const String validationFaceType = 'validation_face_type';
  static const String isFaceRecognitionRegistered =
      'is_face_recognition_registered';
  static const String isFaceRecognitionValidated =
      'is_face_recognition_validated';
}

class User {
  User({
    required this.id,
    required this.email,
    required this.encryptedPassword,
    required this.username,
    required this.fullName,
    this.phone,
    required this.languageType,
    required this.companyCode,
    required this.isBiometrik,
    required this.organizationId,
    required this.functionId,
    required this.structureId,
    required this.employeeStatus,
    required this.userCompanyId,
    required this.packageType,
    required this.roleId,
    required this.isLoginMobile,
    required this.timeoutLogin,
    this.lastSignInAt,
    required this.resignFlag,
    this.resignDate,
    required this.deviceId,
    required this.validationFaceType,
    required this.isFaceRecognitionRegistered,
    required this.isFaceRecognitionValidated,
  });

  int id;
  String email;
  String encryptedPassword;
  String username;
  String fullName;
  int userCompanyId;
  dynamic phone;
  int languageType;
  String companyCode;
  String isBiometrik;
  int organizationId;
  int functionId;
  int structureId;
  int employeeStatus;
  int packageType;
  int roleId;
  String isLoginMobile;
  int timeoutLogin;
  dynamic lastSignInAt;
  int resignFlag;
  dynamic resignDate;
  String deviceId;
  int validationFaceType;
  int isFaceRecognitionRegistered;
  int isFaceRecognitionValidated;

  User copy({
    int? id,
    String? email,
    String? encryptedPassword,
    String? username,
    String? fullName,
    int? userCompanyId,
    dynamic? phone,
    int? languageType,
    String? companyCode,
    String? isBiometrik,
    int? organizationId,
    int? functionId,
    int? structureId,
    int? employeeStatus,
    int? packageType,
    int? roleId,
    String? isLoginMobile,
    int? timeoutLogin,
    dynamic? lastSignInAt,
    int? resignFlag,
    dynamic? resignDate,
    String? deviceId,
    int? validationFaceType,
    int? isFaceRecognitionRegistered,
    int? isFaceRecognitionValidated,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        encryptedPassword: encryptedPassword ?? this.encryptedPassword,
        username: username ?? this.username,
        fullName: fullName ?? this.fullName,
        userCompanyId: userCompanyId ?? this.userCompanyId,
        phone: phone ?? this.phone,
        languageType: languageType ?? this.languageType,
        companyCode: companyCode ?? this.companyCode,
        isBiometrik: isBiometrik ?? this.isBiometrik,
        organizationId: organizationId ?? this.organizationId,
        functionId: functionId ?? this.functionId,
        structureId: structureId ?? this.structureId,
        employeeStatus: employeeStatus ?? this.employeeStatus,
        packageType: packageType ?? this.packageType,
        roleId: roleId ?? this.roleId,
        isLoginMobile: isLoginMobile ?? this.isLoginMobile,
        timeoutLogin: timeoutLogin ?? this.timeoutLogin,
        lastSignInAt: lastSignInAt ?? this.lastSignInAt,
        resignFlag: resignFlag ?? this.resignFlag,
        resignDate: resignDate ?? this.resignDate,
        deviceId: deviceId ?? this.deviceId,
        validationFaceType: validationFaceType ?? this.validationFaceType,
        isFaceRecognitionRegistered:
            isFaceRecognitionRegistered ?? this.isFaceRecognitionRegistered,
        isFaceRecognitionValidated:
            isFaceRecognitionValidated ?? this.isFaceRecognitionValidated,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        encryptedPassword: json["encrypted_password"],
        username: json["username"],
        fullName: json["full_name"],
        phone: json["phone"],
        languageType: json["language_type"],
        companyCode: json["company_code"],
        isBiometrik: json["is_biometrik"],
        organizationId: json["organization_id"],
        functionId: json["function_id"],
        structureId: json["structure_id"],
        employeeStatus: json["employee_status"],
        userCompanyId: json["user_company_id"],
        packageType: json["package_type"],
        roleId: json["role_id"],
        isLoginMobile: json["is_login_mobile"],
        timeoutLogin: json["timeout_login"],
        lastSignInAt: json["last_sign_in_at"] == "null" ||
                json["last_sign_in_at"] == null ||
                json["last_sign_in_at"] == ""
            ? null
            : DateTime.parse(json["last_sign_in_at"]),
        resignDate: json["resign_date"] == "null" ||
                json["resign_date"] == null ||
                json["resign_date"] == ""
            ? null
            : DateTime.parse(json["resign_date"]),
        resignFlag: json["resign_flag"],
        deviceId: json["device_id"] ?? "",
        validationFaceType: json["validation_face_type"],
        isFaceRecognitionRegistered: json["is_face_recognition_registered"],
        isFaceRecognitionValidated: json["is_face_recognition_validated"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "encrypted_password": encryptedPassword,
        "username": username,
        "full_name": fullName,
        "phone": phone,
        "language_type": languageType,
        "company_code": companyCode,
        "is_biometrik": isBiometrik,
        "organization_id": organizationId,
        "function_id": functionId,
        "structure_id": structureId,
        "employee_status": employeeStatus,
        "user_company_id": userCompanyId,
        "package_type": packageType,
        "role_id": roleId,
        "is_login_mobile": isLoginMobile,
        "timeout_login": timeoutLogin,
        "last_sign_in_at":
            lastSignInAt == null ? null : lastSignInAt.toIso8601String(),
        "resign_date": resignDate == null ? null : resignDate.toIso8601String(),
        "resign_flag": resignFlag,
        "device_id": deviceId,
        "validation_face_type": validationFaceType,
        "is_face_recognition_registered": isFaceRecognitionRegistered,
        "is_face_recognition_validated": isFaceRecognitionValidated,
      };
}
