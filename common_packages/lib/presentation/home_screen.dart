import 'package:common_packages/di/injection.dart';
import 'package:common_packages/presentation/blocs/feed/feed_bloc.dart';
import 'package:common_packages/presentation/blocs/friend/friend_bloc.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:common_packages/presentation/blocs/love_letter/love_letter_bloc.dart';
import 'package:common_packages/presentation/blocs/moment/moment_bloc.dart';
import 'package:common_packages/presentation/blocs/note/note_bloc.dart';
import 'package:common_packages/presentation/blocs/photo/photo_bloc.dart';
import 'package:common_packages/presentation/blocs/qa/qa_bloc.dart';
import 'package:common_packages/presentation/blocs/document_reader/document_reader_bloc.dart';
import 'package:common_packages/presentation/blocs/wish/wish_bloc.dart';
import 'package:common_packages/presentation/pages/friend/friend_view.dart';
import 'package:common_packages/presentation/pages/home/home_tab_view.dart';
import 'package:common_packages/presentation/pages/setting/setting_screen.dart';
import 'package:common_packages/presentation/pages/tools/tools_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Track which tabs have been visited - only build once visited
  final _builtTabs = <int>{0};

  // Lazy BLoC instances - created on first access
  PhotoBloc? _photoBloc;
  MomentBloc? _momentBloc;
  FeedBloc? _feedBloc;
  NoteBloc? _noteBloc;
  FinanceBloc? _financeBloc;
  FriendBloc? _friendBloc;
  DocumentReaderBloc? _documentReaderBloc;
  WishBloc? _wishBloc;
  QaBloc? _qaBloc;
  LoveLetterBloc? _loveLetterBloc;

  PhotoBloc get photoBloc => _photoBloc ??= sl<PhotoBloc>();
  MomentBloc get momentBloc => _momentBloc ??= sl<MomentBloc>();
  FeedBloc get feedBloc => _feedBloc ??= sl<FeedBloc>();
  NoteBloc get noteBloc => _noteBloc ??= sl<NoteBloc>();
  FinanceBloc get financeBloc => _financeBloc ??= sl<FinanceBloc>();
  FriendBloc get friendBloc => _friendBloc ??= sl<FriendBloc>();
  DocumentReaderBloc get documentReaderBloc =>
      _documentReaderBloc ??= DocumentReaderBloc(remoteDataSource: sl())..add(const LoadDocumentsEvent());
  WishBloc get wishBloc => _wishBloc ??= sl<WishBloc>();
  QaBloc get qaBloc => _qaBloc ??= sl<QaBloc>();
  LoveLetterBloc get loveLetterBloc => _loveLetterBloc ??= sl<LoveLetterBloc>();

  @override
  void dispose() {
    _photoBloc?.close();
    _momentBloc?.close();
    _feedBloc?.close();
    _noteBloc?.close();
    _financeBloc?.close();
    _friendBloc?.close();
    _documentReaderBloc?.close();
    _wishBloc?.close();
    _qaBloc?.close();
    _loveLetterBloc?.close();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      _builtTabs.add(index);
    });
  }

  Widget _buildTab(int index) {
    if (!_builtTabs.contains(index)) {
      return const SizedBox.shrink();
    }

    switch (index) {
      case 0:
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: photoBloc),
            BlocProvider.value(value: momentBloc),
            BlocProvider.value(value: feedBloc),
            BlocProvider.value(value: qaBloc),
            BlocProvider.value(value: friendBloc),
          ],
          child: const HomeTabView(),
        );
      case 1:
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: noteBloc),
            BlocProvider.value(value: financeBloc),
            BlocProvider.value(value: documentReaderBloc),
            BlocProvider.value(value: wishBloc),
            BlocProvider.value(value: loveLetterBloc),
            BlocProvider.value(value: friendBloc),
          ],
          child: const ToolsView(),
        );
      case 2:
        return BlocProvider.value(
          value: friendBloc,
          child: const FriendView(),
        );
      case 3:
        return const SettingScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(4, _buildTab),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedHome02),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedDashboardSquare01),
            label: 'Cong cu',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedUserGroup),
            label: 'Ban be',
          ),
          NavigationDestination(
            icon: Icon(HugeIcons.strokeRoundedSetting06),
            label: 'Cai dat',
          ),
        ],
      ),
    );
  }
}
