import 'package:common_packages/presentation/pages/feed/feed_view.dart';
import 'package:common_packages/presentation/pages/moment/moment_view.dart';
import 'package:common_packages/presentation/pages/photo_picker/photo_picker_view.dart';
import 'package:common_packages/presentation/pages/qa/qa_view.dart';
import 'package:flutter/material.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lazy: only build sub-tabs when first selected
  final _builtSubTabs = <int>{0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _builtSubTabs.add(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSubTab(int index) {
    if (!_builtSubTabs.contains(index)) return const SizedBox.shrink();
    switch (index) {
      case 0:
        return const MomentView();
      case 1:
        return const FeedView();
      case 2:
        return const PhotoPickerView();
      case 3:
        return const QaView();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chip'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt_outlined, size: 20), text: 'Moment'),
            Tab(icon: Icon(Icons.dynamic_feed_outlined, size: 20), text: 'Feed'),
            Tab(icon: Icon(Icons.photo_library_outlined, size: 20), text: 'Anh'),
            Tab(icon: Icon(Icons.question_answer_outlined, size: 20), text: 'Q&A'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, _buildSubTab),
      ),
    );
  }
}
