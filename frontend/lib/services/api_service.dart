import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Text Input
  static Future<Map<String, dynamic>> processTextInput({
    required String text,
    String projectName = 'Untitled Project',
    String projectType = 'Software',
    int? projectId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/text-input'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'project_name': projectName,
        'project_type': projectType,
        if (projectId != null) 'project_id': projectId,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process text input');
    }
  }
  
  // Audio Upload
  static Future<Map<String, dynamic>> uploadAudio(
    File audioFile, {
    String projectName = 'Untitled Project',
    String projectType = 'Software',
    int? projectId,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/audio-upload'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );
    request.fields['project_name'] = projectName;
    request.fields['project_type'] = projectType;
    if (projectId != null) {
      request.fields['project_id'] = projectId.toString();
    }
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload audio');
    }
  }
  
  // Document Upload
  static Future<Map<String, dynamic>> uploadDocument(
    File documentFile, {
    String projectName = 'Untitled Project',
    String projectType = 'Software',
    int? projectId,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/doc-upload'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('file', documentFile.path),
    );
    request.fields['project_name'] = projectName;
    request.fields['project_type'] = projectType;
    if (projectId != null) {
      request.fields['project_id'] = projectId.toString();
    }
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload document');
    }
  }
  
  // Generate BRD
  static Future<Map<String, dynamic>> generateBRD({
    required int projectId,
    int? inputId,
    String? customText,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-brd'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'project_id': projectId,
        'input_id': inputId,
        'custom_text': customText,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate BRD');
    }
  }
  
  // Generate Technical Document
  static Future<Map<String, dynamic>> generateTechnicalDoc({
    required int projectId,
    int? brdVersionId,
    String? customRequirements,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-technical-doc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'project_id': projectId,
        'brd_version_id': brdVersionId,
        'custom_requirements': customRequirements,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate technical document');
    }
  }
  
  // Update BRD with Feedback
  static Future<Map<String, dynamic>> updateBRD({
    required int projectId,
    required int currentVersionId,
    required String feedback,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update-brd'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'project_id': projectId,
        'current_version_id': currentVersionId,
        'feedback': feedback,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update BRD');
    }
  }
  
  // Get Versions
  static Future<Map<String, dynamic>> getVersions(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/versions/$projectId'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get versions');
    }
  }
  
  // Download Document
  static Future<String> downloadDocument(int versionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/download/$versionId'),
    );
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to download document');
    }
  }
  
  // Get All Projects
  static Future<List<Map<String, dynamic>>> getAllProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['projects']);
    } else {
      throw Exception('Failed to get projects');
    }
  }
  
  // Get Project by ID
  static Future<Map<String, dynamic>> getProject(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get project');
    }
  }
  
  // Clear All Projects (for testing/reset)
  static Future<Map<String, dynamic>> clearAllProjects() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/clear-all'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clear projects');
    }
  }
}

