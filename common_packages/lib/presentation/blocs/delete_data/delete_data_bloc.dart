import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../util/app_preferences.dart';

part 'delete_data_event.dart';
part 'delete_data_state.dart';

class DeleteDataBloc extends Bloc<DeleteDataEvent, DeleteDataState> {
  DeleteDataBloc() : super(const DeleteDataState()) {
    on<DeleteDataRequested>(_onDeleteData);
  }

  Future<void> _onDeleteData(
      DeleteDataRequested event, Emitter<DeleteDataState> emit) async {
    await AppPreferences.clearAll();
    emit(state.copyWith(isDeleted: true));
  }
}
