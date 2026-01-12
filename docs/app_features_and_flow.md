# Tài liệu chức năng & luồng hoạt động hệ thống FoodEcommerce

## 1. Chức năng chính

### 1.1. Đăng ký/Đăng nhập
- Đăng ký tài khoản khách hàng/seller qua email, mật khẩu, xác thực OTP.
- Đăng nhập bằng email/mật khẩu hoặc Google.
- Quên mật khẩu, đổi mật khẩu.

### 1.2. Quản lý sản phẩm
- Seller thêm/sửa/xóa sản phẩm, upload nhiều ảnh.
- Quản lý danh mục sản phẩm, phân loại.
- Hiển thị sản phẩm theo danh mục, tìm kiếm, lọc, sắp xếp.

### 1.3. Đặt hàng & giỏ hàng
- Khách hàng thêm sản phẩm vào giỏ hàng.
- Đặt hàng, chọn địa chỉ giao hàng, phương thức thanh toán.
- Theo dõi trạng thái đơn hàng (chờ xác nhận, đang giao, hoàn thành, hủy).

### 1.4. Quản lý đơn hàng
- Seller xác nhận, cập nhật trạng thái đơn hàng.
- Xem lịch sử đơn hàng, chi tiết đơn hàng.

### 1.5. Tìm kiếm sản phẩm
- Tìm kiếm theo từ khóa, gợi ý lịch sử tìm kiếm.
- Tìm kiếm bằng hình ảnh (Image Search): chọn/chụp ảnh, gửi lên server, trả về sản phẩm tương tự.

### 1.6. Chat & Thông báo
- Chat realtime giữa khách hàng và seller.
- Gửi nhận tin nhắn qua WebSocket/REST API.
- Nhận thông báo FCM khi có tin nhắn mới, đơn hàng mới, trạng thái đơn hàng thay đổi.

### 1.7. Quản lý tài khoản
- Xem/sửa thông tin cá nhân, đổi mật khẩu.
- Quản lý địa chỉ giao hàng.
- Đăng xuất.

---

## 2. Luồng hoạt động chi tiết (FE → BE → DB)

### 2.1. Đăng nhập/Đăng ký
1. **FE**: Gửi thông tin đăng ký/đăng nhập qua API `/api/auth/register` hoặc `/api/auth/login`.
2. **BE**: Kiểm tra hợp lệ, mã hóa mật khẩu, lưu user vào DB (bảng `users`).
3. **BE**: Trả về JWT token, FE lưu token để xác thực các request tiếp theo.

### 2.2. Tìm kiếm sản phẩm
1. **FE**: Gửi request `/api/products/search?keyword=...` hoặc `/api/products/search-by-image` (POST base64 image).
2. **BE**: Nhận request, nếu là search-by-image thì forward sang service FastAPI xử lý AI, nhận về danh sách productId.
3. **BE**: Truy vấn DB (bảng `products`, `product_images`) trả về danh sách sản phẩm phù hợp.
4. **FE**: Hiển thị kết quả tìm kiếm cho người dùng.

### 2.3. Đặt hàng
1. **FE**: Gửi request tạo đơn hàng `/api/orders` với thông tin sản phẩm, địa chỉ, payment.
2. **BE**: Kiểm tra tồn kho, tạo bản ghi mới trong bảng `orders`, `order_items`.
3. **BE**: Gửi thông báo FCM cho seller về đơn hàng mới.
4. **FE**: Hiển thị trạng thái đơn hàng cho khách hàng.

### 2.4. Chat & Thông báo
1. **FE**: Gửi tin nhắn qua API `/api/chat/messages` hoặc WebSocket.
2. **BE**: Lưu tin nhắn vào bảng `messages`, cập nhật bảng `conversations`.
3. **BE**: Gửi FCM notification cho người nhận (dựa vào FCM token lưu trong DB `user_tokens`).
4. **FE**: Nhận FCM, nếu type = "CHAT" thì hiển thị badge/thông báo tin nhắn mới.

### 2.5. Quản lý sản phẩm (Seller)
1. **FE**: Gửi request thêm/sửa/xóa sản phẩm qua `/api/products`.
2. **BE**: Lưu thông tin vào bảng `products`, `product_images`.
3. **FE**: Hiển thị danh sách sản phẩm đã cập nhật.

### 2.6. Quản lý tài khoản/địa chỉ
1. **FE**: Gửi request lấy/cập nhật thông tin user `/api/users/me`, `/api/addresses`.
2. **BE**: Truy vấn/lưu thông tin vào bảng `users`, `addresses`.
3. **FE**: Hiển thị thông tin mới nhất cho người dùng.

---

## 3. Sơ đồ tổng quan

```
[FE - Flutter App]
    |
    |  (REST API, WebSocket, FCM)
    v
[BE - Spring Boot API Gateway]
    |         \
    |          \-- [Python FastAPI Image Search]
    v
[DB - MySQL/PostgreSQL]
```

- **FE**: Giao diện người dùng, gửi nhận dữ liệu qua API, nhận FCM.
- **BE**: Xử lý nghiệp vụ, xác thực, lưu trữ dữ liệu, gửi FCM, forward image search.
- **DB**: Lưu trữ dữ liệu người dùng, sản phẩm, đơn hàng, tin nhắn, token FCM...
- **FastAPI**: Xử lý AI tìm kiếm ảnh, trả về kết quả cho BE.

---

## 4. Ghi chú
- Tất cả API đều xác thực bằng JWT token (trừ đăng ký/đăng nhập).
- FCM token được lưu khi user đăng nhập, dùng để gửi notification realtime.
- Ảnh sản phẩm lưu cloud (Firebase Storage hoặc server riêng), DB chỉ lưu URL.
- Các trạng thái đơn hàng, tin nhắn, notification đều đồng bộ realtime qua FCM hoặc WebSocket.
