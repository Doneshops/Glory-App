// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupClassModel _$GroupClassModelFromJson(
  Map<String, dynamic> json,
) => GroupClassModel(
  id: json['id'] as String,
  nameEn: json['nameEn'] as String?,
  nameAr: json['nameAr'] as String?,
  date: json['date'] as String,
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
  dayNameEn: json['dayNameEn'] as String?,
  dayNameAr: json['dayNameAr'] as String?,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String?,
  startAt: json['startAt'] == null
      ? null
      : DateTime.parse(json['startAt'] as String),
  endAt: json['endAt'] == null ? null : DateTime.parse(json['endAt'] as String),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  instructor: json['instructor'] == null
      ? null
      : GroupClassInstructorModel.fromJson(
          json['instructor'] as Map<String, dynamic>,
        ),
  branch: json['branch'] == null
      ? null
      : GroupClassBranchModel.fromJson(json['branch'] as Map<String, dynamic>),
  location: json['location'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  status: json['status'] as String?,
  cancelReason: json['cancelReason'] as String?,
);

GroupClassInstructorModel _$GroupClassInstructorModelFromJson(
  Map<String, dynamic> json,
) => GroupClassInstructorModel(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

GroupClassBranchModel _$GroupClassBranchModelFromJson(
  Map<String, dynamic> json,
) => GroupClassBranchModel(
  id: json['id'] as String,
  nameEn: json['nameEn'] as String?,
  nameAr: json['nameAr'] as String?,
);

GroupClassesApiResponse _$GroupClassesApiResponseFromJson(
  Map<String, dynamic> json,
) => GroupClassesApiResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => GroupClassModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
);
