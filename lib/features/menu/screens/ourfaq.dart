import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/language_provider_mixin.dart';
import 'package:Saborly/shared/widgets/language_selector.dart';
import 'package:Saborly/shared/widgets/ooter.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen>
    with SingleTickerProviderStateMixin, LanguageProviderMixin<FAQScreen> {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'faq_category_all'; // Fixed initial value

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'faq_category_orders',
      'question': 'faq_order_place_question',
      'answer': 'faq_order_place_answer',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'category': 'faq_category_orders',
      'question': 'faq_order_modify_question',
      'answer': 'faq_order_modify_answer',
      'icon': Icons.edit_outlined,
    },
    {
      'category': 'faq_category_payment',
      'question': 'faq_payment_methods_question',
      'answer': 'faq_payment_methods_answer',
      'icon': Icons.payment_outlined,
    },
    {
      'category': 'faq_category_payment',
      'question': 'faq_payment_security_question',
      'answer': 'faq_payment_security_answer',
      'icon': Icons.lock_outlined,
    },
    {
      'category': 'faq_category_delivery',
      'question': 'faq_delivery_time_question',
      'answer': 'faq_delivery_time_answer',
      'icon': Icons.delivery_dining_outlined,
    },
    {
      'category': 'faq_category_delivery',
      'question': 'faq_delivery_fees_question',
      'answer': 'faq_delivery_fees_answer',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'category': 'faq_category_delivery',
      'question': 'faq_delivery_contactless_question',
      'answer': 'faq_delivery_contactless_answer',
      'icon': Icons.no_meeting_room_outlined,
    },
    {
      'category': 'faq_category_account',
      'question': 'faq_account_track_question',
      'answer': 'faq_account_track_answer',
      'icon': Icons.location_on_outlined,
    },
    {
      'category': 'faq_category_account',
      'question': 'faq_account_incorrect_question',
      'answer': 'faq_account_incorrect_answer',
      'icon': Icons.error_outline,
    },
    {
      'category': 'faq_category_account',
      'question': 'faq_account_dietary_question',
      'answer': 'faq_account_dietary_answer',
      'icon': Icons.restaurant_menu_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_selectedCategory == 'faq_category_all') return _faqs;
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

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
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
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
    child:Directionality(
      textDirection: context.watch<LanguageService>().textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          slivers: [
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
                                Icons.help_outline_rounded,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.get('faq'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.get('faq_subtitle'),
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
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _ResponsiveLayout(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 48 : 24),
                    child: Column(
                      children: [
                        _buildCategoryFilter(),
                        const SizedBox(height: 32),
                        ..._filteredFAQs.asMap().entries.map((entry) => _FAQCard(
                              key: ValueKey(entry.key),
                              questionKey: entry.value['question'],
                              answerKey: entry.value['answer'],
                              icon: entry.value['icon'],
                            )),
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
      ),
    )
  );}
  Widget _buildCategoryFilter() {
    final List<String> _categories = [
      'faq_category_all',
      'faq_category_orders',
      'faq_category_payment',
      'faq_category_delivery',
      'faq_category_account',
    ];
    return Container(
      padding: const EdgeInsets.all(8),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _categories.map((categoryKey) {
          final isSelected = _selectedCategory == categoryKey;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = categoryKey),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppStrings.get(categoryKey),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF495057),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          const Icon(Icons.headset_mic, color: Colors.white, size: 56),
          const SizedBox(height: 20),
          Text(
            AppStrings.get('faq_contact_title'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.get('faq_contact_subtitle'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildContactButton(
                icon: Icons.email_outlined,
                label: AppStrings.get('faq_contact_email'),
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'support@saborly.es',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
              ),
              _buildContactButton(
                icon: Icons.phone_outlined,
                label: AppStrings.get('faq_contact_phone'),
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: '+34932112072',
                  );
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                },
              ),
              _buildContactButton(
                icon: Icons.chat_bubble_outline,
                label: AppStrings.get('faq_contact_chat'),
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(enabled ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(enabled ? 1.0 : 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQCard extends StatefulWidget {
  final String questionKey;
  final String answerKey;
  final IconData icon;

  const _FAQCard({
    Key? key,
    required this.questionKey,
    required this.answerKey,
    required this.icon,
  }) : super(key: key);

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _isExpanded
                ? const Color(0xFFE63946).withOpacity(0.5)
                : const Color(0xFFDEE2E6),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: const Color(0xFFE63946), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.get(widget.questionKey),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2D42),
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFE63946),
                      size: 24,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.get(widget.answerKey),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF495057),
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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