abstract class BottomNavEvent {}

class ChangeTab extends BottomNavEvent {
  ChangeTab(this.indexTab);
  final int indexTab;
}
