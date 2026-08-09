import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class InputScreen extends StatefulWidget {
  final int? projectId;
  final Function(int) onInputProcessed;
  
  const InputScreen({super.key, this.projectId, required this.onInputProcessed});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  String? _extractedText;
  int? _projectId;
  int? _inputId;

  @override
  void initState() {
    super.initState();
    _projectId = widget.projectId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processTextInput() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('Please enter some text');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      Map<String, dynamic> result;
      
      if (_projectId != null) {
        // Use existing project
        result = await ApiService.processTextInput(
          text: _textController.text,
          projectName: 'Existing Project',
          projectType: 'Software',
          projectId: _projectId, // Pass existing project ID
        );
      } else {
        // Create new project
        result = await ApiService.processTextInput(
          text: _textController.text,
          projectName: 'Untitled Project',
          projectType: 'Software',
        );
      }

      setState(() {
        _projectId = result['project_id'];
        _inputId = result['input_id'];
        _extractedText = result['extracted_text'];
        _isProcessing = false;
      });

      _showSnackBar('✅ Text processed successfully!');
      widget.onInputProcessed(_projectId!);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('❌ Error: ${e.toString()}');
    }
  }

  Future<void> _uploadAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final file = File(result.files.single.path!);
        final apiResult = await ApiService.uploadAudio(
          file,
          projectName: 'Untitled Project',
          projectType: 'Software',
          projectId: _projectId, // Pass existing project ID if available
        );

        setState(() {
          _projectId = apiResult['project_id'];
          _inputId = apiResult['input_id'];
          _extractedText = apiResult['extracted_text'];
          _isProcessing = false;
        });

        _showSnackBar('✅ Audio transcribed successfully!');
        widget.onInputProcessed(_projectId!);
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        _showSnackBar('❌ Error: ${e.toString()}');
      }
    }
  }

  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final file = File(result.files.single.path!);
        final apiResult = await ApiService.uploadDocument(
          file,
          projectName: 'Untitled Project',
          projectType: 'Software',
          projectId: _projectId, // Pass existing project ID if available
        );

        setState(() {
          _projectId = apiResult['project_id'];
          _inputId = apiResult['input_id'];
          _extractedText = apiResult['extracted_text'];
          _isProcessing = false;
        });

        _showSnackBar('✅ Document processed successfully!');
        widget.onInputProcessed(_projectId!);
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        _showSnackBar('❌ Error: ${e.toString()}');
      }
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
          // Text Input Card
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
                          Icons.edit_note_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Text Input',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _textController,
                  maxLines: 10,
                  style: AppTextStyles.bodyLarge,
                  decoration: AppDecorations.inputDecoration(
                    labelText: 'Enter your requirements or description',
                    hintText: 'Describe your project requirements, features, and objectives in detail...',
                    prefixIcon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processTextInput,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(_isProcessing ? 'Processing...' : 'Process Text'),
                    style: AppButtonStyles.primaryButton,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Upload Files Card
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
                          Icons.cloud_upload_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Upload Files',
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
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _uploadAudio,
                        icon: const Icon(Icons.mic_rounded, size: 20),
                        label: const Text('Audio'),
                        style: AppButtonStyles.outlinedButton.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _uploadDocument,
                        icon: const Icon(Icons.upload_file_rounded, size: 20),
                        label: const Text('Document'),
                        style: AppButtonStyles.outlinedButton.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Supported formats: PDF, DOC, DOCX, Images (PNG, JPG)',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Extracted Text Display
          if (_extractedText != null) ...[
            const SizedBox(height: 24),
            Container(
              decoration: AppDecorations.cardDecoration.copyWith(
                color: AppColors.success.withOpacity(0.05),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Extracted Text',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Successfully processed',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: SelectableText(
                      _extractedText!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.7,
                      ),
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
