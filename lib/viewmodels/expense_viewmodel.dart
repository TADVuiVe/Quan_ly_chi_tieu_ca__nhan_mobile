import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Quản lý trạng thái và toàn bộ logic cốt lõi của ứng dụng (ViewModel):
// Lưu trữ & Xử lý dữ liệu (Hive): Thêm/đọc giao dịch, lọc tìm kiếm, tính toán thống kê biểu đồ và nén/giải phóng dữ liệu cũ.
// Đa ngôn ngữ & Tiền tệ: Cung cấp từ điển dịch thuật, gọi API lấy tỷ giá thị trường thực tế và tự động quy đổi ngoại tệ.
// Hệ thống & Tài khoản: Quản lý đăng nhập, Offline Mode, Dark Mode, Avatar, Thông báo bảo mật và Gói thành viên.
const Map<String, Map<String, String>> appTranslations = {
  'vi': {
    'category_title': 'Danh mục & Cài đặt', 'upgrade_account': 'Nâng cấp Tài khoản', 'current_plan': 'Gói hiện tại: ', 'system': 'Hệ thống', 'memory_management': 'Quản lý bộ nhớ', 'used': 'Đã dùng: ', 'warning_delete': 'Cảnh báo xóa', 'warning_msg': 'Thao tác này sẽ xoá TOÀN BỘ chi/thu của các ngày/tháng/năm trước.\nBạn có chắc chắn?', 'cancel': 'Hủy', 'confirm_delete': 'Chắc chắn xóa', 'delete_success': 'Đã giải phóng thành công dữ liệu cũ!', 'system_settings': 'Cài đặt hệ thống', 'dark_mode': 'Giao diện nền tối (Dark Mode)', 'notifications': 'Thông báo chi/thu (Chạy nền & Màn hình khóa)', 'link_account': 'Liên kết tài khoản', 'link_desc': 'Kết nối để bảo vệ tài khoản và đồng bộ dữ liệu', 'not_linked': 'Chưa liên kết', 'link_btn': 'Liên kết', 'security': 'Bảo mật tài khoản', 'security_center': 'Trung tâm Bảo mật', 'security_desc': 'Nâng cấp các lớp bảo vệ tài chính của bạn', '2fa': 'Bảo mật 2 lớp (2FA)', '2fa_desc': 'Xác thực qua mã OTP gửi tới SMS hoặc Email.', 'biometric': 'Bảo mật Sinh trắc học', 'biometric_desc': 'Sử dụng Vân tay hoặc Khuôn mặt để đăng nhập an toàn.', 'fido': 'Khóa Vật lý (FIDO2 / Passkey)', 'fido_desc': 'Chuẩn bảo mật cao nhất, chống lừa đảo 100%.', 'turn_on': 'Bật', 'language': 'Ngôn ngữ', 'lang_desc': 'Chọn ngôn ngữ hiển thị cho ứng dụng', 'policy': 'Điều khoản và chính sách', 'in_use': 'Đang sử dụng', 'dev_feature': 'Tính năng đang được phát triển', 'phone': 'Số điện thoại',
    'nav_home': 'Trang chủ', 'nav_stats': 'Thống kê', 'nav_category': 'Danh mục', 'nav_profile': 'Cá nhân',
    'total_balance': 'Tổng số dư tháng này', 'no_transactions': 'Chưa có giao dịch nào.\nHãy bấm + để thêm mới.', 'all': 'Tất cả', 'search_hint': 'Tìm kiếm giao dịch...', 'quick_calc': 'Máy tính nhẩm nhanh tiền dư', 'offline_mode': 'OFFLINE MODE', 'calc_amount': 'Số tiền sẽ dùng', 'item_amount': 'Tổng tiền món đồ', 'item_name_hint': 'Tên đồ cần tiêu (VD: Cơm sườn)', 'remaining_amount': 'Số tiền dư:', 'month': 'Tháng', 'year': 'Năm', 'system_notification': 'Thông báo hệ thống', 'no_noti': 'Chưa có thông báo nào.', 'recorded': 'Đã ghi nhận:\n', 'stats_title': 'Thống kê & Thị trường', 'currency_convert': 'Chuyển đổi ngoại tệ', 'amount': 'Số tiền', 'market_today': 'Thị trường hôm nay', 'gold_tael': 'Vàng (Chỉ)', 'gold_sjc': 'Vàng SJC (Cây/Lượng)', 'yearly_chart': 'Thu Chi Năm', 'total_income': 'Tổng Thu', 'total_expense': 'Tổng Chi', 'activity_this_month': 'Hoạt động tháng này', 'spent_this_month': 'Đã tiêu trong tháng:', 'earned_this_month': 'Đã thu trong tháng:', 'profile_title': 'Hồ sơ Cá nhân', 'anonymous_user': 'Người dùng Ẩn danh', 'finance_payment': 'Tài chính & Thanh toán', 'wallet_bank': 'Ví & Ngân hàng', 'logout': 'Đăng xuất', 'food': 'Ăn uống', 'work': 'Công việc', 'travel': 'Du lịch', 'leisure': 'Cá nhân', 'receive': 'Nhận', 'income_tab': 'Thu tiền', 'expense_tab': 'Tiêu tiền', 'stats_day': 'Thống kê ngày',
    'reason_expense': 'Lý do tiêu', 'reason_income': 'Lý do thu', 'amount_expense': 'Số tiền tiêu', 'amount_income': 'Số tiền thu', 'save_transaction': 'Lưu giao dịch', 'invalid_data': 'Dữ liệu không hợp lệ', 'invalid_data_msg': 'Vui lòng nhập đầy đủ lý do và số tiền hợp lệ.', 'close': 'Đóng',
    'choose_plan': 'Chọn Gói Phù Hợp', 'plan_free': 'Miễn phí', 'plan_basic': 'Gói Cơ bản', 'plan_member': 'Gói Thành viên', 'plan_vip': 'Gói VIP',
    'perk_basic_1': 'Tắt hoàn toàn quảng cáo', 'perk_basic_2': 'Đồng bộ đám mây (5GB)', 'perk_basic_3': 'Tùy chỉnh màu sắc cơ bản',
    'perk_member_1': 'Tất cả quyền lợi Cơ bản', 'perk_member_2': 'Xuất báo cáo PDF / Excel', 'perk_member_3': 'Biểu đồ phân tích nâng cao',
    'perk_vip_1': 'Tất cả quyền lợi Thành viên', 'perk_vip_2': 'Cố vấn tài chính AI cá nhân', 'perk_vip_3': 'Dung lượng lưu trữ không giới hạn', 'perk_vip_4': 'Huy hiệu VIP lấp lánh độc quyền',
    'register_now': 'Đăng ký ngay', 'confirm_payment': 'Xác nhận thanh toán', 'payment_confirm_msg': 'Bạn có đồng ý thanh toán', 'for_plan': 'cho', 'agree': 'Đồng ý', 'upgrade_success': 'Chúc mừng bạn đã nâng cấp lên',
    'payment_link_title': 'Liên kết thanh toán', 'payment_link_desc': 'Kết nối ví hoặc ngân hàng để tự động hóa dữ liệu', 'bank_account': 'Tài khoản Ngân hàng', 'momo_wallet': 'Ví MoMo', 'zalopay_wallet': 'Ví ZaloPay', 'per_month': '/ tháng',
    'offline_blocked': 'Thao tác không thể hoạt động trong offline',
  },
  'en': {
    'category_title': 'Categories & Settings', 'upgrade_account': 'Upgrade Account', 'current_plan': 'Current Plan: ', 'system': 'System', 'memory_management': 'Storage Management', 'used': 'Used: ', 'warning_delete': 'Delete Warning', 'warning_msg': 'This action will delete all transactions from PREVIOUS days/months/years.\nAre you sure?', 'cancel': 'Cancel', 'confirm_delete': 'Confirm Delete', 'delete_success': 'Old data successfully cleared!', 'system_settings': 'System Settings', 'dark_mode': 'Dark Mode', 'notifications': 'Background Notifications', 'link_account': 'Link Accounts', 'link_desc': 'Connect to protect your account and sync data', 'not_linked': 'Not linked', 'link_btn': 'Link', 'security': 'Account Security', 'security_center': 'Security Center', 'security_desc': 'Upgrade your financial protection layers', '2fa': 'Two-Factor Auth (2FA)', '2fa_desc': 'Authenticate via OTP sent to SMS or Email.', 'biometric': 'Biometric Security', 'biometric_desc': 'Use Fingerprint or FaceID to login safely.', 'fido': 'Hardware Key (FIDO2 / Passkey)', 'fido_desc': 'Highest security standard, 100% anti-phishing.', 'turn_on': 'Enable', 'language': 'Language', 'lang_desc': 'Select the display language for the app', 'policy': 'Terms and Policies', 'in_use': 'In use', 'dev_feature': 'Feature under development', 'phone': 'Phone Number',
    'nav_home': 'Home', 'nav_stats': 'Statistics', 'nav_category': 'Categories', 'nav_profile': 'Profile',
    'total_balance': 'Total Balance this month', 'no_transactions': 'No transactions yet.\nTap + to add.', 'all': 'All', 'search_hint': 'Search transactions...', 'quick_calc': 'Quick Balance Calculator', 'offline_mode': 'OFFLINE MODE', 'calc_amount': 'Amount to spend', 'item_amount': 'Total item amount', 'item_name_hint': 'Item name (e.g. Lunch)', 'remaining_amount': 'Remaining:', 'month': 'Month', 'year': 'Year', 'system_notification': 'System Notifications', 'no_noti': 'No notifications.', 'recorded': 'Recorded:\n', 'stats_title': 'Statistics & Market', 'currency_convert': 'Currency Conversion', 'amount': 'Amount', 'market_today': 'Market Today', 'gold_tael': 'Gold (Tael)', 'gold_sjc': 'SJC Gold', 'yearly_chart': 'Income/Expense Year', 'total_income': 'Total Income', 'total_expense': 'Total Expense', 'activity_this_month': 'Activity this month', 'spent_this_month': 'Spent this month:', 'earned_this_month': 'Earned this month:', 'profile_title': 'Profile', 'anonymous_user': 'Anonymous User', 'finance_payment': 'Finance & Payment', 'wallet_bank': 'Wallet & Banking', 'logout': 'Log Out', 'food': 'Food', 'work': 'Work', 'travel': 'Travel', 'leisure': 'Personal', 'receive': 'Receive', 'income_tab': 'Income', 'expense_tab': 'Expense', 'stats_day': 'Stats for',
    'reason_expense': 'Expense reason', 'reason_income': 'Income reason', 'amount_expense': 'Expense amount', 'amount_income': 'Income amount', 'save_transaction': 'Save Transaction', 'invalid_data': 'Invalid Data', 'invalid_data_msg': 'Please enter a valid reason and amount.', 'close': 'Close',
    'choose_plan': 'Choose Your Plan', 'plan_free': 'Free', 'plan_basic': 'Basic Plan', 'plan_member': 'Member Plan', 'plan_vip': 'VIP Plan',
    'perk_basic_1': 'Completely remove ads', 'perk_basic_2': 'Cloud sync (5GB)', 'perk_basic_3': 'Basic color customization',
    'perk_member_1': 'All Basic benefits', 'perk_member_2': 'Export PDF / Excel reports', 'perk_member_3': 'Advanced analytics charts',
    'perk_vip_1': 'All Member benefits', 'perk_vip_2': 'Personal AI financial advisor', 'perk_vip_3': 'Unlimited cloud storage', 'perk_vip_4': 'Exclusive sparkling VIP badge',
    'register_now': 'Register Now', 'confirm_payment': 'Confirm Payment', 'payment_confirm_msg': 'Do you agree to pay', 'for_plan': 'for', 'agree': 'Agree', 'upgrade_success': 'Congratulations! You upgraded to',
    'payment_link_title': 'Payment Linking', 'payment_link_desc': 'Connect wallet or bank for automated data', 'bank_account': 'Bank Account', 'momo_wallet': 'MoMo Wallet', 'zalopay_wallet': 'ZaloPay Wallet', 'per_month': '/ month',
    'offline_blocked': 'Action unavailable in offline mode',
  },
  'zh': {
    'category_title': '类别与设置', 'upgrade_account': '升级账户', 'current_plan': '当前计划: ', 'system': '系统', 'memory_management': '存储管理', 'used': '已用: ', 'warning_delete': '删除警告', 'warning_msg': '此操作将删除所有过往日期/月份/年份的全部收支记录。\n您确定吗？', 'cancel': '取消', 'confirm_delete': '确认删除', 'delete_success': '旧数据清理成功！', 'system_settings': '系统设置', 'dark_mode': '深色模式', 'notifications': '收支通知 (后台运行)', 'link_account': '关联账户', 'link_desc': '连接以保护账户并同步数据', 'not_linked': '未关联', 'link_btn': '关联', 'security': '账户安全', 'security_center': '安全中心', 'security_desc': '升级您的财务保护层', '2fa': '双重认证 (2FA)', '2fa_desc': '通过发送到短信或电子邮件的OTP进行身份验证。', 'biometric': '生物识别安全', 'biometric_desc': '使用指纹或面部识别安全登录。', 'fido': '硬件密钥 (FIDO2)', 'fido_desc': '最高安全标准，100%防网络钓鱼。', 'turn_on': '开启', 'language': '语言', 'lang_desc': '选择应用程序的显示语言', 'policy': '条款和政策', 'in_use': '使用中', 'dev_feature': '功能开发中', 'phone': '电话号码',
    'nav_home': '主页', 'nav_stats': '统计', 'nav_category': '类别', 'nav_profile': '个人',
    'total_balance': '本月总余额', 'no_transactions': '暂无交易。\n点击 + 添加。', 'all': '全部', 'search_hint': '搜索交易...', 'quick_calc': '快速余额计算器', 'offline_mode': '离线模式', 'calc_amount': '计划使用金额', 'item_amount': '物品总金额', 'item_name_hint': '物品名称 (例如：午餐)', 'remaining_amount': '剩余金额:', 'month': '月', 'year': '年', 'system_notification': '系统通知', 'no_noti': '暂无通知。', 'recorded': '已记录:\n', 'stats_title': '统计与市场', 'currency_convert': '货币转换', 'amount': '金额', 'market_today': '今日市场', 'gold_tael': '黄金 (钱)', 'gold_sjc': 'SJC黄金', 'yearly_chart': '收支年度', 'total_income': '总收入', 'total_expense': '总支出', 'activity_this_month': '本月活动', 'spent_this_month': '本月支出:', 'earned_this_month': '本月收入:', 'profile_title': '个人资料', 'anonymous_user': '匿名用户', 'finance_payment': '财务与支付', 'wallet_bank': '钱包与银行', 'logout': '登出', 'food': '餐饮', 'work': '工作', 'travel': '旅行', 'leisure': '个人', 'receive': '接收', 'income_tab': '收入', 'expense_tab': '支出', 'stats_day': '每日统计',
    'reason_expense': '支出原因', 'reason_income': '收入原因', 'amount_expense': '支出金额', 'amount_income': '收入金额', 'save_transaction': '保存交易', 'invalid_data': '无效数据', 'invalid_data_msg': '请输入有效的原因和金额。', 'close': '关闭',
    'choose_plan': '选择适合的计划', 'plan_free': '免费', 'plan_basic': '基础计划', 'plan_member': '会员计划', 'plan_vip': 'VIP计划',
    'perk_basic_1': '完全移除广告', 'perk_basic_2': '云同步 (5GB)', 'perk_basic_3': '基础颜色自定义',
    'perk_member_1': '所有基础权益', 'perk_member_2': '导出 PDF / Excel 报告', 'perk_member_3': '高级分析图表',
    'perk_vip_1': '所有会员权益', 'perk_vip_2': '个人AI财务顾问', 'perk_vip_3': '无限云存储', 'perk_vip_4': '独家闪耀VIP徽章',
    'register_now': '立即注册', 'confirm_payment': '确认付款', 'payment_confirm_msg': '您同意支付', 'for_plan': '购买', 'agree': '同意', 'upgrade_success': '恭喜您升级到',
    'payment_link_title': '支付关联', 'payment_link_desc': '连接钱包或银行以实现数据自动化', 'bank_account': '银行账户', 'momo_wallet': 'MoMo钱包', 'zalopay_wallet': 'ZaloPay钱包', 'per_month': '/ 月',
    'offline_blocked': '离线模式下无法操作',
  },
  'ja': {
    'category_title': 'カテゴリと設定', 'upgrade_account': 'アカウントのアップグレード', 'current_plan': '現在のプラン: ', 'system': 'システム', 'memory_management': 'ストレージ管理', 'used': '使用済み: ', 'warning_delete': '削除の警告', 'warning_msg': '過去の日付・月・年の収支データをすべて削除する。\nよろしいですか？', 'cancel': 'キャンセル', 'confirm_delete': '削除を確認', 'delete_success': 'データが正常に消去されました！', 'system_settings': 'システム設定', 'dark_mode': 'ダークモード', 'notifications': '収支通知（バックグラウンド）', 'link_account': 'アカウント連携', 'link_desc': 'アカウントを保護し、データを同期します', 'not_linked': '未連携', 'link_btn': '連携する', 'security': 'セキュリティ', 'security_center': 'セキュリティセンター', 'security_desc': '財務保護レイヤーをアップグレードする', '2fa': '2要素認証 (2FA)', '2fa_desc': 'SMSまたはメールのOTPで認証します。', 'biometric': '生体認証', 'biometric_desc': '指紋または顔認識で安全にログイン。', 'fido': 'ハードウェアキー (FIDO2)', 'fido_desc': '最高のセキュリティ基準、100％フィッシング対策。', 'turn_on': 'オン', 'language': '言語', 'lang_desc': '表示言語を選択してください', 'policy': '利用規約とポリシー', 'in_use': '使用中', 'dev_feature': '開発中の機能', 'phone': '電話番号',
    'nav_home': 'ホーム', 'nav_stats': '統計', 'nav_category': 'カテゴリ', 'nav_profile': 'プロフィール',
    'total_balance': '今月の合計残高', 'no_transactions': '取引はまだありません。\n+ をタップして追加します。', 'all': 'すべて', 'search_hint': '取引を検索...', 'quick_calc': 'クイック残高計算機', 'offline_mode': 'オフラインモード', 'calc_amount': '使用予定金額', 'item_amount': '商品の合計金額', 'item_name_hint': 'アイテム名 (例: 昼食)', 'remaining_amount': '残額:', 'month': '月', 'year': '年', 'system_notification': 'システム通知', 'no_noti': '通知はありません。', 'recorded': '記録済み:\n', 'stats_title': '統計と市場', 'currency_convert': '通貨換算', 'amount': '金額', 'market_today': '今日の市場', 'gold_tael': '金 (両)', 'gold_sjc': 'SJC金', 'yearly_chart': '収支年', 'total_income': '総収入', 'total_expense': '総支出', 'activity_this_month': '今月の活動', 'spent_this_month': '今月の支出:', 'earned_this_month': '今月の収入:', 'profile_title': 'プロフィール', 'anonymous_user': '匿名ユーザー', 'finance_payment': '財務と支払い', 'wallet_bank': 'ウォレットと銀行', 'logout': 'ログアウト', 'food': '食事', 'work': '仕事', 'travel': '旅行', 'leisure': '個人', 'receive': '受け取る', 'income_tab': '収入', 'expense_tab': '支出', 'stats_day': 'の統計',
    'reason_expense': '支出の理由', 'reason_income': '収入の理由', 'amount_expense': '支出額', 'amount_income': '収入額', 'save_transaction': '取引を保存', 'invalid_data': '無効なデータ', 'invalid_data_msg': '有効な理由と金額を入力してください。', 'close': '閉じる',
    'choose_plan': 'プランを選択', 'plan_free': '無料', 'plan_basic': 'ベーシックプラン', 'plan_member': 'メンバープラン', 'plan_vip': 'VIPプラン',
    'perk_basic_1': '広告を完全に削除', 'perk_basic_2': 'クラウド同期 (5GB)', 'perk_basic_3': '基本カラーのカスタマイズ',
    'perk_member_1': 'すべてのベーシック特典', 'perk_member_2': 'PDF / Excelレポートのエクスポート', 'perk_member_3': '高度な分析チャート',
    'perk_vip_1': 'すべてのメンバー特典', 'perk_vip_2': 'パーソナルAI財務アドバイザー', 'perk_vip_3': '無制限のクラウドストレージ', 'perk_vip_4': '限定の輝くVIPバッジ',
    'register_now': '今すぐ登録', 'confirm_payment': '支払いの確認', 'payment_confirm_msg': '支払いに同意しますか', 'for_plan': 'プラン:', 'agree': '同意する', 'upgrade_success': 'おめでとうございます！アップグレードしました:',
    'payment_link_title': '支払いリンク', 'payment_link_desc': 'ウォレットや銀行を接続してデータを自動化', 'bank_account': '銀行口座', 'momo_wallet': 'MoMoウォレット', 'zalopay_wallet': 'ZaloPayウォレット', 'per_month': '/ 月',
    'offline_blocked': 'オフラインモードでは操作できません',
  }
};

class ExpenseViewModel extends ChangeNotifier {
  List<Expense> _registeredExpenses = [];
  final _myBox = Hive.box('expense_box');

  // HỆ THỐNG ĐA NGÔN NGỮ VÀ QUY ĐỔI TIỀN TỆ
  String _currentLanguage = 'vi';
  String get currentLanguage => _currentLanguage;

  void changeLanguage(String langCode) {
    _currentLanguage = langCode;
    _myBox.put('app_lang', langCode);
    notifyListeners();
  }

  String getText(String key) {
    return appTranslations[_currentLanguage]?[key] ?? key;
  }

  String formatDynamicCurrency(double vndAmount) {
    String targetCurrency = 'VND';
    String pattern = '#,##0 ';
    int decimals = 0;
    String locale = 'vi_VN';

      switch (_currentLanguage) {
        case 'en': targetCurrency = 'USD'; pattern = '\$#,##0.00'; decimals = 2; locale = 'en_US'; break;
        case 'zh': targetCurrency = 'CNY'; pattern = '¥#,##0.00'; decimals = 2; locale = 'zh_CN'; break;
        case 'ja': targetCurrency = 'JPY'; pattern = '¥#,##0'; decimals = 0; locale = 'ja_JP'; break;
      }

    double convertedAmount = vndAmount;
    if (targetCurrency != 'VND' && _exchangeRates.containsKey('VND') && _exchangeRates.containsKey(targetCurrency)) {
      double rateVnd = _exchangeRates['VND']!;
      double rateTarget = _exchangeRates[targetCurrency]!;
      convertedAmount = (vndAmount / rateVnd) * rateTarget;
    }

    return NumberFormat.currency(locale: locale, customPattern: pattern, decimalDigits: decimals).format(convertedAmount).trim();
  }

  // HỆ THỐNG THÔNG BÁO BẢO MẬT & CHẤM ĐỎ
  List<String> _notifications = [];
  int _unreadNotiCount = 0;

  List<String> get notifications => _notifications;
  int get unreadNotiCount => _unreadNotiCount;

  void addNotification(String message) {
    if (_isOfflineMode) return;
    _notifications.insert(0, message); 
    _unreadNotiCount++; 
    _saveNotifications();
    notifyListeners();
  }

  void markNotificationsAsRead() {
    _unreadNotiCount = 0; 
    _saveNotifications();
    notifyListeners();
  }

  void _saveNotifications() {
    _myBox.put('saved_notifications', _notifications);
    _myBox.put('unread_noti_count', _unreadNotiCount);
  }

  // XỬ LÝ ĐĂNG NHẬP, ĐĂNG KÝ & OFFLINE MODE
  bool _isOfflineMode = false;
  String _currentUser = '';

  bool get isOfflineMode => _isOfflineMode;
  String get currentUser => _currentUser;

  void setOfflineMode(bool value) {
    _isOfflineMode = value;
    if (value) {
      _currentUser = 'Khách (Offline)';
      _currentPlan = 'Chưa đăng ký'; 
    }
    notifyListeners();
  }

  Future<bool> registerAccount(String username, String password) async {
    final existingUser = _myBox.get('user_$username');
    if (existingUser != null) return false; 
    
    await _myBox.put('user_$username', password);
    return true; 
  }

  bool login(String username, String password) {
    final savedPassword = _myBox.get('user_$username');
    if (savedPassword != null && savedPassword == password) {
      _currentUser = username;
      _isOfflineMode = false; 
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = '';
    _isOfflineMode = false;
    notifyListeners();
  }

  // DỮ LIỆU THỊ TRƯỜNG & TỶ GIÁ
  bool _isLoadingMarket = false;
  Map<String, double> _exchangeRates = {'USD': 1.0, 'VND': 25000, 'EUR': 0.9, 'JPY': 150, 'CNY': 7.2};
  
  double _btcPrice = 0;
  double _goldPricePerTael = 0; 
  
  int _btcStatus = 0;  
  int _goldStatus = 0; 
  int _selectedYear = DateTime.now().year;

  bool get isLoadingMarket => _isLoadingMarket;
  Map<String, double> get exchangeRates => _exchangeRates;
  
  double get btcPrice => _isOfflineMode ? 0 : _btcPrice;
  double get goldPricePerTael => _isOfflineMode ? 0 : _goldPricePerTael;
  int get btcStatus => _isOfflineMode ? 0 : _btcStatus;
  int get goldStatus => _isOfflineMode ? 0 : _goldStatus;
  int get selectedYear => _selectedYear;

  // --- LOGIC LỌC TÌM KIẾM TRANG CHỦ ---
  String _searchQuery = '';
  Category? _selectedTabCategory;
  Category? get selectedTabCategory => _selectedTabCategory;

  void selectTabCategory(Category? category) {
    _selectedTabCategory = category;
    notifyListeners();
  }

  void runFilter(String query) {
    _searchQuery = query;
    notifyListeners(); 
  }

  List<Expense> get expenses {
    if (_isOfflineMode) return [];
    return _registeredExpenses.where((expense) {
      if (_selectedTabCategory != null && expense.category != _selectedTabCategory) return false;
      if (_searchQuery.isNotEmpty) return expense.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return true;
    }).toList();
  }

  double get totalBalance {
    if (_isOfflineMode) return 0;
    final now = DateTime.now();
    double sum = 0;
    for (final exp in _registeredExpenses) {
      if (exp.date.year == now.year && exp.date.month == now.month) {
        sum += (exp.type == TransactionType.income) ? exp.amount : -exp.amount;
      }
    }
    return sum;
  }

  void changeYear(int delta) {
    _selectedYear += delta;
    notifyListeners();
  }

  List<Map<String, double>> get yearlyChartData {
    if (_isOfflineMode) return List.generate(12, (_) => {'income': 0.0, 'expense': 0.0});
    List<Map<String, double>> data = List.generate(12, (_) => {'income': 0.0, 'expense': 0.0});
    for (var exp in _registeredExpenses) {
      if (exp.date.year == _selectedYear) {
        int monthIndex = exp.date.month - 1;
        if (exp.type == TransactionType.income) {
          data[monthIndex]['income'] = (data[monthIndex]['income'] ?? 0) + exp.amount;
        } else {
          data[monthIndex]['expense'] = (data[monthIndex]['expense'] ?? 0) + exp.amount;
        }
      }
    }
    return data;
  }

  double get yearlyTotalIncome => _isOfflineMode ? 0 : yearlyChartData.fold(0, (sum, item) => sum + (item['income'] ?? 0));
  double get yearlyTotalExpense => _isOfflineMode ? 0 : yearlyChartData.fold(0, (sum, item) => sum + (item['expense'] ?? 0));

  double get currentMonthIncome {
    if (_isOfflineMode) return 0;
    final now = DateTime.now();
    return _registeredExpenses.where((e) => e.date.year == now.year && e.date.month == now.month && e.type == TransactionType.income)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
  
  double get currentMonthExpense {
    if (_isOfflineMode) return 0;
    final now = DateTime.now();
    return _registeredExpenses.where((e) => e.date.year == now.year && e.date.month == now.month && e.type == TransactionType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void loadExpenses() {
    final String? expensesJson = _myBox.get('my_expenses');
    if (expensesJson != null) {
      final List<dynamic> decodedData = jsonDecode(expensesJson);
      _registeredExpenses = decodedData.map((item) => Expense.fromJson(item)).toList();
    }

    _isDarkMode = _myBox.get('is_dark_mode', defaultValue: false);
    _isNotificationEnabled = _myBox.get('is_noti_enabled', defaultValue: true);
    _currentPlan = _myBox.get('current_plan', defaultValue: 'Miễn phí');
    _avatarPath = _myBox.get('avatar_path', defaultValue: '');
    
    _notifications = _myBox.get('saved_notifications', defaultValue: <String>[]);
    _unreadNotiCount = _myBox.get('unread_noti_count', defaultValue: 0);

    // Load saved language
    _currentLanguage = _myBox.get('app_lang', defaultValue: 'vi');

    fetchMarketData(); 
    notifyListeners(); 
  }

  Future<void> fetchMarketData() async {
    _isLoadingMarket = true;
    notifyListeners(); 
    try {
      final resRates = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (resRates.statusCode == 200) {
        final data = jsonDecode(resRates.body);
        _exchangeRates = (data['rates'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toDouble()));
      }
      final resBtc = await http.get(Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT'));
      if (resBtc.statusCode == 200) {
        final data = jsonDecode(resBtc.body);
        _btcPrice = double.parse(data['price']); 
      } else {
        _btcPrice = 64500.0; 
      }
    } catch (e) {
      _btcPrice = 64500.0; 
    }
    _goldPricePerTael = 83000000 + Random().nextDouble() * 4000000;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = _myBox.get('market_date');
    double prevBtc = _myBox.get('prev_btc', defaultValue: _btcPrice);
    double prevGold = _myBox.get('prev_gold', defaultValue: _goldPricePerTael);
    if (savedDate != todayStr) {
      _myBox.put('market_date', todayStr);
      _myBox.put('prev_btc', _btcPrice);
      _myBox.put('prev_gold', _goldPricePerTael);
    }
    _btcStatus = _btcPrice > prevBtc ? 1 : (_btcPrice < prevBtc ? -1 : 0);
    _goldStatus = _goldPricePerTael > prevGold ? 1 : (_goldPricePerTael < prevGold ? -1 : 0);
    _isLoadingMarket = false;
    notifyListeners(); 
  }

  void _saveExpenses() {
    final String encodedData = jsonEncode(_registeredExpenses.map((e) => e.toJson()).toList());
    _myBox.put('my_expenses', encodedData);
  }

  void addExpense(Expense expense) {
    if (_isOfflineMode) return; 
    _registeredExpenses.add(expense);
    _saveExpenses();
    notifyListeners(); 
  }

  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get isNotificationEnabled => _isNotificationEnabled;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    _myBox.put('is_dark_mode', value); 
    notifyListeners();
  }

  void toggleNotification(bool value) {
    _isNotificationEnabled = value;
    _myBox.put('is_noti_enabled', value); 
    notifyListeners();
  }

  String get storageSize {
    if (_registeredExpenses.isEmpty) return "0.12 MB"; 
    double size = 0.12 + (_registeredExpenses.length * 0.05);
    return "${size.toStringAsFixed(2)} MB";
  }

  void clearOldData() {
    final now = DateTime.now();
    final keepList = _registeredExpenses.where((expense) => 
      expense.date.year == now.year && expense.date.month == now.month
    ).toList();
    final oldList = _registeredExpenses.where((expense) => 
      !(expense.date.year == now.year && expense.date.month == now.month)
    ).toList();
    Map<String, Map<TransactionType, double>> monthlySummary = {};
    for (var exp in oldList) {
      String key = '${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}';
      if (!monthlySummary.containsKey(key)) {
        monthlySummary[key] = {TransactionType.income: 0.0, TransactionType.expense: 0.0};
      }
      monthlySummary[key]![exp.type] = monthlySummary[key]![exp.type]! + exp.amount;
    }
    monthlySummary.forEach((key, types) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDayOfMonth = DateTime(year, month + 1, 0); 
      
      if (types[TransactionType.income]! > 0) {
        keepList.add(Expense(
          title: 'Tổng thu Tháng $month/$year', 
          amount: types[TransactionType.income]!,
          date: lastDayOfMonth,
          category: Category.receive,
          type: TransactionType.income,
        ));
      }
      if (types[TransactionType.expense]! > 0) {
        keepList.add(Expense(
          title: 'Tổng chi Tháng $month/$year', 
          amount: types[TransactionType.expense]!,
          date: lastDayOfMonth,
          category: Category.work, 
          type: TransactionType.expense,
        ));
      }
    });
    _registeredExpenses = keepList;
    
    _notifications.clear();
    _unreadNotiCount = 0;
    _saveNotifications();
    
    _saveExpenses(); 
    notifyListeners(); 
  }

  String _currentPlan = 'Miễn phí';
  String get currentPlan => _currentPlan;

  void updatePlan(String planName) {
    _currentPlan = planName;
    _myBox.put('current_plan', planName); 
    notifyListeners();
  }

  String _avatarPath = '';
  String get avatarPath => _isOfflineMode ? '' : _avatarPath;

  Future<void> pickAvatar() async {
    if (_isOfflineMode) return; 
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _avatarPath = pickedFile.path;
      _myBox.put('avatar_path', _avatarPath); 
      notifyListeners();
    }
  }
  
  // HÀM CHUYỂN NGOẠI TỆ NGƯỜI DÙNG NHẬP VỀ LẠI VND ĐỂ LƯU VÀO CSDL
  double convertToBaseCurrency(double inputAmount) {
    if (_currentLanguage == 'vi' || isOfflineMode) return inputAmount;

    String targetCurrency = 'VND';
    if (_currentLanguage == 'en') targetCurrency = 'USD';
    else if (_currentLanguage == 'zh') targetCurrency = 'CNY';
    else if (_currentLanguage == 'ja') targetCurrency = 'JPY';

    if (_exchangeRates.containsKey('VND') && _exchangeRates.containsKey(targetCurrency)) {
      double rateVnd = _exchangeRates['VND']!;
      double rateTarget = _exchangeRates[targetCurrency]!;
      
      return (inputAmount / rateTarget) * rateVnd; 
    }
    return inputAmount;
  }
}