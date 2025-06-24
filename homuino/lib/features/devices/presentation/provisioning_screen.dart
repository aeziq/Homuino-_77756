import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class ProvisioningScreen extends StatefulWidget {
  final String deviceId;
  final bool allowRetry;

  const ProvisioningScreen({
    required this.deviceId,
    this.allowRetry = false,
    Key? key,
  }) : super(key: key);

  @override
  _ProvisioningScreenState createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends State<ProvisioningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isProvisioning = false;
  bool _isScanning = false;
  List<WiFiAccessPoint> _networks = [];
  String? _error;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      await _handlePermissionRequest();
      return;
    }
    setState(() => _permissionsGranted = true);
    await _startScan();
  }

  Future<void> _handlePermissionRequest() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      setState(() {
        _error = 'Location permissions are required to scan WiFi networks';
        _permissionsGranted = false;
      });
      return;
    }
    setState(() => _permissionsGranted = true);
    await _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final result = await WiFiScan.instance.startScan();
      if (result != true) {
        throw Exception('Failed to start WiFi scan');
      }

      final networks = await WiFiScan.instance.getScannedResults();
      setState(() => _networks = networks);
    } catch (e) {
      setState(() => _error = 'Failed to scan networks: ${e.toString()}');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _sendToESP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProvisioning = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get the user's email and UID
      final email = user.email ?? '';
      final uid = user.uid;

      final response = await http.post(
        Uri.parse('http://192.168.4.1/save'),
        body: {
          'ssid': _ssidController.text,
          'password': _passwordController.text,
          'deviceId': widget.deviceId,
          'userEmail': email,
          'userId': uid,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Device configuration failed');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProvisioning = false);
      }
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Step 1: Select your WiFi network',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (!_permissionsGranted)
                _buildPermissionWarning()
              else if (_isScanning)
                _buildScanningIndicator()
              else
                _buildNetworkDropdown(),

              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'WiFi Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your WiFi password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Step 2: Configure Device',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Note: Your phone will temporarily connect to the device\'s WiFi',
                style: TextStyle(color: Colors.grey),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isProvisioning ? null : _sendToESP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProvisioning
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
                    : const Text('Configure Device'),
              ),

              if (widget.allowRetry)
                TextButton(
                  onPressed: _isProvisioning ? null : _sendToESP,
                  child: const Text('Retry Configuration'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permissions Required',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Location permissions are needed to scan for WiFi networks.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handlePermissionRequest,
              child: const Text('Grant Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return const Column(
      children: [
        SizedBox(height: 16),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 8),
        Text('Scanning for networks...'),
      ],
    );
  }

  Widget _buildNetworkDropdown() {
    return DropdownButtonFormField<String>(
      items: _networks.map((ap) {
        return DropdownMenuItem(
          value: ap.ssid,
          child: Text(ap.ssid),
        );
      }).toList(),
      onChanged: (ssid) => _ssidController.text = ssid ?? '',
      decoration: const InputDecoration(
        labelText: 'WiFi Network',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.wifi),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a WiFi network';
        }
        return null;
      },
    );
  }
}