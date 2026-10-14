import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../theme.dart';
import 'vault_home_screen.dart';

/// Matches the Stitch "Vault Lock Screen" (ayureze_vault_lock_screen/
/// code.html): a 4-digit PIN gate shown every time the Health Vault is
/// opened. There's no local_auth dependency in this project yet, so the
/// "biometric" affordance from the mock is a visual placeholder that
/// falls back to the PIN pad rather than a real fingerprint/face
/// prompt - wiring real biometrics needs a device to test against,
/// which this environment doesn't have.
class VaultLockScreen extends HookWidget {
  const VaultLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storedPin = SharedPreferenceHelper.getString(Preferences.vault_pin);
    final isSettingUp = storedPin == null || storedPin.isEmpty;
    final entered = useState('');
    final confirmPin = useState<String?>(null);
    final error = useState<String?>(null);

    void onDigit(String digit) {
      if (entered.value.length >= 4) return;
      error.value = null;
      entered.value += digit;
      if (entered.value.length == 4) {
        Future.microtask(() {
          if (isSettingUp && confirmPin.value == null) {
            confirmPin.value = entered.value;
            entered.value = '';
          } else if (isSettingUp) {
            if (entered.value == confirmPin.value) {
              SharedPreferenceHelper.setString(
                  Preferences.vault_pin, entered.value);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const VaultHomeScreen()));
            } else {
              error.value = 'PINs did not match. Try again.';
              entered.value = '';
              confirmPin.value = null;
            }
          } else {
            if (entered.value == storedPin) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const VaultHomeScreen()));
            } else {
              error.value = 'Incorrect PIN';
              entered.value = '';
            }
          }
        });
      }
    }

    void onBackspace() {
      if (entered.value.isEmpty) return;
      entered.value = entered.value.substring(0, entered.value.length - 1);
    }

    final title = !isSettingUp
        ? 'Unlock your Health Vault'
        : confirmPin.value == null
            ? 'Create a Vault PIN'
            : 'Confirm your PIN';

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.sagePrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  size: 44, color: AppColors.sagePrimary),
            ),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < entered.value.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? AppColors.sagePrimary
                        : AppColors.creamSurfaceLowest,
                    border: Border.all(color: AppColors.slateBorder),
                  ),
                );
              }),
            ),
            if (error.value != null) ...[
              const SizedBox(height: 12),
              Text(error.value!,
                  style: const TextStyle(color: AppColors.clayAlert)),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                    _PadButton(label: d, onTap: () => onDigit(d)),
                  const SizedBox(),
                  _PadButton(label: '0', onTap: () => onDigit('0')),
                  _PadButton(
                    icon: Icons.backspace_outlined,
                    onTap: onBackspace,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _PadButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedMd,
      child: Center(
        child: label != null
            ? Text(label!, style: Theme.of(context).textTheme.headlineLarge)
            : Icon(icon, color: AppColors.slateTextSecondary),
      ),
    );
  }
}
