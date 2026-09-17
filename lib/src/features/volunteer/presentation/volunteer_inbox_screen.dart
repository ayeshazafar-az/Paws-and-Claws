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
      final currentId = SupabaseSetup.client.auth.currentUser?.id;
      if (currentId == null) return;

      // Fetch all messages where user is either sender or receiver
      final res = await SupabaseSetup.client
          .from('messages')
          .select('sender_id, receiver_id, created_at')
          .or('sender_id.eq.$currentId,receiver_id.eq.$currentId')
          .order('created_at', ascending: false);

      final Set<String> uniqueIds = {};
      final List<Map<String, dynamic>> distinctConvos = [];

      for (final msg in res) {
        final sender = msg['sender_id'] as String;
        final receiver = msg['receiver_id'] as String;

        final otherId = sender == currentId ? receiver : sender;

        if (!uniqueIds.contains(otherId)) {
          uniqueIds.add(otherId);
          distinctConvos.add({
            'contact_id': otherId,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        centerTitle: true,
      ),
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
                final contactId = convo['contact_id'] as String;
                final isLegacy =
                    contactId == '00000000-0000-0000-0000-000000000000';

                final shortId = isLegacy
                    ? 'LEGACY'
                    : contactId.substring(contactId.length - 6).toUpperCase();
                final titleName = isLegacy
                    ? 'Legacy Animal Support'
                    : 'User #$shortId';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary.withOpacity(
                      0.1,
                    ),
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  title: Text(
                    titleName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Tap to view conversation',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  tileColor: theme.brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  onTap: () {
                    // Bypass GoRouter to push complex parameters easily and maintain backstack perfectly
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(
                          targetUserId: isLegacy ? '' : contactId,
                          targetUserName: titleName,
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
