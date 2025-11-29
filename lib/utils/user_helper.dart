String getUserRoleFromEmail(String? email) {
  if (email == null) return 'KASIR';

  // Deteksi role dari email
  final emailLower = email.toLowerCase();
  if (emailLower.contains('admin') ||
      emailLower.contains('owner') ||
      emailLower.contains('manager')) {
    return 'ADMIN';
  } else {
    return 'KASIR';
  }
}
