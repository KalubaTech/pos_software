import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../utils/colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController pinController = TextEditingController();
  String enteredPin = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      AppColors.darkSurface,
                      AppColors.darkSurfaceVariant,
                    ]
                  : [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                      AppColors.secondary.withValues(alpha: 0.5),
                    ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      duration: Duration(milliseconds: 800),
                      child: _buildLogo(isDark),
                    ),
                    SizedBox(height: 60),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: _buildLoginCard(isDark),
                    ),
                    SizedBox(height: 24),
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      delay: Duration(milliseconds: 200),
                      child: _buildQuickLoginSection(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLogo(bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.darkPrimary : Colors.black)
                    .withValues(alpha: isDark ? 0.3 : 0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Iconsax.shop,
            size: 80,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Dynamos POS',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Point of Sale System',
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : Colors.white.withValues(alpha: 0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark) {
    return Container(
      constraints: BoxConstraints(maxWidth: 450),
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkSurfaceVariant, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter PIN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Enter your 4-digit PIN to continue',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          _buildPinDisplay(isDark),
          SizedBox(height: 32),
          _buildNumPad(isDark),
        ],
      ),
    );
  }

  Widget _buildPinDisplay(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < enteredPin.length;
        final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isFilled
                  ? primaryColor
                  : (isDark ? AppColors.darkSurfaceVariant : Colors.grey[200]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFilled
                    ? primaryColor
                    : (isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[300]!),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                isFilled ? '●' : '',
                style: TextStyle(
                  fontSize: 32,
                  color: isDark ? AppColors.darkTextPrimary : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumPad(bool isDark) {
    return Column(
      children: [
        _buildNumPadRow(['1', '2', '3'], isDark),
        SizedBox(height: 12),
        _buildNumPadRow(['4', '5', '6'], isDark),
        SizedBox(height: 12),
        _buildNumPadRow(['7', '8', '9'], isDark),
        SizedBox(height: 12),
        _buildNumPadRow(['', '0', 'back'], isDark),
      ],
    );
  }

  Widget _buildNumPadRow(List<String> numbers, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        if (number.isEmpty) return SizedBox(width: 80);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _buildNumPadButton(number, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildNumPadButton(String value, bool isDark) {
    final isBackspace = value == 'back';

    return InkWell(
      onTap: isLoading ? null : () => _handleNumPadTap(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isBackspace
              ? Colors.red.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? AppColors.darkSurfaceVariant : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.getDivider(isDark) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: isBackspace
              ? Icon(Iconsax.back_square, size: 28, color: Colors.red)
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
        ),
      ),
    );
  }

  void _handleNumPadTap(String value) {
    setState(() {
      if (value == 'back') {
        if (enteredPin.isNotEmpty) {
          enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        }
      } else {
        if (enteredPin.length < 4) {
          enteredPin += value;

          if (enteredPin.length == 4) {
            _attemptLogin();
          }
        }
      }
    });
  }

  Future<void> _attemptLogin() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(milliseconds: 500)); // Smooth animation

    final success = await authController.login(enteredPin);

    setState(() {
      isLoading = false;
      if (!success) {
        enteredPin = '';
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid PIN or inactive account'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildQuickLoginSection(bool isDark) {
    return Container(
      constraints: BoxConstraints(maxWidth: 450),
      child: Column(
        children: [
          Text(
            'Quick Login',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Obx(() {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: authController.cashiers
                  .where((c) => c.isActive)
                  .map((cashier) => _buildQuickLoginCard(cashier, isDark))
                  .toList(),
            );
          }),
          SizedBox(height: 16),
          Text(
            'Demo PINs: Admin (1234), John (1111), Sarah (2222), Mike (3333)',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginCard(cashier, bool isDark) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return InkWell(
      onTap: () {
        setState(() {
          enteredPin = cashier.pin;
          _attemptLogin();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: Text(
                cashier.name[0],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              cashier.name.split(' ')[0],
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              cashier.role.name.toUpperCase(),
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}
