import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  bool _showAddProject = false;
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController();
  String _selectedProjectType = 'Software';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await ApiService.getAllProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
        _showAddProject = projects.isEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showSnackBar('Error loading projects: ${e.toString()}');
      }
    }
  }

  Future<void> _createProject() async {
    if (_projectNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter a project name');
      return;
    }

    try {
      // Create project by processing empty text (this creates a project)
      await ApiService.processTextInput(
        text: _projectDescriptionController.text.trim().isEmpty
            ? 'Project: ${_projectNameController.text}'
            : _projectDescriptionController.text.trim(),
        projectName: _projectNameController.text.trim(),
        projectType: _selectedProjectType,
      );

      _projectNameController.clear();
      _projectDescriptionController.clear();
      setState(() {
        _showAddProject = false;
      });
      _loadProjects();
      if (mounted) {
        _showSnackBar('✅ Project created successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error creating project: ${e.toString()}');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'My Projects',
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_showAddProject && !_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showAddProject = true;
                  });
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add Project Form
                  if (_showAddProject) ...[
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
                            Icons.add_circle_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Create New Project',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _projectNameController,
                    style: AppTextStyles.bodyLarge,
                    decoration: AppDecorations.inputDecoration(
                      labelText: 'Project Name',
                      hintText: 'Enter a descriptive project name',
                      prefixIcon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedProjectType,
                    style: AppTextStyles.bodyLarge,
                    decoration: AppDecorations.inputDecoration(
                      labelText: 'Project Type',
                      prefixIcon: Icons.category_outlined,
                    ),
                    items: ['Software', 'Hardware', 'Business Process']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      type == 'Software' ? Icons.computer_outlined :
                                      type == 'Hardware' ? Icons.memory_outlined :
                                      Icons.business_center_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    type,
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _projectDescriptionController,
                    maxLines: 4,
                    style: AppTextStyles.bodyLarge,
                    decoration: AppDecorations.inputDecoration(
                      labelText: 'Project Description (Optional)',
                      hintText: 'Brief description of your project...',
                      prefixIcon: Icons.description_outlined,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showAddProject = false;
                              _projectNameController.clear();
                              _projectDescriptionController.clear();
                            });
                          },
                          child: const Text('Cancel'),
                          style: AppButtonStyles.outlinedButton,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _createProject,
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: const Text('Create'),
                          style: AppButtonStyles.primaryButton,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
                    const SizedBox(height: 24),
                  ],

                  // Projects List
                  if (_isLoading) ...[
            Container(
              decoration: AppDecorations.cardDecoration,
              padding: const EdgeInsets.all(48),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                    ),
                  ),
                  ] else if (_projects.isEmpty && !_showAddProject) ...[
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
                      Icons.folder_open_rounded,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Projects Yet',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create your first project to get started',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAddProject = true;
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Create Project'),
                    style: AppButtonStyles.primaryButton,
                  ),
                    ],
                  ),
                ),
                  ] else if (_projects.isNotEmpty) ...[
                    ..._projects.map((project) => _buildProjectCard(project)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.cardDecoration,
      child: Material(
        color: Colors.transparent,
          child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(
                  projectId: project['id'],
                  projectName: project['name'],
                ),
              ),
            );
            // Refresh projects when returning
            _loadProjects();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    project['project_type'] == 'Software' ? Icons.computer_rounded :
                    project['project_type'] == 'Hardware' ? Icons.memory_rounded :
                    Icons.business_center_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['name'],
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              project['project_type'],
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(project['created_at']),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

