class InvitationListMaster {
  List<Invitations>? invitations;

  InvitationListMaster({this.invitations});

  InvitationListMaster.fromJson(Map<String, dynamic> json) {
    if (json['invitations'] != null) {
      invitations = <Invitations>[];
      json['invitations'].forEach((v) {
        invitations!.add(new Invitations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.invitations != null) {
      data['invitations'] = this.invitations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Invitations {
  int? id;
  String? email;
  String? role;
  String? inviteCode;
  String? companyName;
  String? createdAt;

  Invitations(
      {this.id,
        this.email,
        this.role,
        this.inviteCode,
        this.companyName,
        this.createdAt});

  Invitations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    role = json['role'];
    inviteCode = json['invite_code'];
    companyName = json['company_name'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['role'] = this.role;
    data['invite_code'] = this.inviteCode;
    data['company_name'] = this.companyName;
    data['created_at'] = this.createdAt;
    return data;
  }
}