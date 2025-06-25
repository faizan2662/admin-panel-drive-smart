// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/booking_model.dart';
// import '../../providers/booking_provider.dart';
// import '../../utils/theme.dart';
//
// class BookingEditDialog extends StatefulWidget {
//   final BookingModel booking;
//
//   const BookingEditDialog({
//     super.key,
//     required this.booking,
//   });
//
//   @override
//   State<BookingEditDialog> createState() => _BookingEditDialogState();
// }
//
// class _BookingEditDialogState extends State<BookingEditDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _traineeNameController;
//   late TextEditingController _trainerNameController;
//   late TextEditingController _locationController;
//   late TextEditingController _vehicleTypeController;
//   late String _selectedStatus;
//   late String _selectedGender;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _traineeNameController = TextEditingController(text: widget.booking.traineeName ?? '');
//     _trainerNameController = TextEditingController(text: widget.booking.trainerName ?? '');
//     _locationController = TextEditingController(text: widget.booking.location);
//     _vehicleTypeController = TextEditingController(text: widget.booking.vehicleType ?? '');
//     _selectedStatus = widget.booking.status ?? 'pending';
//     _selectedGender = widget.booking.gender;
//   }
//
//   @override
//   void dispose() {
//     _traineeNameController.dispose();
//     _trainerNameController.dispose();
//     _locationController.dispose();
//     _vehicleTypeController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: 600,
//         constraints: const BoxConstraints(maxHeight: 700),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(8),
//                   topRight: Radius.circular(8),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.edit, color: Colors.white),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Edit Booking',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Plan Information (Read-only)
//                       _buildReadOnlySection('Plan Information', [
//                         _buildReadOnlyRow('Plan Name', widget.booking.planData.planName),
//                         _buildReadOnlyRow('Plan Type', widget.booking.planData.planType),
//                         _buildReadOnlyRow('Description', widget.booking.planData.displayText),
//                       ]),
//
//                       const SizedBox(height: 20),
//
//                       // Editable Fields
//                       const Text(
//                         'Participant Information',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       TextFormField(
//                         controller: _traineeNameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Trainee Name',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter trainee name';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       TextFormField(
//                         controller: _trainerNameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Trainer Name',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter trainer name';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       DropdownButtonFormField<String>(
//                         value: _selectedGender,
//                         decoration: const InputDecoration(
//                           labelText: 'Gender',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: 'Male', child: Text('Male')),
//                           DropdownMenuItem(value: 'Female', child: Text('Female')),
//                           DropdownMenuItem(value: 'Other', child: Text('Other')),
//                         ],
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() {
//                               _selectedGender = value;
//                             });
//                           }
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       TextFormField(
//                         controller: _vehicleTypeController,
//                         decoration: const InputDecoration(
//                           labelText: 'Vehicle Type',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       TextFormField(
//                         controller: _locationController,
//                         decoration: const InputDecoration(
//                           labelText: 'Location',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter location';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       DropdownButtonFormField<String>(
//                         value: _selectedStatus,
//                         decoration: const InputDecoration(
//                           labelText: 'Status',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: 'pending', child: Text('Pending')),
//                           DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
//                           DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
//                           DropdownMenuItem(value: 'completed', child: Text('Completed')),
//                         ],
//                         onChanged: (value) {
//                           if (value != null) {
//                             setState(() {
//                               _selectedStatus = value;
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Actions
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text('Cancel'),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _saveChanges,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                         : const Text('Save Changes'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReadOnlySection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey[50],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           child: Column(children: children),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReadOnlyRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(color: Colors.grey[700]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final updates = {
//       'traineeName': _traineeNameController.text.trim(),
//       'trainerName': _trainerNameController.text.trim(),
//       'gender': _selectedGender,
//       'vehicleType': _vehicleTypeController.text.trim(),
//       'location': _locationController.text.trim(),
//       'status': _selectedStatus,
//     };
//
//     final success = await context.read<BookingProvider>().updateBooking(
//       widget.booking.id,
//       updates,
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (success) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Booking updated successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to update booking'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
