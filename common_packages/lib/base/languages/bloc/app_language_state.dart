part of 'app_language_bloc.dart';

class AppLanguageState extends Equatable {
  const AppLanguageState({
    AppLanguage? selectedLanguage,
  }) : selectedLanguage = selectedLanguage ?? AppLanguage.vietnamese;

  final AppLanguage selectedLanguage;

  @override
  List<Object> get props => [selectedLanguage];

  AppLanguageState copyWith({AppLanguage? selectedLanguage}) {
    return AppLanguageState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
