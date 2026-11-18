part of 'group_classes_cubit.dart';

enum GroupClassesStatus { initial, loading, loaded, failure }

final class GroupClassesState extends Equatable {
  const GroupClassesState({
    this.status = GroupClassesStatus.initial,
    this.classes = const [],
    this.errorMessage,
  });

  final GroupClassesStatus status;
  final List<GroupClassEntity> classes;
  final String? errorMessage;

  bool get isLoading =>
      status == GroupClassesStatus.loading ||
      status == GroupClassesStatus.initial;

  /// Next classes that haven't ended and aren't cancelled, nearest first.
  List<GroupClassEntity> upcoming(DateTime now) => classes
      .where((c) => !c.isCancelled && !c.isOver(now))
      .toList();

  GroupClassesState copyWith({
    GroupClassesStatus? status,
    List<GroupClassEntity>? classes,
    Object? errorMessage = _unset,
  }) {
    return GroupClassesState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, classes, errorMessage];
}

const _unset = Object();
