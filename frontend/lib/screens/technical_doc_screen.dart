import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TechnicalDocScreen extends StatefulWidget {
  final int? projectId;

  const TechnicalDocScreen({super.key, this.projectId});

  @override
  State<TechnicalDocScreen> createState() => _TechnicalDocScreenState();
}

class _TechnicalDocScreenState extends State<TechnicalDocScreen> {
  bool _isGenerating = false;
  String? _tddContent;
  int? _currentVersionId;

  Future<void> _generateTechnicalDoc() async {
    if (widget.projectId == null) {
      _showSnackBar('Please process input first');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await ApiService.generateTechnicalDoc(
        projectId: widget.projectId!,
      );

      setState(() {
        _tddContent = result['tdd_content'];
        _currentVersionId = result['version_id'];
        _isGenerating = false;
      });

      _showSnackBar('✅ Technical Document generated successfully!');
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showSnackBar('❌ Error: ${e.toString()}');
    }
  }

  Future<void> _downloadTDD() async {
    if (_currentVersionId == null) {
      _showSnackBar('No Technical Document to download');
      return;
    }

    try {
      final content = await ApiService.downloadDocument(_currentVersionId!);
      await Clipboard.setData(ClipboardData(text: content));
      _showSnackBar('✅ Technical Document copied to clipboard!');
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
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message.replaceAll(RegExp(r'[✅❌]'), '').trim())),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.architecture,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Generate TDD',
                        style: AppTextStyles.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating || widget.projectId == null
                              ? null
                              : _generateTechnicalDoc,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                )
                              : const Icon(Icons.code),
                          label: Text(
                              _isGenerating ? 'Generating...' : 'Generate TDD'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      if (_tddContent != null) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _downloadTDD,
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Loading State
          if (_isGenerating) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Generating Technical Document...',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take 30-60 seconds',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Generated TDD Display
          if (_tddContent != null && !_isGenerating) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Generated Technical Document',
                              style: AppTextStyles.titleLarge,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _tddContent!));
                            _showSnackBar('✅ Copied to clipboard!');
                          },
                          tooltip: 'Copy to clipboard',
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: SelectableText(
                        _tddContent!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.8,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Empty State
          if (widget.projectId == null && !_isGenerating) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Project Selected',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please go to the Input tab and process your requirements first.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
