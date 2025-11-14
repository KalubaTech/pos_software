import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/appearance_controller.dart';
import '../../models/client_model.dart';
import '../../utils/colors.dart';

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(controller, isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.filteredCustomers.isEmpty) {
                  return _buildEmptyState(controller, isDark);
                }

                return _buildCustomersList(controller, isDark);
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddCustomerDialog(controller, isDark),
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          icon: Icon(Iconsax.add),
          label: Text('Add Customer'),
        ),
      );
    });
  }

  Widget _buildHeader(CustomerController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getDivider(isDark), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                        .withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${controller.filteredCustomers.length} customers',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: 'Search customers by name, email, or phone...',
              hintStyle: TextStyle(color: AppColors.getTextTertiary(isDark)),
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: AppColors.getTextSecondary(isDark),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.getDivider(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.getDivider(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : Colors.grey[100],
            ),
            onChanged: controller.searchCustomers,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CustomerController controller, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.profile_2user,
            size: 80,
            color: AppColors.getTextTertiary(isDark),
          ),
          SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first customer to get started',
            style: TextStyle(color: AppColors.getTextTertiary(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(CustomerController controller, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: controller.filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = controller.filteredCustomers[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: AppColors.getSurfaceColor(isDark),
          elevation: isDark ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.getDivider(isDark), width: 1),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor:
                  (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withOpacity(isDark ? 0.25 : 0.1),
              child: Text(
                customer.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
            ),
            title: Text(
              customer.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Iconsax.sms,
                      size: 14,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    SizedBox(width: 6),
                    Text(
                      customer.email,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Iconsax.call,
                      size: 14,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    SizedBox(width: 6),
                    Text(
                      customer.phoneNumber,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(
                Iconsax.more,
                color: AppColors.getTextSecondary(isDark),
              ),
              color: AppColors.getSurfaceColor(isDark),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.edit,
                        size: 18,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _showEditCustomerDialog(controller, customer, isDark),
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _showDeleteConfirmation(controller, customer, isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCustomerDialog(CustomerController controller, bool isDark) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Customer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.user,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.sms,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.call,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please fill all fields',
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : Colors.white,
                          colorText: AppColors.getTextPrimary(isDark),
                        );
                        return;
                      }

                      final customer = ClientModel(
                        id: 'c${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        email: emailController.text,
                        phoneNumber: phoneController.text,
                      );

                      await controller.addCustomer(customer);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text('Add Customer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCustomerDialog(
    CustomerController controller,
    ClientModel customer,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final phoneController = TextEditingController(text: customer.phoneNumber);

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Customer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.user,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.sms,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  prefixIcon: Icon(
                    Iconsax.call,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.getDivider(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedCustomer = ClientModel(
                        id: customer.id,
                        name: nameController.text,
                        email: emailController.text,
                        phoneNumber: phoneController.text,
                      );

                      await controller.updateCustomer(updatedCustomer);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    CustomerController controller,
    ClientModel customer,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Text(
          'Delete Customer',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        content: Text(
          'Are you sure you want to delete ${customer.name}?',
          style: TextStyle(color: AppColors.getTextSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getTextSecondary(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteCustomer(customer.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
