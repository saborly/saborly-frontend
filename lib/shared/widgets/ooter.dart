import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodKingFooter extends StatelessWidget {
  const FoodKingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
  return Consumer<LanguageService>(
      builder: (context, languageService, _) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A1611), Color(0xFF4A2015)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Main Content
          Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 48 : (isTablet ? 40 : 32),
              horizontal: isDesktop ? 60 : (isTablet ? 40 : 24),
            ),
            child: isDesktop
                ? _buildDesktopLayout(context)
                : isTablet
                    ? _buildTabletLayout(context)
                    : _buildMobileLayout(context),
          ),

          // Bottom Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: isDesktop ? 60 : (isTablet ? 40 : 24),
              ),
              child: isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCopyright(),
                        _buildPaymentMethods(),
                      ],
                    )
                  : Column(
                      children: [
                        _buildCopyright(),
                        const SizedBox(height: 16),
                        _buildPaymentMethods(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
   }); }


  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBrandSection(context)),
        const SizedBox(width: 60),
        Expanded(child: _buildQuickLinks(context)),
        const SizedBox(width: 40),
        Expanded(child: _buildResourcesLinks(context)),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: _buildContactSection(context)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildBrandSection(context)),
            const SizedBox(width: 40),
            Expanded(child: _buildQuickLinks(context)),
            const SizedBox(width: 40),
            Expanded(child: _buildResourcesLinks(context)),
          ],
        ),
        const SizedBox(height: 40),
        _buildContactSection(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(context),
        const SizedBox(height: 32),
        _buildQuickLinks(context),
        const SizedBox(height: 28),
        _buildResourcesLinks(context),
        const SizedBox(height: 32),
        _buildContactSection(context),
      ],
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Image.asset(
          'assets/images/logo3.png',
          width: isDesktop ? 70 : 60,
          height: isDesktop ? 70 : 60,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          AppStrings.get('brandDescription'),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),

        // Social Icons
        Row(
          children: [
            _buildSocialButton(
              Icons.facebook_rounded,
              'https://www.facebook.com/SaborlyBurger/',
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              Icons.camera_alt_rounded,
              'https://www.instagram.com/saborly.es/?igsh=eDg0a2FvZ2Zqbmg%3D&utm_source=qr#',
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              Icons.email_rounded,
              'mailto:info@saborly.es',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.secondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return _buildFooterSection(
      context,
      AppStrings.get('quickLinks'),
      [
        AppStrings.get('aboutUs'),
        AppStrings.get('ourMenu'),
        AppStrings.get('profile'),
        AppStrings.get('cart'),
      ],
    );
  }

  Widget _buildResourcesLinks(BuildContext context) {
    return _buildFooterSection(
      context,
      AppStrings.get('resources'),
      [
        AppStrings.get('contactUs'),
        AppStrings.get('helpAndSupport'),
        AppStrings.get('privacyPolicy'),
        AppStrings.get('faq'),
      ],
    );
  }

  Widget _buildFooterSection(
    BuildContext context,
    String title,
    List<String> links,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map((link) => _buildFooterLink(context, link)),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text) {
    final linkDestinations = {
      AppStrings.get('aboutUs'): AppRoutes.about,
      AppStrings.get('ourMenu'): AppRoutes.menu,
      AppStrings.get('profile'): AppRoutes.profile,
      AppStrings.get('cart'): AppRoutes.cart,
      AppStrings.get('contactUs'): 'mailto:info@saborly.es',
      AppStrings.get('helpAndSupport'): AppRoutes.contact,
      AppStrings.get('privacyPolicy'): AppRoutes.privacy,
      AppStrings.get('faq'): AppRoutes.faq,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            final destination = linkDestinations[text];
            if (destination != null) {
              if (destination.startsWith('http') ||
                  destination.startsWith('mailto') ||
                  destination.startsWith('tel')) {
                _launchURL(destination);
              } else {
                context.go(destination);
              }
            }
          },
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('stayConnected'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          AppStrings.get('subscribeOffers'),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // Newsletter Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.get('yourEmail'),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Contact Info
        _buildContactItem(
          Icons.email_outlined,
          AppStrings.get('infoEmail'),
          'mailto:${AppStrings.get('infoEmail')}',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.phone_outlined,
          AppStrings.get('34 932112072'),
          'tel:${AppStrings.get('34 932112072')}',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.location_on_outlined,
          AppStrings.get('address'),
          '',
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, String url) {
    return MouseRegion(
      cursor: url.isNotEmpty ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: url.isNotEmpty ? () => _launchURL(url) : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© ${DateTime.now().year} ${AppStrings.get('copyright').replaceAll('© 2025', '').trim()}',
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 13,
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.get('weAccept'),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 12),
        ...[
          AppStrings.get('visa'),
          AppStrings.get('mastercard'),
          AppStrings.get('paypal'),
        ].map(
          (method) => Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }}
