import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  final int? projectId;
  final int? currentVersionId;
  final Function(int, int, String)? onBRDUpdated;

  const FeedbackScreen({
    super.key,
    this.projectId,
    this.currentVersionId,
    this.onBRDUpdated,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isUpdating = false;
  String? _updatedBRDContent;
  int? _newVersionId;
  int? _newVersionNumber;

  Future<void> _updateBRD() async {
    if (widget.projectId == null || widget.currentVersionId == null) {
      _showSnackBar('No BRD version available for update');
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      _showSnackBar('Please enter your feedback');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final result = await ApiService.updateBRD(
        projectId: widget.projectId!,
        currentVersionId: widget.currentVersionId!,
        feedback: _feedbackController.text,
      );

      setState(() {
        _updatedBRDContent = result['updated_brd_content'];
        _newVersionId = result['new_version_id'];
        _newVersionNumber = result['new_version_number'];
        _isUpdating = false;
      });

      if (widget.onBRDUpdated != null) {
        widget.onBRDUpdated!(
          widget.projectId!,
          _newVersionId!,
          _updatedBRDContent!,
        );
      }

      _showSnackBar('✅ BRD updated successfully!');
      _feedbackController.clear();
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      _showSnackBar('❌ Error: ${e.toString()}');
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
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feedback Input Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Feedback',
                        style: AppTextStyles.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: 'Enter your feedback, suggestions, or changes',
                      hintText: 'Example: Add more details about user authentication...',
                      prefixIcon: const Icon(Icons.comment),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ||
                              widget.projectId == null ||
                              widget.currentVersionId == null
                          ? null
                          : _updateBRD,
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : const Icon(Icons.update),
                      label: Text(_isUpdating ? 'Updating...' : 'Update BRD'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Loading State
          if (_isUpdating) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Updating BRD...',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Incorporating your feedback',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Updated BRD Display
          if (_updatedBRDContent != null && !_isUpdating) ...[
            const SizedBox(height: 24),
            Card(
              color: AppColors.gradientStart.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated BRD',
                                  style: AppTextStyles.titleLarge,
                                ),
                              ],
                            ),
                            if (_newVersionNumber != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Version $_newVersionNumber',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _updatedBRDContent!),
                            );
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: SelectableText(
                        _updatedBRDContent!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Empty State
          if ((widget.projectId == null || widget.currentVersionId == null) && !_isUpdating) ...[
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
                      'No BRD Available',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please generate a BRD first in the BRD tab.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
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
