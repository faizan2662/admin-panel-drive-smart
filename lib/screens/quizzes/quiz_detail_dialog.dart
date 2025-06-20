import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../utils/theme.dart';

class QuizDetailDialog extends StatelessWidget {
  final QuizModel quiz;

  const QuizDetailDialog({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Quiz Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status and Category
            Row(
              children: [
                if (quiz.category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.category!,
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: quiz.isActive
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : Colors.grey[300]!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quiz.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: quiz.isActive ? AppTheme.primaryBlue : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question
            const Text(
              'Question:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quiz.question,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Options
            const Text(
              'Options:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(quiz.options.length, (index) {
              final isCorrect = index == quiz.correctOptionIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: isCorrect
                      ? Border.all(color: AppTheme.primaryGreen, width: 2)
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCorrect ? AppTheme.primaryGreen : Colors.grey[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        quiz.options[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                          color: isCorrect ? AppTheme.primaryGreen : Colors.black87,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Metadata
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Created: ${_formatDate(quiz.createdAt)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.update, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Updated: ${_formatDate(quiz.updatedAt)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}