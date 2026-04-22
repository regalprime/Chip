# Design System

## Vi tri

```
common_packages/lib/base/design_system/
├── design_system.dart          ← Barrel export (import file nay la du)
└── widgets/
    ├── ds_button.dart          ← Button (filled, outlined, ghost, text, danger)
    ├── ds_text_field.dart      ← Input (text, password, multiline)
    ├── ds_search_bar.dart      ← Search voi debounce
    ├── ds_checkbox.dart        ← Checkbox + label
    ├── ds_radio.dart           ← Radio group
    ├── ds_switch.dart          ← Toggle switch + label
    ├── ds_card.dart            ← Card (filled, outlined, flat)
    ├── ds_list_tile.dart       ← List row cho settings/menu
    ├── ds_divider.dart         ← Divider (thuong + co label)
    ├── ds_avatar.dart          ← Avatar (image/initials/icon) + AvatarStack
    ├── ds_badge.dart           ← Badge/chip (5 variants)
    ├── ds_dialog.dart          ← Alert, Confirm, Custom dialog
    ├── ds_bottom_sheet.dart    ← Bottom sheet (thuong + full screen)
    ├── ds_snackbar.dart        ← Snackbar (success, error, warning, info)
    ├── ds_loading.dart         ← Loading (center, inline, overlay) + Skeleton
    └── ds_empty_state.dart     ← Empty state placeholder
```

## Cach su dung

```dart
import 'package:common_packages/base/design_system/design_system.dart';
```

## Vi du nhanh

```dart
// Button
DSButton(label: 'Luu', onPressed: () {})
DSButton(label: 'Xoa', variant: DSButtonVariant.danger, onPressed: () {})
DSButton(label: 'Dang luu...', isLoading: true, onPressed: null)

// Text Field
DSTextField(label: 'Email', prefixIcon: Icons.email_outlined)
DSTextField.password(label: 'Mat khau')
DSTextField.multiline(label: 'Ghi chu', maxLines: 5)

// Search
DSSearchBar(hint: 'Tim kiem...', onChanged: (q) {}, debounceMs: 300)

// Selection
DSCheckbox(value: true, label: 'Dong y', onChanged: (v) {})
DSSwitch(value: true, label: 'Dark Mode', icon: Icons.dark_mode, onChanged: (v) {})
DSRadioGroup<String>(
  value: selected,
  items: [DSRadioItem(value: 'a', label: 'Option A'), ...],
  onChanged: (v) {},
)

// Card
DSCard(child: Text('Noi dung'))
DSCard.outlined(child: Text('Vien'), onTap: () {})

// Avatar
DSAvatar(imageUrl: user.photoUrl, name: user.displayName, size: 48)
DSAvatar.icon(icon: Icons.group, size: 40)

// Badge
DSBadge(label: 'Moi', variant: DSBadgeVariant.success)

// Dialog
final ok = await DSDialog.confirm(context: context, title: 'Xoa?', isDestructive: true);

// Bottom Sheet
DSBottomSheet.show(context: context, title: 'Chon', child: MyContent())

// Snackbar
DSSnackbar.success(context, message: 'Da luu!');
DSSnackbar.error(context, message: 'Loi roi!');

// Loading
DSLoading()                              // Full screen
DSLoading.inline(message: 'Dang tai...')  // Inline

// Empty State
DSEmptyState(icon: Icons.photo, title: 'Chua co anh', actionLabel: 'Them', onAction: () {})
```

## Nguyen tac

- Tat ca component dung `Theme.of(context)` → tu dong ho tro dark/light mode
- Khong hardcode mau, dung `colorScheme` va `appColors`
- Xem them: `the_king_docs/theme.txt` cho chi tiet ve mau sac
