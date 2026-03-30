import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../domain/entities/user_preferences.dart';
import '../controllers/preferences_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        const UserPreferences();

    return AppScaffold(
      title: 'Profile & Settings',
      body: ListView(
        children: [
          PremiumCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    (user?.fullName.characters.firstOrNull ?? 'F')
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'FinSense User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ??
                            'Add Firebase config to load profile details',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Preferences'),
          const SizedBox(height: 12),
          PremiumCard(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: preferences.currencyCode,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const ['USD', 'EUR', 'INR', 'GBP']
                      .map(
                        (code) =>
                            DropdownMenuItem(value: code, child: Text(code)),
                      )
                      .toList(),
                  onChanged: user == null
                      ? null
                      : (value) {
                          ref
                              .read(preferencesControllerProvider.notifier)
                              .save(
                                userId: user.id,
                                preferences: preferences.copyWith(
                                  currencyCode:
                                      value ??
                                      FinanceDefaults.defaultCurrencyCode,
                                ),
                              );
                        },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: preferences.notificationsEnabled,
                  onChanged: user == null
                      ? null
                      : (value) {
                          ref
                              .read(preferencesControllerProvider.notifier)
                              .save(
                                userId: user.id,
                                preferences: preferences.copyWith(
                                  notificationsEnabled: value,
                                ),
                              );
                        },
                  title: const Text('Notifications'),
                ),
                SwitchListTile(
                  value: preferences.smartInsightsEnabled,
                  onChanged: user == null
                      ? null
                      : (value) {
                          ref
                              .read(preferencesControllerProvider.notifier)
                              .save(
                                userId: user.id,
                                preferences: preferences.copyWith(
                                  smartInsightsEnabled: value,
                                ),
                              );
                        },
                  title: const Text('Smart insights'),
                ),
                const ListTile(
                  title: Text('Theme'),
                  subtitle: Text(
                    'Light theme active. Dark theme placeholder ready for future expansion.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(authActionControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/sign-in');
                }
              },
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
