class BlogsResponse {
  bool? success;
  List<Blogs>? data;
  String? msg;

  BlogsResponse({this.success, this.data, this.msg});

  BlogsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Blogs.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Blogs {
  int? id;
  String? image;
  String? title;
  String? desc;
  String? blogRef;
  String? fullImage;

  Blogs(
      {this.id,
      this.image,
      this.title,
      this.desc,
      this.blogRef,
      this.fullImage});

  Blogs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    title = json['title'];
    desc = json['desc'];
    blogRef = json['blog_ref'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['blog_ref'] = this.blogRef;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
