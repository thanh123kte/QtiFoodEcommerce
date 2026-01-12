import 'package:datn_foodecommerce_flutter_app/domain/entities/order_tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart' as dio;
import 'package:url_launcher/url_launcher.dart';

import 'order_tracking_view_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final OrderTrackingViewModel _viewModel;
  final MapController _mapController = MapController();
  bool _mapReady = false;
  List<LatLng> _routePoints = const [];
  LatLng? _lastDriverPos;
  DateTime? _lastDriverUpdate;
  DateTime? _lastRouteFetch;
  static const _minMoveMeters = 5.0; // only update if driver moved >5m
  static const _routeRefetchCooldown = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    debugPrint('[OrderTrackingScreen.initState] Creating view model');
    _viewModel = OrderTrackingViewModel(GetIt.I());
    _viewModel.addListener(_onTrackingUpdated);
    debugPrint('[OrderTrackingScreen.initState] Starting tracking for orderId: ${widget.orderId}');
    _viewModel.startTracking(widget.orderId);
  }

  void _onTrackingUpdated() {
    debugPrint('[OrderTrackingScreen._onTrackingUpdated] called');
    final tracking = _viewModel.tracking;
    if (tracking != null && _mapReady) {
      debugPrint('[OrderTrackingScreen._onTrackingUpdated] Tracking data available');
      final driverLat = tracking.driverLocation.latitude;
      final driverLng = tracking.driverLocation.longitude;
      final currentPos = LatLng(driverLat, driverLng);
      // Skip if no movement beyond threshold or same timestamp
      final movedEnough = _hasMovedEnough(_lastDriverPos, currentPos);
      final sameTimestamp = _lastDriverUpdate != null &&
          _lastDriverUpdate == tracking.driverLocation.updatedAt;
      if (!movedEnough || sameTimestamp) {
        debugPrint('[OrderTrackingScreen] Skipping map update (minor/no change)');
      } else {
        debugPrint('[OrderTrackingScreen._onTrackingUpdated] Moving map to: ($driverLat, $driverLng)');
        _mapController.move(currentPos, 15.0);
        _lastDriverPos = currentPos;
        _lastDriverUpdate = tracking.driverLocation.updatedAt;
      }
      // If we have recipient coordinates, fetch route
      final rLat = tracking.recipientLatitude;
      final rLng = tracking.recipientLongitude;
      if (rLat != null && rLng != null) {
        // Throttle route fetches to avoid spamming network
        final now = DateTime.now();
        if (_lastRouteFetch == null || now.difference(_lastRouteFetch!) > _routeRefetchCooldown) {
          _lastRouteFetch = now;
          _fetchRoute(LatLng(driverLat, driverLng), LatLng(rLat, rLng));
        }
      }
    } else {
      debugPrint('[OrderTrackingScreen._onTrackingUpdated] Tracking data is null or map not ready');
    }
  }

  @override
  void dispose() {
    debugPrint('[OrderTrackingScreen.dispose] called');
    _viewModel.removeListener(_onTrackingUpdated);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theo dõi đơn hàng'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Consumer<OrderTrackingViewModel>(
          builder: (context, vm, _) {
            final tracking = vm.tracking;
            if (vm.isLoading && tracking == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null && tracking == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${vm.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.startTracking(widget.orderId),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (tracking == null) {
              return const Center(child: Text('Không có dữ liệu theo dõi'));
            }
            return Stack(
              children: [
                _buildMap(tracking),
                _buildBottomSheet(context, tracking),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMap(OrderTracking tracking) {
    final driverLat = tracking.driverLocation.latitude;
    final driverLng = tracking.driverLocation.longitude;

    // Parse recipient address to get approx location
    // For now, using driver location as reference
    final driverLocation = LatLng(driverLat, driverLng);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: driverLocation,
        initialZoom: 15.0,
        onMapReady: () {
          setState(() {
            _mapReady = true;
          });
          debugPrint('[OrderTrackingScreen] Map is ready');
          // Trigger update to move camera to current location
          _onTrackingUpdated();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.datn.foodecommerce',
          additionalOptions: const {
            'id': 'FoodEcommerceApp/1.0',
          },
        ),
        // Draw OSRM route if available, otherwise a straight fallback line when both markers exist
        PolylineLayer(
          polylines: [
            if (_routePoints.isNotEmpty)
              Polyline(
                points: _routePoints,
                strokeWidth: 4,
                color: Colors.blueAccent,
              )
            else if (tracking.recipientLatitude != null && tracking.recipientLongitude != null)
              Polyline(
                points: [
                  driverLocation,
                  LatLng(tracking.recipientLatitude!, tracking.recipientLongitude!),
                ],
                strokeWidth: 3,
                color: Colors.blue.withOpacity(0.5),
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Driver marker
            Marker(
              width: 50,
              height: 50,
              point: driverLocation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4)
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Recipient location marker from shipping lat/lng
            if (tracking.recipientLatitude != null && tracking.recipientLongitude != null)
              Marker(
                width: 50,
                height: 50,
                point: LatLng(tracking.recipientLatitude!, tracking.recipientLongitude!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    try {
      // OSRM public demo server (car profile). Note: rate-limited.
      final url =
          'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson';
      final httpClient = GetIt.I.get<dio.Dio>();
      debugPrint('[OrderTrackingScreen] Fetching OSRM route: $url');
      final resp = await httpClient.get(url);
      debugPrint('[OrderTrackingScreen] OSRM status: ${resp.statusCode}');
      final routes = resp.data['routes'] as List?;
      if (routes == null || routes.isEmpty) return;
      final geometry = routes.first['geometry'];
      final coords = (geometry['coordinates'] as List)
          .map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      setState(() {
        _routePoints = coords;
      });
      debugPrint('[OrderTrackingScreen] Route points: ${_routePoints.length}');
    } catch (e) {
      debugPrint('[OrderTrackingScreen] Fetch OSRM route error: $e');
    }
  }

  bool _hasMovedEnough(LatLng? from, LatLng to) {
    if (from == null) return true;
    // Approximate distance in meters using Haversine via latlong2 Distance
    final distance = Distance().as(LengthUnit.Meter, from, to);
    return distance >= _minMoveMeters;
  }

  Widget _buildBottomSheet(BuildContext context, OrderTracking tracking) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        tracking.driverName.isNotEmpty
                            ? tracking.driverName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tracking.driverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            tracking.driverPhone,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final phone = normalizePhone(tracking.driverPhone);

                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Số điện thoại tài xế không khả dụng')),
                          );
                          return;
                        }

                        final uri = Uri(scheme: 'tel', path: phone);

                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          debugPrint('Launch dialer failed: $e');

                          // fallback cho emulator
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Thiết bị không hỗ trợ gọi: $phone')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Gọi'),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 16),
                _buildInfoRow('Địa chỉ shop', tracking.storeAddress),
                const SizedBox(height: 12),
                _buildInfoRow('Địa chỉ giao', tracking.shippingAddress),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Cập nhật lần cuối',
                  _formatTime(tracking.driverLocation.updatedAt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inSeconds < 60) {
      return 'Vừa cập nhật';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} phút trước';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} giờ trước';
    } else {
      return '${duration.inDays} ngày trước';
    }
  }
  String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}
