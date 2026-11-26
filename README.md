# Store Management System - مشروع إدارة المتجر للكلية 🏬

مشروع Flutter بسيط، منظم، وموثق بالكامل سطر بسطر مخصص لمشروع العملي للكلية وفقاً للشروط المحددة بدقة.

---

## 🎯 مواصفات المشروع ومطابقة شروط العملي:
1. **عدد أفراد الفريق (Team):** يدعم حتى 8 أفراد (يوجد مكان مخصص لأسماء الفريق).
2. **عدد الشاشات (2 - 3 Screens):**
   - **الشاشة الأولى (`AuthScreen`):** تسجيل الدخول وإنشاء حساب (Login & Register) مع التحقق من صحة البيانات.
   - **الشاشة الثانية (`HomeScreen`):** لوحة تحكم المتجر وإدارة المنتجات (إحصائيات، بحث، فلترة بالأقسام، وعمليات CRUD للمنتجات).
   - **الشاشة الثالثة (`CategoryScreen`):** شاشة مخصصة لإدارة الأقسام (CRUD للأقسام + عرض عدد المنتجات المرتبطة بكل قسم).
3. **عمليات CRUD الأربعة (Get - Add - Update - Delete) باستخدام Hive:**
   - تم تطبيق الـ 4 عمليات بالكامل على **الأقسام (Categories)**.
   - تم تطبيق الـ 4 عمليات بالكامل على **المنتجات (Products)**.
4. **إدارة الحالة (State Management):**
   - مستخدم فيها **`provider`** حصرياً عبر `ChangeNotifier`, `MultiProvider`, `Consumer`, `context.watch`, `context.read`.
5. **الالتزام الصارم بالمكتبات المسموح بها فقط:**
   - الحزم المستخدمة هي فقط:
     - `hive: ^2.2.3`
     - `hive_flutter: ^1.1.0`
     - `provider: ^6.1.5+1`
     - `cupertino_icons` (الافتراضية في فلاتر)
   - **لا توجد أي مكتبات خارجية أخرى (ممنوع Bloc, GetX, Dio, Riverpod, Http, SharedPreferences, etc.) لضمان الحصول على الدرجة كاملة.**
6. **التوثيق والشرح:** كل ملف وكل دالة وكل سطر عليه تعليقات واضحة جداً باللغة الإنجليزية لتسهيل الشرح والمناقشة.

---

## 📁 هيكل المشروع (Project Architecture):
```text
lib/
├── models/
│   ├── user_model.dart       // كلاس المستخدم لتسجيل الدخول والإنشاء
│   ├── category_model.dart   // كلاس القسم (id, name, description)
│   └── product_model.dart    // كلاس المنتج (id, name, category, price, quantity)
│
├── services/
│   └── hive_service.dart     // تهيئة الـ Hive وفتح الصناديق (Boxes) والبيانات التجريبية
│
├── providers/
│   ├── auth_provider.dart    // إدارة حالة تسجيل الدخول والمستخدم الحالي
│   ├── category_provider.dart// إدارة حالة الأقسام وتنفيذ CRUD مع Hive
│   └── product_provider.dart // إدارة حالة المنتجات وتنفيذ CRUD مع Hive والبحث والفلترة
│
├── screens/
│   ├── auth_screen.dart      // الشاشة 1: تسجيل الدخول وإنشاء حساب
│   ├── home_screen.dart      // الشاشة 2: لوحة المتجر والمنتجات
│   └── category_screen.dart  // الشاشة 3: إدارة الأقسام
│
└── main.dart                 // نقطة البداية، تهيئة الـ Hive و MultiProvider
```

---

## 🔄 شرح عمليات CRUD في المشروع (Hive + Provider):

### 1. عمليات الأقسام (Categories CRUD):
| العملية | الكود في `CategoryProvider` | الشرح |
| :--- | :--- | :--- |
| **GET (قراءة)** | `box.values` -> `CategoryModel.fromMap()` | قراءة كافة الأقسام المخزنة من صندوق Hive |
| **ADD (إضافة)** | `await box.put(id, newCategory.toMap())` | إنشاء قسم وتخزينه كـ Map داخل الصندوق |
| **UPDATE (تعديل)** | `await box.put(id, updatedCategory.toMap())` | تعديل بيانات القسم وتحديث الصندوق |
| **DELETE (حذف)** | `await box.delete(id)` | حذف القسم نهائياً من صندوق Hive |

### 2. عمليات المنتجات (Products CRUD):
| العملية | الكود في `ProductProvider` | الشرح |
| :--- | :--- | :--- |
| **GET (قراءة)** | `box.values` -> `ProductModel.fromMap()` | جلب جميع المنتجات المخزنة من صندوق Hive |
| **ADD (إضافة)** | `await box.put(id, newProduct.toMap())` | إضافة منتج جديد باسم وقسم وسعر وكمية |
| **UPDATE (تعديل)** | `await box.put(id, updatedProduct.toMap())` | تعديل السعر أو الكمية أو الاسم وتحديث Hive |
| **DELETE (حذف)** | `await box.delete(id)` | حذف المنتج من الـ Box بواسطة الـ ID |

---

## 👥 بيانات أعضاء الفريق (Team Members):
*(يمكنكم كتابة أسماء وأرقام جلوس الفريق هنا لتقديمها للدكتور)*:
1. `اسم الطالب الأول` - `ID`
2. `اسم الطالب الثاني` - `ID`
3. `اسم الطالب الثالث` - `ID`
4. `اسم الطالب الرابع` - `ID`
5. `اسم الطالب الخامس` - `ID`
6. `اسم الطالب السادس` - `ID`
7. `اسم الطالب السابع` - `ID`
8. `اسم الطالب الثامن` - `ID`

---

## 🚀 كيفية تشغيل المشروع (How to Run):
1. قم بفتح مجلد المشروع في الـ Terminal:
   ```bash
   cd store
   ```
2. تثبيت الحزم:
   ```bash
   flutter pub get
   ```
3. تشغيل المشروع على المحاكي أو المتصفح أو الويندوز:
   ```bash
   flutter run
   ```

---

## 💡 أسئلة شائعة متوقعة في المناقشة (Defense Q&A):
* **س: ليه خزنا البيانات كـ Map بدل ما نعمل Hive TypeAdapter مع code generator؟**
  * **ج:** لأن الـ Hive يدعم تخزين الـ Maps والأنواع الأساسية natively بدون الحاجة لـ `build_runner` أو توليد ملفات خارجية معقدة قد تفشل في التشغيل، وهذا يوضح فكرة حفظ واسترجاع البيانات بأسلوب واضح ومباشر (`toMap` و `fromMap`).
* **س: إزاي الـ UI بيحس بالتغيير لما أضيف أو أحذف منتج؟**
  * **ج:** بنستدعي `notifyListeners()` داخل الـ Provider، وفي شاشات الـ UI بنستخدم `context.watch<ProductProvider>()` أو `Consumer` فيتم إعادة بناء الـ Widgets وتحديث الشاشة تلقائياً.
* **س: إزاي ربطنا الـ Auth بالـ Screens؟**
  * **ج:** في `main.dart` وضعنا `Consumer<AuthProvider>` يفحص `auth.isAuthenticated`؛ فإذا كان مسجل دخول يعرض `HomeScreen`، وإذا لم يسجل يعرض `AuthScreen`. وعند الضغط على Logout يتغير المتغير ويتحول فوراً لشاشة الدخول.
