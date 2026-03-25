// File: features/menu/screens/privacy_policy_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/shared/widgets/language_selector.dart';
import 'package:Saborly/shared/widgets/ooter.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
              DateTime? _lastPressedAt;

 return PopScope(
      canPop: kIsWeb,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || kIsWeb) return;
        
        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;
          
          // Show toast message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
  AppStrings.get('pressBackAgain'),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.textDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
            ),
          );
          return;
        }
        
        // Exit app
        SystemNavigator.pop();
      },
    child:Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
        SliverAppBar(
  expandedHeight: isDesktop ? 280 : 220,
  floating: false,
  pinned: true,
  backgroundColor: AppColors.primary,
  flexibleSpace: FlexibleSpaceBar(
    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
               Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.privacy_tip_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get('privacy'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.get('privacy_subtitle'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
          // Content
         SliverToBoxAdapter(
  child: FadeTransition(
    opacity: _fadeAnimation,
    child: _ResponsiveLayout(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 48 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 32),
            _buildLastUpdated(),
            const SizedBox(height: 48),
            _buildSection(
              icon: Icons.info_outline,
              titleKey: 'info_collect_title',
              contentKey: 'info_collect_content',
              pointKeys: [
                'info_collect_point1',
                'info_collect_point2',
                'info_collect_point3',
                'info_collect_point4',
                'info_collect_point5',
              ],
            ),
            _buildSection(
              icon: Icons.thumb_up_outlined,
              titleKey: 'use_info_title',
              contentKey: 'use_info_content',
              pointKeys: [
                'use_info_point1',
                'use_info_point2',
                'use_info_point3',
                'use_info_point4',
                'use_info_point5',
                'use_info_point6',
              ],
            ),
            _buildSection(
              icon: Icons.share_outlined,
              titleKey: 'sharing_title',
              contentKey: 'sharing_content',
              pointKeys: [
                'sharing_point1',
                'sharing_point2',
                'sharing_point3',
                'sharing_point4',
              ],
            ),
            _buildSection(
              icon: Icons.security_outlined,
              titleKey: 'security_title',
              contentKey: 'security_content',
              pointKeys: [
                'security_point1',
                'security_point2',
                'security_point3',
                'security_point4',
                'security_point5',
              ],
            ),
            _buildSection(
              icon: Icons.verified_user_outlined,
              titleKey: 'rights_title',
              contentKey: 'rights_content',
              pointKeys: [
                'rights_point1',
                'rights_point2',
                'rights_point3',
                'rights_point4',
                'rights_point5',
                'rights_point6',
              ],
            ),
            _buildSection(
              icon: Icons.cookie_outlined,
              titleKey: 'cookies_title',
              contentKey: 'cookies_content',
              pointKeys: [
                'cookies_point1',
                'cookies_point2',
                'cookies_point3',
                'cookies_point4',
              ],
            ),
            _buildSection(
              icon: Icons.child_care_outlined,
              titleKey: 'children_privacy_title',
              contentKey: 'children_privacy_content',
              pointKeys: [],
            ),
            const SizedBox(height: 48),
            _buildContactCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  ),
),
if (isDesktop)
            SliverToBoxAdapter(
              child: FoodKingFooter(),
            ),
        ],
      ),
    )
  );}
Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child:  Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text(
            AppStrings.get('privacy_intro'),
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF495057),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Row(
      children: [
        Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
        AppStrings.get('last_updated'),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

 Widget _buildSection({
  required IconData icon,
  required String titleKey,
  required String contentKey,
  required List<String> pointKeys,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 32),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppStrings.get(titleKey),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.get(contentKey),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF495057),
            height: 1.7,
          ),
        ),
        if (pointKeys.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...pointKeys.map((key) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.get(key),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF495057),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    ),
  );
}
  Widget _buildContactCard() {
  return Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        const Icon(Icons.support_agent, color: Colors.white, size: 48),
        const SizedBox(height: 16),
        Text(
          AppStrings.get('contact_questions'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.get('contact_support'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildContactButton(
              icon: Icons.email_outlined,
              label: AppStrings.get('contact_email'),
            ),
            _buildContactButton(
              icon: Icons.phone_outlined,
              label: AppStrings.get('contact_phone'),
            ),
          ],
        ),
      ],
    ),
  );
}
  Widget _buildContactButton({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


class _ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const _ResponsiveLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth;
        if (constraints.maxWidth > 1200) {
          maxWidth = 900; // Desktop
        } else if (constraints.maxWidth > 600) {
          maxWidth = 700; // Tablet
        } else {
          maxWidth = double.infinity; // Mobile
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}