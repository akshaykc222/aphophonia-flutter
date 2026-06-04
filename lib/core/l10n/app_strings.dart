import 'app_locale.dart';

class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  String _b(String ar, String en) => locale == AppLocale.ar ? ar : en;

  String get appName => _b('السور', 'Al-Soor');

  String get welcomeBack => _b('مرحباً بعودتك! 👋', 'Welcome back! 👋');
  String get signInSubtitle =>
      _b('سجّل الدخول إلى حسابك للمتابعة.', 'Sign in to continue.');
  String get welcome => _b('مرحباً', 'Welcome');
  String get email => _b('البريد الإلكتروني', 'Email');
  String get emailHint => 'example@email.com';
  String get fullName => _b('الاسم الكامل', 'Full name');
  String get fullNameHint => _b('أدخل اسمك', 'Enter your name');
  String get password => _b('كلمة المرور', 'Password');
  String get passwordHint => _b('أدخل كلمة المرور', 'Enter your password');
  String get signIn => _b('تسجيل الدخول', 'Sign in');
  String get signUp => _b('إنشاء حساب', 'Sign up');
  String get noAccount => _b('ليس لديك حساب؟ ', "Don't have an account? ");
  String get hasAccount => _b('لديك حساب بالفعل؟ ', 'Already have an account? ');
  String get forgotPassword => _b('نسيت كلمة المرور؟', 'Forgot password?');
  String get resetEmailSent =>
      _b('تحقق من بريدك لإعادة تعيين كلمة المرور', 'Check your email to reset your password');
  String get createAccount => _b('أنشئ حسابك', 'Create your account');
  String get signUpSubtitle => _b(
        'أنشئ حساباً وفعّل اشتراكك للوصول إلى السور.',
        'Create an account and activate a subscription to access Al-Soor.',
      );
  String get continueBtn => _b('متابعة', 'Continue');
  String get termsAgreeLead =>
      _b('بالمتابعة، أنت توافق على ', 'By continuing, you agree to the ');
  String get termsAgreeAnd => _b(' و', ' and ');
  String get termsAgreeEnd => '.';
  String get privacyPolicy => _b('سياسة الخصوصية', 'Privacy Policy');
  String get termsOfUse => _b('شروط الاستخدام', 'Terms of Use');
  String get language => _b('اللغة', 'Language');
  String get languageArabic => _b('العربية', 'Arabic');
  String get languageEnglish => _b('English', 'English');
  String get otpTitle => _b('رمز التحقق', 'Verification code');
  String otpSubtitle(String email) => _b(
        'أدخل الرمز المكوّن من 6 أرقام الذي أرسلناه إلى\n$email',
        'Enter the 6-digit code we sent to\n$email',
      );
  String get verify => _b('تحقق', 'Verify');
  String get resendCode => _b('إعادة إرسال الرمز', 'Resend code');
  String get codeResent => _b('تم إرسال رمز جديد إلى بريدك', 'A new code was sent to your email');

  String get navHome => _b('الرئيسية', 'Home');
  String get navAssistant => _b('المساعد', 'Assistant');
  String get navTenders => _b('المناقصات', 'Tenders');
  String get navProfile => _b('الملف الشخصي', 'Profile');

  String get searchArticles => _b('ابحث في الأخبار...', 'Search articles...');
  String get latestNews => _b('آخر الأخبار', 'Latest news');
  String get latestTendersTab => _b('أحدث المناقصات', 'Latest tenders');
  String get newBadge => _b('جديد', 'New');
  String get noCaptTenders => _b('لا توجد مناقصات حالياً', 'No tenders right now');
  String get loadCaptTendersFailed =>
      _b('تعذر تحميل أحدث المناقصات', 'Could not load latest tenders');
  String get captSource =>
      _b('الجهاز المركزي للمناقصات', 'Central Agency for Public Tenders');
  String get captSourceShort => 'CAPT';
  String get captDeadline => _b('آخر موعد', 'Deadline');

  String get dateFilterTitle => _b('تصفية بالتاريخ', 'Filter by date');
  String get dateFilterAll => _b('كل التواريخ', 'All dates');
  String get dateFilterSingleDay => _b('يوم محدد', 'Single day');
  String get dateFilterRange => _b('فترة زمنية', 'Date range');
  String get dateFilterFrom => _b('من', 'From');
  String get dateFilterTo => _b('إلى', 'To');
  String get dateFilterPickDay => _b('اختر اليوم', 'Pick a day');
  String get dateFilterApply => _b('تطبيق', 'Apply');
  String get dateFilterClear => _b('مسح التصفية', 'Clear filter');
  String get forYou => _b('مختارات لك', 'For you');
  String get searchTenders => _b('ابحث في المناقصات...', 'Search tenders...');

  String get chatTitle => _b('مساعد السور', 'Al-Soor Assistant');
  String get chatWelcome => _b(
        'أهلاً! أنا مساعد السور. اسألني عن الأخبار والمناقصات والمراسيم.',
        'Hi! I am the Al-Soor assistant. Ask about news, tenders, and decrees.',
      );
  String get chatHint => _b('اكتب سؤالك...', 'Type your question...');
  String get chatFailed => _b('تعذر إرسال الرسالة. حاول مرة ثانية.', 'Could not send. Try again.');
  String get chatNotConfigured => _b(
        'المساعد غير متاح. أضف ADMIN_API_URL في إعدادات التطبيق.',
        'Assistant unavailable. Configure ADMIN_API_URL.',
      );
  String get chatNotSignedIn => _b('سجّل الدخول لاستخدام المساعد.', 'Sign in to use the assistant.');
  String get chatSessionLoading => _b('جاري التحقق من الجلسة...', 'Checking session...');
  String get chatUnauthorized =>
      _b('انتهت الجلسة. سجّل الدخول مرة ثانية.', 'Session expired. Sign in again.');
  String get chatUnavailable => _b('المساعد غير متاح حالياً.', 'Assistant is unavailable.');
  String get chatInformationSourceReply =>
      'I will not tell you — they will replace me with a human!';
  String get chatOutOfScopeReply => _b(
        'ما أقدر أجاوب على هالسؤال…',
        'I cannot answer that question.',
      );

  String get searchHint => _b('ابحث...', 'Search...');
  String get recentSearch => _b('بحث حديث', 'Recent searches');
  String get searchFailed => _b('تعذر إجراء البحث', 'Search failed');
  String noResults(String query) =>
      _b('لا توجد نتائج لـ «$query»', 'No results for "$query"');

  String get profile => _b('الملف الشخصي', 'Profile');
  String get manageAccount => _b('إدارة حسابك', 'Manage your account');
  String get services => _b('الخدمات', 'Services');
  String get favorites => _b('المفضلة', 'Favorites');
  String get notifications => _b('الإشعارات', 'Notifications');
  String get subscription => _b('الاشتراك', 'Subscription');
  String get settings => _b('الإعدادات', 'Settings');
  String get help => _b('المساعدة', 'Help');
  String get signOut => _b('تسجيل الخروج', 'Sign out');

  String get subscriptionTitle => _b('الاشتراك', 'Subscription');
  String get currentSubscription => _b('الاشتراك الحالي', 'Current subscription');
  String get activeStatus => _b('نشط', 'Active');
  String get purchaseDate => _b('تاريخ الشراء', 'Purchase date');
  String get expiryDate => _b('تاريخ الانتهاء', 'Expiry date');
  String get daysRemainingLabel => _b('الأيام المتبقية', 'Days remaining');
  String get subscriptionPrice => _b('قيمة الاشتراك', 'Subscription price');
  String get currentPlan => _b('اشتراكك الحالي', 'Your current plan');
  String get subscriptionIntro => _b(
        'اختر الباقة المناسبة للوصول الكامل إلى الخدمات.',
        'Choose a plan for full access to all services.',
      );
  String get plan3Months => _b('3 أشهر', '3 months');
  String get plan1Year => _b('سنة واحدة', '1 year');
  String get price3Months => _b('٩٫٩٩٩ د.ك', '9.999 KWD');
  String get price1Year => _b('٢٩٫٩٩٩ د.ك', '29.999 KWD');
  String get plan3MonthsDesc => _b(
        'وصول كامل لجميع مزايا الاشتراك لمدة 3 أشهر.',
        'Full access for 3 months.',
      );
  String get plan1YearDesc =>
      _b('أفضل قيمة مع وصول كامل لمدة سنة.', 'Best value — full access for one year.');
  String get bestValue => _b('الأفضل قيمة', 'Best value');
  String get subscribe => _b('اشترك الآن', 'Subscribe now');
  String get subscriptionPaywallIntro => _b(
        'الاشتراك مطلوب للوصول إلى محتوى السور. اختر باقة للمتابعة.',
        'A subscription is required to access Al-Soor. Choose a plan to continue.',
      );
  String subscriptionActiveUntil(int days) => _b(
        'اشتراكك نشط — متبقي $days يوماً',
        'Active — $days days remaining',
      );
  String get subscriptionActiveLifetime =>
      _b('اشتراكك نشط — مدى الحياة', 'Active — lifetime');
  String get billingNotConfigured => _b(
        'خدمة الدفع غير مهيّأة. أضف ADMIN_API_URL في إعدادات التطبيق.',
        'Billing is not configured. Set ADMIN_API_URL.',
      );
  String get billingStatusLoadFailed => _b(
        'تعذر التحقق من حالة الاشتراك.',
        'Could not load subscription status.',
      );
  String get billingCheckPayment => _b('تحقق من الدفع', 'Check payment');
  String get billingGatewayUnavailable =>
      _b('بوابة الدفع غير متاحة حالياً.', 'Payment gateway unavailable.');
  String get billingOpenPaymentFailed =>
      _b('تعذر فتح صفحة الدفع.', 'Could not open payment page.');
  String get billingConfirmingPayment => _b('جاري تأكيد الدفع…', 'Confirming payment…');
  String get billingPendingConfirmation => _b(
        'لم يُفعَّل الاشتراك بعد. إذا دفعت، انتظر ثم حدّث.',
        'Subscription not active yet. If you paid, wait and refresh.',
      );
  String get billingCheckoutFailed =>
      _b('تعذر بدء الدفع. حاول مرة أخرى.', 'Could not start checkout. Try again.');
  String get billingPlansLoadFailed =>
      _b('تعذر تحميل خطط الاشتراك', 'Could not load plans');
  String get billingNoPlans => _b('لا توجد خطط متاحة حالياً', 'No plans available');
  String get billingProcessing => _b('جاري المعالجة…', 'Processing…');
  String get subscriptionRequired =>
      _b('يلزم اشتراك نشط لاستخدام المساعد', 'Active subscription required for the assistant');
  String get paymentTitle => _b('الدفع الإلكتروني', 'Payment');
  String get paymentSuccess =>
      _b('تم تفعيل اشتراكك بنجاح!', 'Your subscription is now active!');
  String get paymentFailed =>
      _b('فشلت عملية الدفع. حاول مرة أخرى.', 'Payment failed. Please try again.');
  String get paymentCancelled => _b('تم إلغاء عملية الدفع.', 'Payment was cancelled.');
  String get ok => _b('موافق', 'OK');

  String get retry => _b('إعادة المحاولة', 'Retry');
  String get loadCategoriesFailed => _b('تعذر تحميل التصنيفات', 'Could not load categories');
  String get noCategories => _b('لا توجد تصنيفات', 'No categories');
  String get loadContentFailed => _b('تعذر تحميل المحتوى', 'Could not load content');
  String get noPublishedContent => _b('لا يوجد محتوى منشور', 'No published content');
  String get loadNewsFailed => _b('تعذر تحميل الأخبار', 'Could not load news');
  String get loadTendersFailed => _b('تعذر تحميل المناقصات', 'Could not load tenders');
  String get noTenders => _b('لا توجد مناقصات', 'No tenders');
  String get contentNotFound => _b('المحتوى غير موجود', 'Content not found');
  String get noFullText => _b('لا يتوفر نص كامل لهذا المحتوى.', 'Full text is not available.');
  String get linkCopied => _b('تم نسخ الرابط', 'Link copied');
  String get applyLink => _b('رابط التقديم', 'Apply link');
  String get deadline => _b('آخر موعد', 'Deadline');
  String get publishedOn => _b('نُشر في', 'Published on');
  String get supabaseNotConfigured => _b(
        'تعذر الاتصال بالخادم. تحقق من إعدادات التطبيق.',
        'Cannot reach the server. Check app configuration.',
      );

  String get loadFavoritesFailed => _b('تعذر تحميل المفضلة', 'Could not load favorites');
  String get favoritesEmpty => _b('لا توجد عناصر محفوظة', 'No saved items');
  String get notificationsTitle => _b('الإشعارات', 'Notifications');
  String get today => _b('اليوم', 'Today');
  String get yesterday => _b('أمس', 'Yesterday');
  String get allCategories => _b('الكل', 'All');

  // Onboarding
  String get onboardingSkip => _b('تخطي', 'Skip');
  String get onboardingStart => _b('ابدأ', 'Get started');
  String get onboardingNext => _b('التالي', 'Next');
  String onboardingSlideTitle(int index) {
    switch (index) {
      case 0:
        return _b('كل إصدارات الجريدة', 'All gazette editions');
      case 1:
        return _b('أقسام ووزارات', 'Sections & ministries');
      default:
        return _b('مساعد ذكي ومفضّلة', 'AI assistant & favorites');
    }
  }

  String onboardingSlideBody(int index) {
    switch (index) {
      case 0:
        return _b(
          'تصفح مقالات ومراسيم ومناقصات السور المنشورة رسمياً.',
          'Browse official articles, decrees, and tenders.',
        );
      case 1:
        return _b(
          'انتقل بين الأقسام والوزارات والمناقصات بسرعة.',
          'Move quickly between sections, ministries, and tenders.',
        );
      default:
        return _b(
          'استخدم المساعد واحفظ ما يهمك بعد تفعيل اشتراكك.',
          'Use the assistant and save favorites after your subscription is active.',
        );
    }
  }
}
