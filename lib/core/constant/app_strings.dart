class AppStrings {
  // Current language (default Spanish)
  static String _currentLanguage = 'es';
  
  // Update language when LanguageService changes
  static void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }
  
  
    static String _getCurrentLanguage() {
    // You'll need to access LanguageService instance
    // This should be set whenever language changes
    return _currentLanguage;
  }
  // Get translation for a key
 static String get(String key) {
    return _translations[_currentLanguage]?[key] ?? 
           _translations['es']![key] ?? 
           key;
  }
  
  // Translation maps for all 4 languages
  static const Map<String, Map<String, String>> _translations = {
    // ==================== ENGLISH ====================
    'en': {
      // App Info
      'appName': 'Saborly',
      'appSlogan': 'Delicious Food Delivered Fast',
        "driverPickup": "Driver PickUp",
      // General
      'search': 'Search',
      'viewAll': 'View All',
      'add': 'Add',
      'remove': 'Remove',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'retry': 'Retry',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'somethingWentWrong': 'Something went wrong',
      'noData': 'No data found',
      'noInternet': 'No internet connection',
      'shop': 'Shop',
      "deliveryNotAvailableNow": "Delivery not available now",
      // Navigation
      'home': 'Home',
      'menu': 'Menu',
      'offers': 'Offers',
      'profile': 'Profile',
      'back': 'Back',
      
      // Authentication
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'signOut': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': "Already have an account?",
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'phoneNumber': 'Phone Number',
      'loginRequired': 'Please log in to continue',
      'loginToContinue': 'Log In to Continue',
      
      // Home
      'ourMenu': 'Our Menu',
      'featuredItems': 'Featured Items',
      'mostPopularItems': 'Most Popular Items',
      'freeDelivery': 'FREE DELIVERY',
      'tryChicken': 'TRY CHICKEN',
      'freeShake': 'FREE SHAKE',
      'coolDown': 'COOL DOWN',
      "canDeliver": "Can Deliver",
      // Categories
      'friendsFamily': 'Friends &\nFamily Combo',
      'highOnCoffee': 'High On\nCoffee Combo',
      'duetCombos': 'Duet Combos',
      'whopper': 'Whopper',
      'veg': 'Vegetarian',
      'nonVeg': 'Non-Vegetarian',
      
      // Cart & Checkout
      'myCart': 'My Cart',
      'checkout': 'Checkout',
      'proceedToCheckout': 'Proceed to Checkout',
      'placeOrder': 'Place Order',
      'addToCart': 'Add to Cart',
      'quantity': 'Quantity',
      'mealSize': 'Meal Size',
      'mediumMeal': 'Medium Meal',
      'largeMeal': 'Large Meal',
      'burgerOnly': 'Burger Only',
      'extras': 'Extras',
      'addons': 'Add-ons',
      'extraCheese': 'Extra Cheese',
      'extraPattyChicken': 'Extra Chicken Patty',
      'specialInstructions': 'Special Instructions',
      'instructionsHint': 'Any notes for the order (Cheese, etc.)',
      'subtotal': 'Subtotal',
      'deliveryFee': 'Delivery Fee',
      'total': 'Total',
      'cartSummary': 'Cart Summary',
      'frequentlyBoughtTogether': 'Frequently Bought Together',
      
      // Delivery & Location
      'delivery': 'Delivery',
      'takeaway': 'Takeaway',
      'selectBranch': 'Select Branch',
      'deliveryAddress': 'Delivery Address',
      'addAddress': 'Add Address',
      'editAddress': 'Edit Address',
      'homeAddress': 'Home',
      'workAddress': 'Work',
      'preferenceTime': 'Preferred Delivery Time',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'now': 'Now',
      'estimatedDelivery': 'Estimated delivery time',
      
      // Payment
      'selectPaymentMethod': 'Select your payment method',
      'paypal': 'PayPal',
      'stripe': 'Stripe',
      'visaCard': 'VISA Card',
      'mastercard': 'Mastercard',
      'cardNumber': 'Card Number',
      'expiresOn': 'Expires on',
      'payNow': 'Pay Now',
      'cancelOrder': 'Cancel',
      'cashOnDelivery': 'Cash on Delivery',
      'paymentMethod': 'Payment Method',
      'paymentStatus': 'Payment Status',
      'unpaid': 'Unpaid',
      'paid': 'Paid',
      
      // Orders
      'orderStatus': 'Order Status',
      'orderDetails': 'Order Details',
      'orderPlaced': 'Order placed',
      'orderConfirmed': 'Order confirmed',
      'preparing': 'Preparing',
      'outForDelivery': 'Out for delivery',
      'ready': 'Ready for pickup',
      'delivered': 'Delivered',
      'getYourOrder': 'Get your order ',
      'orderHistory': 'Order History',
      'reorder': 'Reorder',
      'trackOrder': 'Track Order',
      'orderCompleted':'Order Completed',
            
      // Validation Messages
      'pleaseEnterEmail': 'Please enter your email',
      'pleaseEnterValidEmail': 'Please enter a valid email',
      'pleaseEnterPassword': 'Please enter your password',
      'passwordTooShort': 'Password must be at least 6 characters',
      'passwordsDontMatch': 'Passwords do not match',
      'pleaseEnterName': 'Please enter your name',
      'pleaseEnterPhone': 'Please enter your phone number',
      
      // Success Messages
      'orderPlacedSuccessfully': 'Order placed successfully!',
      'accountCreatedSuccessfully': 'Account created successfully!',
      'profileUpdatedSuccessfully': 'Profile updated successfully!',
      'addressAddedSuccessfully': 'Address added successfully!',
      
      // Error Messages
      'failedToPlaceOrder': 'Failed to place order',
      'failedToLogin': 'Failed to log in',
      'failedToCreateAccount': 'Failed to create account',
      'failedToLoadData': 'Failed to load data',
      'failedToUpdateProfile': 'Failed to update profile',
      
      // Time
      'minutes': 'min',
      'hours': 'hours',
      'am': 'am',
      'pm': 'pm',
      
      // Price
      'currency': '€',
      'free': 'Free',
      
      // Restaurant Info
      'boshundhoraRA': 'Spain',
      'gulshan2': 'Spain',
      'banani': 'Spain',
      'dhanmondi': 'Spain',
      'km': 'km',
      'flat': 'Flat',
      'house': 'House',
      'road': 'Road',

      'specialOffers': 'Special Offers',
    'hotDeals': 'HOT DEALS',
    'exclusiveOffers': 'Exclusive Offers',
    'saveUpTo': 'Save up to 50% on your favorite meals',
    'itemsOnOffer': 'items on offer',
    'noOffersAvailable': 'No Offers Available',
    'checkBackLater': 'Check back later for exciting deals!\nNew offers are added regularly.',
    'browseMenu': 'Browse Menu',
    'featuredItemsTitle': 'Featured Items',
    'popularItemsTitle': 'Popular Items',
    'noFeaturedItems': 'No Featured Items',
    'noPopularItems': 'No Popular Items',
    'checkBackForItems': 'Check back later for items',
    
    'viewYourOrders': 'View your past orders',
    'orderNumber': 'Order #',
    'items': 'items',
    'item': 'item',
    'totalAmount': 'Total Amount',
    'viewDetails': 'View Details',
    'goToMenu': 'Go to menu',
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    
    'readyForPickup': 'Ready for Pickup',
    'collected': 'Collected',
 
    'cancelled': 'Cancelled',
    'refunded': 'Refunded',
    'branch': 'Branch',
    'noOrdersYet': 'No Orders Yet',
    'orderHistoryAppear': 'Your order history will appear here\nonce you place your first order',
    'startOrdering': 'Start Ordering',
    'contactUs': 'Contact Us',
    'sendMessage': 'Send us a Message',
    'fullName': 'Full Name',
    'yourName': 'Your name',
    'phoneOptional': 'Phone (Optional)',
    'subject': 'Subject',
    'subjectOfMessage': 'Subject of message',
    'message': 'Message',
    'writeMessageHere': 'Write your message here...',
  
    'callUs': 'Call Us',
    'visitUs': 'Visit Us',
    'writeUs': 'Write Us',
    'followUs': 'Follow Us',
    'discoverOurOfferings': 'Discover our delicious offerings',
    'allCategories': 'All Categories',
    'noFeaturedItemsFound': 'No Featured Items',
    'noPopularItemsFound': 'No Popular Items',
    'checkBackLaterFor': 'Check back later for',
    
    // Order History
    'loadingYourOrders': 'Loading your orders...',
    'oopsSomethingWrong': 'Oops! Something went wrong',
    'yourOrderHistory': 'Your order history will appear here\nonce you place your first order',
    
    'yesterday': 'Yesterday',
    
    // Offers
    'loadingAmazingOffers': 'Loading amazing offers...',
   
    'saveUpTo50': 'Save up to 50% on your favorite meals',

    'checkBackForDeals': 'Check back later for exciting deals!\nNew offers are added regularly.',
      "pizza": "Pizza",
  "burger": "Burger",
  "pasta": "Pasta",
  "salad": "Salad",
    // Contact
    'sendUsMessage': 'Send us a Message',
    'completeTheForm': 'Complete the form and we\'ll get back to you soon',
   
    'emailAddress': 'Email Address',
 
    'writeYourMessage': 'Write your message here...',
     "yourMessage": "Your Message",
    'pleaseEnterSubject': 'Please enter the subject',
    'pleaseEnterMessage': 'Please enter your message',
    'messageTooShort': 'Message must be at least 10 characters',
    'messageTooLong': 'Message cannot exceed 2000 characters',
      "calculating": "Calculating",

    // Profile
    'accountManagement': 'Account Management',
    'manageYourAccount': 'Manage your account settings and preferences',
    'activityOverview': 'Activity Overview',
    'orders': 'Orders',
    'reviews': 'Reviews',
    'favorites': 'Favorites',
    'points': 'Points',
    'quickActions': 'Quick Actions',
    'downloadData': 'Download Data',
    'helpCenter': 'Help Center',
    'editProfile': 'Edit Profile',
    'accountSettings': 'Account Settings',
    'personalInformation': 'Personal Information',
    'preferences': 'Preferences',
    'notifications': 'Notifications',
    'privacy': 'Privacy',
    'securitySupport': 'Security & Support',
    'changePassword': 'Change Password',
    'helpSupport': 'Help & Support',
    'about': 'About',
    'version': 'Version',
    "changeAddress": "Change Address",
    // Cart
    'emptyCart': 'Your cart is empty',
    'addSomeFood': 'Add some delicious food to get started',

    'anySpecialRequests': 'Any special requests or instructions for your order...',
      "range": "Range",
        "readyIn": "Ready In",
    // Checkout
    'deliveryAvailable': 'Delivery Available',
    'deliveryNotAvailable': 'Delivery Not Available',
    'distance': 'Distance',
    'addressBeyondRange': 'Address is beyond delivery range',
    'pleaseSelectAddress': 'Please select a delivery address',
    'addMoreForFree': 'more for FREE delivery!',
    'noDeliveryAddress': 'No Delivery Address',
    'addDeliveryAddress': 'Add your delivery address to continue',
    'selectAddress': 'Select Address',
    'completeAddressDetails': 'Complete Address Details',
    'savedAddresses': 'Saved Addresses',
    'addYourFirstAddress': 'Add Your First Address',
    'addNewAddress': 'Add New Address',
    'searchAddress': 'Search Address',
    'startTypingAddress': 'Start typing your address...',
    'noAddressesFound': 'No addresses found',
    'tryDifferentSearch': 'Try a different search term',
    'addressType': 'Address Type',

    'office': 'Office',
    'other': 'Other',
    'apartmentNumber': 'Apartment/House Number',
    'apartmentPlaceholder': 'e.g., Apt 4B, Floor 2, Building C',
    'deliveryInstructions': 'Delivery Instructions (Optional)',
    'deliveryInstructionsPlaceholder': 'e.g., Ring the bell, Leave at door',
    'saveAddress': 'Save Address',
    'pleaseEnterApartment': 'Please enter your apartment/house number',
    'pickupLocation': 'Pickup Location',
    'pickupTime': 'Pickup Time',
    
    // Payment
    'pickupOrder': 'Pickup Order',
    'deliveryOrder': 'Delivery Order',
    'payAtShop': 'Pay at Shop',
    'payAtCounter': 'Pay at the counter when you collect your order',
    'choosePaymentType': 'Choose Payment Type',
    'cash': 'Cash',
    'card': 'Card',
    'payWithCash': 'Pay with cash',
    'payWithCard': 'Pay with card',
    'otherOptions': 'Other Options (Coming Soon)',
    'paySecurelyWith': 'Pay securely with',
    'comingSoon': 'Coming Soon',
    'paymentSummary': 'Payment Summary',
    'orderType': 'Order Type',

    'paymentType': 'Payment Type',
    'payAtShopCounter': 'Pay at the shop counter when collecting',
    'payWithCashOnDelivery': 'Pay with cash when your order arrives',
    'payWithCardOnDelivery': 'Pay with card when your order arrives',
    'noneSelected': 'None Selected',
    'shopPayment': 'Shop Payment',
    'deliveryPayment': 'Delivery Payment',
    
    // Menu
    'loadingDeliciousMenu': 'Loading delicious menu...',
    'discoverDelicious': 'Discover our delicious offerings',
    'filters': 'Filters',
    'foodType': 'Food Type',
    'vegetarian': 'Vegetarian',
    'nonVegetarian': 'Non-Vegetarian',
    'popularItems': 'Popular Items',
    'clearAll': 'Clear All',
    'apply': 'Apply',
    'advancedFilters': 'Advanced Filters',
    'chooseDeliveryAddress': 'Choose where to deliver your order',
      'setAsDefault': 'Set as Default',
      'delete': 'Delete',
      'deleteAddress': 'Delete Address',
      'confirmDeleteAddress': 'Are you sure you want to delete this address? This action cannot be undone.',
      'defaultAddressUpdated': 'Default address updated',
      'addressDeletedSuccessfully': 'Address deleted successfully',
   "yourOrderWillBeReady": "Your order will be ready",
      'addressSavedWithDistance': 'Address saved! Distance: {distance}',
      'addressBeyondRangeWithLimit': 'Sorry, this address is beyond our {limit}km delivery range',
      'failedToFetchPlaceDetails': 'Failed to fetch place details',
      'noDescription': 'No description',
      'pleaseSelectDeliveryAddress': 'Please select a delivery address',
      'addressBeyondDeliveryRange': 'Selected address is beyond delivery range',
   
      'cartEmpty': 'Your cart is empty',
      'moreItems': '+{count} more items',
     
      'noOrdersDescription': 'Your order history will appear here\nonce you place your first order',
          'welcomeBack': 'Welcome back! Please enter your credentials.',

      'pickup': 'Pickup',
      'pressBackAgain': 'Press back again to exit',
     
      'securityAndSupport': 'Security & Support',
      'helpAndSupport': 'Help & Support',
  
      'signInPrompt': 'Sign in to access your profile and orders',
      'viewPastOrders': 'View your past orders',
      'updatePassword': 'Update your password',
      'getInTouch': 'Get in touch with us',
      'learnAboutUs': 'Learn more about us',
      'notificationPreferences': 'Notification preferences',
      'getHelpAndSupport': 'Get help and support',
      'appVersion': 'Version 1.0.0',
      'aboutApp': 'About Saborly',
      'appDescription': 'Welcome to Saborly! We deliver delicious food from your favorite restaurants right to your door.',
      'copyright': '© 2025 Saborly. All rights reserved.',
      'companyAddress': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
      'close': 'Close',
      'save': 'Save',
      "restaurantClosed": "Restaurant Closed",
  "restaurantClosedDescription": "Sorry, we're not accepting orders right now",
  "checkOurHours": "Check Our Hours",
  "closingSoon": "Closing Soon",
  "orderBeforeClosing": "Order before we close",
      'areYouSureSignOut': 'Are you sure you want to sign out?',
         'imageNotAvailable': 'Image not available',
      'addedToCart': '{itemName} added to cart',
      'undo': 'Undo',
      'outOfStock': 'out-of-stock',
      'loadingMenu': 'Loading delicious menu...',
      'noCategoriesAvailable': 'No categories available',
      'noFoodItemsAvailable': 'No food items available',
      'discoverOfferings': 'Discover our delicious offerings',
   'appLogo': 'App Logo',
      'noItems': 'No {type} Items',
      'featured': 'Featured',
      'popular': 'Popular',
      
      'aboutUs': 'About Us',
      'cart': 'Cart',
      
      'account': 'Account',

'orderNotFound': 'Order not found',
      'goBack': 'Go Back',

      'callRestaurant': 'Call Restaurant',
      'restaurantAddress': 'Saborly, C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
      'estimatedTime': '40 min',
  
      'paymentFailed': 'Failed',
      'paymentRefunded': 'Refunded',
      'emptyOrderItems': 'Your delicious order items',
      
      'tax': 'Tax:',
  
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dec',
     
      'callError': 'Unable to make a call to 34932112072',
      'callErrorGeneric': 'Error making call: {error}',
      'loadingOffers': 'Loading amazing offers...',
     
      'checkBackLaterOffers': 'Check back later for exciting deals!\nNew offers are added regularly.',
      'addFoodToStart': 'Add some delicious food to get started',
      'specialInstructionsHint': 'Any special requests or instructions for your takeaway order...',
      'orderSummary': 'Order Summary',
      'sizeLabel': 'Size:',
      'extrasLabel': 'Extras:',
      'addonsLabel': 'Addons:',

    
      'payAtShopDescription': 'Pay at the shop when you collect your order',
      'choosePaymentDelivery': 'Choose how you want to pay when delivered',
      
      'otherOptionsComingSoon': 'Other Options (Coming Soon)',
      'paypalDescription': 'Pay securely with PayPal',
      'stripeDescription': 'Pay with credit or debit card',
      'cardDescription': 'Pay with VISA or Mastercard',
  
      'shopPaymentMethod': 'Shop Payment',
      'errorFailedToLoadOrder': 'Error: Failed to load order status',
  
      'unexpectedError': 'Unexpected error. Please try again.',
    
      'businessHours': 'Mon - Sun: 12:00 - 23:00',
      'address': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Spain',
      'infoEmail': 'info@saborly.es',
      'supportEmail': 'soporte@saborly.es',
      // Assuming ContactService returns these static messages
      'formSubmissionSuccess': 'Thank you! Your message has been sent successfully.',
      'formSubmissionError': 'Failed to send message. Please try again.',
      'tagline': 'Delicious food, delivered fast',
      'failedToLoadOffers': 'Failed to load offers',
      'unknownError': 'Unknown error',
      
      'days': '{days} days',
      'offerPlaceholder': 'Offer',
       'brandDescription': 'Exceptional culinary experiences that delight your senses. Join our gastronomic community.',

      // Quick Links
      'quickLinks': 'Quick Links',
      
      'reservations': 'Reservations',
      'gallery': 'Gallery',
      'blog': 'Blog',
      'careers': 'Careers',

      // Resources Links
      'resources': 'Resources',
   
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'cookiePolicy': 'Cookie Policy',
      'faq': 'FAQ',

      // Contact Section
      'stayConnected': 'Stay Connected',
      'subscribeOffers': 'Subscribe for exclusive offers',
      'yourEmail': 'Your email',
      'subscribe': 'Subscribe',
     
      'weAccept': 'We Accept',
      'visa': 'Visa',
      'resetPassword': 'Reset Password',

      
      'enterYourEmail': 'Enter your email',
   
      'verificationCode': 'Verification Code',
      'enter6DigitCode': 'Enter 6-digit code',
      'pleaseEnterCode': 'Please enter the code',
      'codeMustBe6Digits': 'Code must be 6 digits',
      'newPassword': 'New Password',
      'enterNewPassword': 'Enter new password',
      'passwordMinLength': 'Password must be at least 6 characters',
      'reEnterNewPassword': 'Re-enter new password',
      'pleaseConfirmPassword': 'Please confirm your password',
      'passwordsDoNotMatch': 'Passwords do not match',
      'backToLogin': 'Back to Login',

      // SnackBar Messages
      'resetCodeSent': 'Reset code sent to your email',
      'failedToSendResetCode': 'Failed to send reset code',
      'invalid6DigitCode': 'Please enter a valid 6-digit code',
      'codeVerified': 'Code verified successfully',
      'invalidOrExpiredCode': 'Invalid or expired code',
      'passwordResetSuccess': 'Password reset successful!',
      'failedToResetPassword': 'Failed to reset password',
      'newCodeSent': 'New code sent to your email',
      'failedToSendCode': 'Failed to send code',

      // Titles
      'createNewPassword': 'Create New Password',
      'verifyCode': 'Verify Code',

      // Subtitles
      'enterNewPasswordSubtitle': 'Please enter your new password',
      'enterCodeSubtitle': 'Enter the 6-digit code sent to {email}',
      'enterEmailSubtitle': 'Enter your email to receive a reset code',

      // Button Texts
      'resetPasswordButton': 'Reset Password',
      'verifyCodeButton': 'Verify Code',
      'sendResetCode': 'Send Reset Code',
      'resendCodeCountdown': 'Resend code in {seconds}s',
      'resendCode': 'Resend Code',
     'allSet': 'All Set!',
      'passwordUpdatedDescription': 'Your password has been successfully updated. You can now sign in with your new password.',
      'newPasswordRequirements': 'Your new password must be different from the previous one and meet our security requirements.',
  "frequentlyAskedQuestions": "Frequently Asked Questions",
      // Password Requirements
      'passwordMinLength8': 'At least 8 characters long',
      'passwordUpperLower': 'Contains uppercase and lowercase letters',
      'passwordNumber': 'Includes at least one number',
      'passwordSpecialChar': 'Has at least one special character',

      // Form Header and Header
      'passwordUpdated': 'Password Updated!',
      'passwordChanged': 'Your password has been successfully changed.',
      'createStrongPassword': 'Create a strong new password for your account.',

     
      'passwordMinLength8Error': 'Password must be at least 8 characters',
      'passwordSecurityError': 'Password must meet security requirements',

      // Form

      // Success Content
      'passwordResetSuccessDescription': 'Your password has been updated successfully. You can now sign in with your new password.',
      'passwordSecurityTip': 'Keep your password secure and don\'t share it with anyone.',

      // Sign In Button
      'signInNow': 'Sign In Now',

      // SnackBar Messages
      'passwordUpdatedSuccess': 'Password updated successfully!',
      'passwordResetFailed': 'Failed to reset password. Please try again.',
  "yourPhone": "Your Phone",
  "yourSubject": "Your Subject",
      
      // AppBar and Web Header
      'secureAccount': 'Keep your account secure with a strong password',

      // Password Card
      'currentPassword': 'Current Password',
      'enterCurrentPassword': 'Enter current password',
      'pleaseEnterCurrentPassword': 'Please enter your current password',
      'pleaseEnterNewPassword': 'Please enter a new password',
      'passwordMinLength6': 'Password must be at least 6 characters',
      'newPasswordDifferent': 'New password must be different from current password',
      'pleaseConfirmNewPassword': 'Please confirm your new password',

      // Security Tips
      'passwordRequirements': 'Password Requirements',
      'passwordMinLength6Tip': 'At least 6 characters long',
      'passwordNumbersSpecial': 'Add numbers and special characters',
      'avoidCommonWords': 'Avoid common words or patterns',

      // Button
      'changePasswordButton': 'Change Password',

      // SnackBar Messages
      'passwordChangedSuccess': 'Password changed successfully',
      'passwordChangeFailed': 'Failed to change password',
      // Header
      'verifyYourEmail': 'Verify Your Email',
      'sentVerificationCode': 'We\'ve sent a verification code to',

      // Timer
      'codeExpired': 'Code expired',
      'codeExpiresIn': 'Code expires in {time}',

      // Resend Button
      'didntReceiveCode': 'Didn\'t receive the code? ',
      'resend': 'Resend',

      // Button
      'verifyEmail': 'Verify Email',

      // SnackBar Messages
      'emailVerifiedSuccess': 'Email verified successfully!',
      'invalidOrExpiredOTP': 'Invalid or expired OTP. Please try again.',
  'joinApp': 'Join Saborly',
      'createAccountDescription': 'Create your account and start your journey with us. Experience the best shopping platform designed for you.',
 "startYourCulinaryJourney": "Start Your Culinary Journey",
  "searchFoodDescription": "Search for your favorite dishes, cuisines, or ingredients to discover amazing food options",

      // Feature List
      'secureCheckout': 'Secure and fast checkout',
      'personalizedRecommendations': 'Personalized recommendations',
      'exclusiveBenefits': 'Exclusive member benefits',
      'customerSupport': '24/7 customer support',

      // Form Header and Header
      'createAccount': 'Create Account',
      'fillInDetails': 'Fill in your details to get started',
      'signUpToStart': 'Sign up to get started with Saborly.',

      // SnackBar Messages
      'verificationCodeSent': 'Verification code sent! Please check your email.',
      'accountCreatedSuccess': 'Account created successfully!',


      // Hero Section
      'welcomeToApp': 'Welcome to Saborly',
      'bestFastFoodDestination': 'Your destination for the best fast food',

      // Story Section
      'ourStory': 'Our Story',
      'storyDescription': 'Saborlywas born from a passion for delivering delicious, high-quality food. From our beginnings, we have been committed to serving the best dishes, prepared with fresh ingredients and authentic recipes. Every day, we strive to exceed our customers’ expectations and create memorable culinary experiences.',

      // Values Section
      'ourValues': 'Our Values',
      'quality': 'Quality',
      'qualityDescription': 'Fresh, high-quality ingredients',
      'speed': 'Speed',
      'speedDescription': 'Fast service without compromising quality',
      'passion': 'Passion',
      'passionDescription': 'Love for what we do in every dish',
  "orderProgress": "Order Progress",
      // Mission Section
      'ourMission': 'Our Mission',
      'missionDescription': 'To make every meal a special experience, offering authentic flavors and exceptional service that exceeds our customers’ expectations.',
   "paymentInfo": "Payment Info",

     "offerPrice": "Offer Price",
  "startingFrom": "Starting from",


      'privacy_subtitle': 'Your privacy is our priority',
      'privacy_intro': 'At Saborly, we are committed to protecting your privacy and ensuring the security of your personal information. This policy explains how we collect, use, and safeguard your data.',
      'last_updated': 'Last updated: October 18, 2025',
      'info_collect_title': 'Information We Collect',
      'info_collect_content': 'We collect information you provide directly to us when you create an account, place an order, or communicate with us.',
      'info_collect_point1': 'Personal details (name, email, phone number)',
      'info_collect_point2': 'Delivery address and location data',
      'info_collect_point3': 'Payment information (securely encrypted)',
      'info_collect_point4': 'Order history and preferences',
      'info_collect_point5': 'Device and usage information',
      'use_info_title': 'How We Use Your Information',
      'use_info_content': 'We use the information we collect to provide you with the best possible service.',
      'use_info_point1': 'Process and fulfill your orders',
      'use_info_point2': 'Send order confirmations and updates',
      'use_info_point3': 'Provide customer support',
      'use_info_point4': 'Improve our services and user experience',
      'use_info_point5': 'Send promotional offers (with your consent)',
      'use_info_point6': 'Prevent fraud and ensure security',
      'sharing_title': 'Information Sharing & Disclosure',
      'sharing_content': 'We respect your privacy and do not sell your personal information.',
      'sharing_point1': 'Service providers (payment processors, delivery partners)',
      'sharing_point2': 'Legal requirements and law enforcement',
      'sharing_point3': 'Business transfers (mergers, acquisitions)',
      'sharing_point4': 'With your explicit consent',
      'security_title': 'Data Security',
      'security_content': 'We implement industry-standard security measures to protect your information.',
      'security_point1': 'SSL/TLS encryption for data transmission',
      'security_point2': 'Secure payment processing (PCI DSS compliant)',
      'security_point3': 'Regular security audits and updates',
      'security_point4': 'Access controls and authentication',
      'security_point5': 'Data backup and recovery systems',
      'rights_title': 'Your Rights',
      'rights_content': 'You have control over your personal information.',
      'rights_point1': 'Access your personal data',
      'rights_point2': 'Correct inaccurate information',
      'rights_point3': 'Request data deletion',
      'rights_point4': 'Object to processing',
      'rights_point5': 'Data portability',
      'rights_point6': 'Withdraw consent at any time',
      'cookies_title': 'Cookies & Tracking',
      'cookies_content': 'We use cookies to enhance your experience and analyze usage patterns.',
      'cookies_point1': 'Essential cookies (required for functionality)',
      'cookies_point2': 'Performance cookies (analytics)',
      'cookies_point3': 'Functional cookies (preferences)',
      'cookies_point4': 'Marketing cookies (with consent)',
      'children_privacy_title': 'Children\'s Privacy',
      'children_privacy_content': 'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children.',
      'contact_questions': 'Questions About Your Privacy?',
      'contact_support': 'Our team is here to help you understand how we protect your data',
      'contact_email': 'support@saborly.es',
      'contact_phone': '+34 932 112 072',

      // FAQScreen
      'faq_subtitle': 'Find answers to common questions',
      'faq_category_all': 'All',
      'faq_category_orders': 'Orders',
      'faq_category_payment': 'Payment',
      'faq_category_delivery': 'Delivery',
      'faq_category_account': 'Account',
      'faq_contact_title': 'Still have questions?',
      'faq_contact_subtitle': 'Our support team is available 24/7 to assist you',
      'faq_contact_email': 'support@saborly.es',
      'faq_contact_phone': '+34 932 112 072',
      'faq_contact_chat': 'Live Chat (Coming Soon)',
      'faq_order_place_question': 'How do I place an order?',
      'faq_order_place_answer': 'Placing an order is easy! Simply browse our menu, select your favorite items, customize them to your liking, and add them to your cart. Once you\'re ready, proceed to checkout, enter your delivery details, choose your payment method, and confirm your order. You\'ll receive a confirmation email immediately.',
      'faq_order_modify_question': 'Can I modify or cancel my order?',
      'faq_order_modify_answer': 'Yes! You can modify or cancel your order within 5 minutes of placing it through the app. After this time, the restaurant begins preparing your food. If you need to make changes after this window, please contact our customer support team immediately, and we\'ll do our best to help.',
      'faq_payment_methods_question': 'What payment methods do you accept?',
      'faq_payment_methods_answer': 'We accept all major credit and debit cards (Visa, Mastercard, American Express), PayPal, Apple Pay, and Google Pay. All payments are processed through secure, encrypted connections to ensure your financial information is protected.',
      'faq_payment_security_question': 'Is my payment information secure?',
      'faq_payment_security_answer': 'Yes! We use industry-standard SSL encryption and comply with PCI DSS standards to ensure your payment information is completely secure. We never store your full card details on our servers.',
      'faq_delivery_time_question': 'How long does delivery take?',
      'faq_delivery_time_answer': 'Typical delivery time is 30-45 minutes, depending on your location, preparation time, and current demand. You can track your order in real-time through our app, and we\'ll notify you at each stage of the delivery process.',
      'faq_delivery_fees_question': 'Are there delivery fees?',
      'faq_delivery_fees_answer': 'Delivery fees vary based on distance and restaurant. The exact fee is always displayed before you confirm your order.',
      'faq_delivery_contactless_question': 'Do you offer contactless delivery?',
      'faq_delivery_contactless_answer': 'Yes! We offer contactless delivery for your safety and convenience. Simply select this option at checkout, and your order will be left at your door with a notification sent to your phone.',
      'faq_account_track_question': 'How do I track my order?',
      'faq_account_track_answer': 'You can track your order in real-time through our app or website. After placing your order, you\'ll see live updates including order confirmation, preparation status, dispatch notification, and estimated delivery time. You can also see your delivery person\'s location on the map.',
      'faq_account_incorrect_question': 'What if my order is incorrect or missing items?',
      'faq_account_incorrect_answer': 'If there\'s any issue with your order, please contact us immediately through the app or customer support. Take photos of the issue if possible. We\'ll work with the restaurant to resolve the problem and offer a refund, replacement, or credit to your account.',
      'faq_account_dietary_question': 'Do you have dietary filters?',
      'faq_account_dietary_answer': 'Yes! You can filter menu items by dietary preferences including vegetarian, vegan, gluten-free, dairy-free, nut-free, halal, and kosher. We also provide detailed allergen information for each dish. Look for the filter icon in the app menu.',

    
 
  "noNotifications": "No Notifications",
  "youWillSeeNotificationsHere": "You will see notifications here",
  "markAllAsRead": "Mark all as read",

  "allNotificationsMarkedAsRead": "All notifications marked as read",
  "notificationDeleted": "Notification deleted",
 
  "clearAllNotifications": "Clear All Notifications",
  "areYouSureYouWantToClearAllNotifications": "Are you sure you want to clear all notifications?",
  "allNotificationsCleared": "All notifications cleared",
  "noNotificationsInThisCategory": "No notifications in this category"
    },
    
    // ==================== SPANISH ====================
    'es': {
      // App Info
      'appName': 'Saborly',
      'appSlogan': 'Comida Deliciosa Entregada Rápido',
        "orderProgress": "Progreso del pedido",
      // General
      'search': 'Buscar',
      'orderCompleted':'Pedido completado',
            
  "driverPickup": "Recogida del conductor",

      'viewAll': 'Ver Todo',
      'add': 'Añadir',
      'remove': 'Eliminar',
        "paymentInfo": "Información de pago",
      'confirm': 'Confirmar',
      'cancel': 'Cancelar',
      'retry': 'Reintentar',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'somethingWentWrong': 'Algo salió mal',
      'noData': 'No se encontraron datos',
      'noInternet': 'Sin conexión a internet',
      'shop': 'Tienda',
        "startYourCulinaryJourney": "Comienza tu viaje culinario",
  "searchFoodDescription": "Busca tus platos, cocinas o ingredientes favoritos para descubrir opciones de comida increíbles",
      // Navigation
      'home': 'Inicio',
      'menu': 'Menú',
      'offers': 'Ofertas',
      'profile': 'Perfil',
      'back': 'Atrás',
        "restaurantClosed": "Restaurante cerrado",
  "restaurantClosedDescription": "Lo sentimos, no estamos aceptando pedidos en este momento",
  "checkOurHours": "Consulta nuestro horario",
  "closingSoon": "Cerrando pronto",
  "orderBeforeClosing": "Haz tu pedido antes de que cerremos",
      // Authentication
      'signIn': 'Iniciar Sesión',
      'signUp': 'Registrarse',
      'signOut': 'Cerrar Sesión',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'confirmPassword': 'Confirmar Contraseña',
      'forgotPassword': '¿Olvidaste tu Contraseña?',
      'dontHaveAccount': "¿No tienes una cuenta?",
      'alreadyHaveAccount': "¿Ya tienes una cuenta?",
      'firstName': 'Nombre',
      'lastName': 'Apellido',
      'phoneNumber': 'Número de Teléfono',
      'loginRequired': 'Por favor inicia sesión para continuar',
      'loginToContinue': 'Inicia Sesión para Continuar',
        "canDeliver": "Puede entregar",
      // Home
      'ourMenu': 'Nuestro Menú',
      'featuredItems': 'Artículos Destacados',
      'mostPopularItems': 'Artículos Más Populares',
      'freeDelivery': 'ENVÍO GRATIS',
      'tryChicken': 'PRUEBA POLLO',
      'freeShake': 'BATIDO GRATIS',
      'coolDown': 'REFRÉSCATE',
       'privacy': 'Política de Privacidad',
      'privacy_subtitle': 'Tu privacidad es nuestra prioridad',
      'privacy_intro': 'En Saborly, estamos comprometidos con proteger su privacidad y garantizar la seguridad de su información personal. Esta política explica cómo recopilamos, usamos y protegemos sus datos.',
      'last_updated': 'Última actualización: 18 de octubre de 2025',
      'info_collect_title': 'Información que Recopilamos',
      'info_collect_content': 'Recopilamos información que usted nos proporciona directamente cuando crea una cuenta, realiza un pedido o se comunica con nosotros.',
      'info_collect_point1': 'Detalles personales (nombre, correo electrónico, número de teléfono)',
      'info_collect_point2': 'Dirección de entrega y datos de ubicación',
      'info_collect_point3': 'Información de pago (cifrada de forma segura)',
      'info_collect_point4': 'Historial de pedidos y preferencias',
      'info_collect_point5': 'Información del dispositivo y uso',
      'use_info_title': 'Cómo Usamos tu Información',
      'use_info_content': 'Usamos la información que recopilamos para proporcionarte el mejor servicio posible.',
      'use_info_point1': 'Procesar y cumplir con tus pedidos',
      'use_info_point2': 'Enviar confirmaciones y actualizaciones de pedidos',
      'use_info_point3': 'Brindar soporte al cliente',
      'use_info_point4': 'Mejorar nuestros servicios y experiencia del usuario',
      'use_info_point5': 'Enviar ofertas promocionales (con tu consentimiento)',
      'use_info_point6': 'Prevenir fraudes y garantizar la seguridad',
      'sharing_title': 'Compartir y Divulgar Información',
      'sharing_content': 'Respetamos tu privacidad y no vendemos tu información personal.',
      'sharing_point1': 'Proveedores de servicios (procesadores de pagos, socios de entrega)',
      'sharing_point2': 'Requisitos legales y cumplimiento de la ley',
      'sharing_point3': 'Transferencias comerciales (fusiones, adquisiciones)',
      'sharing_point4': 'Con tu consentimiento explícito',
      'security_title': 'Seguridad de los Datos',
      'security_content': 'Implementamos medidas de seguridad estándar de la industria para proteger tu información.',
      'security_point1': 'Cifrado SSL/TLS para la transmisión de datos',
      'security_point2': 'Procesamiento de pagos seguro (cumple con PCI DSS)',
      'security_point3': 'Auditorías de seguridad y actualizaciones regulares',
      'security_point4': 'Controles de acceso y autenticación',
      'security_point5': 'Sistemas de respaldo y recuperación de datos',
      'rights_title': 'Tus Derechos',
      'rights_content': 'Tú tienes control sobre tu información personal.',
      'rights_point1': 'Acceder a tus datos personales',
      'rights_point2': 'Corregir información inexacta',
      'rights_point3': 'Solicitar la eliminación de datos',
      'rights_point4': 'Oponerte al procesamiento',
      'rights_point5': 'Portabilidad de datos',
      'rights_point6': 'Retirar el consentimiento en cualquier momento',
      'cookies_title': 'Cookies y Seguimiento',
      'cookies_content': 'Usamos cookies para mejorar tu experiencia y analizar patrones de uso.',
      'cookies_point1': 'Cookies esenciales (requeridas para la funcionalidad)',
      'cookies_point2': 'Cookies de rendimiento (análisis)',
      'cookies_point3': 'Cookies funcionales (preferencias)',
      'cookies_point4': 'Cookies de marketing (con consentimiento)',
      'children_privacy_title': 'Privacidad de los Niños',
      'children_privacy_content': 'Nuestros servicios no están destinados a niños menores de 13 años. No recopilamos conscientemente información personal de niños.',
      'contact_questions': '¿Preguntas sobre tu privacidad?',
      'contact_support': 'Nuestro equipo está aquí para ayudarte a entender cómo protegemos tus datos',
      'contact_email': 'support@saborly.es',
      'contact_phone': '+34 932 112 072',
  "deliveryNotAvailableNow": "La entrega no está disponible ahora",
      // FAQScreen
      'faq': 'Preguntas Frecuentes',
      'faq_subtitle': 'Encuentra respuestas a preguntas comunes',
      'faq_category_all': 'Todas',
      'faq_category_orders': 'Pedidos',
      'faq_category_payment': 'Pago',
      'faq_category_delivery': 'Entrega',
      'faq_category_account': 'Cuenta',
      'faq_contact_title': '¿Aún tienes preguntas?',
      'faq_contact_subtitle': 'Nuestro equipo de soporte está disponible 24/7 para ayudarte',
      'faq_contact_email': 'support@saborly.es',
      'faq_contact_phone': '+34 932 112 072',
      'faq_contact_chat': 'Chat en Vivo (Próximamente)',
      'faq_order_place_question': '¿Cómo realizo un pedido?',
      'faq_order_place_answer': '¡Realizar un pedido es fácil! Solo explora nuestro menú, selecciona tus artículos favoritos, personalízalos a tu gusto y agrégalos al carrito. Cuando estés listo, procede al pago, ingresa tus detalles de entrega, elige tu método de pago y confirma tu pedido. Recibirás un correo de confirmación inmediatamente.',
      'faq_order_modify_question': '¿Puedo modificar o cancelar mi pedido?',
      'faq_order_modify_answer': '¡Sí! Puedes modificar o cancelar tu pedido dentro de los 5 minutos posteriores a realizarlo a través de la aplicación. Después de este tiempo, el restaurante comienza a preparar tu comida. Si necesitas hacer cambios después de este período, contacta a nuestro equipo de soporte al cliente de inmediato y haremos lo mejor para ayudarte.',
      'faq_payment_methods_question': '¿Qué métodos de pago aceptan?',
      'faq_payment_methods_answer': 'Aceptamos todas las principales tarjetas de crédito y débito (Visa, Mastercard, American Express), PayPal, Apple Pay y Google Pay. Todos los pagos se procesan a través de conexiones seguras y cifradas para garantizar la protección de tu información financiera.',
      'faq_payment_security_question': '¿Es segura mi información de pago?',
      'faq_payment_security_answer': '¡Sí! Usamos cifrado SSL estándar de la industria y cumplimos con los estándares PCI DSS para garantizar que tu información de pago esté completamente segura. Nunca almacenamos los detalles completos de tu tarjeta en nuestros servidores.',
      'faq_delivery_time_question': '¿Cuánto tiempo tarda la entrega?',
      'faq_delivery_time_answer': 'El tiempo de entrega típico es de 30-45 minutos, dependiendo de tu ubicación, el tiempo de preparación y la demanda actual. Puedes rastrear tu pedido en tiempo real a través de nuestra aplicación, y te notificaremos en cada etapa del proceso de entrega.',
      'faq_delivery_fees_question': '¿Hay tarifas de entrega?',
      'faq_delivery_fees_answer': 'Las tarifas de entrega varían según la distancia y el restaurante. La tarifa exacta siempre se muestra antes de que confirmes tu pedido.',
      'faq_delivery_contactless_question': '¿Ofrecen entrega sin contacto?',
      'faq_delivery_contactless_answer': '¡Sí! Ofrecemos entrega sin contacto para tu seguridad y conveniencia. Solo selecciona esta opción al pagar, y tu pedido se dejará en tu puerta con una notificación enviada a tu teléfono.',
      'faq_account_track_question': '¿Cómo rastreo mi pedido?',
      'faq_account_track_answer': 'Puedes rastrear tu pedido en tiempo real a través de nuestra aplicación o sitio web. Después de realizar tu pedido, verás actualizaciones en vivo, incluida la confirmación del pedido, el estado de preparación, la notificación de despacho y el tiempo estimado de entrega. También puedes ver la ubicación de tu repartidor en el mapa.',
      'faq_account_incorrect_question': '¿Qué pasa si mi pedido es incorrecto o faltan artículos?',
      'faq_account_incorrect_answer': 'Si hay algún problema con tu pedido, contáctanos de inmediato a través de la aplicación o el soporte al cliente. Toma fotos del problema si es posible. Trabajaremos con el restaurante para resolver el problema y ofrecer un reembolso, reemplazo o crédito a tu cuenta.',
      'faq_account_dietary_question': '¿Tienen filtros dietéticos?',
      'faq_account_dietary_answer': '¡Sí! Puedes filtrar los elementos del menú por preferencias dietéticas, incluyendo vegetariano, vegano, sin gluten, sin lácteos, sin nueces, halal y kosher. También proporcionamos información detallada sobre alérgenos para cada plato. Busca el ícono de filtro en el menú de la aplicación.',

      // Categories
      'friendsFamily': 'Combo Amigos\ny Familia',
      'highOnCoffee': 'Combo Alto\nen Café',
      'duetCombos': 'Combos Dúo',
      'whopper': 'Whopper',
      'veg': 'Vegetariano',
      'nonVeg': 'No Vegetariano',
      
      // Cart & Checkout
      'myCart': 'Mi Carrito',
      'checkout': 'Pagar',
      'proceedToCheckout': 'Proceder al Pago',
      'placeOrder': 'Realizar Pedido',
      'addToCart': 'Añadir al Carrito',
      'quantity': 'Cantidad',
      'mealSize': 'Tamaño de Comida',
      'mediumMeal': 'Comida Mediana',
      'largeMeal': 'Comida Grande',
      'burgerOnly': 'Solo Hamburguesa',
      'extras': 'Extras',
      'addons': 'Complementos',
      'extraCheese': 'Queso Extra',
      'extraPattyChicken': 'Carne de Pollo Extra',
      'specialInstructions': 'Instrucciones especiales',
      'instructionsHint': 'Alguna nota para el pedido (Queso, etc.)',
      'subtotal': 'Subtotal',
      'deliveryFee': 'Tarifa de Envío',
      'total': 'Total',
      'cartSummary': 'Resumen del Carrito',
      'frequentlyBoughtTogether': 'Frecuentemente Comprados Juntos',
        "yourSubject": "Tu asunto",
      // Delivery & Location
      'delivery': 'Domicilio',
      'takeaway': 'Para Llevar',
      'selectBranch': 'Seleccionar Sucursal',
      'deliveryAddress': 'Dirección de Entrega',
      'addAddress': 'Añadir Dirección',
      'editAddress': 'Editar Dirección',
      'homeAddress': 'Casa',
      'workAddress': 'Trabajo',
      'preferenceTime': 'Hora Preferida de Entrega',
      'today': 'Hoy',
      'tomorrow': 'Mañana',
      'now': 'Ahora',
      'estimatedDelivery': 'Tiempo estimado de entrega',
      
      // Payment
      'selectPaymentMethod': 'Selecciona tu método de pago',
      'paypal': 'PayPal',
      'stripe': 'Stripe',
      'visaCard': 'Tarjeta VISA',
      'mastercard': 'Mastercard',
      'cardNumber': 'Número de Tarjeta',
      'expiresOn': 'Expira el',
      'payNow': 'Pagar Ahora',
      'cancelOrder': 'Cancelar',
      'cashOnDelivery': 'Pago Contra Entrega',
      'paymentMethod': 'Método de Pago',
      'paymentStatus': 'Estado del Pago',
      'unpaid': 'No Pagado',
      'paid': 'Pagado',
        "yourPhone": "Tu teléfono",
        "yourMessage": "Tu mensaje",
      // Orders
      'orderStatus': 'Estado del Pedido',
      'orderDetails': 'Detalles del Pedido',
      'orderPlaced': 'Pedido realizado',
      'orderConfirmed': 'Pedido confirmado',
      'preparing': 'Preparando',
      'outForDelivery': 'En camino',
      'ready': 'Listo para entregar',
      'delivered': 'Entregado',
      'getYourOrder': 'Recibe tu pedido ',
      'orderHistory': 'Historial de Pedidos',
      'reorder': 'Volver a Pedir',
      'trackOrder': 'Rastrear Pedido',
      
      // Validation Messages
      'pleaseEnterEmail': 'Por favor ingresa tu correo electrónico',
      'pleaseEnterValidEmail': 'Por favor ingresa un correo válido',
      'pleaseEnterPassword': 'Por favor ingresa tu contraseña',
      'passwordTooShort': 'La contraseña debe tener al menos 6 caracteres',
      'passwordsDontMatch': 'Las contraseñas no coinciden',
      'pleaseEnterName': 'Por favor ingresa tu nombre',
      'pleaseEnterPhone': 'Por favor ingresa tu número de teléfono',
        "yourOrderWillBeReady": "Tu pedido estará listo",
      // Success Messages
      'orderPlacedSuccessfully': '¡Pedido realizado con éxito!',
      'accountCreatedSuccessfully': '¡Cuenta creada con éxito!',
      'profileUpdatedSuccessfully': '¡Perfil actualizado con éxito!',
      'addressAddedSuccessfully': '¡Dirección añadida con éxito!',
        "readyIn": "Listo en",
      // Error Messages
      'failedToPlaceOrder': 'Error al realizar el pedido',
      'failedToLogin': 'Error al iniciar sesión',
      'failedToCreateAccount': 'Error al crear la cuenta',
      'failedToLoadData': 'Error al cargar los datos',
      'failedToUpdateProfile': 'Error al actualizar el perfil',
      
      // Time
      'minutes': 'min',
      'hours': 'horas',
      'am': 'am',
      'pm': 'pm',
      
      // Price
      'currency': '€',
      'free': 'Gratis',
      
      // Restaurant Info
      'boshundhoraRA': 'España',
      'gulshan2': 'España',
      'banani': 'España',
      'dhanmondi': 'España',
      'km': 'km',
      'flat': 'Piso',
      'house': 'Casa',
      'road': 'Calle',
      'specialOffers': 'Ofertas Especiales',
    'hotDeals': 'OFERTAS CALIENTES',
    'exclusiveOffers': 'Ofertas Exclusivas',
    'saveUpTo': 'Ahorra hasta un 50% en tus comidas favoritas',
    'itemsOnOffer': 'artículos en oferta',
    'noOffersAvailable': 'No Hay Ofertas Disponibles',
    'checkBackLater': '¡Vuelve más tarde para ofertas emocionantes!\nSe añaden nuevas ofertas regularmente.',
    'browseMenu': 'Ver Menú',
    'featuredItemsTitle': 'Artículos Destacados',
    'popularItemsTitle': 'Artículos Populares',
    'noFeaturedItems': 'No Hay Artículos Destacados',
    'noPopularItems': 'No Hay Artículos Populares',
    'checkBackForItems': 'Vuelve más tarde para artículos',
    'viewYourOrders': 'Ver tus pedidos anteriores',
    'orderNumber': 'Pedido #',
    'items': 'artículos',
    'item': 'artículo',
    'totalAmount': 'Monto Total',
    'viewDetails': 'Ver Detalles',
    'goToMenu': 'Ir al menú',
    'pending': 'Pendiente',
    'confirmed': 'Confirmado',
    "range": "Rango",
    'readyForPickup': 'Listo para Recoger',
    'collected': 'Recogido',
    "changeAddress": "Cambiar dirección",
    'cancelled': 'Cancelado',
    'refunded': 'Reembolsado',
    'branch': 'Sucursal',
    'noOrdersYet': 'Aún No Hay Pedidos',
    'orderHistoryAppear': 'Tu historial de pedidos aparecerá aquí\nuna vez que realices tu primer pedido',
    'startOrdering': 'Comenzar a Pedir',
    'contactUs': 'Contáctanos',
    'sendMessage': 'Envíanos un Mensaje',
    'fullName': 'Nombre Completo',
    'yourName': 'Tu nombre',
    'phoneOptional': 'Teléfono (Opcional)',
    'subject': 'Asunto',
    'subjectOfMessage': 'Asunto del mensaje',
    'message': 'Mensaje',
    'writeMessageHere': 'Escribe tu mensaje aquí...',
    'callUs': 'Llámanos',
    'visitUs': 'Visítanos',
    'writeUs': 'Escríbenos',
    'followUs': 'Síguenos',
       'discoverOurOfferings': 'Descubre nuestras deliciosas ofertas',
    'allCategories': 'Todas las Categorías',
    'noFeaturedItemsFound': 'No hay artículos destacados',
    'noPopularItemsFound': 'No hay artículos populares',
    'checkBackLaterFor': 'Vuelve más tarde para',
    
    // Order History
    'loadingYourOrders': 'Cargando tus pedidos...',
    'oopsSomethingWrong': '¡Ups! Algo salió mal',
    'yourOrderHistory': 'Tu historial de pedidos aparecerá aquí\nuna vez que realices tu primer pedido',
   "calculating": "Calculando",
    'yesterday': 'Ayer',
    
    // Offers
    'loadingAmazingOffers': 'Cargando ofertas increíbles...',
  
    'saveUpTo50': 'Ahorra hasta un 50% en tus comidas favoritas',

    'checkBackForDeals': '¡Vuelve más tarde para ofertas emocionantes!\nSe añaden nuevas ofertas regularmente.',
    
    // Contact
    'sendUsMessage': 'Envíanos un Mensaje',
    'completeTheForm': 'Completa el formulario y nos pondremos en contacto contigo pronto',
   
    'writeYourMessage': 'Escribe tu mensaje aquí...',

    'pleaseEnterSubject': 'Por favor ingresa el asunto',
    'pleaseEnterMessage': 'Por favor ingresa tu mensaje',
    'messageTooShort': 'El mensaje debe tener al menos 10 caracteres',
    'messageTooLong': 'El mensaje no puede exceder 2000 caracteres',
    
    // Profile
    'accountManagement': 'Gestión de Cuenta',
    'manageYourAccount': 'Gestiona tu cuenta y preferencias',
    'activityOverview': 'Resumen de Actividad',
    'orders': 'Pedidos',
    'reviews': 'Reseñas',
    'favorites': 'Favoritos',
    'points': 'Puntos',
    'quickActions': 'Acciones Rápidas',
    'downloadData': 'Descargar Datos',
    'helpCenter': 'Centro de Ayuda',
    'editProfile': 'Editar Perfil',
    'accountSettings': 'Configuración de Cuenta',
    'personalInformation': 'Información Personal',
    'preferences': 'Preferencias',
    'notifications': 'Notificaciones',
 
    'securitySupport': 'Seguridad y Soporte',
    'changePassword': 'Cambiar Contraseña',
    'helpSupport': 'Ayuda y Soporte',
    'about': 'Acerca de',
    'version': 'Versión',
    
    // Cart
    'emptyCart': 'Tu carrito está vacío',
    'addSomeFood': 'Añade comida deliciosa para comenzar',
  
    'anySpecialRequests': 'Alguna solicitud especial o instrucciones para tu pedido...',
    
    // Checkout
    'deliveryAvailable': 'Entrega Disponible',
    'deliveryNotAvailable': 'Entrega No Disponible',
    'distance': 'Distancia',
    'addressBeyondRange': 'La dirección está fuera del rango de entrega',
    'pleaseSelectAddress': 'Por favor selecciona una dirección de entrega',
  
    'addMoreForFree': 'más para envío GRATIS!',
    'noDeliveryAddress': 'Sin Dirección de Entrega',
    'addDeliveryAddress': 'Añade tu dirección de entrega para continuar',
    'selectAddress': 'Seleccionar Dirección',
    'completeAddressDetails': 'Completa los Detalles de la Dirección',
    'savedAddresses': 'Direcciones Guardadas',
    'addYourFirstAddress': 'Añade Tu Primera Dirección',
    'addNewAddress': 'Añadir Nueva Dirección',
    'searchAddress': 'Buscar Dirección',
    'startTypingAddress': 'Comienza a escribir tu dirección...',
    'noAddressesFound': 'No se encontraron direcciones',
    'tryDifferentSearch': 'Intenta con otro término de búsqueda',
    'addressType': 'Tipo de Dirección',
      "frequentlyAskedQuestions": "Preguntas frecuentes", 
     "pizza": "Pizza",
  "burger": "Hamburguesa",
  "pasta": "Pasta",
  "salad": "Ensalada",
    'office': 'Oficina',
    'other': 'Otro',
    'apartmentNumber': 'Número de Apartamento/Casa',
    'apartmentPlaceholder': 'ej., Apt 4B, Piso 2, Edificio C',
    'deliveryInstructions': 'Instrucciones de Entrega (Opcional)',
    'deliveryInstructionsPlaceholder': 'ej., Tocar el timbre, Dejar en la puerta',
    'saveAddress': 'Guardar Dirección',
    'pleaseEnterApartment': 'Por favor ingresa tu número de apartamento/casa',
    'pickupLocation': 'Lugar de Recogida',
    'pickupTime': 'Hora de Recogida',
    
    // Payment
    'pickupOrder': 'Pedido para Recoger',
    'deliveryOrder': 'Pedido a Domicilio',
    'payAtShop': 'Pagar en Tienda',
    'payAtCounter': 'Paga en el mostrador cuando recojas tu pedido',
    'choosePaymentType': 'Elige el Tipo de Pago',
    'cash': 'Efectivo',
    'card': 'Tarjeta',
    'payWithCash': 'Pagar con efectivo',
    'payWithCard': 'Pagar con tarjeta',
    'otherOptions': 'Otras Opciones (Próximamente)',
    'paySecurelyWith': 'Paga de forma segura con',
    'comingSoon': 'Próximamente',
    'paymentSummary': 'Resumen de Pago',
    'orderType': 'Tipo de Pedido',

    'paymentType': 'Tipo de Pago',
    'payAtShopCounter': 'Paga en el mostrador al recoger',
    'payWithCashOnDelivery': 'Paga con efectivo cuando llegue tu pedido',
    'payWithCardOnDelivery': 'Paga con tarjeta cuando llegue tu pedido',
    'noneSelected': 'Ninguno Seleccionado',
    'shopPayment': 'Pago en Tienda',
    'deliveryPayment': 'Pago a Domicilio',
    
    // Menu
    'loadingDeliciousMenu': 'Cargando menú delicioso...',
  
    'discoverDelicious': 'Descubre nuestras deliciosas ofertas',
    'filters': 'Filtros',
    'foodType': 'Tipo de Comida',
    'vegetarian': 'Vegetariano',
    'nonVegetarian': 'No Vegetariano',
    'popularItems': 'Artículos Populares',
    'clearAll': 'Limpiar Todo',
    'apply': 'Aplicar',
    'advancedFilters': 'Filtros Avanzados',

      'default': 'Predeterminada',
      'chooseDeliveryAddress': 'Elige dónde entregar tu pedido',
      'setAsDefault': 'Establecer como Predeterminada',
      'delete': 'Eliminar',
      'deleteAddress': 'Eliminar Dirección',
      'confirmDeleteAddress': '¿Estás seguro de que quieres eliminar esta dirección? Esta acción no se puede deshacer.',
      'defaultAddressUpdated': 'Dirección predeterminada actualizada',
      'addressDeletedSuccessfully': 'Dirección eliminada con éxito',

      'addressSavedWithDistance': '¡Dirección guardada! Distancia: {distance}',
      'addressBeyondRangeWithLimit': 'Lo sentimos, esta dirección está fuera de nuestro rango de entrega de {limit}km',
      'failedToFetchPlaceDetails': 'No se pudieron obtener los detalles del lugar',
      'noDescription': 'Sin descripción',
      'pleaseSelectDeliveryAddress': 'Por favor, selecciona una dirección de entrega',
      'addressBeyondDeliveryRange': 'La dirección seleccionada está fuera del rango de entrega',
      
      'cartEmpty': 'Tu carrito está vacío',
      'moreItems': '+{count} elementos más',
   
      'noOrdersDescription': 'Tu historial de pedidos aparecerá aquí\nuna vez que realices tu primer pedido',

      'pickup': 'Recogida',
 'pressBackAgain': 'Presiona de nuevo para salir',
    
      'securityAndSupport': 'Seguridad y Soporte',
      'helpAndSupport': 'Ayuda y Soporte',
      
      'signInPrompt': 'Inicia sesión para acceder a tu perfil y pedidos',
      'viewPastOrders': 'Ver tus pedidos anteriores',
      'updatePassword': 'Actualizar tu contraseña',
   
      'getInTouch': 'Ponte en contacto con nosotros',
      'learnAboutUs': 'Conoce más sobre nosotros',
      'notificationPreferences': 'Preferencias de notificaciones',
      'getHelpAndSupport': 'Obtener ayuda y soporte',
      'appVersion': 'Versión 1.0.0',
      'aboutApp': 'Acerca de Saborly',
      'appDescription': '¡Bienvenido a Saborly! Entregamos comida deliciosa de tus restaurantes favoritos directamente a tu puerta.',
      'copyright': '© 2025 Saborly. Todos los derechos reservados.',
      'companyAddress': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, España',
      'close': 'Cerrar',
      'save': 'Guardar',
      'areYouSureSignOut': '¿Estás seguro de que quieres cerrar sesión?',

      'loadingMenu': 'Cargando menú delicioso...',
      'noCategoriesAvailable': 'No hay categorías disponibles',
      'noFoodItemsAvailable': 'No hay elementos de comida disponibles',
      'discoverOfferings': 'Descubre nuestras deliciosas ofertas',
     
      'popular': 'Popular',
      'appLogo': 'Logotipo de la Aplicación',
      'noItems': 'No hay elementos {type}',
      'featured': 'Destacados',
   
      'aboutUs': 'Sobre Nosotros',
      'cart': 'Carrito',

      'account': 'Cuenta',
       'orderNotFound': 'Pedido no encontrado',
      'goBack': 'Volver',
     
      'callRestaurant': 'Llamar al Restaurante',
      'restaurantAddress': 'Saborly, C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, España',
      'estimatedTime': '40 min',
     
      'paymentFailed': 'Fallido',
      'paymentRefunded': 'Reembolsado',
      'emptyOrderItems': 'Tus deliciosos elementos del pedido',
    
      'tax': 'Impuesto:',
    
      'jan': 'Ene',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Abr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Ago',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dic',
      
      'callError': 'No se puede realizar una llamada a 34932112072',
      'callErrorGeneric': 'Error al realizar la llamada: {error}',
       'loadingOffers': 'Cargando ofertas increíbles...',
     
      'checkBackLaterOffers': 'Vuelve a consultar más tarde para ofertas emocionantes.\nSe añaden nuevas ofertas regularmente.',
      'addFoodToStart': 'Añade algo de comida deliciosa para comenzar',

      'specialInstructionsHint': 'Cualquier solicitud o instrucción especial para tu pedido para llevar...',
      'orderSummary': 'Resumen del Pedido',
      'sizeLabel': 'Tamaño:',
      'extrasLabel': 'Extras:',
      'addonsLabel': 'Complementos:',

     
      'otherOptionsComingSoon': 'Otras Opciones (Próximamente)',
     
      'paypalDescription': 'Paga de forma segura con PayPal',
      'stripeDescription': 'Paga con tarjeta de crédito o débito',
      'cardDescription': 'Paga con VISA o Mastercard',
     
      'shopPaymentMethod': 'Pago en Tienda',
      'errorFailedToLoadOrder': 'Error: No se pudo cargar el estado del pedido',
      'unexpectedError': 'Error inesperado. Por favor intenta de nuevo.',
   
      'businessHours': 'Lun - Dom: 12:00 - 23:00',
      'address': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, España',
      'infoEmail': 'info@saborly.es',
      'supportEmail': 'soporte@saborly.es',
      'formSubmissionSuccess': '¡Gracias! Tu mensaje ha sido enviado con éxito.',
      'formSubmissionError': 'No se pudo enviar el mensaje. Por favor intenta de nuevo.',
            'tagline': 'Comida deliciosa, entregada rápido',
      'failedToLoadOffers': 'No se pudieron cargar las ofertas',
      'unknownError': 'Error desconocido',
     
      'days': '{days} días',
      'offerPlaceholder': 'Oferta',
      'brandDescription': 'Experiencias culinarias excepcionales que deleitan tus sentidos. Únete a nuestra comunidad gastronómica.',

      // Quick Links
      'quickLinks': 'Enlaces Rápidos',
    
      'reservations': 'Reservaciones',
      'gallery': 'Galería',
      'blog': 'Blog',
      'careers': 'Carreras',

      // Resources Links
      'resources': 'Recursos',
    
      'privacyPolicy': 'Política de Privacidad',
      'termsOfService': 'Términos de Servicio',
      'cookiePolicy': 'Política de Cookies',
    

      // Contact Section
      'stayConnected': 'Mantente Conectado',
      'subscribeOffers': 'Suscríbete para recibir ofertas exclusivas',
      'yourEmail': 'Tu correo electrónico',
      'subscribe': 'Suscribirse',
    
      // Payment Methods
      'weAccept': 'Aceptamos',
      'visa': 'Visa',
         'resetPassword': 'Restablecer Contraseña',

      // Form Fields
      'enterYourEmail': 'Ingresa tu correo electrónico',
       'verificationCode': 'Código de Verificación',
      'enter6DigitCode': 'Ingresa el código de 6 dígitos',
      'pleaseEnterCode': 'Por favor, ingresa el código',
      'codeMustBe6Digits': 'El código debe tener 6 dígitos',
      'newPassword': 'Nueva Contraseña',
      'enterNewPassword': 'Ingresa la nueva contraseña',
      'passwordMinLength': 'La contraseña debe tener al menos 6 caracteres',
      'reEnterNewPassword': 'Reingresa la nueva contraseña',
      'pleaseConfirmPassword': 'Por favor, confirma tu contraseña',
      'passwordsDoNotMatch': 'Las contraseñas no coinciden',
      'backToLogin': 'Volver al Inicio de Sesión',

      // SnackBar Messages
      'resetCodeSent': 'Código de restablecimiento enviado a tu correo',
      'failedToSendResetCode': 'No se pudo enviar el código de restablecimiento',
      'invalid6DigitCode': 'Por favor, ingresa un código de 6 dígitos válido',
      'codeVerified': 'Código verificado con éxito',
      'invalidOrExpiredCode': 'Código inválido o expirado',
      'passwordResetSuccess': '¡Contraseña restablecida con éxito!',
      'failedToResetPassword': 'No se pudo restablecer la contraseña',
      'newCodeSent': 'Nuevo código enviado a tu correo',
      'failedToSendCode': 'No se pudo enviar el código',

      // Titles
      'createNewPassword': 'Crear Nueva Contraseña',
      'verifyCode': 'Verificar Código',

      // Subtitles
      'enterNewPasswordSubtitle': 'Por favor, ingresa tu nueva contraseña',
      'enterCodeSubtitle': 'Ingresa el código de 6 dígitos enviado a {email}',
      'enterEmailSubtitle': 'Ingresa tu correo para recibir un código de restablecimiento',

      // Button Texts
      'resetPasswordButton': 'Restablecer Contraseña',
      'verifyCodeButton': 'Verificar Código',
      'sendResetCode': 'Enviar Código de Restablecimiento',
      'resendCodeCountdown': 'Reenviar código en {seconds}s',
      'resendCode': 'Reenviar Código',
     'allSet': '¡Todo Listo!',
      'passwordUpdatedDescription': 'Tu contraseña ha sido actualizada con éxito. Ahora puedes iniciar sesión con tu nueva contraseña.',
      'newPasswordRequirements': 'Tu nueva contraseña debe ser diferente a la anterior y cumplir con nuestros requisitos de seguridad.',

      // Password Requirements
      'passwordMinLength8': 'Al menos 8 caracteres de longitud',
      'passwordUpperLower': 'Contiene letras mayúsculas y minúsculas',
      'passwordNumber': 'Incluye al menos un número',
      'passwordSpecialChar': 'Tiene al menos un carácter especial',

      // Form Header and Header
      'passwordUpdated': '¡Contraseña Actualizada!',
      'passwordChanged': 'Tu contraseña ha sido cambiada con éxito.',
      'createStrongPassword': 'Crea una nueva contraseña segura para tu cuenta.',

      // Password Fields
     'passwordMinLength8Error': 'La contraseña debe tener al menos 8 caracteres',
      'passwordSecurityError': 'La contraseña debe cumplir con los requisitos de seguridad',

      // Form

      // Success Content
      'passwordResetSuccessDescription': 'Tu contraseña ha sido actualizada con éxito. Ahora puedes iniciar sesión con tu nueva contraseña.',
      'passwordSecurityTip': 'Mantén tu contraseña segura y no la compartas con nadie.',

      // Sign In Button
      'signInNow': 'Iniciar Sesión Ahora',

      // SnackBar Messages
      'passwordUpdatedSuccess': '¡Contraseña actualizada con éxito!',
      'passwordResetFailed': 'No se pudo restablecer la contraseña. Por favor, intenta de nuevo.',

       // Existing translations

      // AppBar and Web Header
      'secureAccount': 'Mantén tu cuenta segura con una contraseña fuerte',

      // Password Card
      'currentPassword': 'Contraseña Actual',
      'enterCurrentPassword': 'Ingresa la contraseña actual',
      'pleaseEnterCurrentPassword': 'Por favor, ingresa tu contraseña actual',
      'pleaseEnterNewPassword': 'Por favor, ingresa una nueva contraseña',
      'passwordMinLength6': 'La contraseña debe tener al menos 6 caracteres',
      'newPasswordDifferent': 'La nueva contraseña debe ser diferente de la actual',
      'pleaseConfirmNewPassword': 'Por favor, confirma tu nueva contraseña',

      // Security Tips
      'passwordRequirements': 'Requisitos de Contraseña',
      'passwordMinLength6Tip': 'Al menos 6 caracteres de longitud',
      'passwordNumbersSpecial': 'Añade números y caracteres especiales',
      'avoidCommonWords': 'Evita palabras o patrones comunes',

      // Button
      'changePasswordButton': 'Cambiar Contraseña',

      // SnackBar Messages
      'passwordChangedSuccess': 'Contraseña cambiada con éxito',
      'passwordChangeFailed': 'No se pudo cambiar la contraseña',
       // Header
      'verifyYourEmail': 'Verifica tu Correo Electrónico',
      'sentVerificationCode': 'Hemos enviado un código de verificación a',

      // Timer
      'codeExpired': 'Código expirado',
      'codeExpiresIn': 'El código expira en {time}',

      // Resend Button
      'didntReceiveCode': '¿No recibiste el código? ',
      'resend': 'Reenviar',

      // Button
      'verifyEmail': 'Verificar Correo',

      // SnackBar Messages
      'emailVerifiedSuccess': '¡Correo verificado con éxito!',
      'invalidOrExpiredOTP': 'Código OTP inválido o expirado. Por favor, intenta de nuevo.',
       'joinApp': 'Únete a Saborly',
      'createAccountDescription': 'Crea tu cuenta y comienza tu viaje con nosotros. Experimenta la mejor plataforma de compras diseñada para ti.',

      // Feature List
      'secureCheckout': 'Pago seguro y rápido',
      'personalizedRecommendations': 'Recomendaciones personalizadas',
      'exclusiveBenefits': 'Beneficios exclusivos para miembros',
      'customerSupport': 'Soporte al cliente 24/7',

      // Form Header and Header
      'createAccount': 'Crear Cuenta',
      'fillInDetails': 'Rellena tus datos para comenzar',
      'signUpToStart': 'Regístrate para empezar con Saborly.',

      // SnackBar Messages
      'verificationCodeSent': '¡Código de verificación enviado! Por favor, revisa tu correo.',
      'accountCreatedSuccess': '¡Cuenta creada con éxito!',
       // AppBar

      // Hero Section
      'welcomeToApp': 'Bienvenido a Saborly',
      'bestFastFoodDestination': 'Tu destino para la mejor comida rápida',

      // Story Section
      'ourStory': 'Nuestra Historia',
      'storyDescription': 'Saborlynació de una pasión por ofrecer comida deliciosa y de calidad. Desde nuestros inicios, nos hemos comprometido a servir los mejores platos, preparados con ingredientes frescos y recetas auténticas. Cada día trabajamos para superar las expectativas de nuestros clientes y crear experiencias culinarias memorables.',

      // Values Section
      'ourValues': 'Nuestros Valores',
      'quality': 'Calidad',
      'qualityDescription': 'Ingredientes frescos y de primera calidad',
      'speed': 'Rapidez',
      'speedDescription': 'Servicio rápido sin comprometer la calidad',
      'passion': 'Pasión',
      'passionDescription': 'Amor por lo que hacemos en cada plato',

      // Mission Section
      'ourMission': 'Nuestra Misión',
      'missionDescription': 'Hacer que cada comida sea una experiencia especial, ofreciendo sabores auténticos y un servicio excepcional que supere las expectativas de nuestros clientes.',
  "offerPrice": "Precio de la oferta",
  "startingFrom": "A partir de",

  "noNotifications": "Sin notificaciones",
  "youWillSeeNotificationsHere": "Verás las notificaciones aquí",
  "markAllAsRead": "Marcar todo como leído",
  "allNotificationsMarkedAsRead": "Todas las notificaciones marcadas como leídas",
  "notificationDeleted": "Notificación eliminada",
  "undo": "Deshacer",
  "clearAllNotifications": "Borrar todas las notificaciones",
  "areYouSureYouWantToClearAllNotifications": "¿Estás seguro de que quieres borrar todas las notificaciones?",
  "allNotificationsCleared": "Todas las notificaciones borradas",
  "noNotificationsInThisCategory": "No hay notificaciones en esta categoría"
      
    },
    
    // ==================== CATALAN ====================
    'ca': {
      // App Info
      'appName': 'Saborly',
      'appSlogan': 'Menjar Deliciós Entregat Ràpid',
     
                        'orderCompleted':'Comanda completada',

  "driverPickup": "Recollida del conductor",      // General
      'search': 'Cercar',
      'viewAll': 'Veure Tot',
      'add': 'Afegir',
      'remove': 'Eliminar',
      'confirm': 'Confirmar',
      'cancel': 'Cancel·lar',
      'retry': 'Tornar a intentar',
      'loading': 'Carregant...',
      'error': 'Error',
      'success': 'Èxit',
      'somethingWentWrong': 'Alguna cosa ha anat malament',
      'noData': 'No s\'han trobat dades',
      'noInternet': 'Sense connexió a internet',
      'shop': 'Botiga',
        "offerPrice": "Precio de la oferta",
  "startingFrom": "A partir de",
  "specialInstructions": "Agrega aquí cualquier instrucción especial...",
  "totalAmount": "Importe total",
      // Navigation
      'home': 'Inici',
      'menu': 'Menú',
      'offers': 'Ofertes',
      'profile': 'Perfil',
      'back': 'Enrere',
      
      // Authentication
      'signIn': 'Iniciar Sessió',
      'signUp': 'Registrar-se',
      'signOut': 'Tancar Sessió',
      'email': 'Correu Electrònic',
      'password': 'Contrasenya',
      'confirmPassword': 'Confirmar Contrasenya',
      'forgotPassword': 'Has oblidat la contrasenya?',
      'dontHaveAccount': "No tens un compte?",
      'alreadyHaveAccount': "Ja tens un compte?",
      'firstName': 'Nom',
      'lastName': 'Cognom',
      'phoneNumber': 'Número de Telèfon',
      'loginRequired': 'Si us plau, inicia sessió per continuar',
      'loginToContinue': 'Iniciar Sessió per Continuar',
        "message": "Missatge",
      // Home
      'ourMenu': 'El Nostre Menú',
      'featuredItems': 'Articles Destacats',
      'mostPopularItems': 'Articles Més Populars',
      'freeDelivery': 'ENVIAMENT GRATUÏT',
      'tryChicken': 'PROVA POLLASTRE',
      'freeShake': 'BATUT GRATUÏT',
      'coolDown': 'REFRESCA\'T',
      "changeAddress": "Canviar adreça",
      // Categories
      'friendsFamily': 'Combo Amics\ni Família',
      'highOnCoffee': 'Combo Alt\nen Cafè',
      'duetCombos': 'Combos Duet',
      'whopper': 'Whopper',
      'veg': 'Vegetarià',
      'nonVeg': 'No Vegetarià',
      
      // Cart & Checkout
      'myCart': 'El Meu Carret',
      'checkout': 'Pagar',
      'proceedToCheckout': 'Procedir al Pagament',
      'placeOrder': 'Fer Comanda',
      'addToCart': 'Afegir al Carret',
      'quantity': 'Quantitat',
      'mealSize': 'Mida del Menjar',
      'mediumMeal': 'Menjar Mitjà',
      'largeMeal': 'Menjar Gran',
      'burgerOnly': 'Només Hamburguesa',
      'extras': 'Extres',
      'addons': 'Complements',
      'extraCheese': 'Formatge Extra',
      'extraPattyChicken': 'Carn de Pollastre Extra',
      'instructionsHint': 'Alguna nota per a la comanda (Formatge, etc.)',
      'subtotal': 'Subtotal',
      'deliveryFee': 'Taxa d\'Enviament',
      'total': 'Total',
      'cartSummary': 'Resum del Carret',
      'frequentlyBoughtTogether': 'Comprats Freqüentment Junts',
      
      // Delivery & Location
      'delivery': 'Lliurament a Domicili',
      'takeaway': 'Per Emportar',
      'selectBranch': 'Seleccionar Sucursal',
      'deliveryAddress': 'Adreça de Lliurament',
      'addAddress': 'Afegir Adreça',
      'editAddress': 'Editar Adreça',
      'homeAddress': 'Casa',
      'workAddress': 'Treball',
      'preferenceTime': 'Hora Preferida de Lliurament',
      'today': 'Avui',
      'tomorrow': 'Demà',
      'now': 'Ara',
      'estimatedDelivery': 'Temps estimat de lliurament',
      
      // Payment
      'selectPaymentMethod': 'Selecciona el teu mètode de pagament',
      'paypal': 'PayPal',
      'stripe': 'Stripe',
      'visaCard': 'Targeta VISA',
      'mastercard': 'Mastercard',
      'cardNumber': 'Número de Targeta',
      'expiresOn': 'Expira el',
      'payNow': 'Pagar Ara',
      'cancelOrder': 'Cancel·lar',
      'cashOnDelivery': 'Pagament Contra Lliurament',
      'paymentMethod': 'Mètode de Pagament',
      'paymentStatus': 'Estat del Pagament',
      'unpaid': 'No Pagat',
      'paid': 'Pagat',
      
      // Orders
      'orderStatus': 'Estat de la Comanda',
      'orderDetails': 'Detalls de la Comanda',
      'orderPlaced': 'Comanda realitzada',
      'orderConfirmed': 'Comanda confirmada',
      'preparing': 'Preparant',
      'outForDelivery': 'En camí',
      'ready': 'Llest per recollir',
      'delivered': 'Lliurat',
      'getYourOrder': 'Rep la teva comanda ',
      'orderHistory': 'Historial de Comandes',
      'reorder': 'Tornar a Demanar',
      'trackOrder': 'Rastrejar Comanda',
      
      // Validation Messages
      'pleaseEnterEmail': 'Si us plau, introdueix el teu correu electrònic',
      'pleaseEnterValidEmail': 'Si us plau, introdueix un correu vàlid',
      'pleaseEnterPassword': 'Si us plau, introdueix la teva contrasenya',
      'passwordTooShort': 'La contrasenya ha de tenir almenys 6 caràcters',
      'passwordsDontMatch': 'Les contrasenyes no coincideixen',
      'pleaseEnterName': 'Si us plau, introdueix el teu nom',
      'pleaseEnterPhone': 'Si us plau, introdueix el teu número de telèfon',
      
      // Success Messages
      'orderPlacedSuccessfully': 'Comanda realitzada amb èxit!',
      'accountCreatedSuccessfully': 'Compte creat amb èxit!',
      'profileUpdatedSuccessfully': 'Perfil actualitzat amb èxit!',
      'addressAddedSuccessfully': 'Adreça afegida amb èxit!',
      
      // Error Messages
      'failedToPlaceOrder': 'Error al realitzar la comanda',
      'failedToLogin': 'Error a l\'iniciar sessió',
      'failedToCreateAccount': 'Error al crear el compte',
      'failedToLoadData': 'Error al carregar les dades',
      'failedToUpdateProfile': 'Error a l\'actualitzar el perfil',
        "calculating": "Calculant",

      // Time
      'minutes': 'min',
      'hours': 'hores',
      'am': 'am',
      'pm': 'pm',
      
      // Price
      'currency': '€',
      'free': 'Gratuït',
      
      // Restaurant Info
      'boshundhoraRA': 'Espanya',
      'gulshan2': 'Espanya',
      'banani': 'Espanya',
      'dhanmondi': 'Espanya',
      'km': 'km',
      'flat': 'Pis',
      'house': 'Casa',
      'road': 'Carrer',
       'specialOffers': 'Ofertes Especials',
    'hotDeals': 'OFERTES CALENTES',
    'exclusiveOffers': 'Ofertes Exclusives',
    'saveUpTo': 'Estalvia fins a un 50% en els teus plats favorits',

    'discoverOurOfferings': 'Descobreix les nostres ofertes delicioses',
    'allCategories': 'Totes les Categories',
    'loadingYourOrders': 'Carregant les teves comandes...',
    'oopsSomethingWrong': 'Vaja! Alguna cosa ha anat malament',
    'noOrdersYet': 'Encara No Hi Ha Comandes',

    'sendUsMessage': 'Envia\'ns un Missatge',
    'fullName': 'Nom Complet',
    'accountManagement': 'Gestió del Compte',
    'emptyCart': 'El teu carret està buit',
    'deliveryAvailable': 'Lliurament Disponible',
    'pickupOrder': 'Comanda per Recollir',
    'cash': 'Efectiu',
    'card': 'Targeta',
    'loadingDeliciousMenu': 'Carregant menú deliciós...',
    'filters': 'Filtres',
    'vegetarian': 'Vegetarià',
    'pending': 'Pendent',
    'confirmed': 'Confirmat',
     "canDeliver": "Pot lliurar",
  "range": "Abast"
,
 'default': 'Per Defecte',
      'chooseDeliveryAddress': 'Tria on lliurar la teva comanda',
      'setAsDefault': 'Establir com a Per Defecte',
      'delete': 'Eliminar',
      'deleteAddress': 'Eliminar Adreça',
      'confirmDeleteAddress': 'Estàs segur que vols eliminar aquesta adreça? Aquesta acció no es pot desfer.',
      'defaultAddressUpdated': 'Adreça per defecte actualitzada',
      'addressDeletedSuccessfully': 'Adreça eliminada amb èxit',
 'completeAddressDetails': 'Completar Detalls de l\'Adreça',
      'selectAddress': 'Seleccionar Adreça',
      'savedAddresses': 'Adreces Guardades',
      'addYourFirstAddress': 'Afegeix la Teva Primera Adreça',
      'addNewAddress': 'Afegir Nova Adreça',
      'searchAddress': 'Cercar Adreça',
      'startTypingAddress': 'Comença a escriure la teva adreça...',
      'noAddressesFound': 'No s\'han trobat adreces',
      'tryDifferentSearch': 'Prova amb un terme de cerca diferent',
      'office': 'Oficina',
      'other': 'Altres',
      'apartmentNumber': 'Número d\'Apartament/Casa *',
      'apartmentPlaceholder': 'p.ex., Apto 4B, Pis 2, Edifici C',
      'deliveryInstructions': 'Instruccions de Lliurament (Opcional)',
      'deliveryInstructionsPlaceholder': 'p.ex., Toca el timbre, Deixa a la porta',
      'saveAddress': 'Guardar Adreça',
      'pleaseEnterApartment': 'Si us plau, introdueix el número d\'apartament/casa',
      'addressSavedWithDistance': 'Adreça guardada! Distància: {distance}',
      'addressBeyondRangeWithLimit': 'Ho sentim, aquesta adreça està fora del nostre rang de lliurament de {limit}km',
      'failedToFetchPlaceDetails': 'No s\'han pogut obtenir els detalls del lloc',
      'noDescription': 'Sense descripció',
      'pleaseSelectDeliveryAddress': 'Si us plau, selecciona una adreça de lliurament',
      'addressBeyondDeliveryRange': 'L\'adreça seleccionada està fora del rang de lliurament',
      'pickupLocation': 'Ubicació de Recollida',
      'pickupTime': 'Hora de Recollida',
      'cartEmpty': 'El teu carret està buit',
      'moreItems': '+{count} elements més',

      'noOrdersDescription': 'El teu historial de comandes apareixerà aquí\nun cop facis la teva primera comanda',
      'startOrdering': 'Començar a Demanar',
      'orderNumber': 'Comanda #{id}',
      'viewDetails': 'Veure Detalls',
      'goToMenu': 'Anar al menú',
      'item': 'article',
      'items': 'articles',
      'branch': 'Sucursal',
      'pickup': 'Recollida',
          'welcomeBack': '¡Bienvenido de nuevo! Por favor, introduce tus credenciales.',

      'yesterday': 'Ahir',
      'pressBackAgain': 'Prem de nou per sortir',
      'quickActions': 'Accions Ràpides',
      'downloadData': 'Descarregar Dades',
      'helpCenter': 'Centre d\'Ajuda',
      'accountSettings': 'Configuració de Compte',
      'personalInformation': 'Informació Personal',
      'preferences': 'Preferències',
      'notifications': 'Notificacions',
      'privacy': 'Privadesa',
      'securityAndSupport': 'Seguretat i Suport',
      'changePassword': 'Canviar Contrasenya',
      'helpAndSupport': 'Ajuda i Suport',
      'about': 'Sobre',
      'signInPrompt': 'Inicia sessió per accedir al teu perfil i comandes',
      'viewPastOrders': 'Veure les teves comandes anteriors',
      'updatePassword': 'Actualitzar la teva contrasenya',
      'contactUs': 'Contacta\'ns',
      'getInTouch': 'Posa\'t en contacte amb nosaltres',
      'learnAboutUs': 'Coneix més sobre nosaltres',
      'notificationPreferences': 'Preferències de notificacions',
      'getHelpAndSupport': 'Obtenir ajuda i suport',
      'appVersion': 'Versió 1.0.0',
      'aboutApp': 'Sobre Saborly',
      'appDescription': 'Benvingut a Saborly! Entreguem menjar deliciós dels teus restaurants favorits directament a la teva porta.',
      'copyright': '© 2025 Saborly. Tots els drets reservats.',
      'companyAddress': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Espanya',
      'close': 'Tancar',
      'save': 'Desar',
      'areYouSureSignOut': 'Estàs segur que vols tancar sessió?',
        // New translations
      'imageNotAvailable': 'Imatge no disponible',
      'addedToCart': '{itemName} afegit al carret',
      'undo': 'Desfer',
      'outOfStock': 'sense existències',
      'loadingMenu': 'Carregant menú deliciós...',
      'noCategoriesAvailable': 'No hi ha categories disponibles',
      'noFoodItemsAvailable': 'No hi ha elements de menjar disponibles',
      'discoverOfferings': 'Descobreix les nostres delicioses ofertes',
     
      'nonVegetarian': 'No Vegetarià',
      'popular': 'Popular',
      'popularItems': 'Elements Populars',
      'foodType': 'Tipus de Menjar',
      'clearAll': 'Esborrar Tot',
      'apply': 'Aplicar',
        'appLogo': 'Logotip de l\'Aplicació',
      'noItems': 'No hi ha elements {type}',
      'checkBackLater': 'Torna a consultar més tard per elements {type}',
      'featured': 'Destacats',
         
      'aboutUs': 'Sobre Nosaltres',

      'cart': 'Carret',
   
      'account': 'Compte',
       'orderNotFound': 'Comanda no trobada',
      'goBack': 'Tornar',
      'collected': 'Recollit',
      'readyForPickup': 'Llest per Recollir',
      'callRestaurant': 'Trucar al Restaurant',
      'restaurantAddress': 'Saborly, C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Espanya',
      'estimatedTime': '40 min',
  
      'paymentFailed': 'Fallat',
      'paymentRefunded': 'Reemborsat',
      'emptyOrderItems': 'Els teus deliciosos elements de la comanda',
   
      'tax': 'Impost:',
  
      'jan': 'Gen',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Abr',
      'may': 'Mai',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Ago',
      'sep': 'Set',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Des',
  
      'callError': 'No es pot fer una trucada a 34932112072',
      'callErrorGeneric': 'Error en fer la trucada: {error}',
        'loadingOffers': 'Carregant ofertes increïbles...',
    
      'noOffersAvailable': 'No Hi Ha Ofertes Disponibles',
      'checkBackLaterOffers': 'Torna a consultar més tard per ofertes emocionants.\nS\'afegeixen noves ofertes regularment.',
      'browseMenu': 'Explorar Menú',
 "startYourCulinaryJourney": "Comença el teu viatge culinari",
  "searchFoodDescription": "Cerca els teus plats, cuines o ingredients preferits per descobrir opcions de menjar increïbles",
      'addFoodToStart': 'Afegeix menjar deliciós per començar',
      "pizza": "Pizza",
  "burger": "Hamburguesa",
  "pasta": "Pasta",
  "salad": "Amanida",
      'specialInstructionsHint': 'Qualsevol sol·licitud o instrucció especial per a la teva comanda per emportar...',
      'orderSummary': 'Resum de la Comanda',
      'sizeLabel': 'Mida:',
      'extrasLabel': 'Extres:',
      'addonsLabel': 'Complements:',
      'deliveryOrder': 'Comanda a Domicili',
      'payAtShopDescription': 'Paga a la botiga quan recullis la teva comanda',
      'choosePaymentDelivery': 'Tria com vols pagar quan es lliuri',
      'paymentSummary': 'Resum de Pagament',
      'orderType': 'Tipus de Comanda',
 
      'payAtShopCounter': 'Paga al taulell de la botiga quan recullis',
      'payWithCashOnDelivery': 'Paga amb efectiu quan arribi la teva comanda',
      'payWithCardOnDelivery': 'Paga amb targeta quan arribi la teva comanda',
      'shopPayment': 'Pagament a la Botiga',
      'deliveryPayment': 'Pagament a Domicili',
      'choosePaymentType': 'Tria el Tipus de Pagament',
      'otherOptionsComingSoon': 'Altres Opcions (Properament)',
      'payAtShop': 'Pagar a la Botiga',
      'paypalDescription': 'Paga de forma segura amb PayPal',
      'stripeDescription': 'Paga amb targeta de crèdit o dèbit',
      'cardDescription': 'Paga amb VISA o Mastercard',
      'comingSoon': 'Properament',
      'payWithCash': 'Pagar amb efectiu',
      'payWithCard': 'Pagar amb targeta',
      'noneSelected': 'Cap Seleccionat',
      'shopPaymentMethod': 'Pagament a la Botiga',
      'errorFailedToLoadOrder': 'Error: No s\'ha pogut carregar l\'estat de la comanda',

      'unexpectedError': 'Error inesperat. Si us plau, intenta de nou.',
      'businessHours': 'Dill - Diu: 12:00 - 23:00',
      'address': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelona, Espanya',
      'infoEmail': 'info@saborly.es',
      'supportEmail': 'suport@saborly.es',
      'formSubmissionSuccess': 'Gràcies! El teu missatge s\'ha enviat amb èxit.',
      'formSubmissionError': 'No s\'ha pogut enviar el missatge. Si us plau, intenta de nou.',
       'tagline': 'Menjar deliciós, lliurat ràpid',
      'failedToLoadOffers': 'No s\'han pogut carregar les ofertes',
      'unknownError': 'Error desconegut',
     
      'days': '{days} dies',
      'offerPlaceholder': 'Oferta',
       'brandDescription': 'Experiències culinàries excepcionals que delecten els teus sentits. Uneix-te a la nostra comunitat gastronòmica.',

      // Quick Links
      'quickLinks': 'Enllaços Ràpids',
   
      'reservations': 'Reserves',
      'gallery': 'Galeria',
      'blog': 'Blog',
      'careers': 'Carreres',

      // Resources Links
      'resources': 'Recursos',
      
      'privacyPolicy': 'Política de Privacitat',
      'termsOfService': 'Termes de Servei',
      'cookiePolicy': 'Política de Cookies',
      'faq': 'Preguntes Freqüents',

      // Contact Section
      'stayConnected': 'Mantén-te Connectat',
      'subscribeOffers': 'Subscriu-te per a ofertes exclusives',
      'yourEmail': 'El teu correu electrònic',
      'subscribe': 'Subscriure\'s',
     
      // Copyright

      // Payment Methods
      'weAccept': 'Acceptem',
      'visa': 'Visa',
           'resetPassword': 'Restablir Contrasenya',

      // Form Fields
      'enterYourEmail': 'Introdueix el teu correu electrònic',

      'verificationCode': 'Codi de Verificació',
      'enter6DigitCode': 'Introdueix el codi de 6 dígits',
      'pleaseEnterCode': 'Si us plau, introdueix el codi',
      'codeMustBe6Digits': 'El codi ha de tenir 6 dígits',
      'newPassword': 'Nova Contrasenya',
      'enterNewPassword': 'Introdueix la nova contrasenya',
      'passwordMinLength': 'La contrasenya ha de tenir almenys 6 caràcters',
      'reEnterNewPassword': 'Torna a introduir la nova contrasenya',
      'pleaseConfirmPassword': 'Si us plau, confirma la teva contrasenya',
      'passwordsDoNotMatch': 'Les contrasenyes no coincideixen',
      'backToLogin': 'Tornar a l\'Inici de Sessió',
  "manageYourAccount": "Gestiona el teu compte",
      // SnackBar Messages
      'resetCodeSent': 'Codi de restabliment enviat al teu correu',
      'failedToSendResetCode': 'No s\'ha pogut enviar el codi de restabliment',
      'invalid6DigitCode': 'Si us plau, introdueix un codi de 6 dígits vàlid',
      'codeVerified': 'Codi verificat amb èxit',
      'invalidOrExpiredCode': 'Codi invàlid o expirat',
      'passwordResetSuccess': 'Contrasenya restablida amb èxit!',
      'failedToResetPassword': 'No s\'ha pogut restablir la contrasenya',
      'newCodeSent': 'Nou codi enviat al teu correu',
      'failedToSendCode': 'No s\'ha pogut enviar el codi',

      // Titles
      'createNewPassword': 'Crear Nova Contrasenya',
      'verifyCode': 'Verificar Codi',

      // Subtitles
      'enterNewPasswordSubtitle': 'Si us plau, introdueix la teva nova contrasenya',
      'enterCodeSubtitle': 'Introdueix el codi de 6 dígits enviat a {email}',
      'enterEmailSubtitle': 'Introdueix el teu correu per rebre un codi de restabliment',

      // Button Texts
      'resetPasswordButton': 'Restablir Contrasenya',
      'verifyCodeButton': 'Verificar Codi',
      'sendResetCode': 'Enviar Codi de Restabliment',
      'resendCodeCountdown': 'Reenviar codi en {seconds}s',
      'resendCode': 'Reenviar Codi',
      'allSet': 'Tot a Punt!',
      'passwordUpdatedDescription': 'La teva contrasenya s\'ha actualitzat amb èxit. Ara pots iniciar sessió amb la teva nova contrasenya.',
      'newPasswordRequirements': 'La teva nova contrasenya ha de ser diferent de l\'anterior i complir amb els nostres requisits de seguretat.',

      // Password Requirements
      'passwordMinLength8': 'Almenys 8 caràcters de llargada',
      'passwordUpperLower': 'Conté lletres majúscules i minúscules',
      'passwordNumber': 'Inclou almenys un número',
      'passwordSpecialChar': 'Té almenys un caràcter especial',

      // Form Header and Header
      'passwordUpdated': 'Contrasenya Actualitzada!',
      'passwordChanged': 'La teva contrasenya s\'ha canviat amb èxit.',
      'createStrongPassword': 'Crea una nova contrasenya segura per al teu compte.',
  "editProfile": "Edita el perfil",
      // Password Fields
     'passwordMinLength8Error': 'La contrasenya ha de tenir almenys 8 caràcters',
      'passwordSecurityError': 'La contrasenya ha de complir amb els requisits de seguretat',
  "paymentInfo": "Informació de pagament",
      // Form

      // Success Content
      'passwordResetSuccessDescription': 'La teva contrasenya s\'ha actualitzat amb èxit. Ara pots iniciar sessió amb la teva nova contrasenya.',
      'passwordSecurityTip': 'Mantén la teva contrasenya segura i no la comparteixis amb ningú.',

      // Sign In Button
      'signInNow': 'Iniciar Sessió Ara',
  "visitUs": "Visita'ns",
      // SnackBar Messages
      'passwordUpdatedSuccess': 'Contrasenya actualitzada amb èxit!',
      'passwordResetFailed': 'No s\'ha pogut restablir la contrasenya. Si us plau, intenta de nou.',

       // AppBar and Web Header
      'secureAccount': 'Mantén el teu compte segur amb una contrasenya forta',

      // Password Card
      'currentPassword': 'Contrasenya Actual',
      'enterCurrentPassword': 'Introdueix la contrasenya actual',
      'pleaseEnterCurrentPassword': 'Si us plau, introdueix la teva contrasenya actual',
      'pleaseEnterNewPassword': 'Si us plau, introdueix una nova contrasenya',
      'passwordMinLength6': 'La contrasenya ha de tenir almenys 6 caràcters',
      'newPasswordDifferent': 'La nova contrasenya ha de ser diferent de l\'actual',
      'pleaseConfirmNewPassword':'Si us plau, confirma la teva nova contrasenya',

      // Security Tips
      'passwordRequirements': 'Requisits de Contrasenya',
      'passwordMinLength6Tip': 'Almenys 6 caràcters de llargada',
      'passwordNumbersSpecial': 'Afegeix números i caràcters especials',
      'avoidCommonWords': 'Evita paraules o patrons comuns',
  "yourMessage": "El teu missatge",
      // Button
      'changePasswordButton': 'Canviar Contrasenya',

      // SnackBar Messages
      'passwordChangedSuccess': 'Contrasenya canviada amb èxit',
      'passwordChangeFailed': 'No s\'ha pogut canviar la contrasenya',
       'verifyYourEmail': 'Verifica el teu Correu Electrònic',
      'sentVerificationCode': 'Hem enviat un codi de verificació a',

      // Timer
      'codeExpired': 'Codi expirat',
      'codeExpiresIn': 'El codi expira en {time}',

      // Resend Button
      'didntReceiveCode': 'No has rebut el codi? ',
      'resend': 'Reenviar',

      // Button
      'verifyEmail': 'Verificar Correu',

      // SnackBar Messages
      'emailVerifiedSuccess': 'Correu verificat amb èxit!',
      'invalidOrExpiredOTP': 'Codi OTP invàlid o expirat. Si us plau, intenta de nou.',
        'joinApp': 'Uneix-te a Saborly',
      'createAccountDescription': 'Crea el teu compte i comença el teu viatge amb nosaltres. Experimenta la millor plataforma de compres dissenyada per a tu.',

      // Feature List
      'secureCheckout': 'Pagament segur i ràpid',
      'personalizedRecommendations': 'Recomanacions personalitzades',
      'exclusiveBenefits': 'Beneficis exclusius per a membres',
      'customerSupport': 'Suport al client 24/7',

      // Form Header and Header
      'createAccount': 'Crear Compte',
      'fillInDetails': 'Omple les teves dades per començar',
      'signUpToStart': 'Registrat per començar amb Saborly.',

      // SnackBar Messages
      'verificationCodeSent': 'Codi de verificació enviat! Si us plau, revisa el teu correu.',
      'accountCreatedSuccess': 'Compte creat amb èxit!',
       // AppBar

      // Hero Section
      'welcomeToApp': 'Benvingut a Saborly',
      'bestFastFoodDestination': 'La teva destinació per al millor menjar ràpid',

      // Story Section
      'ourStory': 'La Nostra Història',
      'storyDescription': 'Saborlyva néixer d’una passió per oferir menjar deliciós i de qualitat. Des dels nostres inicis, ens hem compromès a servir els millors plats, preparats amb ingredients frescos i receptes autèntiques. Cada dia treballem per superar les expectatives dels nostres clients i crear experiències culinàries memorables.',

      // Values Section
      'ourValues': 'Els Nostres Valors',
      'quality': 'Qualitat',
      'qualityDescription': 'Ingredients frescos i de primera qualitat',
      'speed': 'Rapidesa',
      'speedDescription': 'Servei ràpid sense comprometre la qualitat',
      'passion': 'Passió',
      'passionDescription': 'Amor pel que fem en cada plat',
  "activityOverview": "Resum d'activitat",
      // Mission Section
      'ourMission': 'La Nostra Missió',
      'missionDescription': 'Fer que cada àpat sigui una experiència especial, oferint sabors autèntics i un servei excepcional que superi les expectatives dels nostres clients.',
    "orderProgress": "Progreso del pedido",
  "writeUs": "Escriu-nos",
  "yourName": "El teu nom",
  "yourPhone": "El teu telèfon",
  "yourSubject": "موضوعك",
    "sendMessage": "Envia missatge",
      "followUs": "Segueix-nos",
        "readyIn": "Preparat en",
  "yourOrderWillBeReady": "La teva comanda estarà llesta",   
  
   "itemsOnOffer": "Articles en oferta",
     "frequentlyAskedQuestions": "Preguntes freqüents",

      'privacy_subtitle': 'La teva privacitat és la nostra prioritat',
      'privacy_intro': 'A Saborly, estem compromesos a protegir la teva privacitat i garantir la seguretat de la teva informació personal. Aquesta política explica com recollim, utilitzem i protegim les teves dades.',
      'last_updated': 'Darrera actualització: 18 d’octubre de 2025',
      'info_collect_title': 'Informació que Recollim',
      'info_collect_content': 'Recollim informació que ens proporciones directament quan crees un compte, fas una comanda o et comuniques amb nosaltres.',
      'info_collect_point1': 'Detalls personals (nom, correu electrònic, número de telèfon)',
      'info_collect_point2': 'Adreça de lliurament i dades d’ubicació',
      'info_collect_point3': 'Informació de pagament (xifrada de manera segura)',
      'info_collect_point4': 'Historial de comandes i preferències',
      'info_collect_point5': 'Informació del dispositiu i ús',
      'use_info_title': 'Com Utilitzem la Teva Informació',
      'use_info_content': 'Utilitzem la informació que recollim per oferir-te el millor servei possible.',
      'use_info_point1': 'Processar i complir les teves comandes',
      'use_info_point2': 'Enviar confirmacions i actualitzacions de comandes',
      'use_info_point3': 'Oferir suport al client',
      'use_info_point4': 'Millorar els nostres serveis i l’experiència de l’usuari',
      'use_info_point5': 'Enviar ofertes promocionals (amb el teu consentiment)',
      'use_info_point6': 'Prevenir fraus i garantir la seguretat',
      'sharing_title': 'Compartir i Divulgació d’Informació',
      'sharing_content': 'Respectem la teva privacitat i no venem la teva informació personal.',
      'sharing_point1': 'Proveïdors de serveis (processadors de pagaments, socis de lliurament)',
      'sharing_point2': 'Requisits legals i compliment de la llei',
      'sharing_point3': 'Transferències empresarials (fusiones, adquisicions)',
      'sharing_point4': 'Amb el teu consentiment explícit',
      'security_title': 'Seguretat de les Dades',
      'security_content': 'Implementem mesures de seguretat estàndard de la indústria per protegir la teva informació.',
      'security_point1': 'Xifratge SSL/TLS per a la transmissió de dades',
      'security_point2': 'Processament de pagaments segur (complint amb PCI DSS)',
      'security_point3': 'Auditories de seguretat i actualitzacions regulars',
      'security_point4': 'Controls d’accés i autenticació',
      'security_point5': 'Sistemes de còpia de seguretat i recuperació de dades',
      'rights_title': 'Els Teus Drets',
      'rights_content': 'Tu tens control sobre la teva informació personal.',
      'rights_point1': 'Accedir a les teves dades personals',
      'rights_point2': 'Corregir informació inexacta',
      'rights_point3': 'Sol·licitar l’eliminació de dades',
      'rights_point4': 'Oposar-te al processament',
      'rights_point5': 'Portabilitat de dades',
      'rights_point6': 'Retirar el consentiment en qualsevol moment',
      'cookies_title': 'Cookies i Seguiment',
      'cookies_content': 'Utilitzem cookies per millorar la teva experiència i analitzar patrons d’ús.',
      'cookies_point1': 'Cookies essencials (requerides per a la funcionalitat)',
      'cookies_point2': 'Cookies de rendiment (anàlisi)',
      'cookies_point3': 'Cookies funcionals (preferències)',
      'cookies_point4': 'Cookies de màrqueting (amb consentiment)',
      'children_privacy_title': 'Privacitat dels Nens',
      'children_privacy_content': 'Els nostres serveis no estan destinats a nens menors de 13 anys. No recollim conscientment informació personal de nens.',
      'contact_questions': 'Preguntes sobre la teva privacitat?',
      'contact_support': 'El nostre equip està aquí per ajudar-te a entendre com protegim les teves dades',
      'contact_email': 'support@saborly.es',
      'contact_phone': '+34 932 112 072',
  "deliveryNotAvailableNow": "El lliurament no està disponible ara",
  
      // FAQScreen
      'faq_subtitle': 'Troba respostes a preguntes comunes',
      'faq_category_all': 'Totes',
      'faq_category_orders': 'Comandes',
      'faq_category_payment': 'Pagament',
      'faq_category_delivery': 'Lliurament',
      'faq_category_account': 'Compte',
      'faq_contact_title': 'Encara tens preguntes?',
      'faq_contact_subtitle': 'El nostre equip de suport està disponible 24/7 per ajudar-te',
      'faq_contact_email': 'support@saborly.es',
      'faq_contact_phone': '+34 932 112 072',
      'faq_contact_chat': 'Xat en Viu (Pròximament)',
      'faq_order_place_question': 'Com faig una comanda?',
      'faq_order_place_answer': 'Fer una comanda és fàcil! Només explora el nostre menú, selecciona els teus articles preferits, personalitza’ls al teu gust i afegeix-los al carret. Quan estiguis llest, ves al pagament, introdueix els detalls de lliurament, tria el mètode de pagament i confirma la comanda. Rebràs un correu de confirmació immediatament.',
      'faq_order_modify_question': 'Puc modificar o cancel·lar la meva comanda?',
      'faq_order_modify_answer': 'Sí! Pots modificar o cancel·lar la teva comanda dins dels 5 minuts següents a fer-la a través de l’aplicació. Després d’aquest temps, el restaurant comença a preparar el teu menjar. Si necessites fer canvis després d’aquest període, contacta amb el nostre equip de suport al client immediatament i farem tot el possible per ajudar-te.',
      'faq_payment_methods_question': 'Quins mètodes de pagament accepteu?',
      'faq_payment_methods_answer': 'Acceptem totes les targetes de crèdit i dèbit principals (Visa, Mastercard, American Express), PayPal, Apple Pay i Google Pay. Tots els pagaments es processen a través de connexions segures i xifrades per garantir la protecció de la teva informació financera.',
      'faq_payment_security_question': 'És segura la meva informació de pagament?',
      'faq_payment_security_answer': 'Sí! Utilitzem xifratge SSL estàndard de la indústria i complim amb els estàndards PCI DSS per garantir que la teva informació de pagament estigui completament segura. Mai emmagatzemem els detalls complets de la teva targeta als nostres servidors.',
      'faq_delivery_time_question': 'Quant de temps triga el lliurament?',
      'faq_delivery_time_answer': 'El temps de lliurament típic és de 30-45 minuts, depenent de la teva ubicació, el temps de preparació i la demanda actual. Pots rastrejar la teva comanda en temps real a través de la nostra aplicació, i et notificarem en cada etapa del procés de lliurament.',
      'faq_delivery_fees_question': 'Hi ha tarifes de lliurament?',
      'faq_delivery_fees_answer': 'Les tarifes de lliurament varien segons la distància i el restaurant. La tarifa exacta sempre es mostra abans que confirmis la teva comanda.',
      'faq_delivery_contactless_question': 'Oferiu lliurament sense contacte?',
      'faq_delivery_contactless_answer': 'Sí! Oferim lliurament sense contacte per a la teva seguretat i conveniència. Només selecciona aquesta opció al pagar, i la teva comanda es deixarà a la teva porta amb una notificació enviada al teu telèfon.',
      'faq_account_track_question': 'Com puc rastrejar la meva comanda?',
      'faq_account_track_answer': 'Pots rastrejar la teva comanda en temps real a través de la nostra aplicació o lloc web. Després de fer la comanda, veuràs actualitzacions en viu, incloent-hi la confirmació de la comanda, l’estat de preparació, la notificació de l’enviament i el temps estimat de lliurament. També pots veure la ubicació del teu repartidor al mapa.',
      'faq_account_incorrect_question': 'Què passa si la meva comanda és incorrecta o falten articles?',
      'faq_account_incorrect_answer': 'Si hi ha algun problema amb la teva comanda, contacta’ns immediatament a través de l’aplicació o el suport al client. Fes fotos del problema si és possible. Treballarem amb el restaurant per resoldre el problema i oferir un reemborsament, reemplaçament o crèdit al teu compte.',
      'faq_account_dietary_question': 'Teniu filtres dietètics?',
      'faq_account_dietary_answer': 'Sí! Pots filtrar els elements del menú per preferències dietètiques, incloent-hi vegetarià, vegà, sense gluten, sense lactis, sense fruits secs, halal i kosher. També proporcionem informació detallada sobre al·lèrgens per a cada plat. Cerca l’icona de filtre al menú de l’aplicació.',
  "noNotifications": "Sense notificacions",
  "youWillSeeNotificationsHere": "Veuràs les notificacions aquí",
  "markAllAsRead": "Marca-ho tot com a llegit",
  "allNotificationsMarkedAsRead": "Totes les notificacions marcades com a llegides",
  "notificationDeleted": "Notificació eliminada",
  "clearAllNotifications": "Esborra totes les notificacions",
  "areYouSureYouWantToClearAllNotifications": "Estàs segur que vols esborrar totes les notificacions?",
  "allNotificationsCleared": "Totes les notificacions esborrades",
  "noNotificationsInThisCategory": "No hi ha notificacions en aquesta categoria",


    "restaurantClosed": "Restaurante cerrado",
  "restaurantClosedDescription": "Lo sentimos, no estamos aceptando pedidos en este momento",
  "checkOurHours": "Consulta nuestro horario",
  "closingSoon": "Cerrando pronto",
  "orderBeforeClosing": "Haz tu pedido antes de que cerremos",
   },
    
    // ==================== ARABIC ====================
    'ar': {
      // App Info
      'appName': 'Saborly',
      'appSlogan': 'طعام لذيذ يتم تسليمه بسرعة',
       "changeAddress": "تغيير العنوان",
       "yourName": "اسمك",
         "yourPhone": "هاتفك",
           "activityOverview": "نظرة عامة على النشاط",
  "yourSubject": "موضوعك",
    "readyIn": "جاهز خلال"
,  "deliveryNotAvailableNow": "التوصيل غير متاح الآن",
  "frequentlyAskedQuestions": "الأسئلة الشائعة",
  "orderProgress": "تقدم الطلب",
  "yourOrderWillBeReady": "سيكون طلبك جاهزًا",
    "driverPickup": "استلام السائق",
      // General
      'search': 'بحث',
      'viewAll': 'عرض الكل',
      'add': 'إضافة',
      'remove': 'إزالة',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'retry': 'إعادة المحاولة',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجاح',
      'somethingWentWrong': 'حدث خطأ ما',
      'noData': 'لا توجد بيانات',
      'noInternet': 'لا يوجد اتصال بالإنترنت',
      'shop': 'متجر',
          'specialOffers': 'عروض خاصة',
    'hotDeals': 'عروض ساخنة',
    'exclusiveOffers': 'عروض حصرية',
    'saveUpTo': 'وفر حتى 50٪ على وجباتك المفضلة',
      // Navigation
      'home': 'الرئيسية',
      'menu': 'القائمة',
      'offers': 'العروض',
      'profile': 'الملف الشخصي',
      'back': 'رجوع',
        "range": "النطاق"
,      'welcomeBack': 'مرحبًا بعودتك! يرجى إدخال بياناتك.',
  "yourMessage": "رسالتك",
        "canDeliver": "يمكن التوصيل",
      // Authentication
      'signIn': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'signOut': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'هل نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'هل لديك حساب بالفعل؟',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'phoneNumber': 'رقم الهاتف',
      'loginRequired': 'يرجى تسجيل الدخول للمتابعة',
      'loginToContinue': 'تسجيل الدخول للمتابعة',
      "nonVegetarian": "غير نباتي",
        "writeUs": "اكتب لنا",
  "message": "رسالة",
      // Home
      'ourMenu': 'قائمتنا',
      'featuredItems': 'عناصر مميزة',
      'mostPopularItems': 'العناصر الأكثر شعبية',
      'freeDelivery': 'توصيل مجاني',
      'tryChicken': 'جرب الدجاج',
      'freeShake': 'مخفوق مجاني',
      'coolDown': 'انتعش',
       'orderCompleted':'تم إكمال الطلب',
      // Categories
      'friendsFamily': 'كومبو الأصدقاء\nوالعائلة',
      'highOnCoffee': 'كومبو القهوة\nالعالية',
      'duetCombos': 'كومبو الثنائي',
      'whopper': 'واوبر',
      'veg': 'نباتي',
      'nonVeg': 'غير نباتي',
        "followUs": "تابعنا",
      // Cart & Checkout
      'myCart': 'سلتي',
      'checkout': 'الدفع',
      'proceedToCheckout': 'المتابعة للدفع',
      'placeOrder': 'تأكيد الطلب',
      'addToCart': 'أضف إلى السلة',
      'quantity': 'الكمية',
      'mealSize': 'حجم الوجبة',
      'mediumMeal': 'وجبة متوسطة',
      'largeMeal': 'وجبة كبيرة',
      'burgerOnly': 'برجر فقط',
      'extras': 'إضافات',
      'addons': 'إضافات إضافية',
      'extraCheese': 'جبن إضافي',
      'extraPattyChicken': 'قطعة دجاج إضافية',
      'specialInstructions': 'تعليمات خاصة',
      'instructionsHint': 'أي ملاحظات للطلب (جبن، إلخ)',
      'subtotal': 'المجموع الفرعي',
      'deliveryFee': 'رسوم التوصيل',
      'total': 'الإجمالي',
      'cartSummary': 'ملخص السلة',
      'frequentlyBoughtTogether': 'تم شراؤها معاً بشكل متكرر',
      "subject": "الموضوع",
      // Delivery & Location
      'delivery': 'توصيل',
      'takeaway': 'استلام',
      'selectBranch': 'اختر الفرع',
      'deliveryAddress': 'عنوان التوصيل',
      'addAddress': 'إضافة عنوان',
      'editAddress': 'تعديل العنوان',
      'homeAddress': 'المنزل',
      'workAddress': 'العمل',
      'preferenceTime': 'وقت التوصيل المفضل',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'now': 'الآن',
        "itemsOnOffer": "عناصر على العرض"
,
 "pizza": "بيتزا",
  "burger": "برجر",
  "pasta": "معكرونة",
  "salad": "سلطة",
      'estimatedDelivery': 'وقت التوصيل المتوقع',
        "calculating": "جارٍ الحساب",
      // Payment
      'selectPaymentMethod': 'اختر طريقة الدفع',
      'paypal': 'باي بال',
      'stripe': 'سترايب',
      'visaCard': 'بطاقة فيزا',
      'mastercard': 'ماستركارد',
      'cardNumber': 'رقم البطاقة',
      'expiresOn': 'تنتهي في',
      'payNow': 'ادفع الآن',
      'cancelOrder': 'إلغاء',
      'cashOnDelivery': 'الدفع عند الاستلام',
      'paymentMethod': 'طريقة الدفع',
      'paymentStatus': 'حالة الدفع',
      'unpaid': 'غير مدفوع',
      'paid': 'مدفوع',
      
      // Orders
      'orderStatus': 'حالة الطلب',
      'orderDetails': 'تفاصيل الطلب',
      'orderPlaced': 'تم تقديم الطلب',
      'orderConfirmed': 'تم تأكيد الطلب',
      'preparing': 'قيد التحضير',
      'outForDelivery': 'في الطريق',
      'ready': 'جاهز للاستلام',
      'delivered': 'تم التوصيل',
      'getYourOrder': 'احصل على طلبك ',
      'orderHistory': 'سجل الطلبات',
      'reorder': 'إعادة الطلب',
      'trackOrder': 'تتبع الطلب',
       "startYourCulinaryJourney": "ابدأ رحلتك الطهوية",
  "searchFoodDescription": "ابحث عن أطباقك أو مطابخك أو مكوناتك المفضلة لاكتشاف خيارات طعام مذهلة",
      // Validation Messages
      'pleaseEnterEmail': 'يرجى إدخال بريدك الإلكتروني',
      'pleaseEnterValidEmail': 'يرجى إدخال بريد إلكتروني صالح',
      'pleaseEnterPassword': 'يرجى إدخال كلمة المرور',
      'passwordTooShort': 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل',
      'passwordsDontMatch': 'كلمات المرور غير متطابقة',
      'pleaseEnterName': 'يرجى إدخال اسمك',
      'pleaseEnterPhone': 'يرجى إدخال رقم هاتفك',
      
      // Success Messages
      'orderPlacedSuccessfully': 'تم تقديم الطلب بنجاح!',
      'accountCreatedSuccessfully': 'تم إنشاء الحساب بنجاح!',
      'profileUpdatedSuccessfully': 'تم تحديث الملف الشخصي بنجاح!',
      'addressAddedSuccessfully': 'تم إضافة العنوان بنجاح!',
      
      // Error Messages
      'failedToPlaceOrder': 'فشل في تقديم الطلب',
      'failedToLogin': 'فشل تسجيل الدخول',
      'failedToCreateAccount': 'فشل في إنشاء الحساب',
      'failedToLoadData': 'فشل في تحميل البيانات',
      'failedToUpdateProfile': 'فشل في تحديث الملف الشخصي',
        "sendMessage": "إرسال رسالة",
      // Time
      'minutes': 'دقيقة',
      'hours': 'ساعات',
      'am': 'ص',
      'pm': 'م',
      
      // Price
      'currency': '€',
      'free': 'مجاني',
      
      // Restaurant Info
      'boshundhoraRA': 'إسبانيا',
      'gulshan2': 'إسبانيا',
      'banani': 'إسبانيا',
      'dhanmondi': 'إسبانيا',
      'km': 'كم',
      'flat': 'شقة',
      'house': 'منزل',
      'road': 'طريق',
       'discoverOurOfferings': 'اكتشف عروضنا اللذيذة',
    'allCategories': 'جميع الفئات',
    'loadingYourOrders': 'جاري تحميل طلباتك...',
    'oopsSomethingWrong': 'عذراً! حدث خطأ ما',
    'noOrdersYet': 'لا توجد طلبات بعد',
  "editProfile": "تعديل الملف الشخصي",
    'sendUsMessage': 'أرسل لنا رسالة',
    'fullName': 'الاسم الكامل',
    'accountManagement': 'إدارة الحساب',
    'emptyCart': 'سلتك فارغة',
    'deliveryAvailable': 'التوصيل متاح',
    'pickupOrder': 'طلب استلام',
    'cash': 'نقدي',
    'card': 'بطاقة',
    'loadingDeliciousMenu': 'جاري تحميل القائمة اللذيذة...',
    'filters': 'الفلاتر',
    'vegetarian': 'نباتي',
    'pending': 'قيد الانتظار',
    'confirmed': 'مؤكد',
   'default': 'افتراضي',
      'chooseDeliveryAddress': 'اختر مكان تسليم طلبك',
      'setAsDefault': 'تعيين كافتراضي',
      'delete': 'حذف',
      'deleteAddress': 'حذف العنوان',
      'confirmDeleteAddress': 'هل أنت متأكد من أنك تريد حذف هذا العنوان؟ لا يمكن التراجع عن هذا الإجراء.',
      'defaultAddressUpdated': 'تم تحديث العنوان الافتراضي',
      'addressDeletedSuccessfully': 'تم حذف العنوان بنجاح',
       'completeAddressDetails': 'إكمال تفاصيل العنوان',
      'selectAddress': 'اختيار العنوان',
      'savedAddresses': 'العناوين المحفوظة',
      'addYourFirstAddress': 'أضف عنوانك الأول',
      'addNewAddress': 'إضافة عنوان جديد',
      'searchAddress': 'البحث عن عنوان',
      'startTypingAddress': 'ابدأ بكتابة عنوانك...',
      'noAddressesFound': 'لم يتم العثور على عناوين',
      'tryDifferentSearch': 'جرب مصطلح بحث مختلف',
      'office': 'مكتب',
      'other': 'أخرى',
      'apartmentNumber': 'رقم الشقة/المنزل *',
      'apartmentPlaceholder': 'مثال، شقة 4B، الطابق 2، المبنى C',
      'deliveryInstructions': 'تعليمات التسليم (اختياري)',
      'deliveryInstructionsPlaceholder': 'مثال، قرع الجرس، اترك عند الباب',
      'saveAddress': 'حفظ العنوان',
      'pleaseEnterApartment': 'يرجى إدخال رقم الشقة/المنزل',
      'addressSavedWithDistance': 'تم حفظ العنوان! المسافة: {distance}',
      'addressBeyondRangeWithLimit': 'عذرًا، هذا العنوان خارج نطاق التسليم البالغ {limit}كم',
      'failedToFetchPlaceDetails': 'فشل في جلب تفاصيل المكان',
      'noDescription': 'لا يوجد وصف',
      'pleaseSelectDeliveryAddress': 'يرجى اختيار عنوان التسليم',
      'addressBeyondDeliveryRange': 'العنوان المختار خارج نطاق التسليم',
      'pickupLocation': 'موقع الاستلام',
      'pickupTime': 'وقت الاستلام',
      'cartEmpty': 'عربتك فارغة',
      'moreItems': '+{count} عناصر أخرى',
      
      'noOrdersDescription': 'سوف يظهر سجل طلباتك هنا\nبمجرد تقديم طلبك الأول',
      'startOrdering': 'ابدأ الطلب',
      'orderNumber': 'الطلب #{id}',
      'totalAmount': 'المبلغ الإجمالي',
      'viewDetails': 'عرض التفاصيل',
      'goToMenu': 'الذهاب إلى القائمة',
      'item': 'عنصر',
      'items': 'عناصر',
      'branch': 'فرع',
      'pickup': 'استلام',
      "visitUs": "زرنا",
  "manageYourAccount": "إدارة حسابك",
      'yesterday': 'أمس',
      'pressBackAgain': 'اضغط مرة أخرى للخروج',
      'quickActions': 'إجراءات سريعة',
      'downloadData': 'تنزيل البيانات',
      'helpCenter': 'مركز المساعدة',
      'accountSettings': 'إعدادات الحساب',
      'personalInformation': 'المعلومات الشخصية',
      'preferences': 'التفضيلات',
      'notifications': 'الإشعارات',
      'privacy': 'الخصوصية',
      'securityAndSupport': 'الأمان والدعم',
      'changePassword': 'تغيير كلمة المرور',
      'helpAndSupport': 'المساعدة والدعم',
      'about': 'حول',
      'signInPrompt': 'تسجيل الدخول للوصول إلى ملفك الشخصي والطلبات',
      'viewPastOrders': 'عرض طلباتك السابقة',
      'updatePassword': 'تحديث كلمة المرور الخاصة بك',
      'contactUs': 'اتصل بنا',
      'getInTouch': 'تواصل معنا',
      'learnAboutUs': 'تعرف على المزيد عنا',
      'notificationPreferences': 'تفضيلات الإشعارات',
      'getHelpAndSupport': 'الحصول على المساعدة والدعم',
      'appVersion': 'الإصدار 1.0.0',
      'aboutApp': 'حول Saborly',
      'appDescription': 'مرحبًا بك في Saborly! نحن نوصل طعامًا لذيذًا من مطاعمك المفضلة مباشرة إلى بابك.',
      'copyright': '© 2025 Saborly. جميع الحقوق محفوظة.',
      'companyAddress': 'شارع بيري الرابع، 208، سان مارتي، 08005 برشلونة، إسبانيا',
      'close': 'إغلاق',
      'save': 'حفظ',
      'areYouSureSignOut': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
         'imageNotAvailable': 'الصورة غير متوفرة',
      'addedToCart': 'تم إضافة {itemName} إلى السلة',
      'undo': 'تراجع',
      'outOfStock': 'نفد المخزون',
         // New translations
      'loadingMenu': 'جارٍ تحميل القائمة اللذيذة...',
      'noCategoriesAvailable': 'لا توجد فئات متاحة',
      'noFoodItemsAvailable': 'لا توجد عناصر طعام متاحة',
      'discoverOfferings': 'اكتشف عروضنا اللذيذة',
 
      'popular': 'شعبي',
      'popularItems': 'العناصر الشعبية',
      'foodType': 'نوع الطعام',
      'clearAll': 'مسح الكل',
      'apply': 'تطبيق',
         'appLogo': 'شعار التطبيق',
      'noItems': 'لا توجد عناصر {type}',
      'checkBackLater': 'تحقق لاحقًا لعناصر {type}',
      'featured': 'مميزة',
   
      'aboutUs': 'معلومات عنا',

      'cart': 'السلة',

      'account': 'الحساب',
       'orderNotFound': 'الطلب غير موجود',
      'goBack': 'ارجع',
      'collected': 'تم الاستلام',
      'readyForPickup': 'جاهز للاستلام',
      'callRestaurant': 'الاتصال بالمطعم',
      'restaurantAddress': 'سابورلي، شارع بيري الرابع، 208، سان مارتي، 08005 برشلونة، إسبانيا',
      'estimatedTime': '40 دقيقة',
   
      'paymentFailed': 'فشل',
      'paymentRefunded': 'تم استرداد المبلغ',
      'emptyOrderItems': 'عناصر طلبك اللذيذة',
     
      'tax': 'الضريبة:',
     
      'jan': 'يناير',
      'feb': 'فبراير',
      'mar': 'مارس',
      'apr': 'أبريل',
      'may': 'مايو',
      'jun': 'يونيو',
      'jul': 'يوليو',
      'aug': 'أغسطس',
      'sep': 'سبتمبر',
      'oct': 'أكتوبر',
      'nov': 'نوفمبر',
      'dec': 'ديسمبر',
     
      'callError': 'غير قادر على إجراء مكالمة إلى 34932112072',
      'callErrorGeneric': 'خطأ أثناء إجراء المكالمة: {error}',
          'loadingOffers': 'جارٍ تحميل عروض مذهلة...',
    
      'noOffersAvailable': 'لا توجد عروض متاحة',
      'checkBackLaterOffers': 'تحقق لاحقًا للحصول على عروض مثيرة!\nتُضاف عروض جديدة بانتظام.',
      'browseMenu': 'تصفح القائمة',
     
      'addFoodToStart': 'أضف بعض الطعام اللذيذ للبدء',

      'specialInstructionsHint': 'أي طلبات أو تعليمات خاصة لطلبك للاستلام...',
      'orderSummary': 'ملخص الطلب',
      'sizeLabel': 'الحجم:',
      'extrasLabel': 'إضافات:',
      'addonsLabel': 'الإضافات:',
      'deliveryOrder': 'طلب توصيل',
      'payAtShopDescription': 'ادفع في المتجر عند استلام طلبك',
      'choosePaymentDelivery': 'اختر كيف تريد الدفع عند التوصيل',
      'paymentSummary': 'ملخص الدفع',
      'orderType': 'نوع الطلب',
      'paymentType': 'نوع الدفع',
     
      'payAtShopCounter': 'ادفع عند مكتب المتجر عند الاستلام',
      'payWithCashOnDelivery': 'ادفع نقدًا عند وصول طلبك',
      'payWithCardOnDelivery': 'ادفع بالبطاقة عند وصول طلبك',
      'shopPayment': 'الدفع في المتجر',
      'deliveryPayment': 'الدفع عند التوصيل',
      'choosePaymentType': 'اختر نوع الدفع',
      'otherOptionsComingSoon': 'خيارات أخرى (قريبًا)',
      'payAtShop': 'الدفع في المتجر',
      'paypalDescription': 'ادفع بأمان مع باي بال',
      'stripeDescription': 'ادفع ببطاقة الائتمان أو الخصم',
      'cardDescription': 'ادفع بفيزا أو ماستركارد',
      'comingSoon': 'قريبًا',
      'payWithCash': 'الدفع نقدًا',
      'payWithCard': 'الدفع بالبطاقة',
      'noneSelected': 'لم يتم اختيار أي شيء',
      'shopPaymentMethod': 'الدفع في المتجر',
      'errorFailedToLoadOrder': 'خطأ: فشل في تحميل حالة الطلب',

      'unexpectedError': 'خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      'businessHours': 'الإثنين - الأحد: 12:00 - 23:00',
      'address': 'شارع بيري الرابع، 208، سان مارتي، 08005 برشلونة، إسبانيا',
      'infoEmail': 'info@saborly.es',
      'supportEmail': 'support@saborly.es',
      'formSubmissionSuccess': 'شكرًا! تم إرسال رسالتك بنجاح.',
      'formSubmissionError': 'فشل في إرسال الرسالة. يرجى المحاولة مرة أخرى.',
           'tagline': 'طعام لذيذ، يتم توصيله بسرعة',
      'failedToLoadOffers': 'فشل في تحميل العروض',
      'unknownError': 'خطأ غير معروف',
     
      'days': '{days} أيام',
      'offerPlaceholder': 'عرض',
      'brandDescription': 'تجارب طهي استثنائية تسعد حواسك. انضم إلى مجتمعنا الغذائي.',

      // Quick Links
      'quickLinks': 'روابط سريعة',
     
      'reservations': 'الحجوزات',
      'gallery': 'معرض الصور',
      'blog': 'المدونة',
      'careers': 'الوظائف',

      // Resources Links
      'resources': 'الموارد',

      'privacyPolicy': 'سياسة الخصوصية',
      'termsOfService': 'شروط الخدمة',
      'cookiePolicy': 'سياسة ملفات تعريف الارتباط',
      'faq': 'الأسئلة الشائعة',

      // Contact Section
      'stayConnected': 'ابقَ على تواصل',
      'subscribeOffers': 'اشترك للحصول على عروض حصرية',
      'yourEmail': 'بريدك الإلكتروني',
      'subscribe': 'اشترك',
    "paymentInfo": "معلومات الدفع",
      // Copyright

      // Payment Methods
      'weAccept': 'نقبل',
      'visa': 'فيزا',
     // AppBar
      'resetPassword': 'إعادة تعيين كلمة المرور',

      // Form Fields
      'enterYourEmail': 'أدخل بريدك الإلكتروني',

      'verificationCode': 'رمز التحقق',
      'enter6DigitCode': 'أدخل رمزًا مكونًا من 6 أرقام',
      'pleaseEnterCode': 'يرجى إدخال الرمز',
      'codeMustBe6Digits': 'يجب أن يكون الرمز مكونًا من 6 أرقام',
      'newPassword': 'كلمة المرور الجديدة',
      'enterNewPassword': 'أدخل كلمة المرور الجديدة',
      'passwordMinLength': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'reEnterNewPassword': 'أعد إدخال كلمة المرور الجديدة',
      'pleaseConfirmPassword': 'يرجى تأكيد كلمة المرور',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'backToLogin': 'العودة إلى تسجيل الدخول',

      // SnackBar Messages
      'resetCodeSent': 'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني',
      'failedToSendResetCode': 'فشل في إرسال رمز إعادة التعيين',
      'invalid6DigitCode': 'يرجى إدخال رمز صالح مكون من 6 أرقام',
      'codeVerified': 'تم التحقق من الرمز بنجاح',
      'invalidOrExpiredCode': 'رمز غير صالح أو منتهي الصلاحية',
      'passwordResetSuccess': 'تم إعادة تعيين كلمة المرور بنجاح!',
      'failedToResetPassword': 'فشل في إعادة تعيين كلمة المرور',
      'newCodeSent': 'تم إرسال رمز جديد إلى بريدك الإلكتروني',
      'failedToSendCode': 'فشل في إرسال الرمز',
  "offerPrice": "سعر العرض",
  "startingFrom": "بدءاً من",

      // Titles
      'createNewPassword': 'إنشاء كلمة مرور جديدة',
      'verifyCode': 'التحقق من الرمز',

      // Subtitles
      'enterNewPasswordSubtitle': 'يرجى إدخال كلمة المرور الجديدة',
      'enterCodeSubtitle': 'أدخل الرمز المكون من 6 أرقام المرسل إلى {email}',
      'enterEmailSubtitle': 'أدخل بريدك الإلكتروني لتلقي رمز إعادة التعيين',

      // Button Texts
      'resetPasswordButton': 'إعادة تعيين كلمة المرور',
      'verifyCodeButton': 'التحقق من الرمز',
      'sendResetCode': 'إرسال رمز إعادة التعيين',
      'resendCodeCountdown': 'إعادة إرسال الرمز في {seconds} ثانية',
      'resendCode': 'إعادة إرسال الرمز',
        'allSet': 'كل شيء جاهز!',
      'passwordUpdatedDescription': 'تم تحديث كلمة المرور الخاصة بك بنجاح. يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.',
      'newPasswordRequirements': 'يجب أن تكون كلمة المرور الجديدة مختلفة عن السابقة وتفي بمتطلبات الأمان الخاصة بنا.',

      // Password Requirements
      'passwordMinLength8': '8 أحرف على الأقل',
      'passwordUpperLower': 'تحتوي على أحرف كبيرة وصغيرة',
      'passwordNumber': 'تشمل رقمًا واحدًا على الأقل',
      'passwordSpecialChar': 'تحتوي على حرف خاص واحد على الأقل',

      // Form Header and Header
      'passwordUpdated': 'تم تحديث كلمة المرور!',
      'passwordChanged': 'تم تغيير كلمة المرور الخاصة بك بنجاح.',
      'createStrongPassword': 'أنشئ كلمة مرور جديدة قوية لحسابك.',

     
      'passwordMinLength8Error': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
      'passwordSecurityError': 'يجب أن تفي كلمة المرور بمتطلبات الأمان',

      // Form

      // AppBar and Web Header
      'secureAccount': 'حافظ على أمان حسابك بكلمة مرور قوية',

      // Password Card
      'currentPassword': 'كلمة المرور الحالية',
      'enterCurrentPassword': 'أدخل كلمة المرور الحالية',
      'pleaseEnterCurrentPassword': 'يرجى إدخال كلمة المرور الحالية',
      'pleaseEnterNewPassword': 'يرجى إدخال كلمة مرور جديدة',
      'passwordMinLength6': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'newPasswordDifferent': 'يجب أن تكون كلمة المرور الجديدة مختلفة عن الحالية',
      'pleaseConfirmNewPassword': 'يرجى تأكيد كلمة المرور الجديدة',

      // Security Tips
      'passwordRequirements': 'متطلبات كلمة المرور',
      'passwordMinLength6Tip': '6 أحرف على الأقل',
      'passwordNumbersSpecial': 'إضافة أرقام وأحرف خاصة',
      'avoidCommonWords': 'تجنب الكلمات أو الأنماط الشائعة',

      // Button
      'changePasswordButton': 'تغيير كلمة المرور',

      // SnackBar Messages
      'passwordChangedSuccess': 'تم تغيير كلمة المرور بنجاح',
      'passwordChangeFailed': 'فشل في تغيير كلمة المرور',
      // Success Content
      'passwordResetSuccessDescription': 'تم تحديث كلمة المرور الخاصة بك بنجاح. يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.',
      'passwordSecurityTip': 'حافظ على أمان كلمة المرور الخاصة بك ولا تشاركها مع أي شخص.',

      // Sign In Button
      'signInNow': 'تسجيل الدخول الآن',

      // SnackBar Messages
      'passwordUpdatedSuccess': 'تم تحديث كلمة المرور بنجاح!',
      'passwordResetFailed': 'فشل في إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى.',
         // Header
      'verifyYourEmail': 'تحقق من بريدك الإلكتروني',
      'sentVerificationCode': 'لقد أرسلنا رمز التحقق إلى',

      // Timer
      'codeExpired': 'انتهت صلاحية الرمز',
      'codeExpiresIn': 'ينتهي الرمز في {time}',

      // Resend Button
      'didntReceiveCode': 'لم تتلق الرمز؟ ',
      'resend': 'إعادة إرسال',

      // Button
      'verifyEmail': 'التحقق من البريد',

      // SnackBar Messages
      'emailVerifiedSuccess': 'تم التحقق من البريد بنجاح!',
      'invalidOrExpiredOTP': 'رمز OTP غير صالح أو منتهي الصلاحية. يرجى المحاولة مرة أخرى.',
       "callUs": "اتصل بنا",
      // Large Screen Layout
      'joinApp': 'انضم إلى Saborly',
      'createAccountDescription': 'أنشئ حسابك وابدأ رحلتك معنا. جرب أفضل منصة تسوق مصممة لك.',

      // Feature List
      'secureCheckout': 'دفع آمن وسريع',
      'personalizedRecommendations': 'توصيات مخصصة',
      'exclusiveBenefits': 'مزايا حصرية للأعضاء',
      'customerSupport': 'دعم العملاء على مدار الساعة',

      // Form Header and Header
      'createAccount': 'إنشاء حساب',
      'fillInDetails': 'املأ بياناتك للبدء',
      'signUpToStart': 'سجل لتبدأ مع Saborly.',

      // SnackBar Messages
      'verificationCodeSent': 'تم إرسال رمز التحقق! يرجى التحقق من بريدك الإلكتروني.',
      'accountCreatedSuccess': 'تم إنشاء الحساب بنجاح!',
          // AppBar

      // Hero Section
      'welcomeToApp': 'مرحبًا بك في Saborly',
      'bestFastFoodDestination': 'وجهتك لأفضل الوجبات السريعة',

      // Story Section
      'ourStory': 'قصتنا',
      'storyDescription': 'وُلد Saborlyمن شغف بتقديم طعام لذيذ وعالي الجودة. منذ بداياتنا، التزمنا بتقديم أفضل الأطباق، المُعدة بمكونات طازجة ووصفات أصيلة. كل يوم، نسعى لتجاوز توقعات عملائنا وخلق تجارب طهي لا تُنسى.',

      // Values Section
      'ourValues': 'قيمنا',
      'quality': 'الجودة',
      'qualityDescription': 'مكونات طازجة وعالية الجودة',
      'speed': 'السرعة',
      'speedDescription': 'خدمة سريعة دون المساس بالجودة',
      'passion': 'الشغف',
      'passionDescription': 'الحب لما نقوم به في كل طبق',

      // Mission Section
      'ourMission': 'مهمتنا',
      'missionDescription': 'جعل كل وجبة تجربة خاصة، من خلال تقديم نكهات أصيلة وخدمة استثنائية تتجاوز توقعات عملائنا.',
   'privacy_subtitle': 'خصوصيتك هي أولويتنا',
      'privacy_intro': 'في سابورلي، نحن ملتزمون بحماية خصوصيتك وضمان أمان معلوماتك الشخصية. توضح هذه السياسة كيفية جمعنا للبيانات واستخدامها وحمايتها.',
      'last_updated': 'آخر تحديث: 18 أكتوبر 2025',
      'info_collect_title': 'المعلومات التي نجمعها',
      'info_collect_content': 'نجمع المعلومات التي تقدمها لنا مباشرة عند إنشاء حساب، أو تقديم طلب، أو التواصل معنا.',
      'info_collect_point1': 'التفاصيل الشخصية (الاسم، البريد الإلكتروني، رقم الهاتف)',
      'info_collect_point2': 'عنوان التسليم وبيانات الموقع',
      'info_collect_point3': 'معلومات الدفع (مشفرة بشكل آمن)',
      'info_collect_point4': 'سجل الطلبات والتفضيلات',
      'info_collect_point5': 'معلومات الجهاز والاستخدام',
      'use_info_title': 'كيف نستخدم معلوماتك',
      'use_info_content': 'نستخدم المعلومات التي نجمعها لتقديم أفضل خدمة ممكنة لك.',
      'use_info_point1': 'معالجة وتنفيذ طلباتك',
      'use_info_point2': 'إرسال تأكيدات وتحديثات الطلبات',
      'use_info_point3': 'تقديم دعم العملاء',
      'use_info_point4': 'تحسين خدماتنا وتجربة المستخدم',
      'use_info_point5': 'إرسال العروض الترويجية (بموافقتك)',
      'use_info_point6': 'منع الاحتيال وضمان الأمان',
      'sharing_title': 'مشاركة المعلومات والكشف عنها',
      'sharing_content': 'نحن نحترم خصوصيتك ولا نبيع معلوماتك الشخصية.',
      'sharing_point1': 'مقدمو الخدمات (معالجو الدفع، شركاء التوصيل)',
      'sharing_point2': 'المتطلبات القانونية وإنفاذ القانون',
      'sharing_point3': 'نقل الأعمال (الاندماجات، الاستحواذ)',
      'sharing_point4': 'بموافقتك الصريحة',
      'security_title': 'أمان البيانات',
      'security_content': 'ننفذ تدابير أمان قياسية في الصناعة لحماية معلوماتك.',
      'security_point1': 'تشفير SSL/TLS لنقل البيانات',
      'security_point2': 'معالجة دفع آمنة (متوافقة مع PCI DSS)',
      'security_point3': 'تدقيقات أمان وعمليات تحديث منتظمة',
      'security_point4': 'ضوابط الوصول والمصادقة',
      'security_point5': 'أنظمة النسخ الاحتياطي واستعادة البيانات',
      'rights_title': 'حقوقك',
      'rights_content': 'لديك السيطرة على معلوماتك الشخصية.',
      'rights_point1': 'الوصول إلى بياناتك الشخصية',
      'rights_point2': 'تصحيح المعلومات غير الدقيقة',
      'rights_point3': 'طلب حذف البيانات',
      'rights_point4': 'الاعتراض على المعالجة',
      'rights_point5': 'قابلية نقل البيانات',
      'rights_point6': 'سحب الموافقة في أي وقت',
      'cookies_title': 'الكوكيز والتتبع',
      'cookies_content': 'نستخدم الكوكيز لتحسين تجربتك وتحليل أنماط الاستخدام.',
      'cookies_point1': 'الكوكيز الأساسية (مطلوبة للوظائف)',
      'cookies_point2': 'كوكيز الأداء (التحليلات)',
      'cookies_point3': 'كوكيز وظيفية (التفضيلات)',
      'cookies_point4': 'كوكيز التسويق (بموافقتك)',
      'children_privacy_title': 'خصوصية الأطفال',
      'children_privacy_content': 'خدماتنا ليست موجهة للأطفال دون سن 13 عامًا. لا نجمع معلومات شخصية من الأطفال عن علم.',
      'contact_questions': 'أسئلة حول خصوصيتك؟',
      'contact_support': 'فريقنا هنا لمساعدتك على فهم كيفية حماية بياناتك',
      'contact_email': 'support@saborly.es',
      'contact_phone': '+34 932 112 072', 
       "noNotifications": "لا توجد إشعارات",
  "youWillSeeNotificationsHere": "سترى الإشعارات هنا",
  "markAllAsRead": "وضع علامة على الكل كمقروء",
  "allNotificationsMarkedAsRead": "تم وضع علامة على جميع الإشعارات كمقروءة",
  "notificationDeleted": "تم حذف الإشعار",

  "clearAllNotifications": "مسح جميع الإشعارات",
  "areYouSureYouWantToClearAllNotifications": "هل أنت متأكد أنك تريد مسح جميع الإشعارات؟",
  "allNotificationsCleared": "تم مسح جميع الإشعارات",
  "noNotificationsInThisCategory": "لا توجد إشعارات في هذه الفئة",
    'faq_subtitle': 'ابحث عن إجابات للأسئلة الشائعة',
      'faq_category_all': 'الكل',
      'faq_category_orders': 'الطلبات',
      'faq_category_payment': 'الدفع',
      'faq_category_delivery': 'التوصيل',
      'faq_category_account': 'الحساب',
      'faq_contact_title': 'هل لديك أسئلة أخرى؟',
      'faq_contact_subtitle': 'فريق الدعم لدينا متاح على مدار الساعة طوال أيام الأسبوع لمساعدتك',
      'faq_contact_email': 'support@saborly.es',
      'faq_contact_phone': '+34 932 112 072',
      'faq_contact_chat': 'الدردشة المباشرة (قريبًا)',
      'faq_order_place_question': 'كيف أقدم طلبًا؟',
      'faq_order_place_answer': 'تقديم طلب سهل! ما عليك سوى تصفح قائمتنا، واختيار العناصر المفضلة لديك، وتخصيصها حسب رغبتك، وإضافتها إلى عربة التسوق. عندما تكون جاهزًا، انتقل إلى الدفع، وأدخل تفاصيل التوصيل، واختر طريقة الدفع، وأكد طلبك. ستتلقى بريدًا إلكترونيًا للتأكيد على الفور.',
      'faq_order_modify_question': 'هل يمكنني تعديل أو إلغاء طلبي؟',
      'faq_order_modify_answer': 'نعم! يمكنك تعديل أو إلغاء طلبك خلال 5 دقائق من تقديمه عبر التطبيق. بعد هذا الوقت، يبدأ المطعم في تحضير طعامك. إذا كنت بحاجة إلى إجراء تغييرات بعد هذه الفترة، يرجى التواصل مع فريق دعم العملاء على الفور، وسنبذل قصارى جهدنا لمساعدتك.',
      'faq_payment_methods_question': 'ما هي طرق الدفع التي تقبلونها؟',
      'faq_payment_methods_answer': 'نقبل جميع بطاقات الائتمان والخصم الرئيسية (Visa، Mastercard، American Express)، PayPal، Apple Pay، وGoogle Pay. تتم معالجة جميع المدفوعات من خلال اتصالات آمنة ومشفرة لضمان حماية معلوماتك المالية.',
      'faq_payment_security_question': 'هل معلومات الدفع الخاصة بي آمنة؟',
      'faq_payment_security_answer': 'نعم! نستخدم تشفير SSL قياسي في الصناعة ونلتزم بمعايير PCI DSS لضمان أن تكون معلومات الدفع الخاصة بك آمنة تمامًا. لا نقوم أبدًا بتخزين تفاصيل بطاقتك الكاملة على خوادمنا.',
      'faq_delivery_time_question': 'كم يستغرق التوصيل؟',
      'faq_delivery_time_answer': 'وقت التوصيل النموذجي هو 30-45 دقيقة، حسب موقعك، وقت التحضير، والطلب الحالي. يمكنك تتبع طلبك في الوقت الفعلي من خلال تطبيقنا، وسنخطرك في كل مرحلة من عملية التوصيل.',
      'faq_delivery_fees_question': 'هل هناك رسوم توصيل؟',
      'faq_delivery_fees_answer': 'تختلف رسوم التوصيل بناءً على المسافة والمطعم. يتم دائمًا عرض الرسوم الدقيقة قبل تأكيد طلبك.',
      'faq_delivery_contactless_question': 'هل تقدمون توصيلًا بدون تلامس؟',
      'faq_delivery_contactless_answer': 'نعم! نقدم توصيلًا بدون تلامس من أجل سلامتك وراحتك. ما عليك سوى اختيار هذا الخيار عند الدفع، وسيتم ترك طلبك عند بابك مع إشعار يُرسل إلى هاتفك.',
      'faq_account_track_question': 'كيف أتتبع طلبي؟',
      'faq_account_track_answer': 'يمكنك تتبع طلبك في الوقت الفعلي من خلال تطبيقنا أو موقعنا الإلكتروني. بعد تقديم طلبك، سترى تحديثات مباشرة تشمل تأكيد الطلب، حالة التحضير، إشعار الإرسال، ووقت التسليم المقدر. يمكنك أيضًا رؤية موقع موزع التوصيل على الخريطة.',
      'faq_account_incorrect_question': 'ماذا لو كان طلبي غير صحيح أو ينقصه عناصر؟',
      'faq_account_incorrect_answer': 'إذا كان هناك أي مشكلة مع طلبك، يرجى التواصل معنا على الفور من خلال التطبيق أو دعم العملاء. التقط صورًا للمشكلة إن أمكن. سنعمل مع المطعم لحل المشكلة وتقديم استرداد، أو استبدال، أو رصيد لحسابك.',
      'faq_account_dietary_question': 'هل لديكم فلاتر غذائية؟',
      'faq_account_dietary_answer': 'نعم! يمكنك تصفية عناصر القائمة حسب التفضيلات الغذائية، بما في ذلك النباتي، والنباتي الصرف، وخالي من الغلوتين، وخالي من الألبان، وخالي من المكسرات، والحلال، والكوشر. نحن نقدم أيضًا معلومات مفصلة عن المواد المسببة للحساسية لكل طبق. ابحث عن أيقونة الفلتر في قائمة التطبيق.',
     "restaurantClosed": "المطعم مغلق",
  "restaurantClosedDescription": "عذرًا، لا نقبل الطلبات في الوقت الحالي",
  "checkOurHours": "تحقق من ساعات عملنا",
  "closingSoon": "سيغلق قريبًا",
  "orderBeforeClosing": "اطلب قبل أن نغلق",
    },

    // ==================== FRENCH ====================
    'fr': {
      // App Info
      'appName': 'Saborly',
      'appSlogan': 'Nourriture Délicieuse Livrée Rapidement',
  "driverPickup": "Ramassage du conducteur",
      // General
      "@@locale": "fr",
  "restaurantClosed": "Restaurant fermé",
  "restaurantClosedDescription": "Désolé, nous n'acceptons pas de commandes pour le moment",
  "checkOurHours": "Consultez nos horaires",
  "closingSoon": "Fermeture imminente",
  "orderBeforeClosing": "Commandez avant la fermeture",
      'search': 'Rechercher',
      'viewAll': 'Voir Tout',
      'add': 'Ajouter',
      'remove': 'Supprimer',
      'confirm': 'Confirmer',
      'cancel': 'Annuler',
      'retry': 'Réessayer',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'somethingWentWrong': 'Quelque chose s\'est mal passé',
      'noData': 'Aucune donnée trouvée',
      'noInternet': 'Pas de connexion Internet',
      'shop': 'Boutique',
      "deliveryNotAvailableNow": "Livraison non disponible actuellement",

      // Navigation
      'home': 'Accueil',
      'menu': 'Menu',
      'offers': 'Offres',
      'profile': 'Profil',
      'back': 'Retour',

      // Authentication
      'signIn': 'Se Connecter',
      'signUp': 'S\'inscrire',
      'signOut': 'Se Déconnecter',
      'email': 'E-mail',
      'password': 'Mot de Passe',
      'confirmPassword': 'Confirmer le Mot de Passe',
      'forgotPassword': 'Mot de Passe Oublié ?',
      'dontHaveAccount': "Vous n'avez pas de compte ?",
      'alreadyHaveAccount': "Vous avez déjà un compte ?",
      'firstName': 'Prénom',
      'lastName': 'Nom',
      'phoneNumber': 'Numéro de Téléphone',
      'loginRequired': 'Veuillez vous connecter pour continuer',
      'loginToContinue': 'Connectez-vous pour Continuer',

      // Home
      'ourMenu': 'Notre Menu',
      'featuredItems': 'Articles en Vedette',
      'mostPopularItems': 'Articles les Plus Populaires',
      'freeDelivery': 'LIVRAISON GRATUITE',
      'tryChicken': 'ESSAYEZ LE POULET',
      'freeShake': 'SHAKE GRATUIT',
      'coolDown': 'RAFRAÎCHISSEZ-VOUS',
      "canDeliver": "Peut Livrer",

      // Categories
      'friendsFamily': 'Combo Amis\net Famille',
      'highOnCoffee': 'Combo Café\nIntense',
      'duetCombos': 'Combos Duo',
      'whopper': 'Whopper',
      'veg': 'Végétarien',
      'nonVeg': 'Non-Végétarien',

      // Cart & Checkout
      'myCart': 'Mon Panier',
      'checkout': 'Paiement',
      'proceedToCheckout': 'Procéder au Paiement',
      'placeOrder': 'Passer la Commande',
      'addToCart': 'Ajouter au Panier',
      'quantity': 'Quantité',
      'mealSize': 'Taille du Repas',
      'mediumMeal': 'Repas Moyen',
      'largeMeal': 'Grand Repas',
      'burgerOnly': 'Burger Seulement',
      'extras': 'Extras',
      'addons': 'Suppléments',
      'extraCheese': 'Fromage Supplémentaire',
      'extraPattyChicken': 'Steak de Poulet Supplémentaire',
      'specialInstructions': 'Instructions Spéciales',
      'instructionsHint': 'Notes pour la commande (Fromage, etc.)',
      'subtotal': 'Sous-total',
      'deliveryFee': 'Frais de Livraison',
      'total': 'Total',
      'cartSummary': 'Résumé du Panier',
      'frequentlyBoughtTogether': 'Achetés Fréquemment Ensemble',

      // Delivery & Location
      'delivery': 'Livraison',
      'takeaway': 'À Emporter',
      'selectBranch': 'Sélectionner la Succursale',
      'deliveryAddress': 'Adresse de Livraison',
      'addAddress': 'Ajouter une Adresse',
      'editAddress': 'Modifier l\'Adresse',
      'homeAddress': 'Domicile',
      'workAddress': 'Travail',
      'preferenceTime': 'Heure de Livraison Préférée',
      'today': 'Aujourd\'hui',
      'tomorrow': 'Demain',
      'now': 'Maintenant',
      'estimatedDelivery': 'Temps de livraison estimé',

      // Payment
      'selectPaymentMethod': 'Sélectionnez votre méthode de paiement',
      'paypal': 'PayPal',
      'stripe': 'Stripe',
      'visaCard': 'Carte VISA',
      'mastercard': 'Mastercard',
      'cardNumber': 'Numéro de Carte',
      'expiresOn': 'Expire le',
      'payNow': 'Payer Maintenant',
      'cancelOrder': 'Annuler',
      'cashOnDelivery': 'Paiement à la Livraison',
      'paymentMethod': 'Méthode de Paiement',
      'paymentStatus': 'Statut du Paiement',
      'unpaid': 'Non Payé',
      'paid': 'Payé',

      // Orders
      'orderStatus': 'Statut de la Commande',
      'orderDetails': 'Détails de la Commande',
      'orderPlaced': 'Commande passée',
      'orderConfirmed': 'Commande confirmée',
      'preparing': 'En Préparation',
      'outForDelivery': 'En Livraison',
      'ready': 'Prêt à être récupéré',
      'delivered': 'Livré',
      'getYourOrder': 'Recevez votre commande ',
      'orderHistory': 'Historique des Commandes',
      'reorder': 'Commander à Nouveau',
      'trackOrder': 'Suivre la Commande',
      'orderCompleted': 'Commande Terminée',

      // Validation Messages
      'pleaseEnterEmail': 'Veuillez saisir votre e-mail',
      'pleaseEnterValidEmail': 'Veuillez saisir un e-mail valide',
      'pleaseEnterPassword': 'Veuillez saisir votre mot de passe',
      'passwordTooShort': 'Le mot de passe doit contenir au moins 6 caractères',
      'passwordsDontMatch': 'Les mots de passe ne correspondent pas',
      'pleaseEnterName': 'Veuillez saisir votre nom',
      'pleaseEnterPhone': 'Veuillez saisir votre numéro de téléphone',

      // Success Messages
      'orderPlacedSuccessfully': 'Commande passée avec succès !',
      'accountCreatedSuccessfully': 'Compte créé avec succès !',
      'profileUpdatedSuccessfully': 'Profil mis à jour avec succès !',
      'addressAddedSuccessfully': 'Adresse ajoutée avec succès !',

      // Error Messages
      'failedToPlaceOrder': 'Échec de la commande',
      'failedToLogin': 'Échec de la connexion',
      'failedToCreateAccount': 'Échec de la création du compte',
      'failedToLoadData': 'Échec du chargement des données',
      'failedToUpdateProfile': 'Échec de la mise à jour du profil',

      // Time
      'minutes': 'min',
      'hours': 'heures',
      'am': 'am',
      'pm': 'pm',

      // Price
      'currency': '€',
      'free': 'Gratuit',

      // Restaurant Info
      'boshundhoraRA': 'Espagne',
      'gulshan2': 'Espagne',
      'banani': 'Espagne',
      'dhanmondi': 'Espagne',
      'km': 'km',
      'flat': 'Appartement',
      'house': 'Maison',
      'road': 'Rue',

      'specialOffers': 'Offres Spéciales',
      'hotDeals': 'OFFRES CHAUDES',
      'exclusiveOffers': 'Offres Exclusives',
      'saveUpTo': 'Économisez jusqu\'à 50% sur vos plats préférés',
      'itemsOnOffer': 'articles en offre',
      'noOffersAvailable': 'Aucune Offre Disponible',
      'checkBackLater': 'Revenez plus tard pour des offres excitantes !\nDe nouvelles offres sont ajoutées régulièrement.',
      'browseMenu': 'Parcourir le Menu',
      'featuredItemsTitle': 'Articles en Vedette',
      'popularItemsTitle': 'Articles Populaires',
      'noFeaturedItems': 'Aucun Article en Vedette',
      'noPopularItems': 'Aucun Article Populaire',
      'checkBackForItems': 'Revenez plus tard pour les articles',

      'viewYourOrders': 'Voir vos commandes précédentes',
      'orderNumber': 'Commande #',
      'items': 'articles',
      'item': 'article',
      'totalAmount': 'Montant Total',
      'viewDetails': 'Voir les Détails',
      'goToMenu': 'Aller au menu',
      'pending': 'En Attente',
      'confirmed': 'Confirmé',

      'readyForPickup': 'Prêt à être Récupéré',
      'collected': 'Récupéré',
      'cancelled': 'Annulé',
      'refunded': 'Remboursé',
      'branch': 'Succursale',
      'noOrdersYet': 'Aucune Commande pour le Moment',
      'orderHistoryAppear': 'Votre historique de commandes apparaîtra ici\nune fois que vous passerez votre première commande',
      'startOrdering': 'Commencer à Commander',
      'contactUs': 'Nous Contacter',
      'sendMessage': 'Envoyez-nous un Message',
      'fullName': 'Nom Complet',
      'yourName': 'Votre nom',
      'phoneOptional': 'Téléphone (Optionnel)',
      'subject': 'Sujet',
      'subjectOfMessage': 'Sujet du message',
      'message': 'Message',
      'writeMessageHere': 'Écrivez votre message ici...',

      'callUs': 'Appelez-nous',
      'visitUs': 'Visitez-nous',
      'writeUs': 'Écrivez-nous',
      'followUs': 'Suivez-nous',
      'discoverOurOfferings': 'Découvrez nos délicieuses offres',
      'allCategories': 'Toutes les Catégories',
      'noFeaturedItemsFound': 'Aucun Article en Vedette',
      'noPopularItemsFound': 'Aucun Article Populaire',
      'checkBackLaterFor': 'Revenez plus tard pour',

      // Order History
      'loadingYourOrders': 'Chargement de vos commandes...',
      'oopsSomethingWrong': 'Oups ! Quelque chose s\'est mal passé',
      'yourOrderHistory': 'Votre historique de commandes apparaîtra ici\nune fois que vous passerez votre première commande',

      'yesterday': 'Hier',

      // Offers
      'loadingAmazingOffers': 'Chargement d\'offres incroyables...',
      'saveUpTo50': 'Économisez jusqu\'à 50% sur vos plats préférés',

      'checkBackForDeals': 'Revenez plus tard pour des offres excitantes !\nDe nouvelles offres sont ajoutées régulièrement.',
      "pizza": "Pizza",
      "burger": "Burger",
      "pasta": "Pâtes",
      "salad": "Salade",

      // Contact
      'sendUsMessage': 'Envoyez-nous un Message',
      'completeTheForm': 'Complétez le formulaire et nous vous recontacterons bientôt',
      'emailAddress': 'Adresse E-mail',
      'writeYourMessage': 'Écrivez votre message ici...',
      "yourMessage": "Votre Message",
      'pleaseEnterSubject': 'Veuillez saisir le sujet',
      'pleaseEnterMessage': 'Veuillez saisir votre message',
      'messageTooShort': 'Le message doit contenir au moins 10 caractères',
      'messageTooLong': 'Le message ne peut pas dépasser 2000 caractères',
      "calculating": "Calcul en cours",

      // Profile
      'accountManagement': 'Gestion du Compte',
      'manageYourAccount': 'Gérez vos paramètres et préférences de compte',
      'activityOverview': 'Aperçu de l\'Activité',
      'orders': 'Commandes',
      'reviews': 'Avis',
      'favorites': 'Favoris',
      'points': 'Points',
      'quickActions': 'Actions Rapides',
      'downloadData': 'Télécharger les Données',
      'helpCenter': 'Centre d\'Aide',
      'editProfile': 'Modifier le Profil',
      'accountSettings': 'Paramètres du Compte',
      'personalInformation': 'Informations Personnelles',
      'preferences': 'Préférences',
      'notifications': 'Notifications',
      'privacy': 'Confidentialité',
      'securitySupport': 'Sécurité & Support',
      'changePassword': 'Changer le Mot de Passe',
      'helpSupport': 'Aide & Support',
      'about': 'À Propos',
      'version': 'Version',
      "changeAddress": "Changer l'Adresse",

      // Cart
      'emptyCart': 'Votre panier est vide',
      'addSomeFood': 'Ajoutez de la délicieuse nourriture pour commencer',
      'anySpecialRequests': 'Des demandes spéciales ou instructions pour votre commande...',
      "range": "Rayon",
      "readyIn": "Prêt dans",

      // Checkout
      'deliveryAvailable': 'Livraison Disponible',
      'deliveryNotAvailable': 'Livraison Non Disponible',
      'distance': 'Distance',
      'addressBeyondRange': 'L\'adresse est hors de la zone de livraison',
      'pleaseSelectAddress': 'Veuillez sélectionner une adresse de livraison',
      'addMoreForFree': 'plus pour la livraison GRATUITE !',
      'noDeliveryAddress': 'Aucune Adresse de Livraison',
      'addDeliveryAddress': 'Ajoutez votre adresse de livraison pour continuer',
      'selectAddress': 'Sélectionner l\'Adresse',
      'completeAddressDetails': 'Compléter les Détails de l\'Adresse',
      'savedAddresses': 'Adresses Enregistrées',
      'addYourFirstAddress': 'Ajoutez Votre Première Adresse',
      'addNewAddress': 'Ajouter une Nouvelle Adresse',
      'searchAddress': 'Rechercher une Adresse',
      'startTypingAddress': 'Commencez à taper votre adresse...',
      'noAddressesFound': 'Aucune adresse trouvée',
      'tryDifferentSearch': 'Essayez un terme de recherche différent',
      'addressType': 'Type d\'Adresse',
      'office': 'Bureau',
      'other': 'Autre',
      'apartmentNumber': 'Numéro d\'Appartement/Maison',
      'apartmentPlaceholder': 'ex. : Appt 4B, Étage 2, Bâtiment C',
      'deliveryInstructions': 'Instructions de Livraison (Optionnel)',
      'deliveryInstructionsPlaceholder': 'ex. : Sonner à la porte, Laisser devant la porte',
      'saveAddress': 'Enregistrer l\'Adresse',
      'pleaseEnterApartment': 'Veuillez saisir votre numéro d\'appartement/maison',
      'pickupLocation': 'Lieu de Récupération',
      'pickupTime': 'Heure de Récupération',

      // Payment
      'pickupOrder': 'Commande à Récupérer',
      'deliveryOrder': 'Commande en Livraison',
      'payAtShop': 'Payer en Boutique',
      'payAtCounter': 'Payez au comptoir lorsque vous récupérez votre commande',
      'choosePaymentType': 'Choisissez le Type de Paiement',
      'cash': 'Espèces',
      'card': 'Carte',
      'payWithCash': 'Payer en espèces',
      'payWithCard': 'Payer par carte',
      'otherOptions': 'Autres Options (À Venir)',
      'paySecurelyWith': 'Payer en toute sécurité avec',
      'comingSoon': 'À Venir',
      'paymentSummary': 'Résumé du Paiement',
      'orderType': 'Type de Commande',
      'paymentType': 'Type de Paiement',
      'payAtShopCounter': 'Payez au comptoir de la boutique lors de la récupération',
      'payWithCashOnDelivery': 'Payez en espèces à la livraison de votre commande',
      'payWithCardOnDelivery': 'Payez par carte à la livraison de votre commande',
      'noneSelected': 'Aucune Sélection',
      'shopPayment': 'Paiement en Boutique',
      'deliveryPayment': 'Paiement à la Livraison',

      // Menu
      'loadingDeliciousMenu': 'Chargement du menu délicieux...',
      'discoverDelicious': 'Découvrez nos délicieuses offres',
      'filters': 'Filtres',
      'foodType': 'Type de Nourriture',
      'vegetarian': 'Végétarien',
      'nonVegetarian': 'Non-Végétarien',
      'popularItems': 'Articles Populaires',
      'clearAll': 'Tout Effacer',
      'apply': 'Appliquer',
      'advancedFilters': 'Filtres Avancés',
      'chooseDeliveryAddress': 'Choisissez où livrer votre commande',
      'setAsDefault': 'Définir par Défaut',
      'delete': 'Supprimer',
      'deleteAddress': 'Supprimer l\'Adresse',
      'confirmDeleteAddress': 'Êtes-vous sûr de vouloir supprimer cette adresse ? Cette action ne peut pas être annulée.',
      'defaultAddressUpdated': 'Adresse par défaut mise à jour',
      'addressDeletedSuccessfully': 'Adresse supprimée avec succès',
      "yourOrderWillBeReady": "Votre commande sera prête",
      'addressSavedWithDistance': 'Adresse enregistrée ! Distance : {distance}',
      'addressBeyondRangeWithLimit': 'Désolé, cette adresse est au-delà de notre rayon de livraison de {limit}km',
      'failedToFetchPlaceDetails': 'Échec de la récupération des détails du lieu',
      'noDescription': 'Aucune description',
      'pleaseSelectDeliveryAddress': 'Veuillez sélectionner une adresse de livraison',
      'addressBeyondDeliveryRange': 'L\'adresse sélectionnée est hors de la zone de livraison',
      'cartEmpty': 'Votre panier est vide',
      'moreItems': '+{count} autres articles',
      'noOrdersDescription': 'Votre historique de commandes apparaîtra ici\nune fois que vous passerez votre première commande',
      'welcomeBack': 'Bon retour ! Veuillez saisir vos identifiants.',
      'pickup': 'Récupération',
      'pressBackAgain': 'Appuyez à nouveau pour quitter',
      'securityAndSupport': 'Sécurité & Support',
      'helpAndSupport': 'Aide & Support',
      'signInPrompt': 'Connectez-vous pour accéder à votre profil et à vos commandes',
      'viewPastOrders': 'Voir vos commandes précédentes',
      'updatePassword': 'Mettre à jour votre mot de passe',
      'getInTouch': 'Entrez en contact avec nous',
      'learnAboutUs': 'En savoir plus sur nous',
      'notificationPreferences': 'Préférences de notifications',
      'getHelpAndSupport': 'Obtenir de l\'aide et du support',
      'appVersion': 'Version 1.0.0',
      'aboutApp': 'À Propos de Saborly',
      'appDescription': 'Bienvenue chez Saborly ! Nous livrons de délicieux plats de vos restaurants préférés directement à votre porte.',
      'copyright': '© 2025 Saborly. Tous droits réservés.',
      'companyAddress': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelone, Espagne',
      'close': 'Fermer',
      'save': 'Enregistrer',
      'areYouSureSignOut': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'imageNotAvailable': 'Image non disponible',
      'addedToCart': '{itemName} ajouté au panier',
      'undo': 'Annuler',
      'outOfStock': 'en rupture de stock',
      'loadingMenu': 'Chargement du menu délicieux...',
      'noCategoriesAvailable': 'Aucune catégorie disponible',
      'noFoodItemsAvailable': 'Aucun article de nourriture disponible',
      'discoverOfferings': 'Découvrez nos délicieuses offres',
      'appLogo': 'Logo de l\'Application',
      'noItems': 'Aucun Article {type}',
      'featured': 'En Vedette',
      'popular': 'Populaire',
      'aboutUs': 'À Propos de Nous',
      'cart': 'Panier',
      'account': 'Compte',
      'orderNotFound': 'Commande non trouvée',
      'goBack': 'Retour',
      'callRestaurant': 'Appeler le Restaurant',
      'restaurantAddress': 'Saborly, C/ de Pere IV, 208, Sant Martí, 08005 Barcelone, Espagne',
      'estimatedTime': '40 min',
      'paymentFailed': 'Échec',
      'paymentRefunded': 'Remboursé',
      'emptyOrderItems': 'Vos délicieux articles de commande',
      'tax': 'Taxe :',
      'jan': 'Jan',
      'feb': 'Fév',
      'mar': 'Mar',
      'apr': 'Avr',
      'may': 'Mai',
      'jun': 'Juin',
      'jul': 'Juil',
      'aug': 'Aoû',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Déc',
      'callError': 'Impossible d\'appeler le 34932112072',
      'callErrorGeneric': 'Erreur lors de l\'appel : {error}',
      'loadingOffers': 'Chargement d\'offres incroyables...',
      'checkBackLaterOffers': 'Revenez plus tard pour des offres excitantes !\nDe nouvelles offres sont ajoutées régulièrement.',
      'addFoodToStart': 'Ajoutez de la délicieuse nourriture pour commencer',
      'specialInstructionsHint': 'Des demandes ou instructions spéciales pour votre commande à emporter...',
      'orderSummary': 'Résumé de la Commande',
      'sizeLabel': 'Taille :',
      'extrasLabel': 'Extras :',
      'addonsLabel': 'Suppléments :',
      'payAtShopDescription': 'Payez à la boutique lorsque vous récupérez votre commande',
      'choosePaymentDelivery': 'Choisissez comment vous voulez payer lors de la livraison',
      'otherOptionsComingSoon': 'Autres Options (À Venir)',
      'paypalDescription': 'Payez en toute sécurité avec PayPal',
      'stripeDescription': 'Payez avec carte de crédit ou de débit',
      'cardDescription': 'Payez avec VISA ou Mastercard',
      'shopPaymentMethod': 'Paiement en Boutique',
      'errorFailedToLoadOrder': 'Erreur : Échec du chargement du statut de la commande',
      'unexpectedError': 'Erreur inattendue. Veuillez réessayer.',
      'businessHours': 'Lun - Dim : 12:00 - 23:00',
      'address': 'C/ de Pere IV, 208, Sant Martí, 08005 Barcelone, Espagne',
      'infoEmail': 'info@saborly.es',
      'supportEmail': 'support@saborly.es',
      'formSubmissionSuccess': 'Merci ! Votre message a été envoyé avec succès.',
      'formSubmissionError': 'Échec de l\'envoi du message. Veuillez réessayer.',
      'tagline': 'Nourriture délicieuse, livrée rapidement',
      'failedToLoadOffers': 'Échec du chargement des offres',
      'unknownError': 'Erreur inconnue',
      'days': '{days} jours',
      'offerPlaceholder': 'Offre',
      'brandDescription': 'Expériences culinaires exceptionnelles qui ravissent vos sens. Rejoignez notre communauté gastronomique.',

      // Quick Links
      'quickLinks': 'Liens Rapides',
      'reservations': 'Réservations',
      'gallery': 'Galerie',
      'blog': 'Blog',
      'careers': 'Carrières',

      // Resources Links
      'resources': 'Ressources',
      'privacyPolicy': 'Politique de Confidentialité',
      'termsOfService': 'Conditions d\'Utilisation',
      'cookiePolicy': 'Politique des Cookies',
      'faq': 'FAQ',

      // Contact Section
      'stayConnected': 'Restez Connecté',
      'subscribeOffers': 'Abonnez-vous pour des offres exclusives',
      'yourEmail': 'Votre e-mail',
      'subscribe': 'S\'abonner',
      'weAccept': 'Nous Acceptons',
      'visa': 'Visa',
      'resetPassword': 'Réinitialiser le Mot de Passe',
      'enterYourEmail': 'Entrez votre e-mail',
      'verificationCode': 'Code de Vérification',
      'enter6DigitCode': 'Entrez le code à 6 chiffres',
      'pleaseEnterCode': 'Veuillez saisir le code',
      'codeMustBe6Digits': 'Le code doit contenir 6 chiffres',
      'newPassword': 'Nouveau Mot de Passe',
      'enterNewPassword': 'Entrez le nouveau mot de passe',
      'passwordMinLength': 'Le mot de passe doit contenir au moins 6 caractères',
      'reEnterNewPassword': 'Resaisissez le nouveau mot de passe',
      'pleaseConfirmPassword': 'Veuillez confirmer votre mot de passe',
      'passwordsDoNotMatch': 'Les mots de passe ne correspondent pas',
      'backToLogin': 'Retour à la Connexion',

      // SnackBar Messages
      'resetCodeSent': 'Code de réinitialisation envoyé à votre e-mail',
      'failedToSendResetCode': 'Échec de l\'envoi du code de réinitialisation',
      'invalid6DigitCode': 'Veuillez saisir un code à 6 chiffres valide',
      'codeVerified': 'Code vérifié avec succès',
      'invalidOrExpiredCode': 'Code invalide ou expiré',
      'passwordResetSuccess': 'Mot de passe réinitialisé avec succès !',
      'failedToResetPassword': 'Échec de la réinitialisation du mot de passe',
      'newCodeSent': 'Nouveau code envoyé à votre e-mail',
      'failedToSendCode': 'Échec de l\'envoi du code',

      // Titles
      'createNewPassword': 'Créer un Nouveau Mot de Passe',
      'verifyCode': 'Vérifier le Code',

      // Subtitles
      'enterNewPasswordSubtitle': 'Veuillez saisir votre nouveau mot de passe',
      'enterCodeSubtitle': 'Entrez le code à 6 chiffres envoyé à {email}',
      'enterEmailSubtitle': 'Entrez votre e-mail pour recevoir un code de réinitialisation',

      // Button Texts
      'resetPasswordButton': 'Réinitialiser le Mot de Passe',
      'verifyCodeButton': 'Vérifier le Code',
      'sendResetCode': 'Envoyer le Code de Réinitialisation',
      'resendCodeCountdown': 'Renvoyer le code dans {seconds}s',
      'resendCode': 'Renvoyer le Code',
      'allSet': 'Tout est Prêt !',
      'passwordUpdatedDescription': 'Votre mot de passe a été mis à jour avec succès. Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.',
      'newPasswordRequirements': 'Votre nouveau mot de passe doit être différent du précédent et répondre à nos exigences de sécurité.',
      "frequentlyAskedQuestions": "Foire Aux Questions",

      // Password Requirements
      'passwordMinLength8': 'Au moins 8 caractères',
      'passwordUpperLower': 'Contient des lettres majuscules et minuscules',
      'passwordNumber': 'Inclut au moins un chiffre',
      'passwordSpecialChar': 'A au moins un caractère spécial',

      // Form Header and Header
      'passwordUpdated': 'Mot de Passe Mis à Jour !',
      'passwordChanged': 'Votre mot de passe a été changé avec succès.',
      'createStrongPassword': 'Créez un nouveau mot de passe fort pour votre compte.',

      'passwordMinLength8Error': 'Le mot de passe doit contenir au moins 8 caractères',
      'passwordSecurityError': 'Le mot de passe doit répondre aux exigences de sécurité',

      // Success Content
      'passwordResetSuccessDescription': 'Votre mot de passe a été mis à jour avec succès. Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.',
      'passwordSecurityTip': 'Gardez votre mot de passe sécurisé et ne le partagez avec personne.',

      // Sign In Button
      'signInNow': 'Se Connecter Maintenant',

      // SnackBar Messages
      'passwordUpdatedSuccess': 'Mot de passe mis à jour avec succès !',
      'passwordResetFailed': 'Échec de la réinitialisation du mot de passe. Veuillez réessayer.',

      // AppBar and Web Header
      'secureAccount': 'Gardez votre compte sécurisé avec un mot de passe fort',

      // Password Card
      'currentPassword': 'Mot de Passe Actuel',
      'enterCurrentPassword': 'Entrez le mot de passe actuel',
      'pleaseEnterCurrentPassword': 'Veuillez saisir votre mot de passe actuel',
      'pleaseEnterNewPassword': 'Veuillez saisir un nouveau mot de passe',
      'passwordMinLength6': 'Le mot de passe doit contenir au moins 6 caractères',
      'newPasswordDifferent': 'Le nouveau mot de passe doit être différent de l\'actuel',
      'pleaseConfirmNewPassword': 'Veuillez confirmer votre nouveau mot de passe',

      // Security Tips
      'passwordRequirements': 'Exigences du Mot de Passe',
      'passwordMinLength6Tip': 'Au moins 6 caractères',
      'passwordNumbersSpecial': 'Ajoutez des chiffres et des caractères spéciaux',
      'avoidCommonWords': 'Évitez les mots ou modèles courants',

      // Button
      'changePasswordButton': 'Changer le Mot de Passe',

      // SnackBar Messages
      'passwordChangedSuccess': 'Mot de passe changé avec succès',
      'passwordChangeFailed': 'Échec du changement de mot de passe',

      // Header
      'verifyYourEmail': 'Vérifiez Votre E-mail',
      'sentVerificationCode': 'Nous avons envoyé un code de vérification à',

      // Timer
      'codeExpired': 'Code expiré',
      'codeExpiresIn': 'Le code expire dans {time}',

      // Resend Button
      'didntReceiveCode': 'Vous n\'avez pas reçu le code ? ',
      'resend': 'Renvoyer',

      // Button
      'verifyEmail': 'Vérifier l\'E-mail',

      // SnackBar Messages
      'emailVerifiedSuccess': 'E-mail vérifié avec succès !',
      'invalidOrExpiredOTP': 'OTP invalide ou expiré. Veuillez réessayer.',
      'joinApp': 'Rejoindre Saborly',
      'createAccountDescription': 'Créez votre compte et commencez votre voyage avec nous. Découvrez la meilleure plateforme de shopping conçue pour vous.',
      "startYourCulinaryJourney": "Commencez Votre Voyage Culinaire",
      "searchFoodDescription": "Recherchez vos plats, cuisines ou ingrédients préférés pour découvrir des options de nourriture incroyables",

      // Feature List
      'secureCheckout': 'Paiement sécurisé et rapide',
      'personalizedRecommendations': 'Recommandations personnalisées',
      'exclusiveBenefits': 'Avantages exclusifs pour les membres',
      'customerSupport': 'Support client 24/7',

      // Form Header and Header
      'createAccount': 'Créer un Compte',
      'fillInDetails': 'Remplissez vos détails pour commencer',
      'signUpToStart': 'Inscrivez-vous pour commencer avec Saborly.',

      // SnackBar Messages
      'verificationCodeSent': 'Code de vérification envoyé ! Veuillez vérifier votre e-mail.',
      'accountCreatedSuccess': 'Compte créé avec succès !',

      // Hero Section
      'welcomeToApp': 'Bienvenue chez Saborly',
      'bestFastFoodDestination': 'Votre destination pour la meilleure restauration rapide',

      // Story Section
      'ourStory': 'Notre Histoire',
      'storyDescription': 'Saborly est né d\'une passion pour livrer de la nourriture délicieuse et de qualité. Depuis nos débuts, nous nous sommes engagés à servir les meilleurs plats, préparés avec des ingrédients frais et des recettes authentiques. Chaque jour, nous nous efforçons de dépasser les attentes de nos clients et de créer des expériences culinaires mémorables.',

      // Values Section
      'ourValues': 'Nos Valeurs',
      'quality': 'Qualité',
      'qualityDescription': 'Ingrédients frais et de haute qualité',
      'speed': 'Rapidité',
      'speedDescription': 'Service rapide sans compromettre la qualité',
      'passion': 'Passion',
      'passionDescription': 'Amour pour ce que nous faisons dans chaque plat',
      "orderProgress": "Progression de la Commande",
      "paymentInfo": "Informations de Paiement",

      // Mission Section
      'ourMission': 'Notre Mission',
      'missionDescription': 'Faire de chaque repas une expérience spéciale, en offrant des saveurs authentiques et un service exceptionnel qui dépasse les attentes de nos clients.',
      "offerPrice": "Prix de l'Offre",
      "startingFrom": "À partir de",

      'privacy_subtitle': 'Votre vie privée est notre priorité',
      'privacy_intro': 'Chez Saborly, nous nous engageons à protéger votre vie privée et à assurer la sécurité de vos informations personnelles. Cette politique explique comment nous collectons, utilisons et protégeons vos données.',
      'last_updated': 'Dernière mise à jour : 18 octobre 2025',
      'info_collect_title': 'Informations que Nous Collectons',
      'info_collect_content': 'Nous collectons les informations que vous nous fournissez directement lorsque vous créez un compte, passez une commande ou communiquez avec nous.',
      'info_collect_point1': 'Détails personnels (nom, e-mail, numéro de téléphone)',
      'info_collect_point2': 'Adresse de livraison et données de localisation',
      'info_collect_point3': 'Informations de paiement (chiffrées en toute sécurité)',
      'info_collect_point4': 'Historique des commandes et préférences',
      'info_collect_point5': 'Informations sur l\'appareil et l\'utilisation',
      'use_info_title': 'Comment Nous Utilisons Vos Informations',
      'use_info_content': 'Nous utilisons les informations que nous collectons pour vous fournir le meilleur service possible.',
      'use_info_point1': 'Traiter et exécuter vos commandes',
      'use_info_point2': 'Envoyer des confirmations et mises à jour de commande',
      'use_info_point3': 'Fournir un support client',
      'use_info_point4': 'Améliorer nos services et l\'expérience utilisateur',
      'use_info_point5': 'Envoyer des offres promotionnelles (avec votre consentement)',
      'use_info_point6': 'Prévenir la fraude et assurer la sécurité',
      'sharing_title': 'Partage et Divulgation des Informations',
      'sharing_content': 'Nous respectons votre vie privée et ne vendons pas vos informations personnelles.',
      'sharing_point1': 'Prestataires de services (processeurs de paiement, partenaires de livraison)',
      'sharing_point2': 'Exigences légales et application de la loi',
      'sharing_point3': 'Transferts d\'entreprise (fusions, acquisitions)',
      'sharing_point4': 'Avec votre consentement explicite',
      'security_title': 'Sécurité des Données',
      'security_content': 'Nous mettons en œuvre des mesures de sécurité standard de l\'industrie pour protéger vos informations.',
      'security_point1': 'Chiffrement SSL/TLS pour la transmission des données',
      'security_point2': 'Traitement des paiements sécurisé (conforme PCI DSS)',
      'security_point3': 'Audits de sécurité et mises à jour régulières',
      'security_point4': 'Contrôles d\'accès et authentification',
      'security_point5': 'Systèmes de sauvegarde et de récupération des données',
      'rights_title': 'Vos Droits',
      'rights_content': 'Vous avez le contrôle de vos informations personnelles.',
      'rights_point1': 'Accéder à vos données personnelles',
      'rights_point2': 'Corriger les informations inexactes',
      'rights_point3': 'Demander la suppression des données',
      'rights_point4': 'Vous opposer au traitement',
      'rights_point5': 'Portabilité des données',
      'rights_point6': 'Retirer votre consentement à tout moment',
      'cookies_title': 'Cookies et Suivi',
      'cookies_content': 'Nous utilisons des cookies pour améliorer votre expérience et analyser les modèles d\'utilisation.',
      'cookies_point1': 'Cookies essentiels (nécessaires au fonctionnement)',
      'cookies_point2': 'Cookies de performance (analytiques)',
      'cookies_point3': 'Cookies fonctionnels (préférences)',
      'cookies_point4': 'Cookies marketing (avec consentement)',
      'children_privacy_title': 'Vie Privée des Enfants',
      'children_privacy_content': 'Nos services ne sont pas destinés aux enfants de moins de 13 ans. Nous ne collectons pas sciemment d\'informations personnelles auprès d\'enfants.',
      'contact_questions': 'Des Questions Sur Votre Vie Privée ?',
      'contact_support': 'Notre équipe est là pour vous aider à comprendre comment nous protégeons vos données',
      'contact_email': 'support@saborly.es',
      'contact_phone': '+34 932 112 072',

      // FAQScreen
      'faq_subtitle': 'Trouvez des réponses aux questions courantes',
      'faq_category_all': 'Toutes',
      'faq_category_orders': 'Commandes',
      'faq_category_payment': 'Paiement',
      'faq_category_delivery': 'Livraison',
      'faq_category_account': 'Compte',
      'faq_contact_title': 'Vous avez encore des questions ?',
      'faq_contact_subtitle': 'Notre équipe de support est disponible 24h/24 et 7j/7 pour vous aider',
      'faq_contact_email': 'support@saborly.es',
      'faq_contact_phone': '+34 932 112 072',
      'faq_contact_chat': 'Chat en Direct (À Venir)',
      'faq_order_place_question': 'Comment passer une commande ?',
      'faq_order_place_answer': 'Passer une commande est facile ! Parcourez simplement notre menu, sélectionnez vos articles préférés, personnalisez-les à votre goût et ajoutez-les à votre panier. Lorsque vous êtes prêt, passez à la caisse, entrez vos coordonnées de livraison, choisissez votre méthode de paiement et confirmez votre commande. Vous recevrez immédiatement un e-mail de confirmation.',
      'faq_order_modify_question': 'Puis-je modifier ou annuler ma commande ?',
      'faq_order_modify_answer': 'Oui ! Vous pouvez modifier ou annuler votre commande dans les 5 minutes suivant sa passation via l\'application. Après ce délai, le restaurant commence à préparer votre nourriture. Si vous devez apporter des modifications après cette fenêtre, veuillez contacter immédiatement notre équipe d\'assistance clientèle, et nous ferons de notre mieux pour vous aider.',
      'faq_payment_methods_question': 'Quelles méthodes de paiement acceptez-vous ?',
      'faq_payment_methods_answer': 'Nous acceptons toutes les principales cartes de crédit et de débit (Visa, Mastercard, American Express), PayPal, Apple Pay et Google Pay. Tous les paiements sont traités via des connexions sécurisées et cryptées pour garantir la protection de vos informations financières.',
      'faq_payment_security_question': 'Mes informations de paiement sont-elles sécurisées ?',
      'faq_payment_security_answer': 'Oui ! Nous utilisons le cryptage SSL standard de l\'industrie et respectons les normes PCI DSS pour garantir que vos informations de paiement sont complètement sécurisées. Nous ne stockons jamais les détails complets de votre carte sur nos serveurs.',
      'faq_delivery_time_question': 'Combien de temps prend la livraison ?',
      'faq_delivery_time_answer': 'Le délai de livraison typique est de 30 à 45 minutes, selon votre emplacement, le temps de préparation et la demande actuelle. Vous pouvez suivre votre commande en temps réel via notre application, et nous vous informerons à chaque étape du processus de livraison.',
      'faq_delivery_fees_question': 'Y a-t-il des frais de livraison ?',
      'faq_delivery_fees_answer': 'Les frais de livraison varient en fonction de la distance et du restaurant. Les frais exacts sont toujours affichés avant que vous ne confirmiez votre commande.',
      'faq_delivery_contactless_question': 'Proposez-vous la livraison sans contact ?',
      'faq_delivery_contactless_answer': 'Oui ! Nous proposons la livraison sans contact pour votre sécurité et commodité. Sélectionnez simplement cette option à la caisse, et votre commande sera laissée à votre porte avec une notification envoyée sur votre téléphone.',
      'faq_account_track_question': 'Comment suivre ma commande ?',
      'faq_account_track_answer': 'Vous pouvez suivre votre commande en temps réel via notre application ou site web. Après avoir passé votre commande, vous verrez des mises à jour en direct incluant la confirmation de commande, le statut de préparation, la notification d\'expédition et l\'heure de livraison estimée. Vous pouvez également voir l\'emplacement de votre livreur sur la carte.',
      'faq_account_incorrect_question': 'Que faire si ma commande est incorrecte ou manque des articles ?',
      'faq_account_incorrect_answer': 'S\'il y a un problème avec votre commande, veuillez nous contacter immédiatement via l\'application ou le support client. Prenez des photos du problème si possible. Nous travaillerons avec le restaurant pour résoudre le problème et offrir un remboursement, un remplacement ou un crédit sur votre compte.',
      'faq_account_dietary_question': 'Avez-vous des filtres diététiques ?',
      'faq_account_dietary_answer': 'Oui ! Vous pouvez filtrer les éléments du menu par préférences alimentaires, y compris végétarien, végétalien, sans gluten, sans produits laitiers, sans noix, halal et casher. Nous fournissons également des informations détaillées sur les allergènes pour chaque plat. Cherchez l\'icône de filtre dans le menu de l\'application.',

      "noNotifications": "Aucune Notification",
      "youWillSeeNotificationsHere": "Vous verrez les notifications ici",
      "markAllAsRead": "Tout marquer comme lu",
      "allNotificationsMarkedAsRead": "Toutes les notifications marquées comme lues",
      "notificationDeleted": "Notification supprimée",
      "clearAllNotifications": "Effacer Toutes les Notifications",
      "areYouSureYouWantToClearAllNotifications": "Êtes-vous sûr de vouloir effacer toutes les notifications ?",
      "allNotificationsCleared": "Toutes les notifications effacées",
      "noNotificationsInThisCategory": "Aucune notification dans cette catégorie",
      "yourPhone": "Votre Téléphone",
      "yourSubject": "Votre Sujet"
    },
  };

  // App Info
  static String get appName => get('appName');
  static String get appSlogan => get('appSlogan');
  static String get callus => get('callus');

  // General
  static String get search => get('search');
  static String get viewAll => get('viewAll');
  static String get add => get('add');
  static String get remove => get('remove');
  static String get confirm => get('confirm');
  static String get cancel => get('cancel');
  static String get retry => get('retry');
  static String get loading => get('loading');
  static String get error => get('error');
  static String get success => get('success');
  static String get somethingWentWrong => get('somethingWentWrong');
  static String get noData => get('noData');
  static String get noInternet => get('noInternet');
  static String get shop => get('shop');
  
  // Navigation
  static String get home => get('home');
  static String get menu => get('menu');
  static String get offers => get('offers');
  static String get profile => get('profile');
  static String get back => get('back');
  
  // Authentication
  static String get signIn => get('signIn');
  static String get signUp => get('signUp');
  static String get signOut => get('signOut');
  static String get email => get('email');
  static String get password => get('password');
  static String get confirmPassword => get('confirmPassword');
  static String get forgotPassword => get('forgotPassword');
  static String get dontHaveAccount => get('dontHaveAccount');
  static String get alreadyHaveAccount => get('alreadyHaveAccount');
  static String get firstName => get('firstName');
  static String get lastName => get('lastName');
  static String get phoneNumber => get('phoneNumber');
  static String get loginRequired => get('loginRequired');
  static String get loginToContinue => get('loginToContinue');
  
  // Home
  static String get ourMenu => get('ourMenu');
  static String get featuredItems => get('featuredItems');
  static String get mostPopularItems => get('mostPopularItems');
  static String get freeDelivery => get('freeDelivery');
  static String get tryChicken => get('tryChicken');
  static String get freeShake => get('freeShake');
  static String get coolDown => get('coolDown');
  
  // Categories
  static String get friendsFamily => get('friendsFamily');
  static String get highOnCoffee => get('highOnCoffee');
  static String get duetCombos => get('duetCombos');
  static String get whopper => get('whopper');
  static String get veg => get('veg');
  static String get nonVeg => get('nonVeg');
  static String get appLogo => get('appLogo');
  static String get noItems => get('noItems');
  static String get checkBackLater => get('checkBackLater');
  static String get featured => get('featured');
  static String get popular => get('popular');
  
  // Cart & Checkout
  static String get myCart => get('myCart');
  static String get checkout => get('checkout');
  static String get proceedToCheckout => get('proceedToCheckout');
  static String get placeOrder => get('placeOrder');
  static String get addToCart => get('addToCart');
  static String get quantity => get('quantity');
  static String get mealSize => get('mealSize');
  static String get mediumMeal => get('mediumMeal');
  static String get largeMeal => get('largeMeal');
  static String get burgerOnly => get('burgerOnly');
  static String get extras => get('extras');
  static String get addons => get('addons');
  static String get extraCheese => get('extraCheese');
  static String get extraPattyChicken => get('extraPattyChicken');
  static String get specialInstructions => get('specialInstructions');
  static String get instructionsHint => get('instructionsHint');
  static String get subtotal => get('subtotal');
  static String get deliveryFee => get('deliveryFee');
  static String get total => get('total');
  static String get cartSummary => get('cartSummary');
  static String get frequentlyBoughtTogether => get('frequentlyBoughtTogether');
  
  // Delivery & Location
  static String get delivery => get('delivery');
  static String get takeaway => get('takeaway');
  static String get selectBranch => get('selectBranch');
  static String get deliveryAddress => get('deliveryAddress');
  static String get addAddress => get('addAddress');
  static String get editAddress => get('editAddress');
  static String get homeAddress => get('homeAddress');
  static String get workAddress => get('workAddress');
  static String get preferenceTime => get('preferenceTime');
  static String get today => get('today');
  static String get tomorrow => get('tomorrow');
  static String get now => get('now');
  static String get estimatedDelivery => get('estimatedDelivery');
  
  // Payment
  static String get selectPaymentMethod => get('selectPaymentMethod');
  static String get paypal => get('paypal');
  static String get stripe => get('stripe');
  static String get visaCard => get('visaCard');
  static String get mastercard => get('mastercard');
  static String get cardNumber => get('cardNumber');
  static String get expiresOn => get('expiresOn');
  static String get payNow => get('payNow');
  static String get cancelOrder => get('cancelOrder');
  static String get cashOnDelivery => get('cashOnDelivery');
  static String get paymentMethod => get('paymentMethod');
  static String get paymentStatus => get('paymentStatus');
  static String get unpaid => get('unpaid');
  static String get paid => get('paid');
  
  // Orders
  static String get orderStatus => get('orderStatus');
  static String get orderDetails => get('orderDetails');
  static String get orderPlaced => get('orderPlaced');
  static String get orderConfirmed => get('orderConfirmed');
  static String get preparing => get('preparing');
  static String get outForDelivery => get('outForDelivery');
  static String get ready => get('ready');
  static String get delivered => get('delivered');
  static String get getYourOrder => get('getYourOrder');
  static String get orderHistory => get('orderHistory');
  static String get reorder => get('reorder');
  static String get trackOrder => get('trackOrder');
  
  // Validation Messages
  static String get pleaseEnterEmail => get('pleaseEnterEmail');
  static String get pleaseEnterValidEmail => get('pleaseEnterValidEmail');
  static String get pleaseEnterPassword => get('pleaseEnterPassword');
  static String get passwordTooShort => get('passwordTooShort');
  static String get passwordsDontMatch => get('passwordsDontMatch');
  static String get pleaseEnterName => get('pleaseEnterName');
  static String get pleaseEnterPhone => get('pleaseEnterPhone');
  static String get yourSubject => get('yourSubject');

  // Success Messages
  static String get orderPlacedSuccessfully => get('orderPlacedSuccessfully');
  static String get accountCreatedSuccessfully => get('accountCreatedSuccessfully');
  static String get profileUpdatedSuccessfully => get('profileUpdatedSuccessfully');
  static String get addressAddedSuccessfully => get('addressAddedSuccessfully');
  
  // Error Messages
  static String get failedToPlaceOrder => get('failedToPlaceOrder');
  static String get failedToLogin => get('failedToLogin');
  static String get failedToCreateAccount => get('failedToCreateAccount');
  static String get failedToLoadData => get('failedToLoadData');
  static String get failedToUpdateProfile => get('failedToUpdateProfile');
  
  // Time
  static String get minutes => get('minutes');
  static String get hours => get('hours');
  static String get am => get('am');
  static String get pm => get('pm');
  
  // Price
  static String get currency => get('currency');
  static String get free => get('free');
  
  // Restaurant Info
  static String get boshundhoraRA => get('boshundhoraRA');
  static String get gulshan2 => get('gulshan2');
  static String get banani => get('banani');
  static String get dhanmondi => get('dhanmondi');
  static String get km => get('km');
  static String get flat => get('flat');
  static String get house => get('house');
  static String get road => get('road');

  static String get defaultLabel => get('default');
  static String get chooseDeliveryAddress => get('chooseDeliveryAddress');
  static String get setAsDefault => get('setAsDefault');
  static String get delete => get('delete');
  static String get deleteAddress => get('deleteAddress');
  static String get confirmDeleteAddress => get('confirmDeleteAddress');
  static String get defaultAddressUpdated => get('defaultAddressUpdated');
  static String get addressDeletedSuccessfully => get('addressDeletedSuccessfully');

  // New static getters for backward compatibility
  static String get tagline => get('tagline');
  static String get completeAddressDetails => get('completeAddressDetails');
  static String get selectAddress => get('selectAddress');
  static String get savedAddresses => get('savedAddresses');
  static String get addYourFirstAddress => get('addYourFirstAddress');
  static String get addNewAddress => get('addNewAddress');
  static String get searchAddress => get('searchAddress');
  static String get startTypingAddress => get('startTypingAddress');
  static String get noAddressesFound => get('noAddressesFound');
  static String get tryDifferentSearch => get('tryDifferentSearch');
  static String get office => get('office');
  static String get other => get('other');
  static String get apartmentNumber => get('apartmentNumber');
  static String get apartmentPlaceholder => get('apartmentPlaceholder');
  static String get deliveryInstructions => get('deliveryInstructions');
  static String get deliveryInstructionsPlaceholder => get('deliveryInstructionsPlaceholder');
  static String get saveAddress => get('saveAddress');
  static String get pleaseEnterApartment => get('pleaseEnterApartment');
  static String get addressSavedWithDistance => get('addressSavedWithDistance');
  static String get addressBeyondRangeWithLimit => get('addressBeyondRangeWithLimit');
  static String get failedToFetchPlaceDetails => get('failedToFetchPlaceDetails');
  static String get noDescription => get('noDescription');
  static String get pleaseSelectDeliveryAddress => get('pleaseSelectDeliveryAddress');
  static String get addressBeyondDeliveryRange => get('addressBeyondDeliveryRange');
  static String get pickupLocation => get('pickupLocation');
  static String get pickupTime => get('pickupTime');
  static String get cartEmpty => get('cartEmpty');
  static String get moreItems => get('moreItems');

  static String get noOrdersDescription => get('noOrdersDescription');
  static String get startOrdering => get('startOrdering');
  static String get orderNumber => get('orderNumber');
  static String get totalAmount => get('totalAmount');
  static String get viewDetails => get('viewDetails');
  static String get goToMenu => get('goToMenu');
  static String get item => get('item');
  static String get items => get('items');
  static String get branch => get('branch');
  static String get pickup => get('pickup');
  static String get cash => get('cash');
  static String get card => get('card');

  static String get yesterday => get('yesterday');
  static String get welcomeBack => get('welcomeBack');

  static String get pressBackAgain => get('pressBackAgain');
  static String get quickActions => get('quickActions');
  static String get downloadData => get('downloadData');
  static String get helpCenter => get('helpCenter');
  static String get accountSettings => get('accountSettings');
  static String get personalInformation => get('personalInformation');
  static String get preferences => get('preferences');
  static String get notifications => get('notifications');
  static String get privacy => get('privacy');
  static String get securityAndSupport => get('securityAndSupport');
  static String get changePassword => get('changePassword');
  static String get helpAndSupport => get('helpAndSupport');
  static String get about => get('about');
  static String get signInPrompt => get('signInPrompt');
  static String get viewPastOrders => get('viewPastOrders');
  static String get updatePassword => get('updatePassword');
  static String get contactUs => get('contactUs');
  static String get getInTouch => get('getInTouch');
  static String get learnAboutUs => get('learnAboutUs');
  static String get notificationPreferences => get('notificationPreferences');
  static String get getHelpAndSupport => get('getHelpAndSupport');
  static String get appVersion => get('appVersion');
  static String get aboutApp => get('aboutApp');
  static String get appDescription => get('appDescription');
  static String get copyright => get('copyright');
  static String get companyAddress => get('companyAddress');
  static String get close => get('close');
  static String get save => get('save');
  static String get areYouSureSignOut => get('areYouSureSignOut');
  static String get imageNotAvailable => get('imageNotAvailable');
  static String get addedToCart => get('addedToCart');
  static String get undo => get('undo');
  static String get outOfStock => get('outOfStock');
  static String get loadingMenu => get('loadingMenu');
  static String get noCategoriesAvailable => get('noCategoriesAvailable');
  static String get noFoodItemsAvailable => get('noFoodItemsAvailable');
  static String get discoverOfferings => get('discoverOfferings');
  static String get filters => get('filters');
  static String get allCategories => get('allCategories');
  static String get vegetarian => get('vegetarian');
  static String get nonVegetarian => get('nonVegetarian');
  static String get popularItems => get('popularItems');
  static String get foodType => get('foodType');
  static String get clearAll => get('clearAll');
  static String get apply => get('apply');

  static String get aboutUs => get('aboutUs');
  static String get cart => get('cart');
  static String get account => get('account');

  static String get orderNotFound => get('orderNotFound');
  static String get goBack => get('goBack');
  static String get collected => get('collected');
  static String get readyForPickup => get('readyForPickup');
  static String get callRestaurant => get('callRestaurant');
  static String get restaurantAddress => get('restaurantAddress');
  static String get estimatedTime => get('estimatedTime');
  
  static String get paymentFailed => get('paymentFailed');
  static String get paymentRefunded => get('paymentRefunded');
  static String get emptyOrderItems => get('emptyOrderItems');

  static String get tax => get('tax');
  static String get jan => get('jan');
  static String get feb => get('feb');
  static String get mar => get('mar');
  static String get apr => get('apr');
  static String get may => get('may');
  static String get jun => get('jun');
  static String get jul => get('jul');
  static String get aug => get('aug');
  static String get sep => get('sep');
  static String get oct => get('oct');
  static String get nov => get('nov');
  static String get dec => get('dec');

  static String get callError => get('callError');
  static String get callErrorGeneric => get('callErrorGeneric');
  
  // New static getters for backward compatibility
  static String get loadingOffers => get('loadingOffers');
  static String get specialOffers => get('specialOffers');
  static String get noOffersAvailable => get('noOffersAvailable');
  static String get checkBackLaterOffers => get('checkBackLaterOffers');
  static String get browseMenu => get('browseMenu');
  static String get emptyCart => get('emptyCart');
  static String get addFoodToStart => get('addFoodToStart');

  static String get specialInstructionsHint => get('specialInstructionsHint');
  static String get orderSummary => get('orderSummary');
  static String get sizeLabel => get('sizeLabel');
  static String get extrasLabel => get('extrasLabel');
  static String get addonsLabel => get('addonsLabel');
  static String get pickupOrder => get('pickupOrder');
  static String get deliveryOrder => get('deliveryOrder');
  static String get payAtShopDescription => get('payAtShopDescription');
  static String get choosePaymentDelivery => get('choosePaymentDelivery');
  static String get paymentSummary => get('paymentSummary');
  static String get orderType => get('orderType');
  static String get paymentType => get('paymentType');
 
  static String get payAtShopCounter => get('payAtShopCounter');
  static String get payWithCashOnDelivery => get('payWithCashOnDelivery');
  static String get payWithCardOnDelivery => get('payWithCardOnDelivery');
  static String get shopPayment => get('shopPayment');
  static String get deliveryPayment => get('deliveryPayment');
  static String get choosePaymentType => get('choosePaymentType');
  static String get otherOptionsComingSoon => get('otherOptionsComingSoon');
  static String get payAtShop => get('payAtShop');
  static String get paypalDescription => get('paypalDescription');
  static String get stripeDescription => get('stripeDescription');
  static String get cardDescription => get('cardDescription');
  static String get comingSoon => get('comingSoon');
  static String get payWithCash => get('payWithCash');
  static String get payWithCard => get('payWithCard');
  static String get noneSelected => get('noneSelected');
  static String get shopPaymentMethod => get('shopPaymentMethod');
  static String get errorFailedToLoadOrder => get('errorFailedToLoadOrder');
  static String get unexpectedError => get('unexpectedError');
  static String get businessHours => get('businessHours');
  static String get address => get('address');
  static String get infoEmail => get('infoEmail');
  static String get supportEmail => get('supportEmail');
  static String get formSubmissionSuccess => get('formSubmissionSuccess');
  static String get formSubmissionError => get('formSubmissionError');

  static String get failedToLoadOffers => get('failedToLoadOffers');
  static String get unknownError => get('unknownError');
 
  static String get days => get('days');
  static String get offerPlaceholder => get('offerPlaceholder');
  static String get brandDescription => get('brandDescription');
  static String get quickLinks => get('quickLinks');

  static String get reservations => get('reservations');
  static String get gallery => get('gallery');
  static String get blog => get('blog');
  static String get careers => get('careers');
  static String get resources => get('resources');
 
  static String get privacyPolicy => get('privacyPolicy');
  static String get termsOfService => get('termsOfService');
  static String get cookiePolicy => get('cookiePolicy');
  static String get faq => get('faq');
  static String get stayConnected => get('stayConnected');
  static String get subscribeOffers => get('subscribeOffers');
  static String get yourEmail => get('yourEmail');
  static String get subscribe => get('subscribe');

  static String get weAccept => get('weAccept');
  static String get visa => get('visa');
  
  // New static getters for backward compatibility
  static String get resetPassword => get('resetPassword');
  static String get enterYourEmail => get('enterYourEmail');
  static String get verificationCode => get('verificationCode');
  static String get enter6DigitCode => get('enter6DigitCode');
  static String get pleaseEnterCode => get('pleaseEnterCode');
  static String get codeMustBe6Digits => get('codeMustBe6Digits');
  static String get newPassword => get('newPassword');
  static String get enterNewPassword => get('enterNewPassword');
  static String get passwordMinLength => get('passwordMinLength');
 
  static String get reEnterNewPassword => get('reEnterNewPassword');
  static String get pleaseConfirmPassword => get('pleaseConfirmPassword');
  static String get passwordsDoNotMatch => get('passwordsDoNotMatch');
  static String get backToLogin => get('backToLogin');
  static String get resetCodeSent => get('resetCodeSent');
  static String get failedToSendResetCode => get('failedToSendResetCode');
  static String get invalid6DigitCode => get('invalid6DigitCode');
  static String get codeVerified => get('codeVerified');
  static String get invalidOrExpiredCode => get('invalidOrExpiredCode');
  static String get passwordResetSuccess => get('passwordResetSuccess');
  static String get failedToResetPassword => get('failedToResetPassword');
  static String get newCodeSent => get('newCodeSent');
  static String get failedToSendCode => get('failedToSendCode');
  static String get createNewPassword => get('createNewPassword');
  static String get verifyCode => get('verifyCode');
  static String get enterNewPasswordSubtitle => get('enterNewPasswordSubtitle');
  static String get enterCodeSubtitle => get('enterCodeSubtitle');
  static String get enterEmailSubtitle => get('enterEmailSubtitle');
  static String get resetPasswordButton => get('resetPasswordButton');
  static String get verifyCodeButton => get('verifyCodeButton');
  static String get sendResetCode => get('sendResetCode');
  static String get resendCodeCountdown => get('resendCodeCountdown');
  static String get resendCode => get('resendCode');
  static String get secureAccount => get('secureAccount');
  static String get currentPassword => get('currentPassword');
  static String get enterCurrentPassword => get('enterCurrentPassword');
  static String get pleaseEnterCurrentPassword => get('pleaseEnterCurrentPassword');
  static String get pleaseEnterNewPassword => get('pleaseEnterNewPassword');
  static String get passwordMinLength6 => get('passwordMinLength6');
  static String get newPasswordDifferent => get('newPasswordDifferent');
  static String get pleaseConfirmNewPassword => get('pleaseConfirmNewPassword');
  static String get passwordRequirements => get('passwordRequirements');
  static String get passwordMinLength6Tip => get('passwordMinLength6Tip');
  static String get passwordUpperLower => get('passwordUpperLower');
  static String get passwordNumbersSpecial => get('passwordNumbersSpecial');
  static String get avoidCommonWords => get('avoidCommonWords');
  static String get changePasswordButton => get('changePasswordButton');
  static String get passwordChangedSuccess => get('passwordChangedSuccess');
  static String get passwordChangeFailed => get('passwordChangeFailed');
  static String get verifyYourEmail => get('verifyYourEmail');
  static String get sentVerificationCode => get('sentVerificationCode');
  static String get codeExpired => get('codeExpired');
  static String get codeExpiresIn => get('codeExpiresIn');
  static String get didntReceiveCode => get('didntReceiveCode');
  static String get resend => get('resend');
  static String get verifyEmail => get('verifyEmail');
  static String get emailVerifiedSuccess => get('emailVerifiedSuccess');
  static String get invalidOrExpiredOTP => get('invalidOrExpiredOTP');
  static String get joinApp => get('joinApp');
  static String get createAccountDescription => get('createAccountDescription');
  static String get secureCheckout => get('secureCheckout');
  static String get personalizedRecommendations => get('personalizedRecommendations');
  static String get exclusiveBenefits => get('exclusiveBenefits');
  static String get customerSupport => get('customerSupport');
  static String get createAccount => get('createAccount');
  static String get fillInDetails => get('fillInDetails');
  static String get signUpToStart => get('signUpToStart');
  static String get verificationCodeSent => get('verificationCodeSent');
  static String get accountCreatedSuccess => get('accountCreatedSuccess');
  static String get welcomeToApp => get('welcomeToApp');
  static String get bestFastFoodDestination => get('bestFastFoodDestination');
  static String get ourStory => get('ourStory');
  static String get storyDescription => get('storyDescription');
  static String get ourValues => get('ourValues');
  static String get quality => get('quality');
  static String get qualityDescription => get('qualityDescription');
  static String get speed => get('speed');
  static String get speedDescription => get('speedDescription');
  static String get passion => get('passion');
  static String get passionDescription => get('passionDescription');
  static String get ourMission => get('ourMission');
  static String get missionDescription => get('missionDescription');


  static String get restaurantClosed => get('restaurantClosed') ?? 'Restaurant Closed';
  static String get restaurantClosedDescription => 
     get('restaurantClosedDescription') ?? 
    'Sorry, we\'re not accepting orders right now';
  static String get checkOurHours =>  get('checkOurHours') ?? 'Check Our Hours';
  static String get closingSoon =>  get('closingSoon') ?? 'Closing Soon';
  static String get orderBeforeClosing =>  get('orderBeforeClosing') ?? 'Order before we close';


   static String _getTranslation(String key, String language) {
    if (_translations.containsKey(key)) {
      final translations = _translations[key]!;
      // Try the requested language first
      if (translations.containsKey(language)) {
        return translations[language]!;
      }
      // Fallback to English
      if (translations.containsKey('en')) {
        return translations['en']!;
      }
      // Return first available translation
      return translations.values.first;
    }
    // Key not found, return the key itself
    return key;
  }

}
