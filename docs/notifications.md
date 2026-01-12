# Push notification contract

## Device token registration
- **Endpoint**: `POST /api/device-tokens`
- **Headers**: `X-User-ID: <firebase-uid>`
- **Body**:
  ```json
  {
    "token": "<fcm-token>",
    "platform": "ANDROID" // or "IOS"
  }
  ```
- Store multiple tokens per user (do not overwrite). Ignore duplicates.

## When to send
- **New order (customer -> seller)**: send to all tokens of the store owner/seller.
- **Order status update (seller -> customer)**: send to all tokens of the customer who created the order.

## FCM payload shape
- Always include a `data` section:
  ```json
  {
    "notification": {
      "title": "New order received",
      "body": "Order #12345 from John Doe"
    },
    "data": {
      "type": "ORDER",
      "orderId": "12345",
      "orderStatus": "SHIPPING",
      "role": "SELLER" // or "CUSTOMER"
    }
  }
  ```
- The Flutter app navigates using `orderId` and `role`. `orderStatus` is shown in the body and can be used for future UX.

## Backend hooks (pseudo)
- On order creation:
  - Resolve seller tokens.
  - Send FCM payload above with `role: SELLER` and current status (likely `PENDING`/`CONFIRMED`).
- On order status change:
  - Resolve customer tokens.
  - Send payload above with `role: CUSTOMER` and new status value.
