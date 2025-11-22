import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/business_service.dart';
import '../../services/firedart_sync_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../utils/colors.dart';
import '../../models/cashier_model.dart';
import '../../constants/zambia_locations.dart';
import '../../constants/business_types.dart';
import '../../widgets/location_picker_widget.dart';
import '../auth/login_view.dart';

class BusinessRegistrationView extends StatefulWidget {
  const BusinessRegistrationView({super.key});

  @override
  State<BusinessRegistrationView> createState() =>
      _BusinessRegistrationViewState();
}

class _BusinessRegistrationViewState extends State<BusinessRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final businessService = Get.put(BusinessService());
  final authController = Get.find<AuthController>();

  // Form controllers
  final businessNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final taxIdController = TextEditingController();
  final websiteController = TextEditingController();

  // Admin user controllers
  final adminNameController = TextEditingController();
  final adminEmailController = TextEditingController();
  final adminPinController = TextEditingController();
  final adminConfirmPinController = TextEditingController();

  // Zambian location selection
  String? selectedProvince;
  String? selectedDistrict;

  // Business type selection
  String? selectedBusinessType;

  // GPS location
  double? businessLatitude;
  double? businessLongitude;
  String locationAddress = '';

  bool isLoading = false;
  int currentStep = 0;

  @override
  void dispose() {
    businessNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    taxIdController.dispose();
    websiteController.dispose();
    adminNameController.dispose();
    adminEmailController.dispose();
    adminPinController.dispose();
    adminConfirmPinController.dispose();
    super.dispose();
  }

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
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.white,
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FadeInDown(
                            duration: Duration(milliseconds: 600),
                            child: _buildStepIndicator(isDark),
                          ),
                          SizedBox(height: 32),
                          FadeInUp(
                            duration: Duration(milliseconds: 600),
                            child: _buildCurrentStepContent(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildNavigationButtons(isDark),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.shop,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Your Business',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete the form to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.grey[700]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: [
        _buildStepCircle(0, 'Business', isDark),
        _buildStepLine(0, isDark),
        _buildStepCircle(1, 'Admin', isDark),
        _buildStepLine(1, isDark),
        _buildStepCircle(2, 'Review', isDark),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isDark) {
    final isActive = currentStep == step;
    final isCompleted = currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                  : (isDark ? AppColors.darkSurfaceVariant : Colors.grey[300]),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? Colors.white
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey[700]!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppColors.darkTextPrimary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step, bool isDark) {
    final isCompleted = currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30),
        color: isCompleted
            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
            : (isDark ? AppColors.darkSurfaceVariant : Colors.grey[300]),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (currentStep) {
      case 0:
        return _buildBusinessInfoStep(isDark);
      case 1:
        return _buildAdminInfoStep(isDark);
      case 2:
        return _buildReviewStep(isDark);
      default:
        return SizedBox();
    }
  }

  Widget _buildBusinessInfoStep(bool isDark) {
    return Card(
      color: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tell us about your business',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[700]!,
              ),
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: businessNameController,
              label: 'Business Name',
              icon: Iconsax.shop,
              isDark: isDark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Business Type dropdown
            _buildDropdownField(
              value: selectedBusinessType,
              label: 'Business Type',
              icon: Iconsax.category,
              isDark: isDark,
              items: BusinessTypes.types,
              onChanged: (value) {
                setState(() {
                  selectedBusinessType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select business type';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email Address',
              icon: Iconsax.sms,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number',
              icon: Iconsax.call,
              isDark: isDark,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: addressController,
              label: 'Business Address',
              icon: Iconsax.location,
              isDark: isDark,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Province dropdown
            _buildDropdownField(
              value: selectedProvince,
              label: 'Province',
              icon: Iconsax.location,
              isDark: isDark,
              items: ZambiaLocations.provinces,
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                  selectedDistrict =
                      null; // Reset district when province changes
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a province';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // District dropdown
            _buildDropdownField(
              value: selectedDistrict,
              label: 'District',
              icon: Iconsax.building,
              isDark: isDark,
              items: selectedProvince != null
                  ? ZambiaLocations.getDistricts(selectedProvince!)
                  : [],
              onChanged: selectedProvince != null
                  ? (value) {
                      setState(() {
                        selectedDistrict = value;
                      });
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a district';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: taxIdController,
              label: 'Tax ID (Optional)',
              icon: Iconsax.document_text,
              isDark: isDark,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: websiteController,
              label: 'Website (Optional)',
              icon: Iconsax.link,
              isDark: isDark,
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 24),

            // Location Picker Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (businessLatitude != null && businessLongitude != null)
                    ? (isDark
                          ? AppColors.darkPrimary.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1))
                    : (isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (businessLatitude != null && businessLongitude != null)
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : (isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey[300]!),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.map,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : Colors.black,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Location (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pin your exact location for easier customer navigation',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (businessLatitude != null &&
                      businessLongitude != null) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.location_tick,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  locationAddress.isEmpty
                                      ? 'Location selected'
                                      : locationAddress,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lat: ${businessLatitude!.toStringAsFixed(6)}, Lng: ${businessLongitude!.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(
                        () => LocationPickerWidget(
                          initialLatitude: businessLatitude,
                          initialLongitude: businessLongitude,
                          onLocationSelected: (lat, lng, address) {
                            setState(() {
                              businessLatitude = lat;
                              businessLongitude = lng;
                              locationAddress = address;
                            });
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      businessLatitude != null && businessLongitude != null
                          ? Iconsax.edit
                          : Iconsax.location,
                    ),
                    label: Text(
                      businessLatitude != null && businessLongitude != null
                          ? 'Change Location'
                          : 'Pick Location on Map',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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

  Widget _buildAdminInfoStep(bool isDark) {
    return Card(
      color: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your admin account to manage the business',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[700]!,
              ),
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: adminNameController,
              label: 'Full Name',
              icon: Iconsax.user,
              isDark: isDark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: adminEmailController,
              label: 'Email Address',
              icon: Iconsax.sms,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: adminPinController,
              label: 'PIN (4 digits)',
              icon: Iconsax.lock,
              isDark: isDark,
              isPassword: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter PIN';
                }
                if (value.length != 4) {
                  return 'PIN must be 4 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: adminConfirmPinController,
              label: 'Confirm PIN',
              icon: Iconsax.lock_1,
              isDark: isDark,
              isPassword: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm PIN';
                }
                if (value != adminPinController.text) {
                  return 'PINs do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You will be the admin of this business with full access to all features.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : Colors.black,
                      ),
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

  Widget _buildReviewStep(bool isDark) {
    return Card(
      color: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review Your Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please review your information before submitting',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey[700]!,
              ),
            ),
            SizedBox(height: 24),
            _buildReviewSection('Business Information', [
              {'label': 'Business Name', 'value': businessNameController.text},
              if (selectedBusinessType != null)
                {'label': 'Business Type', 'value': selectedBusinessType!},
              {'label': 'Email', 'value': emailController.text},
              {'label': 'Phone', 'value': phoneController.text},
              {'label': 'Address', 'value': addressController.text},
              if (selectedProvince != null)
                {'label': 'Province', 'value': selectedProvince!},
              if (selectedDistrict != null)
                {'label': 'District', 'value': selectedDistrict!},
              {'label': 'Country', 'value': ZambiaLocations.country},
              if (businessLatitude != null && businessLongitude != null)
                {
                  'label': 'GPS Location',
                  'value':
                      '${businessLatitude!.toStringAsFixed(6)}, ${businessLongitude!.toStringAsFixed(6)}',
                },
              if (taxIdController.text.isNotEmpty)
                {'label': 'Tax ID', 'value': taxIdController.text},
              if (websiteController.text.isNotEmpty)
                {'label': 'Website', 'value': websiteController.text},
            ], isDark),
            SizedBox(height: 24),
            _buildReviewSection('Admin Account', [
              {'label': 'Full Name', 'value': adminNameController.text},
              {'label': 'Email', 'value': adminEmailController.text},
              {'label': 'PIN', 'value': '••••'},
            ], isDark),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.clock, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Approval',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your business registration will be reviewed by our team. You\'ll be notified once approved.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey[700]!,
                          ),
                        ),
                      ],
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

  Widget _buildReviewSection(
    String title,
    List<Map<String, String>> items,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : Colors.black,
          ),
        ),
        SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    item['label']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : Colors.grey[700]!,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['value']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isPassword = false,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: isPassword,
      maxLength: maxLength,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.darkTextSecondary : Colors.grey[700]!,
        ),
        counterText: '',
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required bool isDark,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.darkTextSecondary : Colors.grey[700]!,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : Colors.black,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) SizedBox(width: 16),
          Expanded(
            flex: currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : (currentStep == 2 ? _submitRegistration : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      currentStep == 2 ? 'Submit Registration' : 'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    } else if (currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() {
      if (currentStep < 2) {
        currentStep++;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Generate business ID first
      final businessId = 'BUS_${DateTime.now().millisecondsSinceEpoch}';

      // Create admin cashier with businessId
      final adminId = 'ADMIN_${DateTime.now().millisecondsSinceEpoch}';
      final adminCashier = CashierModel(
        id: adminId,
        name: adminNameController.text,
        email: adminEmailController.text,
        pin: adminPinController.text,
        role: UserRole.admin,
        createdAt: DateTime.now(),
        isActive: true,
        businessId: businessId, // Associate with business
      );

      // Add to auth controller (this is the first cashier for the business)
      await authController.addCashier(adminCashier, isFirstCashier: true);

      // Store admin cashier info in the business registration for later sync
      final adminCashierData = adminCashier.toJson();

      // Register business with the same businessId
      final business = await businessService.registerBusiness(
        businessId: businessId, // Use pre-generated ID
        name: businessNameController.text,
        businessType: selectedBusinessType,
        email: emailController.text,
        phone: phoneController.text,
        address: addressController.text,
        city: selectedDistrict ?? '',
        country: ZambiaLocations.country,
        latitude: businessLatitude,
        longitude: businessLongitude,
        taxId: taxIdController.text.isEmpty ? null : taxIdController.text,
        website: websiteController.text.isEmpty ? null : websiteController.text,
        adminId: adminId,
        adminCashierData: adminCashierData, // Pass cashier data
      );

      if (business != null) {
        // Settings are already embedded in the business document
        // No need to create separate business_settings subcollection
        print('✅ Business registered with embedded settings');

        // Show success dialog
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Iconsax.tick_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Registration Submitted!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your business has been registered and activated successfully!',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.tick_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your business is ready to use!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You can now login with your admin PIN and start using the system.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.off(() => LoginView()); // Go to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Go to Login'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to register business. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Registration error: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
