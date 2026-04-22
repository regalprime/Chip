import 'package:bloc/bloc.dart';
import 'package:common_packages/util/app_language.dart';
import 'package:common_packages/util/app_preferences.dart';
import 'package:equatable/equatable.dart';


part 'app_language_event.dart';
part 'app_language_state.dart';

class AppLanguageBloc extends Bloc<AppLanguageEvent, AppLanguageState> {
  AppLanguageBloc() : super(const AppLanguageState()) {
    on<LoadAppLanguage>(_onLoadAppLanguage);
    on<ChangeAppLanguage>(_onChangeAppLanguage);
  }

  Future<void> _onLoadAppLanguage(
      LoadAppLanguage event, Emitter<AppLanguageState> emit) async {
    final savedLangCode = await AppPreferences.getLanguage();
    final lang = AppLanguage.values.firstWhere(
          (l) => l.value.languageCode == savedLangCode,
      orElse: () => AppLanguage.vietnamese,
    );
    emit(state.copyWith(selectedLanguage: lang));
  }

  Future<void> _onChangeAppLanguage(
      ChangeAppLanguage event, Emitter<AppLanguageState> emit) async {
    await AppPreferences.setLanguage(event.selectedLanguage.value.languageCode);
    emit(state.copyWith(selectedLanguage: event.selectedLanguage));
  }
}
