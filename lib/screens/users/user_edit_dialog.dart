import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/users_provider.dart';
import '../../utils/theme.dart';

class UserEditDialog extends StatefulWidget {
  final UserModel? user;

  const UserEditDialog({super.key, this.user});

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _cnicController = TextEditingController();
  final _locationController = TextEditingController();
  final _fatherNameController = TextEditingController();

  String _selectedRole = 'trainee';
  String _selectedGender = 'Male';
  String _selectedStatus = 'active';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _cityController.text = widget.user!.city ?? '';
      _cnicController.text = widget.user!.cnic ?? '';
      _locationController.text = widget.user!.currentLocation ?? '';
      _fatherNameController.text = widget.user!.fatherName ?? '';
      _selectedRole = widget.user!.role.toString().split('.').last;
      _selectedGender = widget.user!.gender ?? 'Male';
      _selectedStatus = widget.user!.status.toString().split('.').last;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _cnicController.dispose();
    _locationController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    isEditing ? 'Edit User' : 'Add New User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name and Email
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Role, Gender, Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                DropdownMenuItem(value: 'trainer', child: Text('Trainer')),
                                DropdownMenuItem(value: 'trainee', child: Text('Trainee')),
                                DropdownMenuItem(value: 'organization', child: Text('Organization')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Location Information
                      Text(
                        'Location Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // City and Location
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Current Location',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Personal Information
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CNIC and Father's Name
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cnicController,
                              decoration: const InputDecoration(
                                labelText: 'CNIC',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _fatherNameController,
                              decoration: const InputDecoration(
                                labelText: 'Father\'s Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[600], fontSize: 14),
                                ),
                              ),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(isEditing ? 'Update User' : 'Add User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final isEditing = widget.user != null;

      final userData = <String, dynamic>{
        'name': _nameController.text,
        'email': _emailController.text,
        'userType': _selectedRole,
        'gender': _selectedGender,
      };

      // Add optional fields only if they have values
      if (_cityController.text.isNotEmpty) {
        userData['city'] = _cityController.text;
      }
      if (_cnicController.text.isNotEmpty) {
        userData['cnic'] = _cnicController.text;
      }
      if (_locationController.text.isNotEmpty) {
        userData['currentLocation'] = _locationController.text;
      }
      if (_fatherNameController.text.isNotEmpty) {
        userData['fatherName'] = _fatherNameController.text;
      }

      if (!isEditing) {
        // Add timestamp for new users using FieldValue.serverTimestamp()
        userData['timestamp'] = FieldValue.serverTimestamp();
      }

      if (isEditing) {
        // Update existing user
        await firestore.collection('users').doc(widget.user!.id).update(userData);
      } else {
        // Create new user
        await firestore.collection('users').add(userData);
      }

      // Refresh users list
      if (!mounted) return;
      Provider.of<UsersProvider>(context, listen: false).loadUsers();

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving user: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
