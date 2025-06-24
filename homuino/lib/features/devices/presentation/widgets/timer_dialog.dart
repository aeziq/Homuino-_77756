import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homuino/features/devices/data/device_repository.dart';
import 'package:homuino/features/devices/domain/device.dart';

class TimerDialog extends ConsumerStatefulWidget {
  final Device device;
  final String userId;

  const TimerDialog({
    Key? key,
    required this.device,
    required this.userId,
  }) : super(key: key);

  @override
  _TimerDialogState createState() => _TimerDialogState();
}

class _TimerDialogState extends ConsumerState<TimerDialog> {
  late TimeOfDay _selectedTime;
  late bool _isTimerEnabled;
  late String _timerAction;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
    _isTimerEnabled = true;
    _timerAction = 'turn_on';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTimer() async {
    if (!_formKey.currentState!.validate()) return;

    final timerId = 'timer_${DateTime.now().millisecondsSinceEpoch}';
    final timerData = {
      'time': '${_selectedTime.hour}:${_selectedTime.minute}',
      'action': _timerAction,
      'enabled': _isTimerEnabled,
    };

    try {
      // Get current timers
      final currentTimers = widget.device.timers ?? {};
      final updatedTimers = {...currentTimers, timerId: timerData};

      // Update device with new timers
      await ref.read(deviceRepositoryProvider).updateDevice(
        widget.userId,
        widget.device.copyWith(timers: updatedTimers),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save timer: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Timer'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Time'),
                trailing: TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Action:'),
              Row(
                children: [
                  Radio<String>(
                    value: 'turn_on',
                    groupValue: _timerAction,
                    onChanged: (value) {
                      setState(() {
                        _timerAction = value!;
                      });
                    },
                  ),
                  const Text('Turn On'),
                  Radio<String>(
                    value: 'turn_off',
                    groupValue: _timerAction,
                    onChanged: (value) {
                      setState(() {
                        _timerAction = value!;
                      });
                    },
                  ),
                  const Text('Turn Off'),
                ],
              ),
              SwitchListTile(
                title: const Text('Enable Timer'),
                value: _isTimerEnabled,
                onChanged: (value) {
                  setState(() {
                    _isTimerEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTimer,
          child: const Text('Save'),
        ),
      ],
    );
  }
}