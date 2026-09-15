import 'package:flutter/material.dart';
import '../../../core/supabase_setup.dart';
import '../../chat/presentation/chat_room_screen.dart';

class VolunteerInboxScreen extends StatefulWidget {
  const VolunteerInboxScreen({super.key});

  @override
  State<VolunteerInboxScreen> createState() => _VolunteerInboxScreenState();
}

class _VolunteerInboxScreenState extends State<VolunteerInboxScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchInbox();
  }

  Future<void> _fetchInbox() async {
    try {
      // Fetch all messages globally to extract distinct sender IDs
      // ignoring messages sent BY volunteers (where receiver is not null)
      final res = await SupabaseSetup.client
          .from('messages')
          .select('sender_id, created_at')
          .order('created_at', ascending: false);

      final currentId = SupabaseSetup.client.auth.currentUser?.id;
      final Set<String> uniqueIds = {};
      final List<Map<String, dynamic>> distinctConvos = [];

      for (final msg in res) {
        final sender = msg['sender_id'] as String;
        // Only list Adopters who reached out (don't list ourselves!)
        if (sender != currentId && !uniqueIds.contains(sender)) {
          uniqueIds.add(sender);
          distinctConvos.add({
            'adopter_id': sender,
            'last_message_at': msg['created_at'],
          });
        }
      }

      setState(() {
        _conversations = distinctConvos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading inbox: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support Inbox',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Inbox is completely empty.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final convo = _conversations[index];
                final adopterId = convo['adopter_id'] as String;
                final shortId = adopterId
                    .substring(adopterId.length - 6)
                    .toUpperCase();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: Text(
                      shortId.substring(0, 2),
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Adopter #$shortId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Tap to view and reply to messages',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  tileColor: Colors.white,
                  onTap: () {
                    // Bypass GoRouter to push complex parameters easily and maintain backstack perfectly
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(
                          targetUserId: adopterId,
                          targetUserName: 'Adopter #$shortId',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
