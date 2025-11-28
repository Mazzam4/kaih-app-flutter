class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String role;
  final String organizationName;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = 'member',
    this.organizationName = 'Tanpa Organisasi',
  });
}