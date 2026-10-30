import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _urlController = TextEditingController(text: settings.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.tune, color: AppColors.primaryLight, size: 22),
          SizedBox(width: 8),
          Text(
            'Server Settings',
            style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend API URL',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'http://10.0.2.2:8000',
                prefixIcon: Icon(Icons.link, color: AppColors.textMuted, size: 18),
              ),
              style: const TextStyle(color: AppColors.text, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Quick picks
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Android Emul (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _urlController.text = ApiConstants.defaultAndroidEmulatorUrl;
                  },
                ),
                ActionChip(
                  label: const Text('Localhost (127.0.0.1)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _urlController.text = ApiConstants.defaultLocalhostUrl;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Health Status Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (settings.isChecking)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  else
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: settings.isServerReachable == true
                            ? AppColors.success
                            : (settings.isServerReachable == false ? AppColors.error : AppColors.textMuted),
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      settings.isChecking
                          ? 'Pinging server...'
                          : (settings.isServerReachable == true
                              ? 'Server is online and healthy!'
                              : (settings.isServerReachable == false
                                  ? 'Server unreachable. Verify backend is running.'
                                  : 'Status unknown')),
                      style: TextStyle(
                        color: settings.isServerReachable == true ? AppColors.success : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await settings.testConnection();
          },
          child: const Text('Test Connection'),
        ),
        ElevatedButton(
          onPressed: () async {
            final newUrl = _urlController.text.trim();
            if (newUrl.isNotEmpty) {
              await settings.updateBaseUrl(newUrl);
            }
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

