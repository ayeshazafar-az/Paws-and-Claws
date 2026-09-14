import 'package:flutter/material.dart';
import '../../../core/supabase_setup.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final List<double> presets = [10, 25, 50, 100];
  double _selectedAmount = 25;
  bool _isMonthly = false;
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final user = SupabaseSetup.client.auth.currentUser;
      if (user != null) {
        // Record the donation in the database to make it fully functional
        await SupabaseSetup.client.from('donations').insert({
          'user_id': user.id,
          'amount': _selectedAmount,
          'type': _isMonthly ? 'monthly' : 'one-time',
        });
      } else {
        throw Exception("You must be logged in to successfully donate.");
      }

      if (mounted) {
        setState(() => _isProcessing = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thank You! ♥️'),
            content: Text(
              'Your generous donation of \$${_selectedAmount.toInt()} has been successfully processed!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // go back
                },
                child: const Text('Return'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
          'Make a Donation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 48,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Support Changes Lives',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '100% of your donation goes directly towards the care and shelter of rescued animals.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Toggle Monthly/One-time
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(16),
                          selectedColor: Colors.white,
                          fillColor: theme.colorScheme.secondary,
                          color: Colors.grey[600],
                          borderWidth: 0,
                          renderBorder: false,
                          isSelected: [_isMonthly == false, _isMonthly == true],
                          onPressed: (index) {
                            setState(() {
                              _isMonthly = index == 1;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ),
                              child: Text(
                                'One Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ),
                              child: Text(
                                'Monthly',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Amount Presets
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: presets.map((amount) {
                          final isSelected = _selectedAmount == amount;
                          return ChoiceChip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Text(
                                '\$${amount.toInt()}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.primaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: theme.primaryColor,
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            showCheckmark: false,
                            onSelected: (selected) {
                              if (selected)
                                setState(() => _selectedAmount = amount);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    shadowColor: theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                  onPressed: _isProcessing ? null : _processPayment,
                  icon: _isProcessing
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.favorite,
                          size: 20,
                          color: Colors.white,
                        ),
                  label: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Donate \$${_selectedAmount.toInt()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
