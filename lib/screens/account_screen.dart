// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _loggingOut = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchProfile() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() => _user = jsonDecode(response.body));
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() => _user = {
        'name': prefs.getString('user_name') ?? 'User',
        'email': prefs.getString('user_email') ?? '',
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Edit address popup ──
  Future<void> _editAddress() async {
    final controller =
        TextEditingController(text: _user?['address'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Edit Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This address will be used for laundry pickups',
                style:
                    TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Plot 10, Kulambiro Road, Kampala',
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9F8FF),
                  prefixIcon: const Icon(Icons.location_on_rounded,
                      color: purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFEDE9F6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFEDE9F6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: purple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final address = controller.text.trim();
                    if (address.isEmpty) return;
                    Navigator.pop(context);
                    await _updateProfile({'address': address});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Address',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit phone popup ──
  Future<void> _editPhone() async {
    final controller =
        TextEditingController(text: _user?['phone'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Edit Phone Number',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. 0771 234 567',
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9F8FF),
                  prefixIcon: const Icon(Icons.phone_rounded,
                      color: purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFEDE9F6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFEDE9F6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: purple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final phone = controller.text.trim();
                    if (phone.isEmpty) return;
                    Navigator.pop(context);
                    await _updateProfile({'phone': phone});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Phone',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final updated = jsonDecode(response.body)['user'];
        if (!mounted) return;
        setState(() => _user = updated);
        _showSnack('Profile updated successfully!');
      } else {
        _showSnack('Failed to update profile', isError: true);
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _uploadPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/photo'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        file.bytes!,
        filename: file.name,
      ));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _user?['profile_photo_url'] = data['photo_url'];
        });
        _showSnack('Profile photo updated!');
      } else {
        _showSnack('Failed to upload photo', isError: true);
      }
    } catch (e) {
      _showSnack('Error uploading photo', isError: true);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E))),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _loggingOut = true);

    try {
      final token = await _getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/onboarding', (route) => false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : purple,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _user?['profile_photo_url'] as String?;
    final address = _user?['address'] as String?;
    final phone = _user?['phone'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/orders');
          if (index == 2) Navigator.pushNamed(context, '/schedule');
          if (index == 3) Navigator.pushNamed(context, '/notifications');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Account'),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: purple))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── HEADER ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6B21A8),
                            Color(0xFF8B5CF6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          // ── Avatar with upload button ──
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: _uploadPhoto,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color.fromRGBO(
                                            255, 255, 255, 0.4),
                                        width: 2),
                                    image: photoUrl != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(photoUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: const Color.fromRGBO(
                                        255, 255, 255, 0.2),
                                  ),
                                  child: photoUrl == null
                                      ? Center(
                                          child: _uploadingPhoto
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2)
                                              : Text(
                                                  _initials(
                                                      _user?['name']),
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        )
                                      : _uploadingPhoto
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ))
                                          : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _uploadPhoto,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFFEDE9F6),
                                          width: 1),
                                    ),
                                    child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 14,
                                        color: purple),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _user?['name'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color:
                                  Color.fromRGBO(255, 255, 255, 0.75),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(
                                  255, 255, 255, 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (_user?['role'] as String? ?? 'customer')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── PROFILE INFO ──
                          _sectionLabel('Account Information'),
                          const SizedBox(height: 10),
                          _infoCard([
                            _infoRow(
                              Icons.person_rounded,
                              'Full Name',
                              _user?['name'] ?? '—',
                            ),
                            _divider(),
                            _infoRow(
                              Icons.email_rounded,
                              'Email',
                              _user?['email'] ?? '—',
                            ),
                            _divider(),
                            // Phone — editable
                            _editableRow(
                              Icons.phone_rounded,
                              'Phone',
                              phone ?? 'Tap to add phone number',
                              phone == null,
                              onTap: _editPhone,
                            ),
                          ]),

                          const SizedBox(height: 16),

                          // ── ADDRESS ──
                          _sectionLabel('Pickup Address'),
                          const SizedBox(height: 10),

                          // Address card — prominent if missing
                          GestureDetector(
                            onTap: _editAddress,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: address == null
                                    ? const Color(0xFFFFFBEB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: address == null
                                      ? const Color(0xFFFDE68A)
                                      : const Color(0xFFEDE9F6),
                                  width: address == null ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: address == null
                                          ? const Color(0xFFFEF3C7)
                                          : lightPurple,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: address == null
                                          ? const Color(0xFFD97706)
                                          : purple,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          address == null
                                              ? 'No address added yet'
                                              : 'Pickup Address',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: address == null
                                                ? const Color(
                                                    0xFFD97706)
                                                : const Color(
                                                    0xFF9CA3AF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          address ??
                                              'Tap here to add your pickup address',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: address == null
                                                ? const Color(
                                                    0xFF92400E)
                                                : const Color(
                                                    0xFF1A1A2E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: address == null
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (address == null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFFDE68A)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      size: 14,
                                      color: Color(0xFFD97706)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Add your address so we can pre-fill it when you schedule a pickup.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // ── QUICK LINKS ──
                          _sectionLabel('My Activity'),
                          const SizedBox(height: 10),
                          _actionTile(
                            icon: Icons.receipt_long_rounded,
                            label: 'My Orders',
                            subtitle: 'View all your laundry orders',
                            onTap: () =>
                                Navigator.pushNamed(context, '/orders'),
                          ),
                          const SizedBox(height: 10),
                          _actionTile(
                            icon: Icons.notifications_rounded,
                            label: 'Notifications',
                            subtitle: 'View your updates and alerts',
                            onTap: () => Navigator.pushNamed(
                                context, '/notifications'),
                          ),
                          const SizedBox(height: 10),
                          _actionTile(
                            icon: Icons.calendar_month_rounded,
                            label: 'Schedule Pickup',
                            subtitle: 'Book a new laundry pickup',
                            onTap: () => Navigator.pushNamed(
                                context, '/schedule'),
                          ),

                          const SizedBox(height: 24),

                          // ── LOGOUT ──
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loggingOut ? null : _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                disabledBackgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: _loggingOut
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout_rounded,
                                            color: Colors.white,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text('Log Out',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Center(
                            child: Text('Protos Laundries v1.0.0',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF))),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
              color: purple, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9F6)),
        boxShadow: [
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: purple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableRow(
    IconData icon,
    String label,
    String value,
    bool isEmpty, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: purple, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF))),
                  Text(value,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isEmpty
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF1A1A2E))),
                ],
              ),
            ),
            const Icon(Icons.edit_rounded,
                size: 14, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color(0xFFF3F4F6),
      );

  Widget _actionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE9F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}