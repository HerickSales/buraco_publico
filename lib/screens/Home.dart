import 'package:buraco/components/CustomAppBar.dart';
import 'package:buraco/components/CustomBottomNav.dart';
import 'package:buraco/screens/Login.dart';
import 'package:buraco/screens/alert/AlertListScreen.dart';
import 'package:buraco/services/UserPreferencesService.dart';
import 'package:flutter/material.dart';
import '../services/AlertService.dart';
import 'map/MapScreen.dart';
import 'profile/ProfileScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AlertService _alertService = AlertService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  int _selectedIndex = 0;
  bool _isLoading = true;

  String _title = '';

  String _id = '';
  String _name = '';
  String _email = '';
  String _contact = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, dynamic>? userData = await _preferencesService.getUserData();

      if (userData != null) {
        setState(() {
          _id = userData['id'] ?? 'No ID';
          _name = userData['name'] ?? 'No Name';
          _email = userData['email'] ?? 'No Email';
          _contact = userData['contato'] ?? 'No Contact';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        _title = "Lista";
        return AlertListScreen(userId: _id);
      case 2:
        _title = "Perfil";
        return ProfileScreen(
          id: _id,
          name: _name,
          email: _email,
          contact: _contact,
          isLoading: _isLoading,
        );
      default:
        _title = "Mapa";
        return MapScreen(userId: _id, alertService: _alertService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _title),
      body: _getBody(),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
