// lib/app/di/injector.dart
import 'package:datn_foodecommerce_flutter_app/data/repositories_impl/order_tracking_repository_impl.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/order/assign_driver.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/order/cancel_order.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/order/create_order.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/order/get_store_top_products.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/product/get_product_images.dart';
import 'package:datn_foodecommerce_flutter_app/domain/usecases/wishlist/remove_store_from_wishlist.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/cart/cart_sync_notifier.dart';
import 'package:datn_foodecommerce_flutter_app/router/auth_notifier.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/auth/login/login_viewmodel.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/auth/register/register_viewmodel.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/profile/profile_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/dashboard/customer_dashboard_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/addresses_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/add_address_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/analytics/seller_statistics_view_model.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/local/user_local.dart';
import '../data/datasources/local/address_local.dart';
import '../data/datasources/local/product_local.dart';
import '../data/datasources/local/cart_local.dart';
import '../data/datasources/local/store_local.dart';
import '../data/datasources/local/store_category_local.dart';
import '../data/datasources/local/category_local.dart';
import '../data/datasources/local/voucher_local.dart';
import '../data/datasources/local/wishlist_local.dart';
import '../data/datasources/local/search_history_local.dart';
import '../data/datasources/local/session_local.dart';
import '../data/datasources/remote/auth_remote.dart';
import '../data/datasources/remote/user_remote.dart';
import '../data/datasources/remote/address_remote.dart';
import '../data/datasources/remote/place_suggestion_remote.dart';
import '../data/datasources/remote/banner_remote.dart';
import '../data/datasources/remote/store_remote.dart';
import '../data/datasources/remote/store_category_remote.dart';
import '../data/datasources/remote/category_remote.dart';
import '../data/datasources/remote/product_remote.dart';
import '../data/datasources/remote/conversation_remote.dart';
import '../data/datasources/remote/chatbot_remote.dart';
import '../data/datasources/remote/wishlist_remote.dart';
import '../data/datasources/remote/cart_remote.dart';
import '../data/datasources/remote/order_remote.dart';
import '../data/datasources/remote/voucher_remote.dart';
import '../data/datasources/remote/shipping_remote.dart';
import '../data/datasources/remote/search_history_remote.dart';
import '../data/datasources/remote/wallet_remote.dart';
import '../data/datasources/remote/device_token_remote.dart';
import '../data/datasources/remote/store_review_remote.dart';
import '../data/repositories_impl/auth_repository_impl.dart';
import '../data/repositories_impl/profile_repository_impl.dart';
import '../data/repositories_impl/address_repository_impl.dart';
import '../data/repositories_impl/banner_repository_impl.dart';
import '../data/repositories_impl/store_repository_impl.dart';
import '../data/repositories_impl/store_category_repository_impl.dart';
import '../data/repositories_impl/category_repository_impl.dart';
import '../data/repositories_impl/user_repository_impl.dart';
import '../data/repositories_impl/product_repository_impl.dart';
import '../data/repositories_impl/conversation_repository_impl.dart';
import '../data/repositories_impl/chatbot_repository_impl.dart';
import '../data/repositories_impl/wishlist_repository_impl.dart';
import '../data/repositories_impl/cart_repository_impl.dart';
import '../data/repositories_impl/order_repository_impl.dart';
import '../data/repositories_impl/voucher_repository_impl.dart';
import '../data/repositories_impl/shipping_repository_impl.dart';
import '../data/repositories_impl/search_history_repository_impl.dart';
import '../data/repositories_impl/wallet_repository_impl.dart';
import '../data/repositories_impl/device_token_repository_impl.dart';
import '../data/repositories_impl/store_review_repository_impl.dart';
import '../data/datasources/remote/order_tracking_remote.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/repositories/address_repository.dart';
import '../domain/repositories/banner_repository.dart';
import '../domain/repositories/store_repository.dart';
import '../domain/repositories/store_category_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/conversation_repository.dart';
import '../domain/repositories/chatbot_repository.dart';
import '../domain/repositories/wishlist_repository.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/repositories/voucher_repository.dart';
import '../domain/repositories/shipping_repository.dart';
import '../domain/repositories/search_history_repository.dart';
import '../domain/repositories/wallet_repository.dart';
import '../domain/repositories/device_token_repository.dart';
import '../domain/repositories/store_review_repository.dart';
import '../domain/repositories/order_tracking_repository.dart';
import '../domain/usecases/auth/login/sign_in_email.dart';
import '../domain/usecases/auth/login/sign_in_google.dart';
import '../domain/usecases/auth/login/send_password_reset.dart';
import '../domain/usecases/auth/register/sign_up_email.dart';
import '../domain/usecases/profile/get_profile.dart';
import '../domain/usecases/profile/refresh_profile.dart';
import '../domain/usecases/profile/update_profile.dart';
import '../domain/usecases/profile/upload_avatar.dart';
import '../domain/usecases/banner/get_banners_by_status.dart';
import '../domain/usecases/address/get_addresses.dart';
import '../domain/usecases/address/get_address_by_id.dart';
import '../domain/usecases/address/create_address.dart';
import '../domain/usecases/address/delete_address.dart';
import '../domain/usecases/address/search_address_suggestions.dart';
import '../domain/usecases/address/update_address.dart';
import '../domain/usecases/store/create_store.dart';
import '../domain/usecases/store/get_nearby_stores.dart';
import '../domain/usecases/store/get_store_by_owner.dart';
import '../domain/usecases/store/get_store.dart';
import '../domain/usecases/store/increment_store_view.dart';
import '../domain/usecases/store/update_store.dart';
import '../domain/usecases/store/upload_store_image.dart';
import '../domain/usecases/store_review/create_store_review.dart';
import '../domain/usecases/store_review/upload_store_review_images.dart';
import '../domain/usecases/store_review/delete_store_review_image.dart';
import '../domain/usecases/store_review/get_store_reviews_by_store.dart';
import '../domain/usecases/store_review/reply_store_review.dart';
import '../domain/usecases/store_category/create_store_category.dart';
import '../domain/usecases/store_category/delete_store_category.dart';
import '../domain/usecases/store_category/get_store_categories.dart';
import '../domain/usecases/store_category/update_store_category.dart';
import '../domain/usecases/category/get_categories.dart';
import '../domain/usecases/product/get_store_products.dart';
import '../domain/usecases/product/get_products.dart';
import '../domain/usecases/product/create_product.dart';
import '../domain/usecases/product/update_product.dart';
import '../domain/usecases/product/delete_product.dart';
import '../domain/usecases/product/upload_product_images.dart';
import '../domain/usecases/product/search_products.dart';
import '../domain/usecases/product/search_by_image.dart';
import '../domain/usecases/wishlist/add_store_to_wishlist.dart';
import '../domain/usecases/wishlist/check_store_in_wishlist.dart';
import '../domain/usecases/cart/get_cart_items.dart';
import '../domain/usecases/cart/add_product_to_cart.dart';
import '../domain/usecases/cart/update_cart_item_quantity.dart';
import '../domain/usecases/cart/remove_cart_item.dart';
import '../domain/usecases/voucher/get_store_vouchers.dart';
import '../domain/usecases/voucher/get_admin_vouchers.dart';
import '../domain/usecases/voucher/get_voucher.dart';
import '../domain/usecases/voucher/create_voucher.dart';
import '../domain/usecases/order/create_order_item.dart';
import '../domain/usecases/order/get_customer_orders.dart';
import '../domain/usecases/order/get_order_items.dart';
import '../domain/usecases/order/get_store_orders.dart';
import '../domain/usecases/order/get_store_sales_stats.dart';
import '../domain/usecases/order/update_order_status.dart';
import '../domain/usecases/order/get_order_by_id.dart';
import '../domain/usecases/conversation/get_conversations.dart';
import '../domain/usecases/conversation/get_or_create_conversation.dart';
import '../domain/usecases/conversation/get_messages.dart';
import '../domain/usecases/conversation/send_message.dart';
import '../domain/usecases/conversation/mark_conversation_as_read.dart';
import '../domain/usecases/chatbot/send_chatbot_message.dart';
import '../domain/usecases/order/get_order_tracking_stream.dart';
import '../domain/usecases/wishlist/get_wishlist_stores.dart';
import '../domain/usecases/search_history/get_search_history.dart';
import '../domain/usecases/search_history/save_search_history.dart';
import '../domain/usecases/voucher/update_voucher.dart';
import '../domain/usecases/voucher/delete_voucher.dart';
import '../domain/usecases/voucher/increment_voucher_usage.dart';
import '../domain/usecases/shipping/calculate_shipping_fee.dart';
import '../domain/usecases/wallet/get_wallet_balance.dart';
import '../domain/usecases/wallet/top_up_wallet.dart';
import '../domain/usecases/wallet/get_wallet_transactions.dart';
import '../domain/usecases/wallet/withdraw_wallet.dart';
import '../domain/usecases/notifications/register_device_token.dart';
import '../services/location/geolocator_location_provider.dart';
import '../services/location/location_provider.dart';
import '../services/notifications/push_notification_service.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/update_address_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/cart/cart_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/seller/seller_registration_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/store/customer_store_detail_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/profile/seller_profile_overview_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/profile/seller_store_info_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/categories/store_categories_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/products/seller_products_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/vouchers/seller_vouchers_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/orders/seller_orders_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/orders/seller_order_detail_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/wallet/customer_wallet_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/wallet/seller_wallet_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/search/customer_search_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/wishlist/favorite_stores_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/orders/order_list_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/orders/order_detail_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/orders/store_review_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/dashboard/seller_dashboard_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/messenger/messenger_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/messenger/chat_view_model.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/messenger/ai_chat_view_model.dart';
import '../services/chat/chat_socket_service.dart';

bool _hiveInitialized = false;

Future<void> initDependencies({
  required String baseUrl,
  String? hereApiKey ,
  String hereApiBaseUrl = 'https://autosuggest.search.hereapi.com',
  String hereLanguage = 'vi',
}) async {
  final  resolvedHereApiKey = hereApiKey ?? dotenv.env['HERE_API_KEY'];
  if (resolvedHereApiKey == null || resolvedHereApiKey.isEmpty) {
    throw Exception('HERE_API_KEY is missing in .env file');
  }
  final getIt = GetIt.instance;

  if (getIt.isRegistered<FirebaseAuth>()) {
    if (_hiveInitialized) {
      if (Hive.isBoxOpen(UserLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(UserLocal.boxName).close();
      }
      if (Hive.isBoxOpen(AddressLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(AddressLocal.boxName).close();
      }
      if (Hive.isBoxOpen(ProductLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(ProductLocal.boxName).close();
      }
      if (Hive.isBoxOpen(StoreLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(StoreLocal.boxName).close();
      }
      if (Hive.isBoxOpen(StoreCategoryLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(StoreCategoryLocal.boxName).close();
      }
      if (Hive.isBoxOpen(CategoryLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(CategoryLocal.boxName).close();
      }
      if (Hive.isBoxOpen(CartLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(CartLocal.boxName).close();
      }
      if (Hive.isBoxOpen(VoucherLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(VoucherLocal.boxName).close();
      }
      if (Hive.isBoxOpen(SearchHistoryLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(SearchHistoryLocal.boxName).close();
      }
      if (Hive.isBoxOpen(WishlistLocal.boxName)) {
        await Hive.box<Map<dynamic, dynamic>>(WishlistLocal.boxName).close();
      }
    }
    await getIt.reset();
  }

  if (!_hiveInitialized) {
    await Hive.initFlutter();
    _hiveInitialized = true;
  }

  final Box<Map<dynamic, dynamic>> userBox;
  if (Hive.isBoxOpen(UserLocal.boxName)) {
    userBox = Hive.box<Map<dynamic, dynamic>>(UserLocal.boxName);
  } else {
    userBox = await Hive.openBox<Map<dynamic, dynamic>>(UserLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> addressBox;
  if (Hive.isBoxOpen(AddressLocal.boxName)) {
    addressBox = Hive.box<Map<dynamic, dynamic>>(AddressLocal.boxName);
  } else {
    addressBox = await Hive.openBox<Map<dynamic, dynamic>>(AddressLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> productBox;
  if (Hive.isBoxOpen(ProductLocal.boxName)) {
    productBox = Hive.box<Map<dynamic, dynamic>>(ProductLocal.boxName);
  } else {
    productBox = await Hive.openBox<Map<dynamic, dynamic>>(ProductLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> storeBox;
  if (Hive.isBoxOpen(StoreLocal.boxName)) {
    storeBox = Hive.box<Map<dynamic, dynamic>>(StoreLocal.boxName);
  } else {
    storeBox = await Hive.openBox<Map<dynamic, dynamic>>(StoreLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> storeCategoryBox;
  if (Hive.isBoxOpen(StoreCategoryLocal.boxName)) {
    storeCategoryBox = Hive.box<Map<dynamic, dynamic>>(StoreCategoryLocal.boxName);
  } else {
    storeCategoryBox = await Hive.openBox<Map<dynamic, dynamic>>(StoreCategoryLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> categoryBox;
  if (Hive.isBoxOpen(CategoryLocal.boxName)) {
    categoryBox = Hive.box<Map<dynamic, dynamic>>(CategoryLocal.boxName);
  } else {
    categoryBox = await Hive.openBox<Map<dynamic, dynamic>>(CategoryLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> cartBox;
  if (Hive.isBoxOpen(CartLocal.boxName)) {
    cartBox = Hive.box<Map<dynamic, dynamic>>(CartLocal.boxName);
  } else {
    cartBox = await Hive.openBox<Map<dynamic, dynamic>>(CartLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> voucherBox;
  if (Hive.isBoxOpen(VoucherLocal.boxName)) {
    voucherBox = Hive.box<Map<dynamic, dynamic>>(VoucherLocal.boxName);
  } else {
    voucherBox = await Hive.openBox<Map<dynamic, dynamic>>(VoucherLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> searchHistoryBox;
  if (Hive.isBoxOpen(SearchHistoryLocal.boxName)) {
    searchHistoryBox = Hive.box<Map<dynamic, dynamic>>(SearchHistoryLocal.boxName);
  } else {
    searchHistoryBox = await Hive.openBox<Map<dynamic, dynamic>>(SearchHistoryLocal.boxName);
  }

  final Box<Map<dynamic, dynamic>> wishlistBox;
  if (Hive.isBoxOpen(WishlistLocal.boxName)) {
    wishlistBox = Hive.box<Map<dynamic, dynamic>>(WishlistLocal.boxName);
  } else {
    wishlistBox = await Hive.openBox<Map<dynamic, dynamic>>(WishlistLocal.boxName);
  }

  final sharedPrefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton(() => Dio(BaseOptions(baseUrl: baseUrl)));
  getIt.registerLazySingleton(() => ChatSocketService(baseUrl));

  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton(() => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://datn-foodecommerce-default-rtdb.asia-southeast1.firebasedatabase.app',
  ));
  getIt.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  getIt.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  getIt.registerLazySingleton(() => SessionLocal(getIt()));

  getIt.registerLazySingleton(() => AuthRemote(getIt()));
  getIt.registerLazySingleton(() => UserRemote(getIt()));
  getIt.registerLazySingleton(() => AddressRemote(getIt()));
  getIt.registerLazySingleton(() => BannerRemote(getIt()));
  getIt.registerLazySingleton(() => StoreRemote(getIt()));
  getIt.registerLazySingleton(() => StoreCategoryRemote(getIt()));
  getIt.registerLazySingleton(() => CategoryRemote(getIt()));
  getIt.registerLazySingleton(() => ProductRemote(getIt()));
  getIt.registerLazySingleton(() => WishlistRemote(getIt()));
  getIt.registerLazySingleton(() => CartRemote(getIt()));
  getIt.registerLazySingleton(() => OrderRemote(getIt()));
  getIt.registerLazySingleton(() => ConversationRemote(getIt()));
  getIt.registerLazySingleton(() => ChatbotRemote(getIt()));
  getIt.registerLazySingleton(() => VoucherRemote(getIt()));
  getIt.registerLazySingleton(() => ShippingRemote(getIt()));
  getIt.registerLazySingleton(() => SearchHistoryRemote(getIt()));
  getIt.registerLazySingleton(() => WalletRemote(getIt()));
  getIt.registerLazySingleton(() => DeviceTokenRemote(getIt()));
  getIt.registerLazySingleton(() => StoreReviewRemote(getIt()));
  getIt.registerLazySingleton<LocationProvider>(
    () => GeolocatorLocationProvider(),
  );
  getIt.registerLazySingleton(
    () => PlaceSuggestionRemote(
      getIt(),
      getIt(),
      apiKey: resolvedHereApiKey,
      baseUrl: hereApiBaseUrl,
      language: hereLanguage,
    ),
  );
  getIt.registerLazySingleton(() => UserLocal(userBox));
  getIt.registerLazySingleton(() => AddressLocal(addressBox));
  getIt.registerLazySingleton(() => ProductLocal(productBox));
  getIt.registerLazySingleton(() => StoreLocal(storeBox));
  getIt.registerLazySingleton(() => StoreCategoryLocal(storeCategoryBox));
  getIt.registerLazySingleton(() => CategoryLocal(categoryBox));
  getIt.registerLazySingleton(() => CartLocal(cartBox));
  getIt.registerLazySingleton(() => VoucherLocal(voucherBox));
  getIt.registerLazySingleton(() => SearchHistoryLocal(searchHistoryBox));
  getIt.registerLazySingleton(() => WishlistLocal(wishlistBox));

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<AddressRepository>(() => AddressRepositoryImpl(getIt(), getIt(), getIt()));
  getIt.registerLazySingleton<BannerRepository>(() => BannerRepositoryImpl(getIt()));
  getIt.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<StoreCategoryRepository>(() => StoreCategoryRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<WishlistRepository>(() => WishlistRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(getIt(), getIt(), getIt()));
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(getIt()));
  getIt.registerLazySingleton<ConversationRepository>(() => ConversationRepositoryImpl(getIt()));
  getIt.registerLazySingleton<ChatbotRepository>(() => ChatbotRepositoryImpl(getIt()));
  getIt.registerLazySingleton<VoucherRepository>(() => VoucherRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<ShippingRepository>(() => ShippingRepositoryImpl(getIt()));
  getIt.registerLazySingleton<SearchHistoryRepository>(() => SearchHistoryRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(getIt()));
  getIt.registerLazySingleton<DeviceTokenRepository>(() => DeviceTokenRepositoryImpl(getIt()));
  getIt.registerLazySingleton<OrderTrackingRepository>(() => OrderTrackingRepositoryImpl(getIt()));
  getIt.registerLazySingleton<StoreReviewRepository>(() => StoreReviewRepositoryImpl(getIt()));

  getIt.registerLazySingleton(() => OrderTrackingRemote(getIt()));

  getIt.registerFactory(() => SignUpEmail(getIt(), getIt()));
  getIt.registerFactory(() => SignInEmail(getIt(), getIt()));
  getIt.registerFactory(() => SignInGoogle(getIt(), getIt()));
  getIt.registerFactory(() => SendPasswordReset(getIt()));
  getIt.registerFactory(() => GetProfile(getIt()));
  getIt.registerFactory(() => RefreshProfile(getIt()));
  getIt.registerFactory(() => UpdateProfile(getIt()));
  getIt.registerFactory(() => UploadAvatar(getIt()));
  getIt.registerFactory(() => GetBannersByStatus(getIt()));
  getIt.registerFactory(() => GetAddresses(getIt()));
  getIt.registerFactory(() => GetAddressById(getIt()));
  getIt.registerFactory(() => CreateAddress(getIt()));
  getIt.registerFactory(() => UpdateAddress(getIt()));
  getIt.registerFactory(() => DeleteAddress(getIt()));
  getIt.registerFactory(() => SearchAddressSuggestions(getIt()));
  getIt.registerFactory(() => CreateStore(getIt()));
  getIt.registerFactory(() => GetNearbyStores(getIt()));
  getIt.registerFactory(() => GetStoreByOwner(getIt()));
  getIt.registerFactory(() => GetStore(getIt()));
  getIt.registerFactory(() => IncrementStoreView(getIt()));
  getIt.registerFactory(() => UpdateStore(getIt()));
  getIt.registerFactory(() => UploadStoreImage(getIt()));
  getIt.registerFactory(() => GetStoreCategories(getIt()));
  getIt.registerFactory(() => CreateStoreCategory(getIt()));
  getIt.registerFactory(() => UpdateStoreCategory(getIt()));
  getIt.registerFactory(() => DeleteStoreCategory(getIt()));
  getIt.registerFactory(() => GetCategories(getIt()));
  getIt.registerFactory(() => GetProducts(getIt()));
  getIt.registerFactory(() => GetFeaturedProducts(getIt()));
  getIt.registerFactory(() => SearchProducts(getIt()));
  getIt.registerFactory(() => SearchByImage(getIt()));
  getIt.registerFactory(() => AddStoreToWishlist(getIt()));
  getIt.registerFactory(() => RemoveStoreFromWishlist(getIt()));
  getIt.registerFactory(() => CheckStoreInWishlist(getIt()));
  getIt.registerFactory(() => FavoriteStoresViewModel(getIt(), getIt()));
  getIt.registerFactory(() => GetCartItems(getIt()));
  getIt.registerFactory(() => AddProductToCart(getIt()));
  getIt.registerFactory(() => UpdateCartItemQuantity(getIt()));
  getIt.registerFactory(() => RemoveCartItem(getIt()));
  getIt.registerFactory(() => GetWishlistStores(getIt()));
  getIt.registerFactory(() => GetProductImages(getIt()));
  getIt.registerFactory(() => CreateProduct(getIt()));
  getIt.registerFactory(() => UpdateProduct(getIt()));
  getIt.registerFactory(() => DeleteProduct(getIt()));
  getIt.registerFactory(() => UploadProductImages(getIt()));
  getIt.registerFactory(() => GetStoreVouchers(getIt()));
  getIt.registerFactory(() => GetAdminVouchers(getIt()));
  getIt.registerFactory(() => GetVoucher(getIt()));
  getIt.registerFactory(() => CreateVoucher(getIt()));
  getIt.registerFactory(() => UpdateVoucher(getIt()));
  getIt.registerFactory(() => DeleteVoucher(getIt()));
  getIt.registerFactory(() => IncrementVoucherUsage(getIt()));
  getIt.registerFactory(() => CalculateShippingFee(getIt()));
  getIt.registerFactory(() => CreateOrder(getIt()));
  getIt.registerFactory(() => CreateOrderItem(getIt()));
  getIt.registerFactory(() => GetCustomerOrders(getIt()));
  getIt.registerFactory(() => GetOrderItems(getIt()));
  getIt.registerFactory(() => GetStoreOrders(getIt()));
  getIt.registerFactory(() => GetStoreSalesStats(getIt()));
  getIt.registerFactory(() => GetStoreTopProducts(getIt()));
  getIt.registerFactory(() => CreateStoreReview(getIt()));
  getIt.registerFactory(() => UploadStoreReviewImages(getIt()));
  getIt.registerFactory(() => DeleteStoreReviewImage(getIt()));
  getIt.registerFactory(() => GetStoreReviewsByStore(getIt()));
  getIt.registerFactory(() => ReplyStoreReview(getIt()));
  getIt.registerFactory(() => AssignDriver(getIt()));
  getIt.registerFactory(() => GetOrderById(getIt()));
  getIt.registerFactory(() => CancelOrder(getIt()));
  getIt.registerFactory(() => GetConversations(getIt()));
  getIt.registerFactory(() => GetOrCreateConversation(getIt()));
  getIt.registerFactory(() => GetMessages(getIt()));
  getIt.registerFactory(() => SendMessage(getIt()));
  getIt.registerFactory(() => MarkConversationAsRead(getIt()));
  getIt.registerFactory(() => SendChatbotMessage(getIt()));
  getIt.registerFactory(() => GetOrderTrackingStream(getIt()));
  getIt.registerFactory(() => UpdateOrderStatus(getIt()));
  getIt.registerFactory(() => GetSearchHistory(getIt()));
  getIt.registerFactory(() => SaveSearchHistory(getIt()));
  getIt.registerFactory(() => RegisterDeviceToken(getIt()));
  getIt.registerFactory(() => GetWalletBalance(getIt()));
  getIt.registerFactory(() => TopUpWallet(getIt()));
  getIt.registerFactory(() => GetWalletTransactions(getIt()));
  getIt.registerFactory(() => WithdrawWallet(getIt()));

  getIt.registerFactory(() => LoginViewModel(getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => RegisterViewModel(getIt()));
  getIt.registerFactory(() => ProfileViewModel(getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => AddressesViewModel(getIt()));
  getIt.registerFactory(() => AddAddressViewModel(getIt(), getIt()));
  getIt.registerFactory(() => UpdateAddressViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => CartViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => CustomerDashboardViewModel(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => CustomerSearchViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => OrderListViewModel(getIt(), getIt()));
  getIt.registerFactory(() => OrderDetailViewModel(getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => MessengerViewModel(getIt(), getIt()));
  getIt.registerFactory(() => ChatViewModel(getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => AiChatViewModel(getIt()));
  getIt.registerFactory(
    () => CustomerStoreDetailViewModel(
      getIt(), // GetStore
      getIt(), // IncrementStoreView
      getIt(), // GetStoreCategories
      getIt(), // GetProducts
      getIt(), // AddStoreToWishlist
      getIt(), // RemoveStoreFromWishlist
      getIt(), // CheckStoreInWishlist
      getIt(), // GetStoreReviewsByStore
    ),
  );
  getIt.registerFactory(() => SellerRegistrationViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => SellerProfileOverviewViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => SellerStoreInfoViewModel(getIt(), getIt()));
  getIt.registerFactory(() => StoreReviewViewModel(getIt(), getIt()));
  getIt.registerFactory(() => SellerDashboardViewModel(getIt(), getIt()));
  getIt.registerFactory(() => SellerStatisticsViewModel(getIt(), getIt()));
  getIt.registerFactory(() => StoreCategoriesViewModel(getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(
    () => SellerProductsViewModel(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
  getIt.registerFactory(() => SellerVouchersViewModel(getIt(), getIt(), getIt(), getIt()));
  // Wallet
  getIt.registerFactory(() => CustomerWalletViewModel(getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => SellerWalletViewModel(getIt(), getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactory(() => SellerOrdersViewModel(getIt(), getIt()));
  getIt.registerFactory(() => SellerOrderDetailViewModel(getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt(), getIt()));

  getIt.registerLazySingleton(
    () => PushNotificationService(
      getIt(), // FirebaseMessaging
      getIt(), // FirebaseAuth
      getIt(), // RegisterDeviceToken
      getIt(), // SessionLocal
      getIt(), // GetOrderById
      getIt(), // FlutterLocalNotificationsPlugin
    ),
  );

  getIt.registerLazySingleton(() => AuthNotifier(getIt(), getIt()));
  getIt.registerLazySingleton(() => CartSyncNotifier());
}
