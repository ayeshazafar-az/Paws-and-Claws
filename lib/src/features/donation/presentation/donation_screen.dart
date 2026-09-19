import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase_setup.dart';

import '../../../core/models/animal.dart';

class DonationScreen extends ConsumerStatefulWidget {
  final Animal? animal;
  const DonationScreen({super.key, this.animal});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController(text: '50');
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  late double _selectedAmount;
  bool _isProcessing = false;
  bool _isSuccess = false;

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.animal?.adoptionFee.toDouble() ?? 50.0;
    _amountController.text = _selectedAmount.toStringAsFixed(0);
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_amountController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate Secure Stripe API Call
    await Future.delayed(const Duration(seconds: 3));

    try {
      final user = SupabaseSetup.client.auth.currentUser;
      final amount = double.parse(_amountController.text);

      await SupabaseSetup.client.from('donations').insert({
        'user_id': user?.id,
        'amount': amount,
      });

      // Eradicate pet from feed on successful checkout
      if (widget.animal != null) {
        await SupabaseSetup.client
            .from('animals')
            .update({'adoption_status': 'adopted'})
            .eq('id', widget.animal!.id);
      }

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      _successController.forward();

      // Return home after success
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) context.go('/');
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Secure Checkout',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVirtualCreditCard(),
                const SizedBox(height: 32),

                Text(
                  'Select Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey[900],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAmountPresets(),
                const SizedBox(height: 32),

                if (widget.animal != null) ...[
                  Text(
                    'Manual Verification: Transfer To',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beneficiary: ${widget.animal!.sellerName ?? "Verified Rescue Partner"}',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bank Target: SafeX C2C Exchange • Acct: ****8894',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                _buildModernTextField(
                  _amountController,
                  'Custom Amount (\$)',
                  Icons.attach_money,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  _nameController,
                  'Cardholder Name',
                  Icons.person,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  _cardController,
                  'Card Number',
                  Icons.credit_card,
                  isNumber: true,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        _expiryController,
                        'MM/YY',
                        Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModernTextField(
                        _cvvController,
                        'CVV',
                        Icons.security,
                        isNumber: true,
                        obscure: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Processing Securely...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Pay \$${_selectedAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Secured by Stripe Technology',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVirtualCreditCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF333333), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.contactless,
              color: Colors.white.withOpacity(0.5),
              size: 32,
            ),
          ),
          Positioned(
            left: 0,
            top: 20,
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/4/46/Touch_and_go_logo.png',
              width: 50,
              color: Colors.white70,
              errorBuilder: (c, e, s) => const SizedBox.shrink(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '**** **** **** ${_cardController.text.length > 4 ? _cardController.text.substring(_cardController.text.length - 4) : '3947'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARDHOLDER',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nameController.text.isEmpty
                            ? 'Ayesha Z.'
                            : _nameController.text.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _expiryController.text.isEmpty
                            ? '12/28'
                            : _expiryController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.payment, color: Colors.white, size: 36),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPresets() {
    final amounts = widget.animal != null
        ? [widget.animal!.adoptionFee, 50, 100, 500]
        : [10, 50, 100, 500];

    // Remove duplicates if the fee is one of the presets, and take first 4 to fit UI nicely
    final uniqueAmounts = amounts.toSet().toList().take(4).toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: uniqueAmounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAmount = amount.toDouble();
              _amountController.text = amount.toString();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              '\$$amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.blueGrey[800],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: obscure,
      onChanged: (val) =>
          setState(() {}), // trigger rebuild for credit card view
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.blueGrey[400],
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.blueGrey[300]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for your generous donation of \$${_selectedAmount.toStringAsFixed(0)}.',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
