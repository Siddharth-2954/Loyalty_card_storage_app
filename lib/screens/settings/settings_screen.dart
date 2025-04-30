import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_wallet/providers/auth_provider.dart';
import 'package:loyalty_card_wallet/providers/settings_provider.dart';
import 'package:loyalty_card_wallet/screens/auth/login_screen.dart';
import 'package:loyalty_card_wallet/services/sync_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
    });
    
    try {
      await SyncService().syncCards();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settings, auth, _) {
          return ListView(
            children: [
              if (auth.isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Account'),
                  subtitle: Text(auth.email ?? 'Guest'),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      settings.setThemeMode(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Enable card expiry notifications'),
                value: settings.enableNotifications,
                onChanged: (value) {
                  settings.setEnableNotifications(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.sync),
                title: const Text('Auto Sync'),
                subtitle: const Text('Automatically sync cards when online'),
                value: settings.enableAutoSync,
                onChanged: (value) {
                  settings.setEnableAutoSync(value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face ID to unlock the app'),
                value: settings.useBiometrics,
                onChanged: (value) {
                  settings.setUseBiometrics(value);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Now'),
                subtitle: const Text('Manually sync your cards with the cloud'),
                trailing: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isSyncing ? null : _syncNow,
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                subtitle: Text('Version $_appVersion'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Everyday Rewards',
                    applicationVersion: _appVersion,
                    applicationLegalese: '© 2023 Everyday Rewards Inc.',
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'A digital loyalty card wallet that helps you manage all your rewards cards in one place.',
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (auth.isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
            ],
          );
        },
      ),
    );
  }
}
