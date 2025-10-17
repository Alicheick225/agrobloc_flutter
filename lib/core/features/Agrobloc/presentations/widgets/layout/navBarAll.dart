import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';

class NavBarAll extends StatelessWidget {
  const NavBarAll({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Changed background to white
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24.r,
                      backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Assuming avatar image
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGreen, width: 2), // Green border for avatar
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  RichText(
                    text: TextSpan(
                      text: 'Hello ',
                      style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.sp), // Changed to green
                      children: [
                        TextSpan(
                          text: 'Bernard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: AppColors.primaryGreen, // Changed to green
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.explore, color: AppColors.primaryGreen, size: 28.sp), // More original search icon
                  SizedBox(width: 20.w),
                  Icon(Icons.mail, color: AppColors.primaryGreen, size: 28.sp), // More original message icon
                  SizedBox(width: 20.w),
                  Icon(Icons.notifications_active, color: AppColors.primaryGreen, size: 28.sp), // More original notifications icon
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }
}




