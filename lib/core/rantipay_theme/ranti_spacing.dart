import 'package:flutter/material.dart';

class RantiSpacing {
  // Base unit: 4px
  static const double space2 = 2.0; // Micro
  static const double space4 = 4.0; // XXS
  static const double space6 = 6.0; // XS
  static const double space8 = 8.0; // XS
  static const double space12 = 12.0; // S
  static const double space16 = 16.0; // M (Default)
  static const double space20 = 20.0; // L
  static const double space24 = 24.0; // XL
  static const double space32 = 32.0; // XXL
  static const double space40 = 40.0; // XXXL
  static const double space48 = 48.0; // Jumbo

  // Horizontal spacing shortcuts
  static const SizedBox horizontalSpaceExtraSmall = SizedBox(width: space4);
  static const SizedBox horizontalSpaceSmall = SizedBox(width: space8);
  static const SizedBox horizontalSpaceMedium = SizedBox(width: space16);
  static const SizedBox horizontalSpaceLarge = SizedBox(width: space24);
  
  // Vertical spacing shortcuts  
  static const SizedBox verticalSpaceExtraSmall = SizedBox(height: space4);
  static const SizedBox verticalSpaceSmall = SizedBox(height: space8);
  static const SizedBox verticalSpaceMedium = SizedBox(height: space16);
  static const SizedBox verticalSpaceLarge = SizedBox(height: space24);

  static const double sm = space8;
  static const double xs = space4;
  static const double xxs = space2;
  static const double s = space12;
  static const double m = space16;
  static const double l = space20;
  static const double xl = space24;
  static const double xxl = space32;
  static const double xxxl = space40;
  static const double md = space48;
  
  // Component Specific
  static const double screenPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double buttonPadding = 12.0;
  static const double inputPadding = 16.0;

  // Heights
  static const double statusBarHeight = 44.0;
  static const double navBarHeight = 90.0;
  static const double buttonHeight = 50.0;
  static const double inputHeight = 56.0;
  static const double cardHeight = 180.0;

  // size
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
  static const double small = 12.0;
}

class RantiLayout {
  static EdgeInsets screenPadding = const EdgeInsets.symmetric(
    horizontal: RantiSpacing.screenPadding,
  );

  static EdgeInsets cardPadding = const EdgeInsets.all(
    RantiSpacing.cardPadding,
  );

  static EdgeInsets sectionPadding = const EdgeInsets.symmetric(
    horizontal: RantiSpacing.screenPadding,
    vertical: RantiSpacing.space24,
  );

  static SizedBox spacer({double height = 16, double width = 16}) {
    return SizedBox(height: height, width: width);
  }
}

class RantiBorderRadius {
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // Additional radius sizes
  static const double radiusSmall = radiusS;
  static const double radiusPill = radiusFull;

  // Component Specific
  static BorderRadius card = BorderRadius.circular(radiusM);
  static BorderRadius button = BorderRadius.circular(radiusM);
  static BorderRadius input = BorderRadius.circular(radiusM);
  static BorderRadius chip = BorderRadius.circular(radiusXL);
  static BorderRadius modal = const BorderRadius.vertical(
    top: Radius.circular(radiusXXL),
  );

  // Additional border radius properties
  static BorderRadius small = BorderRadius.circular(radiusSmall);
  static BorderRadius pill = BorderRadius.circular(radiusPill);
}
