import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/theme.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedBookings = <String>{};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final filteredBookings = bookingProvider.filteredBookings;

          return Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.book_online,
                          size: isMobile ? 24 : 28,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Bookings Management',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedBookings.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _showBulkDeleteDialog(),
                            icon: const Icon(Icons.delete_sweep),
                            label: Text('Delete Selected (${_selectedBookings.length})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search and Filter Row
                    Row(
                      children: [
                        // Search
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search bookings...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.primaryBlue),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              bookingProvider.setSearchQuery(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: bookingProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredBookings.isEmpty
                    ? _buildEmptyState()
                    : _buildBookingsList(filteredBookings, isMobile),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_online,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookings will appear here when users make training requests',
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

  Widget _buildBookingsList(List<BookingModel> bookings, bool isMobile) {
    return Column(
      children: [
        // Select All Header
        if (bookings.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: (value) {
                    setState(() {
                      _selectAll = value ?? false;
                      if (_selectAll) {
                        _selectedBookings.addAll(bookings.map((b) => b.id));
                      } else {
                        _selectedBookings.clear();
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Select All (${bookings.length} bookings)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedBookings.length} selected',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Bookings List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final isSelected = _selectedBookings.contains(booking.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showBookingDetails(booking),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedBookings.add(booking.id);
                                    } else {
                                      _selectedBookings.remove(booking.id);
                                    }
                                    _selectAll = _selectedBookings.length == bookings.length;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${booking.requestType.replaceAll('_', ' ').toUpperCase()} - ${booking.selectedPlans.join(', ')}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total Amount: Rs.${booking.totalAmount}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusChip(booking.status),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _showDeleteDialog(booking),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Booking',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Booking Details Grid
                          _buildBookingDetailsGrid(booking, isMobile),

                          const SizedBox(height: 16),

                          // Progress and Sessions
                          Row(
                            children: [
                              Expanded(
                                child: _buildProgressCard(booking),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSessionsCard(booking),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Offered Sessions Preview
                          if (booking.offeredSessions.isNotEmpty) ...[
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  'Offered Sessions (${booking.offeredSessions.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: booking.offeredSessions.take(3).map((session) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: session.isBooked
                                        ? Colors.green.withOpacity(0.1)
                                        : AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: session.isBooked
                                            ? Colors.green.withOpacity(0.3)
                                            : AppTheme.primaryBlue.withOpacity(0.3)
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${session.date} at ${session.time}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: session.isBooked ? Colors.green : AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (session.isBooked) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.check_circle,
                                          size: 12,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            if (booking.offeredSessions.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '+${booking.offeredSessions.length - 3} more sessions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsGrid(BookingModel booking, bool isMobile) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        childAspectRatio: isMobile ? 2.5 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        _buildInfoCard('Trainee', booking.traineeName ?? 'N/A', Icons.person),
        _buildInfoCard('Trainer', booking.trainerName ?? 'N/A', Icons.person_pin),
        _buildInfoCard('Booked By', booking.bookedBy, Icons.account_circle),
        _buildInfoCard('Location', booking.trainerLocation ?? booking.location, Icons.location_on),
        _buildInfoCard('Payment', booking.paymentStatus?.toUpperCase() ?? 'PENDING', Icons.payment),
        _buildInfoCard('Sessions', '${booking.sessionCount}', Icons.event),
        _buildInfoCard('Total Lessons', '${booking.totalLessons}', Icons.school),
        _buildInfoCard('Created', _formatTimestamp(booking.createdAt), Icons.access_time),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.progressPercent}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: booking.progressPercent / 100,
            backgroundColor: Colors.blue[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.completedLessons}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ${booking.totalLessons} lessons',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayStatus = status;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        displayStatus = 'ACCEPTED';
        break;
      case 'rejected':
        color = Colors.red;
        displayStatus = 'REJECTED';
        break;
      case 'booking':
      default:
        color = Colors.orange;
        displayStatus = 'BOOKING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => _BookingDetailDialog(booking: booking),
    );
  }

  void _showDeleteDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<BookingProvider>(context, listen: false)
                  .deleteBooking(booking.id);

              if (success) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Bookings'),
        content: Text('Are you sure you want to delete ${_selectedBookings.length} selected bookings? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              int successCount = 0;
              final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

              for (String bookingId in _selectedBookings) {
                final success = await bookingProvider.deleteBooking(bookingId);
                if (success) successCount++;
              }

              setState(() {
                _selectedBookings.clear();
                _selectAll = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$successCount bookings deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM dd, yyyy').format(timestamp);
  }
}

class _BookingDetailDialog extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailDialog({required this.booking});

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
                        _buildInfoRow('Request Type', booking.requestType.replaceAll('_', ' ').toUpperCase()),
                        _buildInfoRow('Status', booking.status.toUpperCase()),
                        _buildInfoRow('Booked By', booking.bookedBy),
                        _buildInfoRow('Total Amount', 'Rs.${booking.totalAmount}'),
                        _buildInfoRow('Payment Status', _getSimplifiedPaymentStatus(booking.paymentStatus)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Participant Information
                    _buildSection(
                      'Participants',
                      [
                        _buildInfoRow('Trainee', booking.traineeName ?? 'N/A'),
                        _buildInfoRow('Trainer', booking.trainerName ?? 'N/A'),
                        _buildInfoRow('Trainer Location', booking.trainerLocation ?? 'N/A'),
                        _buildInfoRow('Location', booking.location),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Progress Information
                    _buildSection(
                      'Progress Details',
                      [
                        _buildInfoRow('Progress', '${booking.progressPercent}%'),
                        _buildInfoRow('Completed Lessons', '${booking.completedLessons}'),
                        _buildInfoRow('Total Lessons', '${booking.totalLessons}'),
                        _buildInfoRow('Session Count', '${booking.sessionCount}'),
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
                              Text(plan.replaceAll('_', ' ').toUpperCase()),
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
                                  session.isBooked ? Icons.check_circle : Icons.schedule,
                                  size: 16,
                                  color: session.isBooked ? Colors.green : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(session.date),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 8),
                                Text(session.time),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: session.isBooked ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    session.isBooked ? 'BOOKED' : 'AVAILABLE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: session.isBooked ? Colors.green : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                            .toList(),
                      ),

                    const SizedBox(height: 20),

                    // Timestamps
                    _buildSection(
                      'Timestamps',
                      [
                        _buildInfoRow('Created At', DateFormat('MMM dd, yyyy at hh:mm a').format(booking.createdAt)),
                        if (booking.acceptedAt != null)
                          _buildInfoRow('Accepted At', DateFormat('MMM dd, yyyy at hh:mm a').format(booking.acceptedAt!)),
                        if (booking.paymentDate != null)
                          _buildInfoRow('Payment Date', DateFormat('MMM dd, yyyy at hh:mm a').format(booking.paymentDate!)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions - Only Delete
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
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

  String _getSimplifiedPaymentStatus(String? paymentStatus) {
    if (paymentStatus == null) return 'Pending';

    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'success':
      case 'successful':
        return 'Paid';
      default:
        return 'Pending';
    }
  }
}
