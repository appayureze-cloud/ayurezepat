import 'package:flutter/material.dart';

import '../../../../theme.dart';

/// The 4 universal system states from the Stitch export
/// (ayureze_loading_state, ayureze_empty_state, ayureze_offline_state,
/// ayureze_error_state): shared, reusable building blocks any screen can
/// drop in instead of ad hoc "No data"/spinner widgets. Existing
/// per-feature loading/empty handling (e.g. NoDataWidget) is left as-is
/// where it already works - these are for screens built or touched
/// going forward.
class AppLoadingState extends StatelessWidget {
  final String? message;

  const AppLoadingState({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.sagePrimary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!,
                style: const TextStyle(color: AppColors.slateTextMuted)),
          ],
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.sagePrimarySubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.sagePrimary),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorState({this.message, this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      body: message ?? 'Please try again in a moment.',
      actionLabel: onRetry != null ? 'Try again' : null,
      onAction: onRetry,
    );
  }
}

class AppOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const AppOfflineState({this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.wifi_off,
      title: 'No internet connection',
      body: 'Check your connection and try again.',
      actionLabel: onRetry != null ? 'Try again' : null,
      onAction: onRetry,
    );
  }
}
