import 'package:flutter/foundation.dart';
import 'package:rw334/service/httpService.dart';

class User extends ChangeNotifier {
  String email;
  String username;
  String picture;
  String name;
  int posts; // number of posts
  int follow; // number of followers
  bool login; // logged in?
  String password;
  int id;


  //final Map following;

  User(
      {int id,
      String email,
      String username,
      String name,
      String picture,
      int post,
      int follow,
      String password}) {
    this.email = email ?? 'example@example.com';
    this.username = username ?? 'username';
    this.picture = picture ?? 'assets/user1.jpeg';
    this.name = name ?? 'name';
    this.posts = allPosts.length ?? 0;
    this.follow = follow ?? 0;
    this.login = true;
    this.password = password ?? '1234';
    this.id = userId ?? 0;

    //this.followers,
    //this.following
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
        password: json["password"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
      };

  String getEmail() {
    return this.email;
  }

  String getUsername() {
    return this.username ?? " ";
  }

  String getPicture() {
    return this.picture;
  }

  String getName() {
    return this.name;
  }

  String getFollowing() {
    int fol = this.follow;
    String follow = fol.toString() + " ";
    return follow;
  }

  @override
  String toString() =>
      'User:  email=\"$email\", username=\"$username\", name=\"$name\", password=\"$password\"';

  String getPost() {
    int post = this.posts;
    String posts = post.toString() + " ";
    return posts;
  }



  // ignore: missing_return
  String logout() {
    this.login = false;
    print("user logged out, take me to sign up page. ples pappy");
    notifyListeners();
    return null;
  }

  Future<bool> update(String username, String psw) async {
    bool fine = false;
    if (psw != this.password) {
      return false;
    }


    bool res = await updateProfile(username);
    print("res: ");
    print(res);
    if (res == true) {
      this.username = username;
      notifyListeners();
      return true;
    }
  }

  void updatePosts() {
    this.posts = this.posts + 1;
    notifyListeners();
  }

}
