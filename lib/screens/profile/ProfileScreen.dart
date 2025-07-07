import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final String contact;
  final bool isLoading;

  const ProfileScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    this.isLoading = false,
  }) : super(key: key);

  Widget _buildProfileItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileItem(label: 'ID', value: id),
          _buildProfileItem(label: 'Name', value: name),
          _buildProfileItem(label: 'Email', value: email),
          _buildProfileItem(label: 'Contact', value: contact),
        ],
      ),
    );
  }
}

