import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final tp = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final user = auth.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Avatar ──────────────────────────────────────────
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFF6C63FF),
            child: Text(user?.initials ?? 'S',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Student',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(user?.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cloud_done, color: Colors.green, size: 14),
              SizedBox(width: 4),
              Text('Synced with NeonDB',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Stats ────────────────────────────────────────────
          Row(children: [
            _Stat(
                label: 'Total',
                value: tp.tasks.length.toString(),
                color: const Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            _Stat(
                label: 'Completed',
                value: tp.completedTasks.length.toString(),
                color: const Color(0xFF43A047)),
            const SizedBox(width: 12),
            _Stat(
                label: 'Pending',
                value: tp.pendingTasks.length.toString(),
                color: const Color(0xFFFFA726)),
          ]),
          const SizedBox(height: 24),

          // ── Account settings ─────────────────────────────────
          _SectionHeader(label: 'Account'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(children: [
              _Tile(
                icon: Icons.person_outline,
                title: 'Edit Name',
                subtitle: user?.name ?? '',
                onTap: () => _editName(context, user?.name ?? ''),
              ),
              const Divider(height: 1, indent: 56),
              _Tile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user?.email ?? '',
                onTap: () {},
                showArrow: false,
              ),
              const Divider(height: 1, indent: 56),
              _Tile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => _changePassword(context),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Appearance ───────────────────────────────────────
          _SectionHeader(label: 'Appearance'),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.dark_mode_outlined,
                    color: Color(0xFF6C63FF), size: 20),
              ),
              title: const Text('Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                  themeProvider.isDarkMode ? 'Dark theme active' : 'Light theme active',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              value: themeProvider.isDarkMode,
              activeThumbColor: const Color(0xFF6C63FF),
              activeTrackColor:
                  const Color(0xFF6C63FF).withValues(alpha: 0.4),
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Notifications ─────────────────────────────────────
          _SectionHeader(label: 'Notifications'),
          const _NotificationSettingsCard(),
          const SizedBox(height: 20),

          // ── About ────────────────────────────────────────────
          _SectionHeader(label: 'About'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(children: [
              _Tile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'Student Planner Pro v2.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Student Planner Pro',
                  applicationVersion: '2.0.0',
                  applicationLegalese:
                      'Built with Flutter + NeonDB\n© 2024',
                ),
              ),
              const Divider(height: 1, indent: 56),
              _Tile(
                icon: Icons.storage_outlined,
                title: 'Backend',
                subtitle: 'NeonDB PostgreSQL',
                onTap: () {},
                showArrow: false,
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Logout ───────────────────────────────────────────
          Card(
            margin: EdgeInsets.zero,
            child: _Tile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Logout',
              titleColor: Colors.red,
              subtitle: 'Sign out of your account',
              onTap: () => _logout(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────

  void _editName(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final ap = ctx.read<AuthProvider>();
                await ap.updateProfile(name: name);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: Icon(Icons.lock_outline)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red));
                return;
              }
              if (newCtrl.text.length < 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Minimum 6 characters'),
                    backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: Colors.green));
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ap = ctx.read<AuthProvider>();
              await ap.logout();
              if (ctx.mounted) ctx.go('/login');
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Notification Settings Card ────────────────────────────────

class _NotificationSettingsCard extends StatelessWidget {
  const _NotificationSettingsCard();

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NotificationProvider>();
    final s = np.settings;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Header row with master toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.notifications_outlined,
                      color: Color(0xFF6C63FF), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('In-App Notifications',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('Choose what alerts you see',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Alert type toggles ──
          _NotifSwitch(
            icon: Icons.warning_rounded,
            iconColor: Colors.red,
            title: 'Overdue Alerts',
            subtitle: 'When a task passes its deadline',
            value: s.overdueAlerts,
            onChanged: (v) => np.updateSetting('notif_overdue', v),
          ),
          const Divider(height: 1, indent: 56),
          _NotifSwitch(
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFFFFA726),
            title: 'Due Soon Alerts',
            subtitle: 'When a task is due within selected hours',
            value: s.dueSoonAlerts,
            onChanged: (v) => np.updateSetting('notif_due_soon', v),
          ),

          // Due soon hours picker
          if (s.dueSoonAlerts) ...[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(56, 0, 16, 8),
              child: Row(
                children: [
                  const Text('Alert me',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HourPicker(
                      value: s.dueSoonHours,
                      options: const [1, 2, 6, 12, 24, 48],
                      onChanged: (v) =>
                          np.updateSetting('notif_soon_hours', v),
                    ),
                  ),
                  const Text('hours before due',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],

          const Divider(height: 1, indent: 56),
          _NotifSwitch(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF6C63FF),
            title: 'Upcoming Task Alerts',
            subtitle: 'Tasks due within selected days',
            value: s.upcomingAlerts,
            onChanged: (v) => np.updateSetting('notif_upcoming', v),
          ),

          // Upcoming days picker
          if (s.upcomingAlerts) ...[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(56, 0, 16, 8),
              child: Row(
                children: [
                  const Text('Tasks within',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HourPicker(
                      value: s.upcomingDays,
                      options: const [1, 2, 3, 5, 7],
                      onChanged: (v) =>
                          np.updateSetting('notif_upcoming_days', v),
                    ),
                  ),
                  const Text('days',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],

          const Divider(height: 1, indent: 56),
          _NotifSwitch(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF43A047),
            title: 'Done Confirmations',
            subtitle: 'When you mark a task as done',
            value: s.doneConfirmations,
            onChanged: (v) => np.updateSetting('notif_done', v),
          ),

          const Divider(height: 1),
          // Daily digest section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE91E8C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.schedule_outlined,
                      color: Color(0xFFE91E8C), size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Digest',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('Scheduled summaries',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _NotifSwitch(
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFFFFA726),
            title: 'Morning Digest',
            subtitle: 'Daily pending task summary at 8:00 AM',
            value: s.morningDigest,
            onChanged: (v) => np.updateSetting('notif_morning', v),
          ),
          const Divider(height: 1, indent: 56),
          _NotifSwitch(
            icon: Icons.nights_stay_outlined,
            iconColor: const Color(0xFF6C63FF),
            title: 'Evening Digest',
            subtitle: 'Remaining tasks check-in at 8:00 PM',
            value: s.eveningDigest,
            onChanged: (v) => np.updateSetting('notif_evening', v),
          ),

          const Divider(height: 1),
          // Reset & clear
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<NotificationProvider>().clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications cleared'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All',
                        style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final np = context.read<NotificationProvider>();
                      await np.updateSetting('notif_overdue', true);
                      await np.updateSetting('notif_due_soon', true);
                      await np.updateSetting('notif_upcoming', true);
                      await np.updateSetting('notif_done', true);
                      await np.updateSetting('notif_morning', true);
                      await np.updateSetting('notif_evening', true);
                      await np.updateSetting('notif_soon_hours', 24);
                      await np.updateSetting('notif_upcoming_days', 3);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings reset to defaults'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('Reset',
                        style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        side: const BorderSide(
                            color: Color(0xFF6C63FF)),
                        padding: const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _NotifSwitch extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotifSwitch({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      activeThumbColor: const Color(0xFF6C63FF),
      activeTrackColor:
          const Color(0xFF6C63FF).withValues(alpha: 0.35),
      onChanged: onChanged,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _HourPicker extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;
  const _HourPicker(
      {required this.value,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((o) {
          final selected = o == value;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF6C63FF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF6C63FF)
                            .withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '$o',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.45),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor, titleColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;
  const _Tile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? const Color(0xFF6C63FF);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: titleColor)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: showArrow
          ? Icon(Icons.chevron_right,
              color: Colors.grey.withValues(alpha: 0.5), size: 20)
          : null,
    );
  }
}
