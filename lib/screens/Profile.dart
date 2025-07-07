import 'package:buraco/services/UserPreferencesService.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserPreferencesService _preferencesService = UserPreferencesService();

  // Variables to store user data
  String _name = '';
  String _email = '';
  String _contact = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the page initializes
    _fetchUserData();
  }

  // Method to fetch user data
  Future<void> _fetchUserData() async {
    try {
      // Get the entire user data map
      Map<String, dynamic>? userData = await _preferencesService.getUserData();

      // Check if user data exists
      if (userData != null) {
        setState(() {
          // Safely extract data with null checks
          _name = userData['name'] ?? 'No Name';
          _email = userData['email'] ?? 'No Email';
          _contact = userData['contact'] ?? 'No Contact';
          _isLoading = false;
        });
      } else {
        // Handle case where no user data exists
        setState(() {
          _isLoading = false;
        });
        _showNoDataDialog();
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  // Method to show dialog when no data exists
  void _showNoDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Profile Data'),
          content: const Text(
            'No user profile data found. Would you like to create one?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editProfile();
              },
              child: const Text('Create Profile'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to show error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to edit profile
  void _editProfile() {
    // Create a form to edit profile
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Controllers for text fields
        final nameController = TextEditingController(text: _name);
        final emailController = TextEditingController(text: _email);
        final contactController = TextEditingController(text: _contact);

        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save updated profile
                _saveUpdatedProfile(
                  nameController.text,
                  emailController.text,
                  contactController.text,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to save updated profile
  Future<void> _saveUpdatedProfile(
    String name,
    String email,
    String contact,
  ) async {
    try {
      // Create updated user data map
      Map<String, dynamic> updatedUserData = {
        'name': name,
        'email': email,
        'contact': contact,
      };

      // Save updated data
      await _preferencesService.saveUserData(updatedUserData);

      // Refresh the UI with new data
      setState(() {
        _name = name;
        _email = email;
        _contact = contact;
      });

      // Close the dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      // Show error message if saving fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem('Name', _name),
                  _buildProfileItem('Email', _email),
                  _buildProfileItem('Contact', _contact),
                ],
              ),
            ),
    );
  }

  // Helper method to build profile item rows
  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
