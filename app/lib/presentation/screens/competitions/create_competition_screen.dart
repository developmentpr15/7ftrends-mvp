import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/competition_provider.dart';
import '../../../models/competition.dart';

class CreateCompetitionScreen extends StatefulWidget {
  const CreateCompetitionScreen({super.key});

  @override
  State<CreateCompetitionScreen> createState() => _CreateCompetitionScreenState();
}

class _CreateCompetitionScreenState extends State<CreateCompetitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _themeController = TextEditingController();
  String _coverImageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Competition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _themeController,
                decoration: const InputDecoration(labelText: 'Theme'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a theme';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newCompetition = Competition(
                      id: DateTime.now().toString(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      theme: _themeController.text,
                      coverImageUrl: _coverImageUrl,
                      endDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    Provider.of<CompetitionProvider>(context, listen: false)
                        .addCompetition(
                      title: newCompetition.title,
                      description: newCompetition.description,
                      theme: newCompetition.theme,
                      endDate: newCompetition.endDate,
                      coverImageUrl: newCompetition.coverImageUrl,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
