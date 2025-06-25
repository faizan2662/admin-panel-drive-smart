import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../utils/theme.dart';

class BookingDetailDialog extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailDialog({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book_online, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSection(
                      'Basic Information',
                      [
                        _buildInfoRow('Booking ID', booking.id),
                        _buildInfoRow('Booked By', booking.bookedBy),
                        _buildInfoRow('Request Type', booking.requestType),
                        _buildInfoRow('Status', booking.status.toUpperCase()),
                        _buildInfoRow('Location', booking.location),
                        _buildInfoRow('Created At', _formatDateTime(booking.createdAt)),
                        if (booking.acceptedAt != null)
                          _buildInfoRow('Accepted At', _formatDateTime(booking.acceptedAt!)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Participant Information
                    _buildSection(
                      'Participants',
                      [
                        _buildInfoRow('Trainee Name', booking.traineeName ?? 'N/A'),
                        _buildInfoRow('Trainee ID', booking.traineeId ?? 'N/A'),
                        _buildInfoRow('Trainer Name', booking.trainerName ?? 'N/A'),
                        _buildInfoRow('Trainer ID', booking.trainerId ?? 'N/A'),
                        _buildInfoRow('Trainer Location', booking.trainerLocation ?? 'N/A'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Session & Progress Information
                    _buildSection(
                      'Session Details',
                      [
                        _buildInfoRow('Total Sessions', booking.sessionCount.toString()),
                        _buildInfoRow('Total Lessons', booking.totalLessons.toString()),
                        _buildInfoRow('Completed Lessons', booking.completedLessons.toString()),
                        _buildInfoRow('Progress', '${booking.progressPercent}%'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Payment Information
                    _buildSection(
                      'Payment Details',
                      [
                        _buildInfoRow('Total Amount', 'PKR ${booking.totalAmount}'),
                        _buildInfoRow('Payment Status', booking.paymentStatus ?? 'N/A'),
                        if (booking.paymentDate != null)
                          _buildInfoRow('Payment Date', _formatDateTime(booking.paymentDate!)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Selected Plans
                    if (booking.selectedPlans.isNotEmpty)
                      _buildSection(
                        'Selected Plans',
                        booking.selectedPlans
                            .map((plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(plan),
                            ],
                          ),
                        ))
                            .toList(),
                      ),

                    const SizedBox(height: 20),

                    // Offered Sessions
                    if (booking.offeredSessions.isNotEmpty)
                      _buildSection(
                        'Offered Sessions (${booking.offeredSessions.length})',
                        booking.offeredSessions
                            .map((session) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  session.isBooked
                                      ? Icons.event_busy
                                      : Icons.event_available,
                                  size: 16,
                                  color: session.isBooked
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(session.date),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 8),
                                Text(session.time),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: session.isBooked
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    session.isBooked ? 'Booked' : 'Available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: session.isBooked
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delete button
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  // Close button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Booking'),
          content: const Text('Are you sure you want to delete this booking? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close confirmation dialog

                final success = await context.read<BookingProvider>().deleteBooking(booking.id);

                if (success) {
                  Navigator.of(context).pop(); // Close detail dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete booking'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
