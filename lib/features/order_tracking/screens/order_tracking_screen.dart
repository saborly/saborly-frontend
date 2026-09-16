import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/features/providers/order_tracking_provider.dart';
import 'package:Saborly/shared/models/order_tracking_info.dart';

/// Live driver-tracking map, reachable from the "Track Order" button on
/// OrderDeliveryTimeCard once a driver is assigned. Registered as a
/// top-level route outside the bottom-nav shell, matching order-status.
class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderTrackingProvider(orderId)..start(),
      child: const _OrderTrackingView(),
    );
  }
}

class _OrderTrackingView extends StatefulWidget {
  const _OrderTrackingView();

  @override
  State<_OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<_OrderTrackingView> {
  GoogleMapController? _mapController;
  bool _hasCenteredOnDriver = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderTrackingProvider>();
    final tracking = provider.tracking;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(AppStrings.trackOrder, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: provider.isLoading && tracking == null
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && tracking == null
              ? Center(
                  child: Text(provider.error!, style: TextStyle(color: AppColors.textMedium)),
                )
              : _buildContent(context, tracking!, provider),
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    const message = "Hi, I'm reaching out about my Saborly delivery.";
    final appUri = Uri.parse('whatsapp://send?phone=$digits&text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }
    final webUri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(message)}');
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Widget _buildContent(BuildContext context, OrderTrackingInfo tracking, OrderTrackingProvider provider) {
    final destination = (tracking.destinationLatitude != null && tracking.destinationLongitude != null)
        ? LatLng(tracking.destinationLatitude!, tracking.destinationLongitude!)
        : null;
    final branch = (tracking.branchLatitude != null && tracking.branchLongitude != null)
        ? LatLng(tracking.branchLatitude!, tracking.branchLongitude!)
        : null;
    final driverPosition = tracking.hasDriverLocation ? LatLng(tracking.latitude!, tracking.longitude!) : null;

    if (driverPosition != null && !_hasCenteredOnDriver) {
      _hasCenteredOnDriver = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(driverPosition, 15));
      });
    } else if (driverPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(driverPosition));
      });
    }

    final markers = <Marker>{
      if (branch != null)
        Marker(
          markerId: const MarkerId('branch'),
          position: branch,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: tracking.branchName ?? 'Restaurant'),
        ),
      if (destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Delivery address'),
        ),
      if (driverPosition != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driverPosition,
          rotation: tracking.heading ?? 0,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: tracking.driverName ?? 'Driver'),
        ),
    };

    final initialCenter = driverPosition ?? branch ?? destination ?? const LatLng(41.4036344, 2.1986439);

    return Column(
      children: [
        if (provider.usingFallbackPolling) _buildFallbackBanner(),
        if (tracking.isStale) _buildStaleBanner(),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: initialCenter, zoom: 14),
            markers: markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
            polylines: (branch != null && destination != null)
                ? {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: [branch, destination],
                      color: AppColors.primary.withOpacity(0.35),
                      width: 3,
                      patterns: [PatternItem.dash(14), PatternItem.gap(10)],
                    ),
                  }
                : {},
          ),
        ),
        _buildInfoPanel(tracking),
      ],
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.warning.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sync_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Text('Reconnecting for live updates…', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildStaleBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.error.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Text("Driver's location hasn't updated recently",
              style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(OrderTrackingInfo tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tracking.trackingStageLabel,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            tracking.isLive ? 'Live location updating' : 'Waiting for driver to start sharing location',
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
          if (tracking.driverName != null && tracking.driverName!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    tracking.driverName![0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tracking.driverName!, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Your driver', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                ),
                if (tracking.driverPhone != null && tracking.driverPhone!.isNotEmpty) ...[
                  IconButton(
                    onPressed: () => _openWhatsApp(tracking.driverPhone!),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF25D366).withOpacity(0.1)),
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: tracking.driverPhone)),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1)),
                    icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
