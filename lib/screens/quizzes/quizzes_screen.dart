import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../models/quiz_model.dart';
import '../../utils/theme.dart';
import 'quiz_edit_dialog.dart';
import 'quiz_detail_dialog.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizzes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quiz Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const QuizEditDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Consumer<QuizProvider>(
              builder: (context, quizProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search quizzes...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          quizProvider.setSearchQuery(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: quizProvider.categoryFilter,
                      items: [
                        const DropdownMenuItem(value: 'All Categories', child: Text('All Categories')),
                        ...quizProvider.getUniqueCategories().map(
                              (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          quizProvider.setCategoryFilter(value);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Quizzes List
            Expanded(
              child: Consumer<QuizProvider>(
                builder: (context, quizProvider, _) {
                  if (quizProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (quizProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading quizzes',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quizProvider.errorMessage!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => quizProvider.loadQuizzes(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (quizProvider.quizzes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            quizProvider.searchQuery.isNotEmpty || quizProvider.categoryFilter != 'All Categories'
                                ? 'No quizzes found matching your filters'
                                : 'No quizzes found',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          if (quizProvider.searchQuery.isNotEmpty || quizProvider.categoryFilter != 'All Categories') ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                quizProvider.setSearchQuery('');
                                quizProvider.setCategoryFilter('All Categories');
                              },
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: quizProvider.quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizProvider.quizzes[index];
                      return _buildQuizCard(context, quiz);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.quiz,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (quiz.category != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                quiz.category!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: quiz.isActive
                                  ? AppTheme.primaryBlue.withOpacity(0.1)
                                  : Colors.grey[300]!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              quiz.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: quiz.isActive ? AppTheme.primaryBlue : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(quiz.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Options
                      ...List.generate(quiz.options.length, (index) {
                        final isCorrect = index == quiz.correctOptionIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? AppTheme.primaryGreen.withOpacity(0.1)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                  border: isCorrect
                                      ? Border.all(color: AppTheme.primaryGreen)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isCorrect
                                          ? AppTheme.primaryGreen
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  quiz.options[index],
                                  style: TextStyle(
                                    color: isCorrect ? AppTheme.primaryGreen : Colors.black87,
                                    fontWeight: isCorrect ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryGreen,
                                  size: 16,
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            tooltip: 'View Details',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => QuizDetailDialog(quiz: quiz),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Edit Quiz',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => QuizEditDialog(quiz: quiz),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              quiz.isActive ? Icons.toggle_on : Icons.toggle_off,
                              size: 20,
                              color: quiz.isActive ? AppTheme.primaryBlue : Colors.grey,
                            ),
                            tooltip: quiz.isActive ? 'Deactivate' : 'Activate',
                            onPressed: () {
                              Provider.of<QuizProvider>(context, listen: false)
                                  .toggleQuizStatus(quiz.id, !quiz.isActive);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            tooltip: 'Delete Quiz',
                            onPressed: () {
                              _showDeleteConfirmation(context, quiz);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context, QuizModel quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<QuizProvider>(context, listen: false).deleteQuiz(quiz.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}