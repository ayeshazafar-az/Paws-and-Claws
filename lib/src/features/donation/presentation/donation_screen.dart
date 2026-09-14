import 'package:flutter/material.dart';

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
    // Simulate gateway delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You! ♥️'),
          content: Text(
            'Your generous donate of \$${_selectedAmount.toInt()} has been successfully processed!',
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Make a Donation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 80,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Your Support Changes Lives',
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '100% of your donation goes directly towards the care and shelter of rescued animals.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Toggle Monthly/One-time
            Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(20),
                selectedColor: Colors.white,
                fillColor: theme.colorScheme.secondary,
                color: theme.primaryColor,
                isSelected: [_isMonthly == false, _isMonthly == true],
                onPressed: (index) {
                  setState(() {
                    _isMonthly = index == 1;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Text('One Time'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Text('Monthly'),
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
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text('\$${amount.toInt()}'),
                  ),
                  selected: isSelected,
                  selectedColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedAmount = amount);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
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
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
