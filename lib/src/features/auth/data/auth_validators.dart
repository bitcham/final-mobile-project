String? validateEmail(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) {
    return 'Email is required.';
  }
  final emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.\-]+$');
  if (!emailPattern.hasMatch(input)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String? value) {
  final input = value ?? '';
  if (input.isEmpty) {
    return 'Password is required.';
  }
  if (input.length < 8) {
    return 'Min 8 characters.';
  }
  if (!RegExp(r'\d').hasMatch(input)) {
    return 'Must include at least one digit.';
  }
  return null;
}

String? validateLoginPassword(String? value) {
  final input = value ?? '';
  if (input.isEmpty) {
    return 'Password is required.';
  }
  return null;
}

String? validateRealName(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) {
    return 'Name is required.';
  }
  return null;
}

String? validateConfirmPassword(String? value, String original) {
  if ((value ?? '') != original) {
    return 'Passwords do not match.';
  }
  return null;
}
