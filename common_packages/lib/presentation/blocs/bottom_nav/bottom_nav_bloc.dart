import 'package:bloc/bloc.dart';
import 'package:common_packages/presentation/blocs/bottom_nav/bottom_nav_event.dart';

class BottomNavBloc extends Bloc<BottomNavEvent, int> {
  BottomNavBloc() : super(0) {
    on<ChangeTab>((event, emit) => emit(event.indexTab));
  }
}
