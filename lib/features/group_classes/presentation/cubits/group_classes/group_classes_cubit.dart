import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/group_class_entity.dart';
import '../../../domain/repositories/group_classes_repository.dart';

part 'group_classes_state.dart';

final class GroupClassesCubit extends Cubit<GroupClassesState> {
  GroupClassesCubit(this._repository) : super(const GroupClassesState());

  final GroupClassesRepository _repository;

  /// Loads the schedule. With no range the server returns this week
  /// (today … today + 6, Asia/Amman).
  Future<void> load({String? from, String? to}) async {
    emit(state.copyWith(status: GroupClassesStatus.loading, errorMessage: null));

    final result = await _repository.getGroupClasses(from: from, to: to);

    result.fold(
      onSuccess: (classes) => emit(
        state.copyWith(status: GroupClassesStatus.loaded, classes: classes),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          status: GroupClassesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
