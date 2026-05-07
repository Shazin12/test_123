import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../dubbing/dubbing_orchestrator.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  final TextEditingController _dgController = TextEditingController();
  final TextEditingController _oaController = TextEditingController();
  final TextEditingController _elController = TextEditingController();
  final TextEditingController _slController = TextEditingController();
  String _targetLang = 'Spanish';

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orchestrator = context.watch<DubbingOrchestrator>();

    return Scaffold(
      appBar: AppBar(title: const Text('AI Dub Pro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildKeyInput('Deepgram API Key', _dgController),
            _buildKeyInput('OpenAI API Key', _oaController),
            _buildKeyInput('ElevenLabs API Key', _elController),
            _buildKeyInput('Sync Labs API Key', _slController),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _targetLang,
              decoration: const InputDecoration(labelText: 'Target Language', border: OutlineInputBorder()),
              items: ['Spanish', 'French', 'German', 'Italian', 'Hindi']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _targetLang = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_file),
              label: Text(_selectedFile == null ? 'Select Video' : 'Change Video'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Text('Selected: ${p_basename(_selectedFile!.path)}', textAlign: TextAlign.center),
            ],
            const SizedBox(height: 32),
            if (orchestrator.status != 'Idle' && orchestrator.status != 'Completed') ...[
              Text(orchestrator.status, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: orchestrator.progress),
              const SizedBox(height: 8),
              Text('${(orchestrator.progress * 100).toInt()}%', textAlign: TextAlign.center),
            ] else if (orchestrator.status == 'Completed') ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const Text('Dubbing Finished!', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () {}, child: const Text('Download Result')),
            ] else
              ElevatedButton(
                onPressed: _selectedFile == null ? null : () => _startDubbing(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text('START DUBBING PIPELINE'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.key),
        ),
      ),
    );
  }

  String p_basename(String path) => path.split('/').last;

  void _startDubbing(BuildContext context) {
    final orch = context.read<DubbingOrchestrator>();
    orch.updateKeys(
      dg: _dgController.text,
      oa: _oaController.text,
      el: _elController.text,
      sl: _slController.text,
    );
    orch.runPipeline(_selectedFile!, _targetLang);
  }
}
