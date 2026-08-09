import 'package:flutter/material.dart';
import 'input_screen.dart';
import 'brd_screen.dart';
import 'feedback_screen.dart';
import 'technical_doc_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int? _currentProjectId;
  int? _currentBRDVersionId;
  String? _currentBRDContent;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      InputScreen(
        onInputProcessed: (projectId) {
          setState(() {
            _currentProjectId = projectId;
            _selectedIndex = 1; // Navigate to BRD screen
          });
        },
      ),
      BRDScreen(
        projectId: _currentProjectId,
        onBRDGenerated: (projectId, versionId, content) {
          setState(() {
            _currentProjectId = projectId;
            _currentBRDVersionId = versionId;
            _currentBRDContent = content;
          });
        },
      ),
      FeedbackScreen(
        projectId: _currentProjectId,
        currentVersionId: _currentBRDVersionId,
        onBRDUpdated: (projectId, versionId, content) {
          setState(() {
            _currentBRDVersionId = versionId;
            _currentBRDContent = content;
          });
        },
      ),
      TechnicalDocScreen(projectId: _currentProjectId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
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
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'BRD AI Generator',
              style: AppTextStyles.appBarTitle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
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
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            height: 72,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                // Update screens with latest project data
                _screens[1] = BRDScreen(
                  projectId: _currentProjectId,
                  onBRDGenerated: (projectId, versionId, content) {
                    setState(() {
                      _currentProjectId = projectId;
                      _currentBRDVersionId = versionId;
                      _currentBRDContent = content;
                    });
                  },
                );
                _screens[2] = FeedbackScreen(
                  projectId: _currentProjectId,
                  currentVersionId: _currentBRDVersionId,
                  onBRDUpdated: (projectId, versionId, content) {
                    setState(() {
                      _currentBRDVersionId = versionId;
                      _currentBRDContent = content;
                    });
                  },
                );
                _screens[3] = TechnicalDocScreen(projectId: _currentProjectId);
              });
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.edit_note_outlined, size: 24),
                selectedIcon: Icon(Icons.edit_note, size: 24),
                label: 'Input',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined, size: 24),
                selectedIcon: Icon(Icons.description, size: 24),
                label: 'BRD',
              ),
              NavigationDestination(
                icon: Icon(Icons.feedback_outlined, size: 24),
                selectedIcon: Icon(Icons.feedback, size: 24),
                label: 'Feedback',
              ),
              NavigationDestination(
                icon: Icon(Icons.code_outlined, size: 24),
                selectedIcon: Icon(Icons.code, size: 24),
                label: 'Technical',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

