import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_strings.dart';

import 'package:Saborly/shared/widgets/custom_text_field.dart';

class SignupNameFields extends StatelessWidget {
  final bool isTablet;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const SignupNameFields({
    super.key,
    required this.isTablet,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: firstNameController,
              labelText: AppStrings.firstName,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterName;
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomTextField(
              controller: lastNameController,
              labelText: AppStrings.lastName,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterName;
                }
                return null;
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          CustomTextField(
            controller: firstNameController,
            labelText: AppStrings.firstName,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterName;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: lastNameController,
            labelText: AppStrings.lastName,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterName;
              }
              return null;
            },
          ),
        ],
      );
    }
  }
}
