import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../../models/user_model.dart';
import '../../providers/users_provider.dart';
import '../../utils/theme.dart';
import 'license_image_viewer.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:html' as html; // for web URL opening

class UserDetailDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.roleColor,
                  radius: 24,
                  child: Text(
                    user.initials,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            user.verificationIcon,
                            color: user.verificationColor,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.roleDisplayName,
                              style: TextStyle(
                                color: user.roleColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.verificationColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.verificationDisplayName,
                              style: TextStyle(
                                color: user.verificationColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content with Tabs
            Expanded(
              child: DefaultTabController(
                length: user.role == UserRole.trainer ? 3 : 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppTheme.primaryBlue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.primaryBlue,
                      tabs: [
                        const Tab(
                          icon: Icon(Icons.person, size: 20),
                          text: 'Personal Info',
                        ),
                        const Tab(
                          icon: Icon(Icons.info, size: 20),
                          text: 'Additional Info',
                        ),
                        if (user.role == UserRole.trainer)
                          const Tab(
                            icon: Icon(Icons.credit_card, size: 20),
                            text: 'License Documents',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Personal Information Tab
                          _buildPersonalInfoTab(),

                          // Additional Information Tab
                          _buildAdditionalInfoTab(),

                          // License Documents Tab (only for trainers)
                          if (user.role == UserRole.trainer)
                            _buildLicenseDocumentsTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Verification Actions
                if (user.verificationStatus != VerificationStatus.verified)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _updateVerificationStatus(context, VerificationStatus.verified),
                        icon: const Icon(Icons.verified, size: 18),
                        label: const Text('Verify User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _updateVerificationStatus(context, VerificationStatus.rejected),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                if (user.verificationStatus == VerificationStatus.verified)
                  OutlinedButton.icon(
                    onPressed: () => _updateVerificationStatus(context, VerificationStatus.notVerified),
                    icon: const Icon(Icons.pending, size: 18),
                    label: const Text('Mark as Unverified'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),

                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('Basic Information', [
            _buildDetailItem('Email', user.email),
            _buildDetailItem('Join Date', _formatDate(user.joinDate)),
            if (user.gender != null) _buildDetailItem('Gender', user.gender!),
          ]),

          if (user.city != null || user.currentLocation != null)
            _buildDetailSection('Location', [
              if (user.city != null) _buildDetailItem('City', user.city!),
              if (user.currentLocation != null) _buildDetailItem('Current Location', user.currentLocation!),
            ]),

          if (user.cnic != null || user.fatherName != null)
            _buildDetailSection('Personal Information', [
              if (user.cnic != null) _buildDetailItem('CNIC', user.cnic!),
              if (user.fatherName != null) _buildDetailItem('Father\'s Name', user.fatherName!),
            ]),

          // Verification Information
          _buildDetailSection('Verification Status', [
            _buildDetailItem('Status', user.verificationDisplayName),
            if (user.verifiedAt != null) _buildDetailItem('Verified Date', _formatDate(user.verifiedAt!)),
            if (user.verifiedBy != null) _buildDetailItem('Verified By', user.verifiedBy!),
          ]),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz Performance Section
          if (_hasQuizData())
            _buildQuizPerformanceSection(),

          // Other Additional Information (excluding license URLs and quiz data)
          if (user.metadata != null && user.metadata!.isNotEmpty)
            _buildDetailSection('Additional Information',
              user.metadata!.entries
                  .where((entry) => !_isHiddenField(entry.key) && entry.value != null)
                  .map((entry) => _buildDetailItem(_formatKey(entry.key), entry.value.toString()))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLicenseDocumentsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driving License Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Get license URLs directly from metadata
          FutureBuilder<Map<String, String?>>(
            future: _getLicenseImageUrls(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final frontUrl = snapshot.data?['front'];
              final backUrl = snapshot.data?['back'];

              if (frontUrl != null || backUrl != null) {
                return Row(
                  children: [
                    // Front License
                    if (frontUrl != null)
                      Expanded(
                        child: _buildDirectViewCard(
                          'Front License',
                          frontUrl,
                          Icons.credit_card,
                          Colors.blue,
                        ),
                      ),

                    if (frontUrl != null && backUrl != null)
                      const SizedBox(width: 16),

                    // Back License
                    if (backUrl != null)
                      Expanded(
                        child: _buildDirectViewCard(
                          'Back License',
                          backUrl,
                          Icons.credit_card_off,
                          Colors.green,
                        ),
                      ),
                  ],
                );
              } else {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.credit_card_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No License Documents Available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This trainer has not uploaded license documents yet.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Get license URLs directly from metadata
  Future<Map<String, String?>> _getLicenseImageUrls() async {
    final Map<String, String?> urls = {'front': null, 'back': null};

    if (user.metadata == null) return urls;

    final frontUrl = user.metadata!['frontLicenseUrl']?.toString();
    final backUrl = user.metadata!['backLicenseUrl']?.toString();

    print('=== USING DIRECT URLS ===');
    print('Front URL: $frontUrl');
    print('Back URL: $backUrl');

    urls['front'] = frontUrl;
    urls['back'] = backUrl;

    print('=========================');
    return urls;
  }

  // Build direct view card with buttons to open images in browser
  Widget _buildDirectViewCard(
      String title,
      String imageUrl,
      IconData icon,
      Color color,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Content area with buttons instead of image
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Container(
              color: Colors.grey[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // License icon
                  Icon(
                    Icons.description,
                    size: 48,
                    color: color.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'License Document Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'Click below to view the document',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // View buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // View in New Tab button
                      ElevatedButton.icon(
                        onPressed: () => _openUrlInNewTab(imageUrl),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('View Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Copy URL button
                      OutlinedButton.icon(
                        onPressed: () => _copyUrlToClipboard(imageUrl),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy URL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Open URL in new browser tab
  void _openUrlInNewTab(String url) {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    }
  }

  // Copy URL to clipboard
  void _copyUrlToClipboard(String url) {
    if (kIsWeb) {
      html.window.navigator.clipboard?.writeText(url);
      // Show a brief success message
      print('URL copied to clipboard: $url');
    }
  }

  // Helper methods for quiz data
  bool _hasQuizData() {
    return user.metadata?['quizPercentage'] != null ||
        user.metadata?['totalQuestions'] != null ||
        user.metadata?['quizScore'] != null;
  }

  int _getQuizPercentage() {
    final percentage = user.metadata?['quizPercentage'];
    if (percentage is int) return percentage;
    if (percentage is String) return int.tryParse(percentage) ?? 0;
    return 0;
  }

  int? _getTotalQuestions() {
    final total = user.metadata?['totalQuestions'];
    if (total is int) return total;
    if (total is String) return int.tryParse(total);
    return null;
  }

  int? _getQuizScore() {
    final score = user.metadata?['quizScore'];
    if (score is int) return score;
    if (score is String) return int.tryParse(score);
    return null;
  }

  double _calculateRating(int percentage) {
    // Convert percentage to 5-star rating
    if (percentage >= 90) {
      return 4.5 + (percentage - 90) * 0.05; // 4.5 to 5.0
    } else if (percentage >= 80) {
      return 3.5 + (percentage - 80) * 0.1; // 3.5 to 4.4
    } else if (percentage >= 70) {
      return 2.5 + (percentage - 70) * 0.1; // 2.5 to 3.4
    } else if (percentage >= 60) {
      return 1.5 + (percentage - 60) * 0.1; // 1.5 to 2.4
    } else if (percentage >= 50) {
      return 0.5 + (percentage - 50) * 0.1; // 0.5 to 1.4
    } else {
      return 0.5; // Minimum rating
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    if (rating >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getPerformanceColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getRatingDescription(double rating) {
    if (rating >= 4.5) return 'Excellent Performance';
    if (rating >= 4.0) return 'Very Good Performance';
    if (rating >= 3.0) return 'Good Performance';
    if (rating >= 2.0) return 'Fair Performance';
    return 'Needs Improvement';
  }

  bool _isHiddenField(String key) {
    // Hide license URLs and quiz data from additional info
    const hiddenKeys = {
      'name', 'email', 'userType', 'timestamp', 'city', 'cnic',
      'currentLocation', 'fatherName', 'gender', 'verificationStatus',
      'verifiedAt', 'verifiedBy', 'frontLicenseUrl', 'backLicenseUrl',
      'quizPercentage', 'totalQuestions', 'quizScore', 'quizCompletedAt',
      'applicationStatus', 'lat', 'lng'
    };
    return hiddenKeys.contains(key);
  }

  void _showImageViewer(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => LicenseImageViewer(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildQuizPerformanceSection() {
    final quizPercentage = _getQuizPercentage();
    final totalQuestions = _getTotalQuestions();
    final quizScore = _getQuizScore();
    final rating = _calculateRating(quizPercentage);

    return _buildDetailSection('Quiz Performance', [
      // Rating Display
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getRatingColor(rating).withOpacity(0.1),
              _getRatingColor(rating).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getRatingColor(rating).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: _getRatingColor(rating),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overall Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getRatingColor(rating),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Star Rating
                Row(
                  children: List.generate(5, (index) {
                    if (index < rating.floor()) {
                      return Icon(Icons.star, color: _getRatingColor(rating), size: 20);
                    } else if (index < rating) {
                      return Icon(Icons.star_half, color: _getRatingColor(rating), size: 20);
                    } else {
                      return Icon(Icons.star_border, color: Colors.grey[400], size: 20);
                    }
                  }),
                ),
                const SizedBox(width: 12),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getRatingColor(rating),
                  ),
                ),
                Text(
                  ' / 5.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getRatingDescription(rating),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Quiz Details
      if (quizScore != null) _buildDetailItem('Quiz Score', '$quizScore'),
      if (totalQuestions != null) _buildDetailItem('Total Questions', '$totalQuestions'),
      _buildDetailItem('Quiz Percentage', '$quizPercentage%'),

      // Performance Bar
      Container(
        margin: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$quizPercentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getPerformanceColor(quizPercentage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: quizPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getPerformanceColor(quizPercentage)),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatKey(String key) {
    return key.split('_').map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1)}'
        : '').join(' ');
  }

  void _updateVerificationStatus(BuildContext context, VerificationStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus == VerificationStatus.verified ? 'Verify' : newStatus == VerificationStatus.rejected ? 'Reject' : 'Unverify'} User'),
        content: Text('Are you sure you want to ${newStatus == VerificationStatus.verified ? 'verify' : newStatus == VerificationStatus.rejected ? 'reject' : 'mark as unverified'} ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<UsersProvider>(context, listen: false)
                  .updateUserVerification(user.id, newStatus);
              Navigator.of(context).pop(); // Close detail dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == VerificationStatus.verified ? Colors.green :
              newStatus == VerificationStatus.rejected ? Colors.red : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus == VerificationStatus.verified ? 'Verify' :
            newStatus == VerificationStatus.rejected ? 'Reject' : 'Unverify'),
          ),
        ],
      ),
    );
  }
}
