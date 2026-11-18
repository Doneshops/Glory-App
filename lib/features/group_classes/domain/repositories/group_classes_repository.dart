import '../../../../core/result/result.dart';
import '../entities/group_class_entity.dart';

abstract interface class GroupClassesRepository {
  /// Group-class schedule visible to the member (their branch + packages).
  /// [from]/[to] are inclusive `YYYY-MM-DD`; omit for this week.
  Future<Result<List<GroupClassEntity>>> getGroupClasses({
    String? from,
    String? to,
  });
}
