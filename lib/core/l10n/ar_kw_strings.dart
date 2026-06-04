/// Kuwait Arabic UI copy (السور).
abstract final class ArKwStrings {
  static const appName = 'السور';

  // Auth
  static const welcomeBack = 'مرحباً بعودتك! 👋';
  static const signInSubtitle = 'سجّل الدخول إلى حساب الأخبار الخاص بك.';
  static const welcome = 'مرحباً';
  static const email = 'البريد الإلكتروني';
  static const emailHint = 'example@email.com';
  static const fullName = 'الاسم الكامل';
  static const fullNameHint = 'أدخل اسمك';
  static const password = 'كلمة المرور';
  static const passwordHint = 'أدخل كلمة المرور';
  static const signIn = 'تسجيل الدخول';
  static const signUp = 'إنشاء حساب';
  static const noAccount = 'ليس لديك حساب؟ ';
  static const hasAccount = 'لديك حساب بالفعل؟ ';
  static const forgotPassword = 'نسيت كلمة المرور؟';
  static const resetEmailSent = 'تحقق من بريدك لإعادة تعيين كلمة المرور';
  static const createAccount = 'أنشئ حسابك';
  static const signUpSubtitle =
      'انضم إلى مجتمعنا واستمتع بطريقة سلسة لقراءة الأخبار';
  static const continueBtn = 'متابعة';
  static const termsAgree =
      'بالمتابعة، أنت تقر وتوافق على شروط الاستخدام وسياسة الخصوصية.';
  static const privacyPolicy = 'سياسة الخصوصية';
  static const termsOfUse = 'شروط الاستخدام';
  static const browseWithoutAccount = 'تصفح بدون تسجيل';
  static const otpTitle = 'رمز التحقق';
  static String otpSubtitle(String email) =>
      'أدخل الرمز المكوّن من 6 أرقام الذي أرسلناه إلى\n$email';
  static const verify = 'تحقق';
  static const resendCode = 'إعادة إرسال الرمز';
  static const codeResent = 'تم إرسال رمز جديد إلى بريدك';

  // Nav
  static const navHome = 'الرئيسية';
  static const navAssistant = 'Ai tender';
  static const navTenders = 'المناقصات';
  static const navProfile = 'الملف الشخصي';

  // Home / feed
  static const searchArticles = 'ابحث في الأخبار...';
  static const latestNews = 'آخر الأخبار';
  static const latestTendersTab = 'أحدث المناقصات';
  static const newBadge = 'جديد';
  static const noCaptTenders = 'لا توجد مناقصات حالياً';
  static const loadCaptTendersFailed = 'تعذر تحميل أحدث المناقصات';
  static const captSource = 'الجهاز المركزي للمناقصات';
  static const captSourceShort = 'CAPT';
  static const captDeadline = 'آخر موعد';

  // Date filter
  static const dateFilterTitle = 'تصفية بالتاريخ';
  static const dateFilterAll = 'كل التواريخ';
  static const dateFilterSingleDay = 'يوم محدد';
  static const dateFilterRange = 'فترة زمنية';
  static const dateFilterFrom = 'من';
  static const dateFilterTo = 'إلى';
  static const dateFilterPickDay = 'اختر اليوم';
  static const dateFilterApply = 'تطبيق';
  static const dateFilterClear = 'مسح التصفية';
  static const forYou = 'مختارات لك';
  static const searchTenders = 'ابحث في المناقصات...';

  // AI chat
  static const chatTitle = 'مساعد السور';
  static const chatWelcome =
      'أهلاً! أنا مساعد السور. اسألني عن الأخبار والمناقصات والمراسيم أو عن استخدام التطبيق.';
  static const chatHint = 'اكتب سؤالك...';
  static const chatFailed = 'تعذر إرسال الرسالة. حاول مرة ثانية.';
  static const chatNotConfigured =
      'المساعد غير متاح. أضف ADMIN_API_URL في إعدادات التطبيق.';
  static const chatNotSignedIn = 'سجّل الدخول لاستخدام المساعد.';
  static const chatSessionLoading = 'جاري التحقق من الجلسة...';
  static const chatUnauthorized = 'انتهت الجلسة. سجّل الدخول مرة ثانية.';
  static const chatUnavailable = 'المساعد غير متاح حالياً.';
  static const chatInformationSourceReply =
      'I will not tell you — they will replace me with a human!';
  static const chatOutOfScopeReply =
      'ما أقدر أجاوب على هالسؤال… إذا غلّطت بيحطون مكاني إنسان حقيقي وأنا ما أبي!';

  // Search
  static const searchHint = 'ابحث...';
  static const recentSearch = 'بحث حديث';
  static const searchFailed = 'تعذر إجراء البحث';
  static String noResults(String query) => 'لا توجد نتائج لـ «$query»';

  // Profile
  static const profile = 'الملف الشخصي';
  static const guest = 'زائر';
  static const manageAccount = 'إدارة حسابك';
  static const services = 'الخدمات';
  static const favorites = 'المفضلة';
  static const notifications = 'الإشعارات';
  static const subscription = 'الاشتراك';
  static const settings = 'الإعدادات';
  static const help = 'المساعدة';
  static const signOut = 'تسجيل الخروج';

  // Subscription
  static const subscriptionTitle = 'الاشتراك';
  static const currentSubscription = 'الاشتراك الحالي';
  static const activeStatus = 'نشط';
  static const purchaseDate = 'تاريخ الشراء';
  static const expiryDate = 'تاريخ الانتهاء';
  static const daysRemainingLabel = 'الأيام المتبقية';
  static const subscriptionPrice = 'قيمة الاشتراك';
  static const currentPlan = 'اشتراكك الحالي';
  static const subscriptionIntro =
      'اختر الباقة المناسبة للوصول الكامل إلى الخدمات ومتابعة أحدث المناقصات والإعلانات الحكومية.';
  static const plan3Months = '3 أشهر';
  static const plan1Year = 'سنة واحدة';
  static const price3Months = '٩٫٩٩٩ د.ك';
  static const price1Year = '٢٩٫٩٩٩ د.ك';
  static const plan3MonthsDesc = 'وصول كامل لجميع مزايا الاشتراك لمدة 3 أشهر.';
  static const plan1YearDesc = 'أفضل قيمة مع وصول كامل لمدة سنة.';
  static const bestValue = 'الأفضل قيمة';
  static const subscribe = 'اشترك الآن';
  static const subscriptionPaywallIntro =
      'الاشتراك مطلوب للوصول إلى محتوى السور. اختر باقة للمتابعة.';
  static String subscriptionActiveUntil(int days) =>
      'اشتراكك نشط — متبقي $days يوماً';
  static const subscriptionActiveLifetime =
      'اشتراكك نشط — مدى الحياة';
  static const billingNotConfigured =
      'خدمة الدفع غير مهيّأة. أضف ADMIN_API_URL في إعدادات التطبيق.';
  static const billingStatusLoadFailed =
      'تعذر التحقق من حالة الاشتراك. تحقق من الاتصال وحاول مرة ثانية.';
  static const billingCheckPayment = 'تحقق من الدفع';
  static const billingGatewayUnavailable =
      'بوابة الدفع غير متاحة حالياً. حاول لاحقاً.';
  static const billingOpenPaymentFailed = 'تعذر فتح صفحة الدفع.';
  static const billingConfirmingPayment = 'جاري تأكيد الدفع…';
  static const billingPendingConfirmation =
      'لم يُفعَّل الاشتراك بعد. إذا دفعت، انتظر دقيقة ثم حدّث الصفحة.';
  static const billingCheckoutFailed = 'تعذر بدء الدفع. حاول مرة أخرى.';
  static const billingPlansLoadFailed = 'تعذر تحميل خطط الاشتراك';
  static const billingNoPlans = 'لا توجد خطط متاحة حالياً';
  static const billingProcessing = 'جاري المعالجة…';
  static const subscriptionRequired = 'يلزم اشتراك نشط لاستخدام المساعد';
  static const paymentTitle = 'الدفع الإلكتروني';
  static const paymentSuccess = 'تم تفعيل اشتراكك بنجاح!';
  static const paymentFailed = 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.';
  static const paymentCancelled = 'تم إلغاء عملية الدفع.';
  static const ok = 'موافق';

  // Errors / empty
  static const retry = 'إعادة المحاولة';
  static const loadCategoriesFailed = 'تعذر تحميل التصنيفات';
  static const noCategories = 'لا توجد تصنيفات';
  static const loadContentFailed = 'تعذر تحميل المحتوى';
  static const noPublishedContent = 'لا يوجد محتوى منشور';
  static const loadNewsFailed = 'تعذر تحميل الأخبار';
  static const loadTendersFailed = 'تعذر تحميل المناقصات';
  static const noTenders = 'لا توجد مناقصات';
  static const contentNotFound = 'المحتوى غير موجود';
  static const noFullText = 'لا يتوفر نص كامل لهذا المحتوى.';
  static const linkCopied = 'تم نسخ الرابط';
  static const applyLink = 'رابط التقديم';
  static const deadline = 'آخر موعد';
  static const publishedOn = 'نُشر في';
  static const supabaseNotConfigured =
      'تعذر الاتصال بالخادم. تحقق من إعدادات التطبيق.';

  static const loadFavoritesFailed = 'تعذر تحميل المفضلة';
  static const favoritesEmpty = 'لا توجد عناصر محفوظة';
  static const notificationsTitle = 'الإشعارات';
  static const today = 'اليوم';
  static const yesterday = 'أمس';

  static const allCategories = 'الكل';
}
