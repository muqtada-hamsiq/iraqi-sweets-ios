# تجهيز Iraqi Sweets للآيفون

## حالة المشروع
- Flutter project موجود.
- مجلد iOS وملف Xcode project موجودان.
- Bundle Identifier الحالي: `com.iraqisweets.game`.
- اسم التطبيق على iPhone: `حلويات عراقية`.
- الحد الأدنى المحدد في المشروع: iOS 15.0.
- الإصدار: 1.0.0 (build 1).

## ملاحظة مهمة
هذا الأرشيف يجهّز مصدر المشروع فقط، وليس ملف IPA موقّعاً. إنشاء تطبيق iOS يتطلب macOS وXcode. ملفات `ios/Flutter/Generated.xcconfig` و`flutter_export_environment.sh` حُذفت لأنها كانت تحتوي مسارات جهاز بناء سابق، وسيعيد Flutter توليدها على جهاز البناء.

## تثبيت شخصي مجاني باستخدام Apple ID
1. على جهاز Mac ثبّت Xcode وFlutter.
2. افتح Terminal داخل مجلد المشروع وشغّل:
   - `flutter pub get`
   - `open ios/Runner.xcworkspace`
3. في Xcode افتح Settings > Accounts وأضف Apple Account.
4. اختر Runner > Signing & Capabilities، فعّل Automatically manage signing، واختر Personal Team.
5. غيّر Bundle Identifier إذا كان مستخدماً مسبقاً بحساب Apple Account.
6. وصّل iPhone وافق على Trust، وفَعّل Developer Mode عند الطلب.
7. اختر جهاز iPhone ثم اضغط Run لتثبيت التطبيق.

التوقيع المجاني مخصص للاختبار الشخصي؛ ملفات التعريف الشخصية تنتهي عادةً بعد 7 أيام، وبعدها يلزم إعادة التوقيع والتثبيت.

## بناء IPA للتطوير
بعد إعداد التوقيع والجهاز في Xcode، يمكن تجربة:
`flutter build ipa --release --export-method development`

قد يتطلب تصدير IPA ضبط ملف التوقيع/ملف التزويد الخاص بجهازك. لا ترفع كلمات مرور Apple Account أو مفاتيحك الخاصة لأي جهة.
