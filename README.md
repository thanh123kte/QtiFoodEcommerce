# QtiFoodEcommerce (Flutter)

Ứng dụng thương mại điện tử đặt đồ ăn, xây dựng bằng Flutter theo kiến trúc Clean Architecture. Dự án hỗ trợ cả vai trò Khách hàng và Người bán, tích hợp thanh toán đơn hàng, giỏ hàng, tìm kiếm (bao gồm tìm kiếm bằng hình ảnh), chat realtime và thông báo đẩy.

> Hình ảnh demo sẽ được bổ sung sau (placeholder).

## Tính năng chính

- Khách hàng:
  - Đăng ký/Đăng nhập (Email/Password, Google) và Quên mật khẩu.
  - Trang chủ với banner, danh mục, sản phẩm nổi bật, cửa hàng gần bạn.
  - Tìm kiếm sản phẩm theo từ khóa và Lịch sử tìm kiếm (1 dòng/mục).
  - Tìm kiếm bằng hình ảnh: chụp/chọn ảnh, mã hóa Base64, gọi API `/api/products/search-by-image`, hiển thị kết quả theo danh sách ID sản phẩm tương tự.
  - Chi tiết sản phẩm, thêm vào giỏ hàng, cập nhật số lượng, xóa.
  - Thanh toán: tạo đơn hàng, áp dụng voucher, tính phí vận chuyển, theo dõi trạng thái đơn realtime.
  - Yêu thích cửa hàng (wishlist).
  - Ví: xem số dư, lịch sử giao dịch, nạp/rút ví.
  - Chat với người bán và Chatbot AI.
  - Thông báo đẩy (FCM): đơn hàng, chat, hệ thống.

- Người bán:
  - Quản lý sản phẩm: tạo/sửa/xóa, tải ảnh sản phẩm.
  - Quản lý đơn hàng: xem danh sách, chi tiết, cập nhật trạng thái, thống kê doanh thu/sản phẩm.
  - Quản lý voucher cửa hàng.
  - Quản lý đánh giá cửa hàng và phản hồi.

## Kiến trúc & Mô-đun

- Clean Architecture:
  - `presentation/`: UI + ViewModel (Provider).
  - `domain/`: Entities, Repositories (abstraction), Use cases.
  - `data/`: Remote datasources (Dio), Local datasources (Hive/SharedPreferences), Repository implementations.
- DI (GetIt): cấu hình tại `lib/di/injector.dart` qua `initDependencies(...)`.
- Điều hướng: Router trung tâm trong `lib/router/`.
- Lưu trữ cục bộ: Hive, SharedPreferences.
- Thông báo: Firebase Cloud Messaging + Flutter Local Notifications.

## Công nghệ sử dụng

- Flutter, Dart
- State management: Provider
- DI: GetIt
- HTTP client: Dio
- Local storage: Hive, SharedPreferences
- Firebase: Auth, Messaging (FCM), Realtime Database
- Local notifications: flutter_local_notifications
- Vị trí/Gợi ý địa điểm: HERE Autosuggest API
- Realtime chat: WebSocket service (`ChatSocketService`)

## Backend & API

- `baseUrl`: truyền vào `initDependencies(baseUrl: ...)` khi khởi tạo ứng dụng.
- Tìm kiếm bằng hình ảnh (proxy Spring Boot):
  - `POST /api/products/search-by-image`
  - Body: `{ "base64_image_string": "<chuỗi base64>" }`
  - Response: danh sách `productDocId` để lọc/hiển thị sản phẩm tương tự.

Xem thêm sơ đồ luồng tại `docs/app_features_and_flow.md` và chi tiết thông báo đẩy tại `docs/notifications.md`.

## Thiết lập môi trường

Yêu cầu tối thiểu:

- Flutter SDK (channel stable)
- Android SDK / Xcode (tùy nền tảng build)
- Dart (đi kèm Flutter)

Cấu hình biến môi trường (.env):

```
HERE_API_KEY=<your_here_api_key>
```

File `.env` cần được load sớm (thư viện `flutter_dotenv`). Trong `initDependencies(...)`, nếu không truyền `hereApiKey`, hệ thống sẽ đọc từ `HERE_API_KEY`.

Firebase:

- Android: đặt `android/app/google-services.json` (đã có trong repo mẫu).
- iOS: thêm `GoogleService-Info.plist` và cấu hình theo tài liệu Firebase.

## Cấu trúc thư mục (rút gọn)

```
lib/
  data/           # datasources (remote/local), models, repositories_impl
  domain/         # entities, repositories (abstract), usecases
  presentation/   # màn hình, widget, viewmodel
  router/         # điều hướng
  di/             # injector (GetIt)
  services/       # chat socket, location, notifications
  utils/          # helpers: formatter, result, image resolver...
docs/             # tài liệu bổ sung
android/ ios/ ... # cấu hình nền tảng
```

## Khởi chạy dự án

1) Cài dependencies:

```bash
flutter pub get
```

2) Cấu hình DI (ví dụ khởi tạo trong `main.dart`):

```dart
await initDependencies(
  baseUrl: 'https://your.api.server',
  // hereApiKey: '...optional nếu không dùng .env',
  // hereApiBaseUrl: 'https://autosuggest.search.hereapi.com',
  // hereLanguage: 'vi',
);
```

3) Chạy ứng dụng:

```bash
flutter run
```

## Build APK (Android)

```bash
flutter build apk --release
```

APK tạo tại `build/app/outputs/apk/release/app-release.apk`.

## Thông báo đẩy (FCM)

- App đăng ký nhận FCM token và lưu về backend.
- Hỗ trợ phân loại tin: ví dụ `type = "CHAT"` để điều hướng/badge chat.
- Thông báo foreground/background hiển thị qua `flutter_local_notifications`.

Chi tiết luồng và payload: xem `docs/notifications.md`.

## Tài liệu bổ sung

- `docs/app_features_and_flow.md`: Tổng quan tính năng, luồng FE→BE→DB.
- `docs/notifications.md`: Cấu trúc và luồng thông báo đẩy.

## Ghi chú

- Vui lòng đảm bảo `HERE_API_KEY` hợp lệ để phần gợi ý địa điểm hoạt động.

## Bản quyền

Mã nguồn thuộc dự án QtiFoodEcommerce. Vui lòng liên hệ chủ kho để biết thêm chi tiết về quyền sử dụng.

## Demo


https://github.com/user-attachments/assets/c48c465f-ae58-4f5f-845d-e9909263e4d8


