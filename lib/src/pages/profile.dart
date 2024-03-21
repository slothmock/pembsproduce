import 'package:flutter/material.dart';
import '../helpers/constants/colors.dart';
import 'login.dart';
import '../widgets/bottom_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();

  var _loading = true;
  late String _email;
  late String _profileImageURL;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data =
          await supabase.from('profiles').select().eq('id', userId).single();
      _nameController.text = (data['full_name'] ?? '') as String;
      _email = (data['email'] ?? '') as String;
      _profileImageURL = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: AppColors.secondaryBackground,
      );
    } catch (error) {
      const SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: Color.fromARGB(220, 27, 11, 11),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final usersName = _nameController.value.text;
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'full_name': usersName,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        const SnackBar(
          content: Text('Successfully updated profile!'),
        );
      }
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: AppColors.secondaryBackground,
      );
    } catch (error) {
      const SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: AppColors.secondaryBackground,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: AppColors.secondaryBackground,
      );
    } catch (error) {
      const SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: AppColors.secondaryBackground,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionDuration: const Duration(seconds: 1),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: a,
            child: c,
          ),
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      bottomNavigationBar: const PPBottomAppBar(index: 2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                Center(child: Image.network(_profileImageURL)),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Your Name'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  initialValue: _email,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loading ? null : _updateProfile,
                  child: Text(_loading ? 'Saving...' : 'Update'),
                ),
                const SizedBox(height: 18),
                TextButton(onPressed: _signOut, child: const Text('Sign Out')),
              ],
            ),
    );
  }
}
