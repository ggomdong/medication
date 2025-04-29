class UserProfileModel {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final String link;
  final bool hasAvatar;
  final List<String> followers;
  final int followerCount;

  UserProfileModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.link,
    required this.hasAvatar,
    required this.followers,
    required this.followerCount,
  });

  UserProfileModel.empty()
    : uid = "",
      email = "",
      name = "",
      bio = "",
      link = "",
      hasAvatar = false,
      followers = [],
      followerCount = 0;

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
      followerCount = json["followerCount"];

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
    );
  }
}
