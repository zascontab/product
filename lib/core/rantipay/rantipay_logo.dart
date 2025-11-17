//

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rantipay_app/core/rantipay_theme/ranti_colors.dart';
import 'package:rantipay_app/core/rantipay_theme/ranti_spacing.dart';

import '../../features/auth/presentation/components/responsive_layout.dart';
import '../i18n/app_locations.dart';
import '../rantipay_theme/ranti_typography.dart';

/// RantiPay logo
class RantiPayLogo extends StatelessWidget {
  final BoxConstraints constraints;

  const RantiPayLogo({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isMobile = ResponsiveLayout.isMobile(constraints);
    final fontMultiplier = ResponsiveLayout.getFontSizeMultiplier(constraints);

    return SvgPicture.asset(
      'assets/images/rantipay/svg/logo_all_vertical.svg',
      width: isMobile ? 480 : 440,
      height: isMobile ? 180 : 140,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Container(
        width: isMobile ? 480 : 440,
        height: isMobile ? 180 : 140,
        decoration: BoxDecoration(
          color: RantiColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(RantiSpacing.space12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(RantiColors.primary),
          ),
        ),
      ),
      errorBuilder: (context, error, stackTrace) {
        // Fallback to PNG if SVG fails
        return Image.asset(
          'assets/images/rantipay/png/logo_all_vertical.png',
          width: isMobile ? 180 : 220,
          height: isMobile ? 60 : 80,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Ultimate fallback - text logo
            return Container(
              width: isMobile ? 180 : 220,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                color: RantiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RantiSpacing.space12),
              ),
              child: Center(
                child: Text(
                  'RantiPay',
                  style: RantiTextStyles.displayLarge(context).copyWith(
                    color: RantiColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: (isMobile ? 24 : 28) * fontMultiplier,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
