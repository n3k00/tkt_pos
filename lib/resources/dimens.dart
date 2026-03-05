import 'package:flutter/widgets.dart';

/// Central place for spacing, padding, and typography tokens to keep the UI
/// consistent across screens.
class Dimens {
  /// Base 4px grid used everywhere in the app.
  static const double base = 4;

  // Spacing scale (use for margin/spacing between widgets)
  static const double spacingMicro = base * 1.5; // 6
  static const double spacingXXS = base; // 4
  static const double spacingXSPlus = base * 2.5; // 10
  static const double spacingXS = base * 2; // 8
  static const double spacingSM = base * 3; // 12
  static const double spacingMD = base * 4; // 16
  static const double spacingLG = base * 5; // 20
  static const double spacingXL = base * 6; // 24
  static const double spacingXXL = base * 8; // 32
  static const double spacingSection = base * 10; // 40

  // Border radius scale
  static const double radiusXS = base * 2; // 8
  static const double radiusSM = base * 2.5; // 10
  static const double radiusMD = base * 3; // 12
  static const double radiusMDPlus = base * 3.5; // 14
  static const double radiusLG = base * 4; // 16
  static const double radiusXL = base * 5; // 20
  static const double radiusXLPlus = base * 4.5; // 18
  static const double radiusXXL = base * 6; // 24
  static const double radiusXXXL = base * 7.5; // 30
  static const double radiusJumbo = base * 7; // 28
  static const double radiusPill = 999; // effectively pill/fully rounded
  static const double radiusInput = radiusJumbo;
  static const BorderRadius borderRadiusInput =
      BorderRadius.all(Radius.circular(radiusInput));

  // Padding helpers
  static const EdgeInsets paddingScreen =
      EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingLG);
  static const EdgeInsets paddingCard =
      EdgeInsets.all(spacingMD); // default card padding
  static const EdgeInsets paddingList =
      EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingMD);
  static const EdgeInsets paddingSection =
      EdgeInsets.symmetric(vertical: spacingSection, horizontal: spacingXL);

  // Input paddings
  static const EdgeInsets inputPadding16 =
      EdgeInsets.symmetric(horizontal: spacingSM, vertical: spacingMD);
  static const EdgeInsets inputPadding14 =
      EdgeInsets.symmetric(horizontal: spacingSM, vertical: spacingSM + base);
  static const EdgeInsets inputCompact =
      EdgeInsets.symmetric(horizontal: spacingSM, vertical: spacingXS);
  static const EdgeInsets inputPadding = inputPadding16;
  static const EdgeInsets inputPaddingDense = inputPadding14;

  // Margin helpers
  static const EdgeInsets marginCard =
      EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingMD);
  static const EdgeInsets marginSection =
      EdgeInsets.only(top: spacingSection, bottom: spacingSection / 2);

  // Typography scale
  static const double fontSizeCaption = 12;
  static const double fontSizeBody = 14;
  static const double fontSizeBodyLarge = 16;
  static const double fontSizeSubtitle = 18;
  static const double fontSizeTitle = 20;
  static const double fontSizeHeadline = 24;
  static const double fontSizeDisplay = 32;

  // Custom font sizes for special cases (e.g., stats, hero numbers)
  static const double fontSizeHero = 40;
  static const double fontSizeMetric = 48;
  static const double fontSizeStat = 22;

  // DataTable row heights
  static const double tableRowMinHeight = 55;
  static const double tableRowMaxHeight = 55;
}
