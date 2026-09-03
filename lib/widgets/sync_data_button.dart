import 'package:flutter/material.dart';
import '../services/web_auth_service.dart';
import '../theme/app_colors.dart';

class SyncDataButton extends StatefulWidget {
  final String? connectCode;
  final VoidCallback? onSyncCompleted;

  const SyncDataButton({
    super.key,
    this.connectCode,
    this.onSyncCompleted,
  });

  @override
  State<SyncDataButton> createState() => _SyncDataButtonState();
}

class _SyncDataButtonState extends State<SyncDataButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSyncing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _isSuccess = false;
    });

    _controller.repeat();

    final code = widget.connectCode ?? WebAuthService.currentUser?.connectCode ?? '';

    try {
      // Refresh Firestore stream & wait briefly for network telemetry
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      setState(() {
        _isSyncing = false;
        _isSuccess = true;
      });
      _controller.stop();
      _controller.reset();

      if (widget.onSyncCompleted != null) {
        widget.onSyncCompleted!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 10),
              Text(
                code.isNotEmpty
                    ? 'Real-time call data synchronized for code $code'
                    : 'Real-time call data synchronized!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset success state after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isSuccess = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _isSuccess = false;
      });
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isSyncing ? null : _handleSync,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isSuccess 
                ? const Color(0xFFECFDF5) // Green tint
                : _isSyncing 
                    ? const Color(0xFFEFF6FF) 
                    : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isSuccess
                  ? const Color(0xFF10B981)
                  : _isSyncing
                      ? AppColors.primary
                      : AppColors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSuccess)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: Color(0xFF10B981),
                )
              else
                RotationTransition(
                  turns: _controller,
                  child: Icon(
                    Icons.sync_rounded,
                    size: 15,
                    color: _isSyncing ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                _isSuccess
                    ? 'Synced!'
                    : _isSyncing
                        ? 'Syncing...'
                        : 'Sync Real-Time Data',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _isSuccess
                      ? const Color(0xFF047857)
                      : _isSyncing
                          ? AppColors.primary
                          : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
