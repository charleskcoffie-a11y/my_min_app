import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_role.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _client = Supabase.instance.client;
  bool _loading = true;
  List<StaffMember> _staff = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _loading = true);
    try {
      final response = await _client.from('staff_members').select();
      final staffList = (response as List<dynamic>)
          .map((row) => StaffMember.fromMap(row as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _staff = staffList);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showAddStaffSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'counselor';

    final sheetContext = context;
    showModalBottomSheet(
      context: sheetContext,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (localContext, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(localContext).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Staff Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                      DropdownMenuItem(value: 'counselor', child: Text('Counselor')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => selectedRole = v); },
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _client.from('staff_members').insert({
                            'name': nameCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'role': selectedRole,
                            'created_at': DateTime.now().toIso8601String(),
                            'is_active': true,
                          });
                          if (!mounted) return;
                          Navigator.pop(localContext);
                          await _loadStaff();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(localContext).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Add Staff'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      floatingActionButton: FloatingActionButton(onPressed: _showAddStaffSheet, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _staff.isEmpty
              ? Center(child: Text('No staff members', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _staff.length,
                  itemBuilder: (_, i) {
                    final member = _staff[i];
                    return Card(
                      child: ListTile(
                        title: Text(member.name),
                        subtitle: Text('${member.email} • ${member.role.name}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () {
                                // Edit dialog
                              },
                            ),
                            PopupMenuItem(
                              child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
                              onTap: () async {
                                try {
                                  await _client.from('staff_members').update({'is_active': false}).eq('id', member.id);
                                  await _loadStaff();
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
