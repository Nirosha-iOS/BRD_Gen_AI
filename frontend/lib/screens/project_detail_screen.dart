import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'input_screen.dart';
import 'brd_screen.dart';
import 'feedback_screen.dart';
import 'technical_doc_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _selectedTab = 0;
  int? _currentBRDVersionId;
  String? _currentBRDContent;

  final List<String> _tabs = ['Input', 'BRD', 'Feedback', 'Technical'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.primary,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.folder_special_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.projectName,
                style: AppTextStyles.appBarTitle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.borderLight,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surfaceContainer,
            ],
          ),
        ),
        child: Column(
          children: [
            // Tab Buttons
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getTabIcon(index, isSelected),
                              size: 20,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _tabs[index],
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  InputScreen(
                    projectId: widget.projectId,
                    onInputProcessed: (projectId) {
                      setState(() {
                        _selectedTab = 1; // Navigate to BRD tab
                      });
                    },
                  ),
                  BRDScreen(
                    projectId: widget.projectId,
                    onBRDGenerated: (projectId, versionId, content) {
                      setState(() {
                        _currentBRDVersionId = versionId;
                        _currentBRDContent = content;
                      });
                    },
                  ),
                  FeedbackScreen(
                    projectId: widget.projectId,
                    currentVersionId: _currentBRDVersionId,
                    onBRDUpdated: (projectId, versionId, content) {
                      setState(() {
                        _currentBRDVersionId = versionId;
                        _currentBRDContent = content;
                      });
                    },
                  ),
                  TechnicalDocScreen(projectId: widget.projectId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTabIcon(int index, bool isSelected) {
    switch (index) {
      case 0:
        return isSelected ? Icons.edit_note : Icons.edit_note_outlined;
      case 1:
        return isSelected ? Icons.description : Icons.description_outlined;
      case 2:
        return isSelected ? Icons.feedback : Icons.feedback_outlined;
      case 3:
        return isSelected ? Icons.code : Icons.code_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

