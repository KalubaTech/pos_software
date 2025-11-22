import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/colors.dart';

class DataLoadingScreen extends StatelessWidget {
  final bool isDark;
  final String message;

  const DataLoadingScreen({
    super.key,
    required this.isDark,
    this.message = 'Loading business data...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.getGradientColors(isDark),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo shimmer
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.6),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Loading text
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                // Progress indicator
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Shimmer cards
                _buildShimmerCard(),
                const SizedBox(height: 16),
                _buildShimmerCard(),
                const SizedBox(height: 16),
                _buildShimmerCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.3),
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
