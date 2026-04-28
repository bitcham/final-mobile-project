class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.roleName,
  });

  final String id;
  final String name;
  final String roleName;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roleName: json['roleName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'roleName': roleName};
  }
}
