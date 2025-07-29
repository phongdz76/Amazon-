import 'dart:io';
import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/account/services/account_services.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final AccountServices accountServices = AccountServices();
  File? _avatarImage;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  bool _hasInitialized = false; // Add flag to track initialization

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _hasInitialized = true; // Mark as initialized
  }

  void _loadUserData() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh when not initialized or when really necessary
    if (!_hasInitialized) {
      _refreshUserDataIfNeeded();
    }
  }

  void _refreshUserDataIfNeeded() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn && mounted) {
      // Refresh user data from server to get latest info
      bool success = await userProvider.refreshUserData();
      if (success && mounted) {
        // Only update controllers when not editing (i.e., fields are empty or unchanged)
        final user = userProvider.user;
        if (_nameController.text.isEmpty || _nameController.text == user.name) {
          _nameController.text = user.name;
        }
        if (_emailController.text.isEmpty ||
            _emailController.text == user.email) {
          _emailController.text = user.email;
        }
        if (_phoneController.text.isEmpty ||
            _phoneController.text == (user.phone ?? '')) {
          _phoneController.text = user.phone ?? '';
        }
        if (_addressController.text.isEmpty ||
            _addressController.text == user.address) {
          _addressController.text = user.address;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void selectAvatarImage() async {
    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowedExtensions: null,
      );

      if (result != null) {
        File selectedFile = File(result.files.single.path!);

        // Check file size (limit to 5MB)
        int fileSizeBytes = await selectedFile.length();
        double fileSizeMB = fileSizeBytes / (1024 * 1024);

        if (fileSizeMB > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size should be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _avatarImage = selectedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }

  void updateProfile() async {
    // Validate form first
    if (!_profileFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user.token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if any data has changed
    String newName = _nameController.text.trim();
    String newPhone = _phoneController.text.trim();
    String newAddress = _addressController.text.trim();

    bool hasChanges =
        newName != user.name ||
        newPhone != (user.phone ?? '') ||
        newAddress != user.address ||
        _avatarImage != null;

    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to update'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Updating profile with:');
      print('Name: $newName');
      print('Phone: $newPhone');
      print('Address: $newAddress');
      print('Avatar: ${_avatarImage != null ? 'Selected' : 'None'}');

      await accountServices.updateProfile(
        context: context,
        name: newName,
        phone: newPhone,
        address: newAddress,
        avatarFile: _avatarImage,
      );

      // Clear the selected image after successful upload
      if (mounted) {
        setState(() {
          _avatarImage = null;
        });

        // Refresh user data after successful update
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Profile update failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeProvider themeProvider,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: themeProvider.getTextSecondaryColor(context),
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: themeProvider.getTextTertiaryColor(context),
            fontSize: 16,
          ),
          filled: true,
          fillColor: enabled 
              ? themeProvider.getSurfaceVariantColor(context)
              : themeProvider.getSurfaceVariantColor(context).withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.getBorderColor(context),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.getBorderColor(context),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.getErrorColor(context),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.getErrorColor(context),
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.getTextTertiaryColor(context),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Use Consumer to listen user changes but don't rebuild the entire widget
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.getAppBarGradient(context),
                ),
              ),
              title: Text(
                'My Profile',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: IconThemeData(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
              elevation: 0,
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _profileFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          themeProvider.getCardShadow(context),
                        ],
                        border: Border.all(
                          color: themeProvider.getBorderColor(context),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: themeProvider.getSurfaceVariantColor(context),
                                backgroundImage: _avatarImage != null
                                    ? FileImage(_avatarImage!)
                                    : user.avatar != null && user.avatar!.isNotEmpty
                                    ? NetworkImage(user.avatar!)
                                    : null,
                                child: _avatarImage == null &&
                                        (user.avatar == null ||
                                            user.avatar!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: themeProvider.getTextSecondaryColor(context),
                                      )
                                    : null,
                              ),
                              if (_isUploadingAvatar)
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _isUploadingAvatar ? null : selectAvatarImage,
                            icon: Icon(
                              Icons.camera_alt,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text(
                              _isUploadingAvatar
                                  ? 'Selecting...'
                                  : 'Change profile picture',
                              style: TextStyle(
                                color: _isUploadingAvatar 
                                    ? themeProvider.getTextSecondaryColor(context)
                                    : Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form Fields Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          themeProvider.getCardShadow(context),
                        ],
                        border: Border.all(
                          color: themeProvider.getBorderColor(context),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: themeProvider.getHeadingStyle(context, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          
                          // Full Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            themeProvider: themeProvider,
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          
                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Email (Read Only)',
                            themeProvider: themeProvider,
                            enabled: false,
                          ),
                          
                          // Phone Field
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            themeProvider: themeProvider,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                String phone = value.trim();
                                if (phone.length < 10 || phone.length > 15) {
                                  return 'Phone number must be 10-15 digits';
                                }
                                if (!RegExp(r'^[\+]?[0-9\s\-\(\)]+$').hasMatch(phone)) {
                                  return 'Invalid phone number format';
                                }
                              }
                              return null;
                            },
                          ),
                          
                          // Address Field
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            hint: 'Enter your address',
                            themeProvider: themeProvider,
                            enabled: !_isLoading,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Address is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Update Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading
                              ? themeProvider.getTextTertiaryColor(context)
                              : Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Updating...',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Update Profile',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
