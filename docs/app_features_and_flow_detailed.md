# Tài liệu chức năng & luồng dữ liệu (FE -> BE -> DB)

> Phạm vi: tổng hợp từ mã nguồn FE Flutter trong `lib/`, cấu hình `kServerBaseUrl`, và các data source/endpoint được gọi bởi app. Backend/DB không nằm trong repo nên phần DB là suy luận dựa trên entity + endpoint hiện có.

## 1. Kiến trúc tổng quan

- **FE (Flutter)**: Presentation (screens + view models) -> Domain (usecases + entities) -> Data (repositories + datasources).
- **DI**: GetIt khởi tạo toàn bộ service, usecase, repository tại `lib/di/injector.dart`.
- **Networking**: `Dio` dùng `kServerBaseUrl` trong `lib/config/server_config.dart`.
- **Local cache**: Hive boxes cho user, address, store, category, product, cart, wishlist, voucher, search history.
- **Session**: SharedPreferences qua `SessionLocal` (remember me, last user, last role, last FCM token).
- **Realtime**: Chat dùng WebSocket STOMP; theo dõi đơn hàng dùng Firebase Realtime Database (RTDB).
- **Notifications**: Firebase Cloud Messaging (FCM) + Local notifications.
- **Bên thứ ba**:
  - HERE API autosuggest cho gợi ý địa chỉ.
  - OpenStreetMap tiles + OSRM routing cho bản đồ theo dõi đơn.
  - SePay QR (fallback) cho top-up ví.

## 2. Chức năng theo vai trò

### 2.1. Khách hàng (Customer)
- Đăng ký/đăng nhập (email, Google), quên mật khẩu.
- Dashboard: banner, danh mục, sản phẩm nổi bật, cửa hàng gần đó.
- Tìm kiếm sản phẩm: từ khóa + hình ảnh; lưu lịch sử tìm kiếm.
- Xem chi tiết cửa hàng/sản phẩm; đánh giá cửa hàng.
- Giỏ hàng: thêm/sửa/xóa.
- Checkout: chọn địa chỉ, tính phí ship, chọn voucher, tạo đơn.
- Đơn hàng: danh sách, chi tiết, hủy, theo dõi realtime.
- Chat với người bán.
- Ví: số dư, nạp tiền, lịch sử, rút tiền.
- Hồ sơ cá nhân + quản lý địa chỉ.
- Wishlist cửa hàng.

### 2.2. Người bán (Seller)
- Đăng ký cửa hàng, cập nhật thông tin + ảnh.
- Quản lý danh mục cửa hàng.
- Quản lý sản phẩm + ảnh sản phẩm.
- Quản lý voucher.
- Quản lý đơn hàng: cập nhật trạng thái, gán tài xế.
- Thống kê: doanh thu, top sản phẩm.
- Ví người bán.
- Chat với khách hàng.

### 2.3. Hệ thống/Chung
- Push notifications (đơn hàng, chat, ví).
- Đăng ký device token theo user.
- Theo dõi vị trí giao hàng realtime (Firebase RTDB).

## 3. Luồng tổng quát (pattern FE -> BE -> DB)

1. **FE**: UI -> ViewModel -> Usecase -> Repository.
2. **FE**: Repository đọc cache (Hive) nếu có, sau đó gọi Remote (Dio) khi cần refresh.
3. **BE**: Nhận request `/api/...`, xử lý nghiệp vụ.
4. **DB**: Lưu/đọc dữ liệu (bảng suy luận: users, stores, products, orders, ...).
5. **FE**: Parse JSON -> Entity -> hiển thị; đồng bộ lại cache local.

## 4. Luồng chi tiết theo chức năng (FE -> BE -> DB)

### 4.1. Đăng ký bằng email
1. **FE**: `RegisterViewModel` gọi `SignUpEmail`.
2. **FE**: `AuthRemote.signUpEmail` dùng **FirebaseAuth** tạo user -> nhận `uid`.
3. **FE**: `UserRepositoryImpl.createUserProfile` gọi **BE** `POST /api/users` (kèm `uid`, email, fullname, password...).
4. **BE**: Validate -> tạo user trong **DB `users`**.
5. **FE**: Lưu cache user vào Hive `user_profiles`. Nếu BE lỗi, FE xóa Firebase user vừa tạo.

### 4.2. Đăng nhập bằng email
1. **FE**: `LoginViewModel.login` -> `SignInEmail`.
2. **FE**: `AuthRemote.signInEmail` (FirebaseAuth) -> lấy `uid`.
3. **FE**: `UserRemote.getUserById` gọi **BE** `GET /api/users/{uid}`.
4. **BE/DB**: Đọc **DB `users`** -> trả profile.
5. **FE**: Lưu cache user (Hive), lưu session (SharedPreferences), đăng ký FCM token:
   - `POST /api/device-tokens` (header `X-User-ID`).
6. **BE/DB**: Lưu token vào **DB `device_tokens`**.

### 4.3. Đăng nhập bằng Google
1. **FE**: `SignInGoogle` gọi Google Sign-In -> FirebaseAuth.
2. **FE**: `GET /api/users/{uid}` để lấy profile.
3. **BE/DB**: Nếu chưa có user -> FE tạo mới bằng `POST /api/users` với role `CUSTOMER`.
4. **FE**: Lưu session + cache; đăng ký device token như 4.2.

### 4.4. Quên mật khẩu
1. **FE**: `SendPasswordReset` gọi FirebaseAuth gửi email reset.
2. **BE/DB**: Không tham gia (reset qua Firebase).

### 4.5. Hồ sơ người dùng + avatar
1. **FE**: `ProfileRepositoryImpl` đọc cache Hive, nếu thiếu gọi **BE** `GET /api/users/{id}`.
2. **BE/DB**: Đọc **DB `users`**.
3. **FE**: Cập nhật hồ sơ -> `PUT /api/users/{id}`.
4. **BE/DB**: Update **DB `users`**.
5. **FE**: Upload avatar -> `POST /api/users/{id}/avatar` (multipart).
6. **BE/DB**: Lưu file + lưu URL trong **DB `users.avatar_url`**.
7. **FE**: Resolve URL ảnh qua `resolveImageUrl/resolveServerAssetUrl`.

### 4.6. Quản lý địa chỉ giao hàng + gợi ý địa chỉ
1. **FE**: `AddressRemote.getAddressesByUser` -> `GET /api/addresses/user/{userId}`.
2. **BE/DB**: Đọc **DB `addresses`**.
3. **FE**: Tạo/sửa/xóa -> `POST /api/addresses`, `PUT /api/addresses/{id}`, `DELETE /api/addresses/{id}`.
4. **DB**: Insert/Update/Delete **`addresses`**.
5. **FE**: Gợi ý địa chỉ dùng HERE API trực tiếp:
   - `PlaceSuggestionRemote` gọi `https://autosuggest.search.hereapi.com/v1/autosuggest`
   - FE lấy vị trí từ `GeolocatorLocationProvider`.
6. **BE/DB**: Không tham gia luồng gợi ý.

### 4.7. Banner & danh mục
1. **FE**: Dashboard gọi `GET /api/banners/status/ACTIVE`.
2. **BE/DB**: Đọc **DB `banners`** -> trả danh sách.
3. **FE**: Danh mục cha gọi `GET /api/categories`.
4. **BE/DB**: Đọc **DB `categories`**.

### 4.8. Cửa hàng (store) & đăng ký seller
1. **FE**: Seller đăng ký -> `POST /api/stores` với `CreateStoreInput`.
2. **BE/DB**: Lưu **DB `stores`** (trạng thái có thể `PENDING`).
3. **FE**: Lấy store theo owner -> `GET /api/stores/owner/{ownerId}`.
4. **BE/DB**: Đọc **DB `stores`**.
5. **FE**: Cập nhật store -> `PUT /api/stores/{id}`.
6. **BE/DB**: Update **DB `stores`**.
7. **FE**: Upload ảnh store -> `POST /api/stores/{id}/image` (multipart).
8. **BE/DB**: Lưu ảnh + URL vào **DB `stores.image_url`** (hoặc bảng media).
9. **FE**: Tăng lượt xem -> `POST /api/stores/{id}/view`.
10. **BE/DB**: Update **DB `stores.view_count`** (suy luận).
11. **FE**: Cửa hàng gần đây -> `GET /api/stores/nearby?lat=...&lng=...`.
12. **BE/DB**: Query theo khoảng cách, trả danh sách **`stores`**.

### 4.9. Danh mục của cửa hàng (store categories)
1. **FE**: `GET /api/store-categories/store/{storeId}`.
2. **BE/DB**: Đọc **DB `store_categories`**.
3. **FE**: CRUD -> `POST /api/store-categories`, `PUT /api/store-categories/{id}`, `DELETE /api/store-categories/{id}`.
4. **DB**: Insert/Update/Delete **`store_categories`**.

### 4.10. Sản phẩm & ảnh sản phẩm
1. **FE**: Lấy sản phẩm nổi bật -> `GET /api/products?page=&limit=`.
2. **FE**: Lấy sản phẩm theo store -> `GET /api/products/store/{storeId}`.
3. **BE/DB**: Query **DB `products`** (+ join `product_images` nếu có).
4. **FE**: Tạo/sửa/xóa sản phẩm -> `POST /api/products`, `PUT /api/products/{id}`, `DELETE /api/products/{id}`.
5. **BE/DB**: Insert/Update/Delete **`products`**.
6. **FE**: Upload ảnh sản phẩm -> `POST /api/product-images/upload/{productId}` (multipart).
7. **BE/DB**: Lưu file + record **`product_images`** (có `is_primary`).
8. **FE**: Khi lấy cart, app có thể gọi `GET /api/product-images/product/{productId}` để bổ sung ảnh.

### 4.11. Tìm kiếm sản phẩm (từ khóa)
1. **FE**: `GET /api/products/search?q=keyword`.
2. **BE**: Parse keyword -> query **DB `products`** (+ text search).
3. **FE**: Hiển thị kết quả + lưu lịch sử tìm kiếm (4.12).

### 4.12. Tìm kiếm bằng hình ảnh
1. **FE**: `POST /api/products/search-by-image` với `base64_image_string`.
2. **BE**: Xử lý ảnh (có thể gọi AI service) -> tìm danh sách sản phẩm phù hợp.
3. **DB**: Query **`products`** và **`product_images`** để trả chi tiết.
4. **FE**: Hiển thị kết quả.

### 4.13. Lịch sử tìm kiếm
1. **FE**: `GET /api/search-history/user/{userId}/top-keywords?limit=...`.
2. **BE/DB**: Đọc **DB `search_history`** (suy luận).
3. **FE**: `POST /api/search-history/user/{userId}` khi user tìm kiếm.
4. **DB**: Insert **`search_history`**.

### 4.14. Wishlist cửa hàng
1. **FE**: Thêm -> `POST /api/wishlist/{customerId}` (body: storeId).
2. **FE**: Xóa -> `DELETE /api/wishlist/{customerId}/store/{storeId}`.
3. **FE**: Kiểm tra -> `GET /api/wishlist/{customerId}/check/{storeId}`.
4. **BE/DB**: CRUD **DB `wishlist`**.

### 4.15. Giỏ hàng
1. **FE**: Lấy giỏ -> `GET /api/cart/{customerId}`.
2. **BE/DB**: Đọc **DB `cart_items`** (hoặc bảng cart).
3. **FE**: Thêm -> `POST /api/cart/{customerId}` (productId, quantity).
4. **FE**: Cập nhật -> `PUT /api/cart/{customerId}/items/{cartItemId}`.
5. **FE**: Xóa -> `DELETE /api/cart/{customerId}/items/{cartItemId}`.
6. **DB**: Insert/Update/Delete **`cart_items`**.
7. **FE**: Cache Hive `cart_items`; khi lỗi mạng dùng cache.

### 4.16. Checkout + tính phí ship + voucher
1. **FE**: Tính phí ship -> `POST /api/shipping/calculate-fee` (tọa độ cửa hàng + người nhận).
2. **BE**: Tính phí -> trả `shipping_fee` (DB có thể không lưu).
3. **FE**: Lấy voucher:
   - Store voucher: `GET /api/vouchers/seller/{storeId}`
   - Admin voucher: `GET /api/vouchers?isCreatedByAdmin=true`
4. **DB**: Đọc **`vouchers`**.
5. **FE**: Khi apply voucher -> `POST /api/vouchers/{id}/increment-usage` (ghi nhận sử dụng).
6. **DB**: Update **`vouchers.usage_count`** hoặc bảng usage (suy luận).

### 4.17. Tạo đơn hàng (order)
1. **FE**: `POST /api/orders` với thông tin: customer, store, address, payment, shipping fee...
2. **BE**: Validate tồn kho + tính tổng -> tạo **DB `orders`**.
3. **FE**: Tạo line items:
   - `POST /api/order-items` (từng item) hoặc
   - `POST /api/order-items/bulk` (danh sách).
4. **DB**: Insert **`order_items`**.
5. **BE**: Gửi FCM cho seller (new order).
6. **FE**: Hiển thị trạng thái order.

### 4.18. Danh sách/chi tiết đơn hàng
1. **FE**: Customer -> `GET /api/orders/customer/{customerId}`.
2. **FE**: Seller -> `GET /api/orders/store/{storeId}`.
3. **BE/DB**: Query **`orders`**.
4. **FE**: Chi tiết -> `GET /api/orders/{orderId}` + `GET /api/order-items/order/{orderId}`.
5. **DB**: Join **`orders`** + **`order_items`**.

### 4.19. Cập nhật trạng thái đơn hàng (Seller)
1. **FE**: `PATCH /api/orders/{orderId}/status?status=...`
   - Trạng thái: `PENDING | CONFIRMED | PREPARING | PREPARED | SHIPPING | DELIVERED | CANCELLED`.
2. **BE/DB**: Update **`orders.status`**.
3. **BE**: Gửi FCM cho customer về trạng thái mới.
4. **FE**: Mở màn hình chi tiết theo notification.

### 4.20. Gán tài xế + theo dõi đơn hàng realtime
1. **FE (Seller)**: `POST /api/orders/{orderId}/assign-driver`.
2. **BE**: Gán driver -> cập nhật **DB `orders.driver_id`** (suy luận).
3. **BE/Driver service**: Đẩy tracking vào **Firebase RTDB**:
   - Path: `order_tracking/{orderId}`.
4. **FE (Customer)**: `OrderTrackingRemote` subscribe RTDB -> nhận driver location + trạng thái.
5. **FE**: Vẽ bản đồ bằng OpenStreetMap; gọi OSRM route để vẽ đường đi.

### 4.21. Đánh giá cửa hàng
1. **FE**: Tạo review -> `POST /api/store-reviews` (rating, comment, orderId...).
2. **BE/DB**: Insert **`store_reviews`**.
3. **FE**: Upload ảnh review -> `POST /api/store-reviews/{id}/images` (multipart).
4. **DB**: Lưu **`store_review_images`** (suy luận).
5. **FE**: Lấy reviews -> `GET /api/store-reviews/store/{storeId}`.
6. **DB**: Query **`store_reviews`**.

### 4.22. Chat & Messenger
1. **FE**: Danh sách hội thoại -> `GET /api/conversations?userId=...`.
2. **BE/DB**: Query **`conversations`** theo user.
3. **FE**: Lấy/tạo hội thoại -> `POST /api/conversations/get-or-create?customerId=&sellerId=`.
4. **BE/DB**: Insert/return **`conversations`**.
5. **FE**: Lấy messages -> `GET /api/chat/conversations/{conversationId}/messages`.
6. **BE/DB**: Query **`messages`**.
7. **FE**: Gửi tin nhắn:
   - REST: `POST /api/chat/messages?senderId=...`
   - WebSocket: STOMP send `/app/chat/messages`
8. **BE**: Lưu **DB `messages`**, update **`conversations.last_message`**, publish WebSocket.
9. **BE**: Gửi FCM notification cho người nhận.

### 4.23. Push notifications
1. **FE**: Lấy FCM token -> `POST /api/device-tokens` với header `X-User-ID`.
2. **BE/DB**: Lưu **`device_tokens`** theo user.
3. **BE**: Khi có order/chat/đổi trạng thái -> gửi FCM payload.
4. **FE**: `PushNotificationService` hiển thị local notification + điều hướng:
   - Order: mở detail (customer/seller).
   - Chat: mở chat/messenger.
   - Wallet: mở ví.

### 4.24. Ví điện tử (wallet)
1. **FE**: Lấy số dư -> `GET /api/wallets/{userId}`.
2. **BE/DB**: Đọc **`wallets`**.
3. **FE**: Nạp tiền -> `POST /api/sepay/topup/{userId}` (amount).
4. **BE**: Tạo giao dịch -> trả `paymentUrl` hoặc `providerTransactionId`.
5. **FE**: Tạo QR fallback từ SePay nếu `paymentUrl` rỗng.
6. **FE**: Lịch sử giao dịch -> `GET /api/wallets/{userId}/transactions`.
7. **DB**: Query **`wallet_transactions`**.
8. **FE**: Rút tiền -> `POST /api/wallets/{userId}/withdraw`.
9. **DB**: Insert **`wallet_transactions`** và update **`wallets.balance`**.

### 4.25. Thống kê (Seller Analytics)
1. **FE**: `GET /api/orders/store/{storeId}/sales-stats?period=...`.
2. **FE**: `GET /api/orders/store/{storeId}/top-products`.
3. **BE/DB**: Aggregate từ **`orders` + `order_items`**.

## 5. Bảng dữ liệu suy luận (từ FE)

- `users` (profile, role, avatar)
- `addresses`
- `stores`, `store_categories`
- `categories`
- `products`, `product_images`
- `cart_items`
- `orders`, `order_items`
- `vouchers`
- `wallets`, `wallet_transactions`
- `wishlist`
- `conversations`, `messages`
- `store_reviews`, `store_review_images`
- `banners`
- `search_history`
- `device_tokens`
- **Firebase RTDB**: `order_tracking/{orderId}` (realtime tracking)

## 6. Ghi chú triển khai

- FE hiện không cấu hình interceptor auth token cho Dio; hầu hết request truyền `userId` qua path hoặc header `X-User-ID` (device token).
- URL ảnh được normalize bằng `resolveImageUrl/resolveServerAssetUrl`.
- Một số luồng gọi trực tiếp bên thứ ba từ FE (HERE API, OSRM), không qua BE.
