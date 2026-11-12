import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/auth_session_entity.dart';
import '../../../domain/entities/review_signup_result.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'review_signup_state.dart';

final class ReviewSignupCubit extends Cubit<ReviewSignupState> {
  ReviewSignupCubit(this._repository) : super(const ReviewSignupState());

  final AuthRepository _repository;

  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phone,
    String? phoneCountryCode,
  }) async {
    emit(const ReviewSignupState(status: ReviewSignupStatus.loading));

    final result = await _repository.reviewSignup(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      phone: phone,
      phoneCountryCode: phoneCountryCode,
    );
    if (isClosed) return;

    emit(
      switch (result) {
        ReviewSignupSuccess(:final session) => ReviewSignupState(
            status: ReviewSignupStatus.success,
            session: session,
          ),
        ReviewSignupFailure(:final kind, :final message) => ReviewSignupState(
            status: ReviewSignupStatus.failure,
            errorKind: kind,
            errorMessage: message,
          ),
      },
    );
  }

  void reset() => emit(const ReviewSignupState());
}
