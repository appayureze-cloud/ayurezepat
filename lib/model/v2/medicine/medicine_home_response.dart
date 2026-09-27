import 'package:doctro_patient/model/v2/home_response.dart';

class MedicineHomeResponse {
  bool? success;
  Data? data;
  String? msg;

  MedicineHomeResponse({this.success, this.data, this.msg});

  MedicineHomeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  List<Banner>? banners;
  List<PopularCategories>? popularCategories;
  List<PopularProducts>? popularProducts;
  List<ShopifyBlog>? blogs;

  // List<Null>? upcomingOrders;

  Data({
    this.banners,
    this.popularCategories,
    this.popularProducts,
    this.blogs,
    // this.upcomingOrders,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['banners'] != null) {
      banners = <Banner>[];
      json['banners'].forEach((v) {
        banners!.add(new Banner.fromJson(v));
      });
    }
    if (json['popular_categories'] != null) {
      popularCategories = <PopularCategories>[];
      json['popular_categories'].forEach((v) {
        popularCategories!.add(new PopularCategories.fromJson(v));
      });
    }
    if (json['popular_products'] != null) {
      popularProducts = <PopularProducts>[];
      json['popular_products'].forEach((v) {
        popularProducts!.add(new PopularProducts.fromJson(v));
      });
    }
    if (json['blogs'] != null) {
      blogs = <ShopifyBlog>[];
      json['blogs'].forEach((v) {
        blogs!.add(new ShopifyBlog.fromJson(v));
      });
    }
    // if (json['upcoming_orders'] != null) {
    //   upcomingOrders = <Null>[];
    //   json['upcoming_orders'].forEach((v) {
    //     upcomingOrders!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banners != null) {
      data['banners'] = this.banners != null
          ? this.banners!.map((v) => v.toJson()).toList()
          : [];
    }
    if (this.popularCategories != null) {
      data['popular_categories'] =
          this.popularCategories!.map((v) => v.toJson()).toList();
    }
    if (this.popularProducts != null) {
      data['popular_products'] =
          this.popularProducts!.map((v) => v.toJson()).toList();
    }
    if (this.blogs != null) {
      data['blogs'] = this.blogs!.map((v) => v.toJson()).toList();
    }
    // if (this.upcomingOrders != null) {
    //   data['upcoming_orders'] =
    //       this.upcomingOrders!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class PopularCategories {
  int? id;
  String? name;
  String? image;

  PopularCategories({this.id, this.name, this.image});

  PopularCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}

class PopularProducts {
  int? id;
  String? title;
  String? image;
  double? price;
  double? mrp;
  double? ratings;
  int? ratingsCount;
  double? discountPrice;
  double? discountPercent;

  PopularProducts(
      {this.id,
      this.title,
      this.image,
      this.price,
      this.mrp,
      this.ratings,
      this.ratingsCount,
      this.discountPrice,
      this.discountPercent});

  PopularProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    price = double.tryParse('${json['price']}');
    mrp = double.tryParse('${json['mrp']}');
    ratings = double.tryParse('${json['ratings']}');
    ratingsCount = json['ratings_count'];
    discountPrice = double.tryParse('${json['discount_price']}');
    discountPercent = double.tryParse('${json['discount_percent']}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['price'] = this.price;
    data['mrp'] = this.mrp;
    data['ratings'] = this.ratings;
    data['ratings_count'] = this.ratingsCount;
    data['discount_price'] = this.discountPrice;
    data['discount_percent'] = this.discountPercent;
    return data;
  }
}

class ShopifyBlog {
  int? id;
  String? title;
  String? createdAt;
  String? bodyHtml;
  int? blogId;
  String? author;
  int? userId;
  String? publishedAt;
  String? updatedAt;
  String? summaryHtml;
  String? templateSuffix;
  String? handle;
  String? tags;
  String? adminGraphqlApiId;
  BlogImage? image;

  ShopifyBlog(
      {this.id,
      this.title,
      this.createdAt,
      this.bodyHtml,
      this.blogId,
      this.author,
      this.userId,
      this.publishedAt,
      this.updatedAt,
      this.summaryHtml,
      this.templateSuffix,
      this.handle,
      this.tags,
      this.adminGraphqlApiId,
      this.image});

  ShopifyBlog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    bodyHtml = json['body_html'];
    blogId = json['blog_id'];
    author = json['author'];
    userId = json['user_id'];
    publishedAt = json['published_at'];
    updatedAt = json['updated_at'];
    summaryHtml = json['summary_html'];
    templateSuffix = json['template_suffix'];
    handle = json['handle'];
    tags = json['tags'];
    adminGraphqlApiId = json['admin_graphql_api_id'];
    image =
        json['image'] != null ? new BlogImage.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['created_at'] = this.createdAt;
    data['body_html'] = this.bodyHtml;
    data['blog_id'] = this.blogId;
    data['author'] = this.author;
    data['user_id'] = this.userId;
    data['published_at'] = this.publishedAt;
    data['updated_at'] = this.updatedAt;
    data['summary_html'] = this.summaryHtml;
    data['template_suffix'] = this.templateSuffix;
    data['handle'] = this.handle;
    data['tags'] = this.tags;
    data['admin_graphql_api_id'] = this.adminGraphqlApiId;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    return data;
  }
}

class BlogImage {
  String? createdAt;
  String? alt;
  int? width;
  int? height;
  String? src;

  BlogImage({this.createdAt, this.alt, this.width, this.height, this.src});

  BlogImage.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    alt = json['alt'];
    width = json['width'];
    height = json['height'];
    src = json['src'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['alt'] = this.alt;
    data['width'] = this.width;
    data['height'] = this.height;
    data['src'] = this.src;
    return data;
  }
}
