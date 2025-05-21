class UserProfileModel {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final String link;
  final bool hasAvatar;
  final List<String> followers;
  final int followerCount;
  final int point;

  final int? height;
  final int? weight;
  final int? age;
  final String? bloodPressure;
  final List<String>? mealTimes;

  UserProfileModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.link,
    required this.hasAvatar,
    required this.followers,
    required this.followerCount,
    required this.point,

    this.height,
    this.weight,
    this.age,
    this.bloodPressure,
    this.mealTimes,
  });

  UserProfileModel.empty()
    : uid = "",
      email = "",
      name = "",
      bio = "",
      link = "",
      hasAvatar = false,
      followers = [],
      followerCount = 0,
      point = 0,

      height = null,
      weight = null,
      age = null,
      bloodPressure = null,
      mealTimes = null;

  UserProfileModel.fromJson(Map<String, dynamic> json)
    : uid = json["uid"],
      email = json["email"],
      name = json["name"],
      bio = json["bio"],
      link = json["link"],
      hasAvatar = json["hasAvatar"],
      followers =
          (json["followers"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      followerCount = json["followerCount"],
      point = json["point"] ?? 0,

      height = json["height"],
      weight = json["weight"],
      age = json["age"],
      bloodPressure = json["bloodPressure"],
      mealTimes =
          (json["mealTimes"] as List?)?.map((e) => e.toString()).toList();

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "bio": bio,
      "link": link,
      "hasAvatar": hasAvatar,
      "followers": followers,
      "followerCount": followerCount,
      "point": point,

      if (height != null) "height": height,
      if (weight != null) "weight": weight,
      if (age != null) "age": age,
      if (bloodPressure != null) "bloodPressure": bloodPressure,
      if (mealTimes != null) "mealTimes": mealTimes,
    };
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? bio,
    String? link,
    bool? hasAvatar,
    List<String>? followers,
    int? followerCount,
    int? point,

    int? height,
    int? weight,
    int? age,
    String? bloodPressure,
    List<String>? mealTimes,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      link: link ?? this.bio,
      hasAvatar: hasAvatar ?? this.hasAvatar,
      followers: followers ?? this.followers,
      followerCount: followerCount ?? this.followerCount,
      point: point ?? this.point,

      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      mealTimes: mealTimes ?? this.mealTimes,
    );
  }
}
