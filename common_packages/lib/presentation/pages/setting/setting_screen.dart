import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/base/languages/l10n/gen/app_localizations.dart';
import 'package:common_packages/presentation/blocs/auth/auth_bloc.dart';
import 'package:common_packages/presentation/blocs/delete_data/delete_data_bloc.dart';
import 'package:common_packages/presentation/pages/setting/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../base/theme/theme_bloc.dart';
import '../../../base/theme/theme_event.dart';
import '../../../base/languages/bloc/app_language_bloc.dart';
import '../../../util/app_language.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return CustomScrollView(
            slivers: [
              // ── Header with user info ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                      ),
                    ),
                    child: SafeArea(
                      child: _UserHeader(authState: authState),
                    ),
                  ),
                ),
              ),

              // ── Settings sections ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Account
                      _SectionTitle(title: 'Tai khoan'),
                      _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF42A5F5),
                            title: context.l10n.profile,
                            subtitle: 'Ten, anh dai dien, gioi thieu',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Profile()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Appearance
                      _SectionTitle(title: 'Giao dien'),
                      _SettingsCard(
                        children: [
                          _ThemeSettingTile(),
                          _Divider(),
                          _LanguageSettingTile(),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Data & Storage
                      _SectionTitle(title: 'Du lieu'),
                      _SettingsCard(
                        children: [
                          _ClearDataTile(),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Account actions
                      _SectionTitle(title: 'Phien dang nhap'),
                      _SettingsCard(
                        children: [
                          _SignOutTile(),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // About
                      _SectionTitle(title: 'Thong tin'),
                      _SettingsCard(
                        children: [
                          _AboutTile(),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// User Header
// ═══════════════════════════════════════════════════════════════════════════════

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    String? name;
    String? email;
    String? photoUrl;

    if (authState is AuthAuthenticated) {
      final user = (authState as AuthAuthenticated).user;
      name = user.displayName;
      email = user.email;
      photoUrl = user.photoUrl;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (email != null) ...[
            const SizedBox(height: 2),
            Text(
              email,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Section helpers
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: context.appColors.divider,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Theme Setting
// ═══════════════════════════════════════════════════════════════════════════════

class _ThemeSettingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return _SettingsTile(
          icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          iconColor: const Color(0xFFFF9800),
          title: AppLocalizations.of(context)!.toggleDarkMode,
          subtitle: isDark ? 'Toi' : 'Sang',
          trailing: Switch(
            value: isDark,
            onChanged: (_) => context.read<ThemeBloc>().add(ChangeTheme()),
          ),
          onTap: () => context.read<ThemeBloc>().add(ChangeTheme()),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Language Setting
// ═══════════════════════════════════════════════════════════════════════════════

class _LanguageSettingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageBloc, AppLanguageState>(
      builder: (context, state) {
        final currentLang = state.selectedLanguage;
        final langName = currentLang == AppLanguage.english ? 'English' : 'Tieng Viet';

        return _SettingsTile(
          icon: Icons.language,
          iconColor: const Color(0xFF5C6BC0),
          title: AppLocalizations.of(context)!.changeLanguage,
          subtitle: langName,
          onTap: () => _showLanguagePicker(context, currentLang),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, AppLanguage current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.changeLanguage,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              ...AppLanguage.values.map((lang) {
                final isSelected = lang == current;
                final label = lang == AppLanguage.english ? 'English' : 'Tieng Viet';
                final flag = lang == AppLanguage.english ? '🇺🇸' : '🇻🇳';

                return ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 24)),
                  title: Text(label),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  selected: isSelected,
                  onTap: () {
                    context.read<AppLanguageBloc>().add(
                          ChangeAppLanguage(selectedLanguage: lang),
                        );
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Clear Data
// ═══════════════════════════════════════════════════════════════════════════════

class _ClearDataTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteDataBloc, DeleteDataState>(
      listener: (context, state) {
        if (state.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Da xoa du lieu cache')),
          );
        }
      },
      child: _SettingsTile(
        icon: Icons.delete_sweep_outlined,
        iconColor: const Color(0xFFFF7043),
        title: AppLocalizations.of(context)!.clearData,
        subtitle: 'Xoa du lieu cache cua ung dung',
        onTap: () => _confirmClear(context),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa du lieu cache?'),
        content: const Text('Hanh dong nay se xoa tat ca du lieu luu tam tren may. Du lieu tren server khong bi anh huong.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DeleteDataBloc>().add(DeleteDataRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sign Out
// ═══════════════════════════════════════════════════════════════════════════════

class _SignOutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        return _SettingsTile(
          icon: Icons.logout,
          iconColor: const Color(0xFFE53935),
          title: AppLocalizations.of(context)!.signOut,
          subtitle: 'Dang xuat khoi tai khoan',
          onTap: () => _confirmSignOut(context),
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dang xuat?'),
        content: const Text('Ban co chac muon dang xuat khoi tai khoan?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(SignOutEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// About
// ═══════════════════════════════════════════════════════════════════════════════

class _AboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '...';

        return _SettingsTile(
          icon: Icons.info_outline,
          iconColor: const Color(0xFF78909C),
          title: 'Phien ban',
          subtitle: version,
        );
      },
    );
  }
}
