import '../../../../core/result/result.dart';
import '../../domain/entities/group_class_entity.dart';
import '../../domain/repositories/group_classes_repository.dart';
import '../datasources/group_classes_remote_api_service.dart';
import '../mappers/group_class_mappers.dart';

final class GroupClassesRepositoryImpl implements GroupClassesRepository {
  const GroupClassesRepositoryImpl(this._remote);

  final GroupClassesRemoteApiService _remote;

  @override
  Future<Result<List<GroupClassEntity>>> getGroupClasses({
    String? from,
    String? to,
  }) async {
    final result = await _remote.getGroupClasses(from: from, to: to);
    return switch (result) {
      Success(:final data) =>
        Success(data.map((item) => item.toEntity()).toList()),
      Failure(:final failure) => Failure(failure),
    };
  }
}
