import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datetime_picker;
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _displayNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _tournamentExperienceController;

  String _experienceLevel = '';
  String _paintingSkill = 'Beginner';
  String _buildingSkill = 'Beginner';
  Map<String, dynamic>? userData;

  List<String> _paintingSkills = ['Beginner', 'Intermediate', 'Advanced', 'Master'];
  List<String> _buildingSkills = ['Beginner', 'Intermediate', 'Advanced', 'Master'];

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _birthDateController = TextEditingController();
    _tournamentExperienceController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          userData = doc.data() as Map<String, dynamic>;

          setState(() {
            _displayNameController.text = userData!['displayName'] ?? '';
            _birthDateController.text = userData!['birthDate'] != null
                ? DateFormat('yyyy-MM-dd').format(userData!['birthDate'].toDate())
                : '';
            _tournamentExperienceController.text = userData!['tournamentExperience'].toString();
            _paintingSkill = userData!['paintingSkill'] ?? 'Beginner';
            _buildingSkill = userData!['miniatureBuildingSkills'] ?? 'Beginner';

            final registrationDate = userData!['createdAt']?.toDate();
            _experienceLevel = _calculateExperienceLevel(registrationDate);
          });
        }
      });
    }
  }

  String _calculateExperienceLevel(DateTime? registrationDate) {
    if (registrationDate == null) return 'Unknown';
    final yearsSinceRegistration = DateTime.now().difference(registrationDate).inDays ~/ 365;
    if (yearsSinceRegistration < 1) return 'Beginner';
    if (yearsSinceRegistration < 2) return 'Apprentice';
    if (yearsSinceRegistration < 3) return 'Experienced';
    return 'Master';
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      int tournamentExperience = int.tryParse(_tournamentExperienceController.text) ?? 0;
      if (tournamentExperience < 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Tournament experience must be greater than 0')));
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'displayName': _displayNameController.text,
        'birthDate': DateTime.parse(_birthDateController.text),
        'paintingSkill': _paintingSkill,
        'miniatureBuildingSkills': _buildingSkill,
        'tournamentExperience': tournamentExperience,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Profile data updated')));
    }
  }

  Future<void> _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Account deleted')));
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/auth_screen');
  }

  void _selectBirthDate() {
    datetime_picker.DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2000, 1, 1),
        maxTime: DateTime.now(), onConfirm: (date) {
          setState(() {
            _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
          });
        }, currentTime: DateTime.now(), locale: datetime_picker.LocaleType.en);
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[200]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Editable fields
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Username', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _birthDateController,
              readOnly: true,
              onTap: _selectBirthDate,
              decoration: const InputDecoration(labelText: 'Birth Date', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _paintingSkill,
              items: _paintingSkills.map((String skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Painting Skills', filled: true, fillColor: Colors.white),
              onChanged: (value) {
                setState(() {
                  _paintingSkill = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _buildingSkill,
              items: _buildingSkills.map((String skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Building Skills', filled: true, fillColor: Colors.white),
              onChanged: (value) {
                setState(() {
                  _buildingSkill = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tournamentExperienceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tournament Experience (years)', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),

            // Read-only fields
            _buildInfoTile('Favorites Count: ${userData?['favorites']?.length ?? 0}', Colors.green),
            const SizedBox(height: 10),
            _buildInfoTile('Total Sets Value: ${userData?['totalSetsValue'] ?? 0}', Colors.orange),
            const SizedBox(height: 10),
            _buildInfoTile('Favorite Universe: ${userData?['favoriteUniverse'] ?? 'N/A'}', Colors.lightBlue),
            const SizedBox(height: 10),
            _buildInfoTile('Favorite Faction: ${userData?['mainFaction'] ?? 'N/A'}', Colors.deepOrange),
            const SizedBox(height: 10),
            _buildInfoTile('Experience Level: $_experienceLevel', Colors.purple),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteAccount,
              child: const Text('Delete Account'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 16),
        ),
      ),
    );
  }
}