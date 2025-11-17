import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/wallet_controller.dart';
import '../../services/wallet_service.dart';
import '../../utils/colors.dart';

class WithdrawalRequestDialog extends StatefulWidget {
  final WalletController controller;

  const WithdrawalRequestDialog({Key? key, required this.controller})
    : super(key: key);

  @override
  State<WithdrawalRequestDialog> createState() =>
      _WithdrawalRequestDialogState();
}

class _WithdrawalRequestDialogState extends State<WithdrawalRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  // Bank Transfer fields
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController();

  // Mobile Money fields
  final _mobileNumberController = TextEditingController();
  String _selectedMobileNetwork = 'MTN';

  // Cash fields
  final _pickupLocationController = TextEditingController();

  String _withdrawalMethod = 'bank_transfer';
  int _currentStep = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankNameController.dispose();
    _mobileNumberController.dispose();
    _pickupLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Request Withdrawal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Available Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    WalletService.formatCurrency(
                      widget.controller.currentBalance,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step 1: Amount
                      if (_currentStep == 0) _buildAmountStep(isMobile),

                      // Step 2: Method Selection
                      if (_currentStep == 1) _buildMethodStep(isMobile),

                      // Step 3: Account Details
                      if (_currentStep == 2) _buildAccountDetailsStep(isMobile),

                      // Step 4: Review
                      if (_currentStep == 3) _buildReviewStep(isMobile),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () {
                                setState(() {
                                  _currentStep--;
                                });
                              },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(_currentStep == 3 ? 'Submit Request' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Enter Amount',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Withdrawal Amount',
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            helperText: 'Minimum: \$10.00 | Maximum: \$10,000.00',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < 10) {
              return 'Minimum withdrawal is \$10.00';
            }
            if (amount > 10000) {
              return 'Maximum withdrawal is \$10,000.00';
            }
            if (amount > widget.controller.currentBalance) {
              return 'Insufficient balance';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Withdrawal requests are processed within 1-3 business days',
                  style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Select Withdrawal Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMethodCard(
          icon: Icons.account_balance,
          title: 'Bank Transfer',
          description: 'Transfer to your bank account',
          value: 'bank_transfer',
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          icon: Icons.phone_android,
          title: 'Mobile Money',
          description: 'Receive via mobile money',
          value: 'mobile_money',
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          icon: Icons.payments,
          title: 'Cash Pickup',
          description: 'Collect cash at our office',
          value: 'cash',
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
  }) {
    final isSelected = _withdrawalMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _withdrawalMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : Colors.grey)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsStep(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Account Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_withdrawalMethod == 'bank_transfer') ...[
          TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Account Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _accountNameController,
            decoration: InputDecoration(
              labelText: 'Account Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bankNameController,
            decoration: InputDecoration(
              labelText: 'Bank Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter bank name';
              }
              return null;
            },
          ),
        ] else if (_withdrawalMethod == 'mobile_money') ...[
          DropdownButtonFormField<String>(
            value: _selectedMobileNetwork,
            decoration: InputDecoration(
              labelText: 'Mobile Network',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ['MTN', 'Airtel', 'Vodafone']
                .map(
                  (network) =>
                      DropdownMenuItem(value: network, child: Text(network)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMobileNetwork = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
              if (!WalletService.isValidMobileNumber(value)) {
                return 'Please enter a valid mobile number';
              }
              return null;
            },
          ),
        ] else if (_withdrawalMethod == 'cash') ...[
          TextFormField(
            controller: _pickupLocationController,
            decoration: InputDecoration(
              labelText: 'Preferred Pickup Location',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'e.g., Main Branch, Downtown Office',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter pickup location';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(bool isMobile) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Review Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildReviewRow('Amount', WalletService.formatCurrency(amount)),
              const Divider(),
              _buildReviewRow(
                'Method',
                WalletService.getWithdrawalMethodDisplay(_withdrawalMethod),
              ),
              const Divider(),
              if (_withdrawalMethod == 'bank_transfer') ...[
                _buildReviewRow(
                  'Account Number',
                  _accountNumberController.text,
                ),
                _buildReviewRow('Account Name', _accountNameController.text),
                _buildReviewRow('Bank Name', _bankNameController.text),
              ] else if (_withdrawalMethod == 'mobile_money') ...[
                _buildReviewRow('Network', _selectedMobileNetwork),
                _buildReviewRow('Mobile Number', _mobileNumberController.text),
              ] else if (_withdrawalMethod == 'cash') ...[
                _buildReviewRow(
                  'Pickup Location',
                  _pickupLocationController.text,
                ),
              ],
              if (_notesController.text.isNotEmpty) ...[
                const Divider(),
                _buildReviewRow('Notes', _notesController.text),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your request will be reviewed and processed within 1-3 business days',
                  style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      // Validate amount
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 1) {
      // Method selected, move to account details
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 2) {
      // Validate account details
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 3) {
      // Submit request
      _submitRequest();
    }
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isProcessing = true;
    });

    final amount = double.parse(_amountController.text);
    Map<String, dynamic> accountDetails = {};

    if (_withdrawalMethod == 'bank_transfer') {
      accountDetails = {
        'account_number': _accountNumberController.text,
        'account_name': _accountNameController.text,
        'bank_name': _bankNameController.text,
      };
    } else if (_withdrawalMethod == 'mobile_money') {
      accountDetails = {
        'network': _selectedMobileNetwork,
        'mobile_number': _mobileNumberController.text,
      };
    } else if (_withdrawalMethod == 'cash') {
      accountDetails = {'pickup_location': _pickupLocationController.text};
    }

    final success = await widget.controller.requestWithdrawal(
      amount: amount,
      withdrawalMethod: _withdrawalMethod,
      accountDetails: accountDetails,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
