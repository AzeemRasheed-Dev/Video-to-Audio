class AppImages {
  const AppImages._(); // Private constructor taake koi iska instance na banaye

  // 1. Root Paths (DRY Principle - Don't Repeat Yourself)
  static const _images = 'assets/images';
  static const _icons = 'assets/icons';

  // 2. App Branding & Logos
  static const appLogo = '$_images/app_logo.png';
  static const splashLogo = '$_images/splash_logo.png';

  // 3. Placeholders & Illustrations
  static const uploadPlaceholder = '$_images/upload_placeholder.png';
  static const emptyState = '$_images/empty_state.png';

  // 4. Custom Icons
  static const musicNote = '$_icons/music_note.png';
  static const convertIcon = '$_icons/convert_icon.png';
}