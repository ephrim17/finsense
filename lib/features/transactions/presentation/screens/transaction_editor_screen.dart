import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/finance_defaults.dart';
import '../../../../core/enums/finance_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../profile/presentation/controllers/preferences_providers.dart';
import '../controllers/transaction_providers.dart';

class TransactionEditorScreen extends ConsumerStatefulWidget {
  const TransactionEditorScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  final TransactionType initialType;

  @override
  ConsumerState<TransactionEditorScreen> createState() =>
      _TransactionEditorScreenState();
}

class _TransactionEditorScreenState
    extends ConsumerState<TransactionEditorScreen> {
  final _accountController = TextEditingController(text: 'Main Account');
  final _paymentController = TextEditingController(text: 'Card');
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  late String _selectedCategory;
  String _amountInput = '';

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedCategory = FinanceDefaults.categoriesFor(_type).first;
  }

  @override
  void dispose() {
    _accountController.dispose();
    _paymentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(transactionActionControllerProvider, (
      _,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _closeEditor();
          });
        },
        error: (error, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          });
        },
      );
    });

    final user = ref.watch(currentUserProvider).valueOrNull;
    final currencyCode =
        ref.watch(userPreferencesProvider).valueOrNull?.currencyCode ??
        user?.currencyCode ??
        FinanceDefaults.defaultCurrencyCode;
    final actionState = ref.watch(transactionActionControllerProvider);
    final amount = double.tryParse(_amountInput) ?? 0;
    final amountDisplay = _amountInput.isEmpty
        ? '${AppFormatters.currencySymbol(currencyCode)}0'
        : '${AppFormatters.currencySymbol(currencyCode)}$_amountInput';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FB),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD8C3FF), Color(0xFFF7F3FF)],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  children: [
                    Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: _closeEditor,
                        ),
                        const Expanded(child: SizedBox.shrink()),
                        Expanded(
                          child: Text(
                            _type == TransactionType.expense
                                ? 'Add Expense'
                                : 'Add Income',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F1B2D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 52),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _TypeToggle(
                      selectedType: _type,
                      onChanged: (type) => setState(() {
                        _type = type;
                        _selectedCategory = FinanceDefaults.categoriesFor(
                          _type,
                        ).first;
                      }),
                    ),
                    const SizedBox(height: 42),
                    Text(
                      amountDisplay,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1B2D),
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter amount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: FinanceDefaults.categoriesFor(_type).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = FinanceDefaults.categoriesFor(
                            _type,
                          )[index];
                          return _CategoryChip(
                            label: category,
                            emoji: _categoryEmoji(category),
                            isSelected: category == _selectedCategory,
                            onTap: () => setState(() {
                              _selectedCategory = category;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryInfoButton(
                            icon: Icons.calendar_today_rounded,
                            label: AppFormatters.longDate(_selectedDate),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SecondaryInfoButton(
                            icon: Icons.tune_rounded,
                            label: 'More details',
                            onTap: _showDetailsSheet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.32),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: actionState.isLoading || user == null
                              ? null
                              : () => _saveTransaction(
                                  userId: user.id,
                                  amount: amount,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(62),
                          ),
                          child: Text(
                            actionState.isLoading
                                ? 'Saving...'
                                : _type == TransactionType.expense
                                ? 'Add Expense'
                                : 'Add Income',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _NumericKeypad(
                onDigit: _appendDigit,
                onDecimal: _appendDecimal,
                onBackspace: _removeLastCharacter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _showDetailsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountController,
                decoration: const InputDecoration(labelText: 'Account'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _paymentController,
                decoration: const InputDecoration(labelText: 'Payment method'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _appendDigit(String value) {
    setState(() {
      if (_amountInput == '0') {
        _amountInput = value;
      } else {
        _amountInput += value;
      }
    });
  }

  void _appendDecimal() {
    if (_amountInput.contains('.')) {
      return;
    }
    setState(() {
      _amountInput = _amountInput.isEmpty ? '0.' : '$_amountInput.';
    });
  }

  void _removeLastCharacter() {
    if (_amountInput.isEmpty) {
      return;
    }
    setState(() {
      _amountInput = _amountInput.substring(0, _amountInput.length - 1);
    });
  }

  Future<void> _saveTransaction({
    required String userId,
    required double amount,
  }) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount greater than zero.')),
      );
      return;
    }

    await ref
        .read(transactionActionControllerProvider.notifier)
        .save(
          userId: userId,
          title: _selectedCategory,
          amount: amount,
          categoryName: _selectedCategory,
          accountId: _accountController.text.trim(),
          paymentMethod: _paymentController.text.trim(),
          transactionDate: _selectedDate,
          type: _type,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
  }

  void _closeEditor() {
    if (!mounted) {
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/dashboard');
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'Groceries':
        return '🛍️';
      case 'Travel':
        return '✈️';
      case 'Transport':
        return '🚕';
      case 'Home':
      case 'Rent':
        return '🏠';
      case 'Food & Dining':
        return '🍜';
      case 'Health':
        return '💊';
      case 'Shopping':
        return '🛒';
      case 'Salary':
        return '💼';
      case 'Bonus':
        return '🎉';
      case 'Investment':
        return '📈';
      default:
        return _type == TransactionType.expense ? '•' : '◦';
    }
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.selectedType, required this.onChanged});

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleSegment(
              label: 'Expenses',
              isSelected: selectedType == TransactionType.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _ToggleSegment(
              label: 'Income',
              isSelected: selectedType == TransactionType.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1F1B2D),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F1B2D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryInfoButton extends StatelessWidget {
  const _SecondaryInfoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4B445D),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
        backgroundColor: Colors.white.withValues(alpha: 0.82),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: const Color(0xFF1F1B2D)),
        ),
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ]) ...[
            Row(
              children: row
                  .map(
                    (digit) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: _KeypadButton(
                          label: digit,
                          onTap: () => onDigit(digit),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _KeypadButton(label: '.', onTap: onDecimal),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _KeypadButton(label: '0', onTap: () => onDigit('0')),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _KeypadButton(
                    icon: Icons.backspace_outlined,
                    onTap: onBackspace,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFDFF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E2F1)),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 28, color: const Color(0xFF1F1B2D))
              : Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F1B2D),
                  ),
                ),
        ),
      ),
    );
  }
}
