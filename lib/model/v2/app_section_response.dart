class AppSectionResponse {
  bool? success;
  List<AppSection>? data;

  AppSectionResponse({this.success, this.data});

  AppSectionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AppSection>[];
      json['data'].forEach((v) {
        data!.add(new AppSection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AppSection {
  int? id;
  String? title;
  String? subtitle;
  String? actionType;
  String? actionValue;
  int? sortOrder;
  int? isActive;
  String? sectionKey;

  AppSection(
      {this.id,
      this.title,
      this.subtitle,
      this.actionType,
      this.actionValue,
      this.sortOrder,
      this.isActive,
      this.sectionKey});

  AppSection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    subtitle = json['subtitle'];
    actionType = json['action_type'];
    actionValue = json['action_value'];
    sortOrder = json['sort_order'];
    isActive = json['is_active'];
    sectionKey = json['section_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['subtitle'] = this.subtitle;
    data['action_type'] = this.actionType;
    data['action_value'] = this.actionValue;
    data['sort_order'] = this.sortOrder;
    data['is_active'] = this.isActive;
    data['section_key'] = this.sectionKey;
    return data;
  }
}
