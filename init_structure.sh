#!/bin/bash

# Ensure we are in a Flutter project root (checks for lib folder)
if [ ! -d "lib" ]; then
  echo "Error: Run this from the root of your Flutter project (where the lib folder is)."
  exit 1
fi

echo "Deploying Attachment App architecture..."

# 1. Clear out the default lib folder
rm -rf lib/*

# 2. Build Core Infrastructure
mkdir -p lib/core/{constants,network,router,theme,utils}
touch lib/core/constants/app_colors.dart
touch lib/core/constants/text_styles.dart
touch lib/core/network/connectivity_wrapper.dart
touch lib/core/network/network_provider.dart
touch lib/core/router/app_router.dart
touch lib/core/theme/app_theme.dart
touch lib/core/utils/validators.dart

# 3. Build Feature Modules (Auth)
mkdir -p lib/features/auth/{presentation,providers,repository}
touch lib/features/auth/presentation/login_screen.dart
touch lib/features/auth/presentation/register_screen.dart
touch lib/features/auth/presentation/phone_screen.dart
touch lib/features/auth/presentation/verify_screen.dart
touch lib/features/auth/presentation/forgot_password_screen.dart
touch lib/features/auth/providers/auth_provider.dart
touch lib/features/auth/repository/auth_repository.dart

# 4. Build Feature Modules (Onboarding)
mkdir -p lib/features/onboarding/{presentation,providers}
touch lib/features/onboarding/presentation/splash_screen.dart
touch lib/features/onboarding/presentation/welcome_screen.dart
touch lib/features/onboarding/presentation/pending_screen.dart
touch lib/features/onboarding/presentation/invite_screen.dart
touch lib/features/onboarding/providers/invite_provider.dart

# 5. Build Feature Modules (Space/Home)
mkdir -p lib/features/space/{presentation,providers,models}
touch lib/features/space/presentation/home_screen.dart
touch lib/features/space/presentation/bottom_nav_wrapper.dart
touch lib/features/space/providers/space_provider.dart
touch lib/features/space/models/space_model.dart

# 6. Build Feature Modules (Chat)
mkdir -p lib/features/chat/{presentation,providers,models}
touch lib/features/chat/presentation/chat_screen.dart
touch lib/features/chat/providers/chat_provider.dart
touch lib/features/chat/models/message_model.dart

# 7. Build Services (Firebase)
mkdir -p lib/services
touch lib/services/firebase_service.dart

# 8. Entry Point
touch lib/main.dart

echo "Directory tree built successfully."
echo "Next steps:"
echo "1. Paste the pubspec.yaml dependencies"
echo "2. Run 'flutter pub get'"
echo "3. Let's start wiring the main.dart and app_router.dart"

