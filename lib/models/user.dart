class IntraUser {
  final int id;
  final String login;
  final String displayName;
  final String? imageUrl;

  IntraUser({
    required this.id,
    required this.login,
    required this.displayName,
    this.imageUrl,
  });

  factory IntraUser.fromJson(Map<String, dynamic> json) {
    return IntraUser(
      id: json['id'],
      login: json['login'],
      displayName: json['displayname'],
      imageUrl: json['image_url'],
    );
  }
}
