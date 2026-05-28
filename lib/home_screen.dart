import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  PlatformFile? _selectedFile;
  String _aiResponse = '';
  bool _isAnalyzing = false;

  final String _apiKey = 'AIzaSyBd-KfbCbjtq1h5FGGPMa3QPRMNE6yLZ2k';

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _analyzeDocument() async {
    if (_selectedFile == null || _promptController.text.isEmpty || _selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file and enter a prompt first.'))
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _aiResponse = '';
    });

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final mimeType = _selectedFile!.extension == 'pdf' ? 'application/pdf' : 'text/plain';

      final documentPart = DataPart(mimeType, _selectedFile!.bytes!);
      final textPart = TextPart(_promptController.text.trim());

      final response = await model.generateContent([
        Content.multi([textPart, documentPart])
      ]);

      setState(() {
        _aiResponse = response.text ?? 'The model did not return any text analysis.';
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'Error analyzing document: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Analyzer'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDocument,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(20)),
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _selectedFile != null ? 'Selected: ${_selectedFile!.name}' : 'Upload PDF or TXT Document',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ask the AI to analyze, summarize, or extract data...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeDocument,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Analyze Document', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              if (_aiResponse.isNotEmpty) ...[
                const Text('AI Analysis Result:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: SelectableText(
                    _aiResponse,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}