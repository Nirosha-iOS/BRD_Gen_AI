import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BRDScreen extends StatefulWidget {
  final int? projectId;
  final Function(int, int, String)? onBRDGenerated;

  const BRDScreen({super.key, this.projectId, this.onBRDGenerated});

  @override
  State<BRDScreen> createState() => _BRDScreenState();
}

class _BRDScreenState extends State<BRDScreen> {
  bool _isGenerating = false;
  String? _brdContent;
  int? _currentVersionId;
  int? _currentVersionNumber;

  Future<void> _generateBRD() async {
    if (widget.projectId == null) {
      _showSnackBar('Please process input first');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await ApiService.generateBRD(projectId: widget.projectId!);

      setState(() {
        _brdContent = result['brd_content'];
        _currentVersionId = result['version_id'];
        _currentVersionNumber = result['version_number'];
        _isGenerating = false;
      });

      if (widget.onBRDGenerated != null) {
        widget.onBRDGenerated!(
          widget.projectId!,
          _currentVersionId!,
          _brdContent!,
        );
      }

      _showSnackBar('✅ BRD generated successfully!');
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showSnackBar('❌ Error: ${e.toString()}');
    }
  }

  Future<void> _downloadBRD() async {
    if (_currentVersionId == null) {
      _showSnackBar('No BRD to download');
      return;
    }

    try {
      final content = await ApiService.downloadDocument(_currentVersionId!);
      await Clipboard.setData(ClipboardData(text: content));
      _showSnackBar('✅ BRD copied to clipboard!');
    } catch (e) {
      _showSnackBar('❌ Error downloading: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              message.startsWith('✅') ? Icons.check_circle : Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.replaceAll(RegExp(r'[✅❌]'), '').trim(),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: message.startsWith('✅') ? AppColors.success : AppColors.error,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Generate Action Card
          Container(
            decoration: AppDecorations.cardDecoration,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: AppDecorations.sectionHeaderDecoration,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Generate BRD',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating || widget.projectId == null
                            ? null
                            : _generateBRD,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded, size: 20),
                        label: Text(_isGenerating ? 'Generating...' : 'Generate BRD'),
                        style: AppButtonStyles.primaryButton,
                      ),
                    ),
                    if (_brdContent != null) ...[
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _downloadBRD,
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text('Download'),
                        style: AppButtonStyles.outlinedButton,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Loading State
          if (_isGenerating) ...[
            const SizedBox(height: 24),
            Container(
              decoration: AppDecorations.cardDecoration,
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Generating BRD...',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This may take 30-60 seconds',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Generated BRD Display
          if (_brdContent != null && !_isGenerating) ...[
            const SizedBox(height: 24),
            Container(
              decoration: AppDecorations.cardDecoration,
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Generated BRD',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready for review',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _brdContent!));
                          _showSnackBar('✅ Copied to clipboard!');
                        },
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: SelectableText(
                      _brdContent!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Empty State
          if (widget.projectId == null && !_isGenerating && _brdContent == null) ...[
            const SizedBox(height: 24),
            Container(
              decoration: AppDecorations.cardDecoration,
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Project Selected',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please go to the Input tab and process your requirements first.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
