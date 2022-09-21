class AmityNotifications {
  bool? lastRead;
  List<Data>? data;

  AmityNotifications({lastRead, data});

  AmityNotifications.fromJson(Map<String, dynamic> json) {
    lastRead = json['lastRead'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastRead'] = lastRead;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? description;
  String? networkId;
  String? userId;
  String? verb;
  String? targetId;
  String? targetGroup;
  String? imageUrl;
  String? targetType;
  bool? hasRead;
  int? lastUpdate;
  List<Actors>? actors;
  int? actorsCount;

  Data(
      {description,
      networkId,
      userId,
      verb,
      targetId,
      targetGroup,
      imageUrl,
      targetType,
      hasRead,
      lastUpdate,
      actors,
      actorsCount});

  Data.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    networkId = json['networkId'];
    userId = json['userId'];
    verb = json['verb'];
    targetId = json['targetId'];
    targetGroup = json['targetGroup'];
    imageUrl = json['imageUrl'];
    targetType = json['targetType'];
    hasRead = json['hasRead'];
    lastUpdate = json['lastUpdate'];
    if (json['actors'] != null) {
      actors = <Actors>[];
      json['actors'].forEach((v) {
        actors!.add(Actors.fromJson(v));
      });
    }
    actorsCount = json['actorsCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['networkId'] = networkId;
    data['userId'] = userId;
    data['verb'] = verb;
    data['targetId'] = targetId;
    data['targetGroup'] = targetGroup;
    data['imageUrl'] = imageUrl;
    data['targetType'] = targetType;
    data['hasRead'] = hasRead;
    data['lastUpdate'] = lastUpdate;
    if (actors != null) {
      data['actors'] = actors!.map((v) => v.toJson()).toList();
    }
    data['actorsCount'] = actorsCount;
    return data;
  }
}

class Actors {
  String? name;
  String? id;

  Actors({name, id});

  Actors.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
