class UserProfile {
  final int id;
  final String username;
  final String? name;
  final double? height;
  final double? weight;
  final int? age;
  final int? sleepTarget;

  const UserProfile({
    required this.id,
    required this.username,
    this.name,
    this.height,
    this.weight,
    this.age,
    this.sleepTarget,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      age: json['age'],
      sleepTarget: json['sleep_target'],
    );
  }

  bool get hasAnyProfileData {
    return name != null ||
        height != null ||
        weight != null ||
        age != null ||
        sleepTarget != null;
  }
}

class UpdateUserProfileRequest {
  final String? name;
  final double? height;
  final double? weight;
  final int? age;
  final int? sleepTarget;

  const UpdateUserProfileRequest({
    this.name,
    this.height,
    this.weight,
    this.age,
    this.sleepTarget,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'height': height,
        'weight': weight,
        'age': age,
        'sleep_target': sleepTarget,
      };
}