import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_model.dart';
import '../../utils/theme.dart';

class QuizEditDialog extends StatefulWidget {
  final QuizModel? quiz;

  const QuizEditDialog({super.key, this.quiz});

  @override
  State<QuizEditDialog> createState() => _QuizEditDialogState();
}

class _QuizEditDialogState extends State<QuizEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
  int _correctOptionIndex = 0;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _questionController.text = widget.quiz!.question;
      _categoryController.text = widget.quiz!.category ?? '';
      for (int i = 0; i < widget.quiz!.options.length && i < 4; i++) {
        _optionControllers[i].text = widget.quiz!.options[i];
      }
      _correctOptionIndex = widget.quiz!.correctOptionIndex;
      _isActive = widget.quiz!.isActive;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _categoryController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.quiz == null ? 'Create Quiz' : 'Edit Quiz',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Question
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              const Text(
                'Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _correctOptionIndex,
                        onChanged: (value) {
                          setState(() {
                            _correctOptionIndex = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${String.fromCharCode(65 + index)}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option ${String.fromCharCode(65 + index)}';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Active Status
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value!;
                      });
                    },
                  ),
                  const Text('Active'),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.quiz == null ? 'Create' : 'Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      final quiz = QuizModel(
        id: widget.quiz?.id ?? '',
        question: _questionController.text,
        options: _optionControllers.map((controller) => controller.text).toList(),
        correctOptionIndex: _correctOptionIndex,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        createdAt: widget.quiz?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: _isActive,
      );

      if (widget.quiz == null) {
        context.read<QuizProvider>().addQuiz(quiz);
      } else {
        context.read<QuizProvider>().updateQuiz(widget.quiz!.id, quiz);
      }

      Navigator.of(context).pop();
    }
  }
}