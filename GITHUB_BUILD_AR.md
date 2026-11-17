# بناء Iraqi Sweets على GitHub Actions

1. ارفع محتويات هذا المشروع إلى مستودع GitHub جديد (Private أفضل).
2. افتح تبويب Actions وفعّل GitHub Actions إذا طُلب ذلك.
3. اختر workflow باسم Build Iraqi Sweets iOS (unsigned) واضغط Run workflow.
4. بعد انتهاء التشغيل بنجاح، نزّل artifact باسم Iraqi-Sweets-unsigned-IPA.

## مهم جداً
هذا المسار يبني حزمة IPA غير موقّعة على macOS runner. لا يمكن تثبيتها مباشرة على iPhone قبل توقيعها بملف provisioning وشهادة صالحة. GitHub لا يتجاوز متطلبات توقيع Apple. لحساب Apple مجاني، يلزم عادةً إعادة توقيع التطبيق عبر أداة sideloading متوافقة وإعادة تثبيته دورياً؛ وغالباً يتطلب الإعداد الأولي جهاز كمبيوتر.

لا ترفع Apple ID أو كلمة مروره أو شهادات التوقيع أو ملفات provisioning إلى المستودع. تم استبعاد ملفات Android المحلية وملف إعدادات توقيع Android من هذه الحزمة لأنها تحتوي بيانات محلية/حساسة.
