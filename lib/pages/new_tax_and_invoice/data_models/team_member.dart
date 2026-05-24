class MemberListMaster {
  List<Members>? members;

  MemberListMaster({this.members});

  MemberListMaster.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Members {
  int? id;
  String? email;
  String? role;
  String? createdAt;

  Members({this.id, this.email, this.role, this.createdAt});

  Members.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    role = json['role'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['role'] = this.role;
    data['created_at'] = this.createdAt;
    return data;
  }
}