
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double budget = 2000000;
    const double spent = 1200000;
    const double progress = spent / budget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anggaran Bulanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(
                Icons.account_balance_outlined,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Rp1.200.000 dari Rp2.000.000',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.primaryLight,
              valueColor: AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '60% digunakan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Sisa Rp800.000',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
