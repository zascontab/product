// ignore_for_file: directives_ordering

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/di/service_container.dart';
import '../../../taxi_rides/presentation/widgets/uber_driver_mode_toggle.dart';
import '../../application/blocs/location_search_bloc.dart';

import 'package:rantipay_app/core/rantipay/rantipay_base/application/blocs/base_crud_bloc.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/common/pagination.dart';

import 'package:rantipay_app/core/rantipay_theme/ranti_colors.dart';
import 'package:rantipay_app/core/rantipay_theme/ranti_typography.dart';
import 'package:rantipay_app/core/rantipay_theme/design_tokens.dart';
import 'package:rantipay_app/features/deliveries/delivery/domain/entities/promotion_entity.dart';

import '../../domain/entities/delivery_entity.dart';
import '../../domain/entities/delivery_filter_category.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../application/blocs/delivery_bloc.dart';
import '../../application/blocs/restaurant_bloc.dart';
import '../widgets/delivery_hero_section.dart';
import '../widgets/delivery_category_carousel.dart';
import '../../../../../core/widgets/cards/ranti_card_icon_detail.dart';
import '../widgets/featured_restaurants_section.dart';
import '../widgets/promotions_section.dart';
import '../widgets/quick_reorder_section.dart';
import '../widgets/popular_near_you_section.dart';
import '../widgets/shimmer_components.dart';
import '../widgets/delivery_list_item.dart';
import '../../../../dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import '../../../../../core/database/rantipay_database.dart';
import '../../../../../scripts/populate_local_data.dart';
import '../../infrastructure/services/ranti_location_service.dart';
//import '../widgets/ranti_location_picker_widget.dart';

// Uber-style Delivery Map Widget

// TODO: DELETE LEGACY - Replace with AdvancedTrackingGeoPage
// import 'uber_route_tracking_example_page.dart'; // LEGACY - MARKED FOR DELETION
// import '../../application/blocs/route_tracking_bloc.dart'; // LEGACY - MARKED FOR DELETION

// NEW UBER-STYLE BOOKING FLOW
import 'uber_style_booking_flow.dart';

// Integrated taxi system widgets

/// Uber/UberEats-style delivery dashboard for RantiPay
/// Features a modern, intuitive interface for food delivery and transportation services
class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key});

  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

class _DeliveryHomePageState extends State<DeliveryHomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _currentLocation = 'Ubicación actual';
  bool _isRefreshing = false;
  RantiLocationService? _locationService;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: RantiDesignTokens.durationNormal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: RantiDesignTokens.curveEaseOut,
    );
    _fadeController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Handle scroll-based UI updates if needed
    });
  }

  void _loadInitialData() {
    // Initialize location service
    try {
      _locationService = GetIt.instance<RantiLocationService>();
      _loadCurrentLocation();
    } catch (e) {
      // Location service not available
      _locationService = null;
    }

    // Load delivery data
    context.read<DeliveryBloc>().loadActiveDeliveries();

    // Load restaurant data
    context.read<RestaurantBloc>().loadFeaturedRestaurants();
    context.read<RestaurantBloc>().loadOpenRestaurants();
  }

  Future<void> _loadCurrentLocation() async {
    if (_locationService != null) {
      try {
        // Listen to current address stream
        _locationService!.currentAddressStream.listen((address) {
          if (address != null && mounted) {
            setState(() {
              _currentLocation = (address.street?.isNotEmpty == true)
                  ? address.street!
                  : 'Mi ubicación actual';
            });
          }
        });

        // Get current position to trigger address resolution
        await _locationService!.getCurrentPosition();
      } catch (e) {
        // Fallback to default location
        setState(() {
          _currentLocation = 'Ubicación no disponible';
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Refresh both delivery and restaurant data
    context.read<DeliveryBloc>().loadActiveDeliveries();
    context.read<RestaurantBloc>().loadFeaturedRestaurants();
    context.read<RestaurantBloc>().loadOpenRestaurants();

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: RantiColors.getBackground(context),
      // FAB para crear nuevo delivery y acceso a analytics
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "analytics",
            onPressed: _navigateToAnalyticsDashboard,
            backgroundColor: RantiColors.getSecondary(context),
            foregroundColor: RantiColors.getTextOnPrimary(context),
            tooltip: 'Analytics Dashboard',
            child: const Icon(Icons.analytics),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "delivery",
            onPressed: _createNewDelivery,
            backgroundColor: RantiColors.getPrimary(context),
            foregroundColor: RantiColors.getTextOnPrimary(context),
            icon: const Icon(Icons.add),
            label: const Text('New Delivery'),
            tooltip: 'Create a new delivery',
          ),
        ],
      ),
      body: Stack(
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDarkMode
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: SafeArea(
              top: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BlocBuilder<DeliveryBloc, BaseCrudState<DeliveryEntity>>(
                  builder: (context, deliveryState) {
                    return BlocBuilder<RestaurantBloc, RestaurantState>(
                      builder: (context, restaurantState) {
                        // Show loading if any BLoC is loading
                        if ((deliveryState.dataState.isLoading ||
                                _isRestaurantLoading(restaurantState)) &&
                            !_isRefreshing) {
                          return _buildLoadingState();
                        }

                        // Show error if any BLoC has error
                        if (deliveryState.dataState.hasError &&
                            !_isRefreshing) {
                          return _buildErrorState(
                              deliveryState.errorState?.message ??
                                  'Something went wrong');
                        }

                        if (_isRestaurantError(restaurantState) &&
                            !_isRefreshing) {
                          return _buildErrorState(
                              _getRestaurantErrorMessage(restaurantState));
                        }

                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: RantiColors.getPrimary(context),
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            slivers: [
                              // Hero Section with Location and Search
                              SliverToBoxAdapter(
                                child: DeliveryHeroSection(
                                  currentLocation: _currentLocation,
                                  onLocationTap: _showLocationPicker,
                                  onSearchTap: _navigateToSearch,
                                ),
                              ),

                              // Delivery Domains Selection
                              SliverToBoxAdapter(
                                child: _buildDeliveryDomainsSection(),
                              ),

                              // Category Carousel
                              SliverToBoxAdapter(
                                child: DeliveryCategoryCarousel(
                                  onCategoryTap: _navigateToCategory,
                                ),
                              ),

                              // Uber-style Map Access Section
                              SliverToBoxAdapter(
                                child: _buildUberMapAccessSection(),
                              ),

                              // Featured Restaurants - Using RestaurantBloc data
                              SliverToBoxAdapter(
                                child: FeaturedRestaurantsSection(
                                  restaurants:
                                      _getRestaurantsFromState(restaurantState),
                                  onRestaurantTapped: (restaurant) =>
                                      _navigateToRestaurant(
                                          restaurant.id.uniqueKey),
                                ),
                              ),

                              // Promotions Section
                              SliverToBoxAdapter(
                                child: PromotionsSection(
                                  promotions:
                                      _getMockPromotions(), // TODO: Get from actual data source
                                  onPromotionTapped: (promotion) =>
                                      _navigateToPromotion(promotion.id),
                                ),
                              ),

                              // Quick Reorder Section - Using DeliveryBloc data
                              if (_hasRecentOrders(deliveryState))
                                SliverToBoxAdapter(
                                  child: QuickReorderSection(
                                    recentOrders:
                                        _getRecentOrders(deliveryState),
                                    onReorderTap: _handleReorder,
                                    onSeeAllTap: () =>
                                        _navigateToOrderHistory(),
                                  ),
                                ),

                              // Active Deliveries Section with Uber-style List
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      RantiDesignTokens.spaceM),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Active Deliveries Y',
                                            style:
                                                RantiTextStyles.title(context),
                                          ),
                                          TextButton(
                                            onPressed: _navigateToDeliveryList,
                                            child: Text(
                                              'See All',
                                              style: TextStyle(
                                                color: RantiColors.getPrimary(
                                                    context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: RantiDesignTokens.spaceM),
                                      _buildActiveDeliveriesList(deliveryState),
                                    ],
                                  ),
                                ),
                              ),

                              // Popular Near You
                              SliverToBoxAdapter(
                                child: PopularNearYouSection(
                                  onRestaurantTap: _navigateToRestaurant,
                                  onSeeAllTap: () =>
                                      _navigateToPopularRestaurants(),
                                ),
                              ),

                              // Bottom Padding
                              const SliverPadding(
                                padding: EdgeInsets.only(bottom: 80),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          // Debug buttons for testing (only visible in debug mode)
          if (kDebugMode)
            Positioned(
              top: 50,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: _populateTestData,
                    backgroundColor:
                        RantiColors.getError(context).withValues(alpha: 0.8),
                    foregroundColor: RantiColors.getTextOnPrimary(context),
                    heroTag: "debugPopulate",
                    tooltip: 'Populate test data',
                    child: const Icon(Icons.bug_report, size: 16),
                  ),
                  const SizedBox(height: 8),
                  /*  FloatingActionButton.small(
                    onPressed: _testFavoritesFeature,
                    backgroundColor:
                        RantiColors.getPrimary(context).withValues(alpha: 0.8),
                    foregroundColor: RantiColors.getTextOnPrimary(context),
                    heroTag: "debugFavorites",
                    tooltip: 'Test Favorites & History',
                    child: const Icon(Icons.favorite, size: 16),
                  ), */
                ],
              ),
            ),

          // Driver Mode Toggle - positioned at top right
          // Navegación optimizada al Dashboard de Conductor
          UberDriverModeToggle(
            isDriverMode: false, // Start in passenger mode
            showEarnings: false, // Hide earnings for now
            onToggle: () {
              // Navegar al dashboard de conductor usando push (permite retorno)
              // La ruta automáticamente obtiene el usuario autenticado desde RantiPayAuthBloc (GetIt)
              // y usa AuthToDriverMapper para convertirlo al formato requerido
              context.push('/taxi-rides/driver-dashboard');
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildLoadingState() {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              ShimmerHeroSection(),
              ShimmerCategoryCarousel(),
              ShimmerRestaurantSection(),
              ShimmerPromotionSection(),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasRecentOrders(BaseCrudState<DeliveryEntity> state) {
    final deliveries = state.dataState.data ?? [];
    return deliveries.any((d) => d.deliveryStatus == DeliveryStatus.DELIVERED);
  }

  List<DeliveryEntity> _getRecentOrders(BaseCrudState<DeliveryEntity> state) {
    final deliveries = state.dataState.data ?? [];
    return deliveries
        .where((d) => d.deliveryStatus == DeliveryStatus.DELIVERED)
        .take(5)
        .toList();
  }

  // Navigation Methods
  Future<void> _showLocationPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: RantiColors.getSurface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RantiDesignTokens.radiusXL),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(RantiDesignTokens.spaceL),
          child: _locationService != null
              ? Container()
              /*   ? RantiLocationPickerWidget(
                  title: 'Seleccionar ubicación',
                  subtitle: 'Toca en el mapa para seleccionar una ubicación',
                  mapController: RantiMapController.createForDelivery(
                    locationService: _locationService!,
                    geocoderService: GetIt.instance<RantiGeocoderService>(),
                  ),
                  showCurrentLocationButton: true,
                  onLocationSelected: (locationData) {
                    setState(() {
                      _currentLocation = locationData['address'] as String? ??
                          'Ubicación actual';
                    });
                    Navigator.pop(context);
                  },
                ) */
              : _buildLocationPickerSheet(),
        ),
      ),
    );
  }

  Widget _buildLocationPickerSheet() {
    return Container(
      padding: const EdgeInsets.all(RantiDesignTokens.spaceL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seleccionar ubicación',
                style: RantiTextStyles.headline(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: RantiColors.getTextPrimary(context),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: RantiDesignTokens.spaceM),
          _buildLocationOption(
            icon: Icons.my_location,
            title: 'Usar ubicación actual',
            subtitle: 'Detectar automáticamente',
            onTap: () {
              setState(() => _currentLocation = 'Mi ubicación actual');
              Navigator.pop(context);
            },
          ),
          _buildLocationOption(
            icon: Icons.home,
            title: 'Casa',
            subtitle: 'Av. Principal 123',
            onTap: () {
              setState(() => _currentLocation = 'Casa');
              Navigator.pop(context);
            },
          ),
          _buildLocationOption(
            icon: Icons.work,
            title: 'Trabajo',
            subtitle: 'Torre Empresarial, Piso 10',
            onTap: () {
              setState(() => _currentLocation = 'Trabajo');
              Navigator.pop(context);
            },
          ),
          _buildLocationOption(
            icon: Icons.add_location,
            title: 'Agregar nueva dirección',
            subtitle: 'Guardar una ubicación frecuente',
            onTap: () {
              Navigator.pop(context);
              _navigateToAddAddress();
            },
          ),
          const SizedBox(height: RantiDesignTokens.spaceL),
        ],
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(RantiDesignTokens.spaceS),
        decoration: BoxDecoration(
          color: RantiColors.getPrimary(context).withAlpha(25),
          borderRadius: BorderRadius.circular(RantiDesignTokens.radiusM),
        ),
        child: Icon(
          icon,
          color: RantiColors.getPrimary(context),
          size: RantiDesignTokens.iconSizeM,
        ),
      ),
      title: Text(
        title,
        style: RantiTextStyles.bodyMedium.copyWith(
          color: RantiColors.getTextPrimary(context),
          fontWeight: RantiDesignTokens.weightMedium,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: RantiTextStyles.bodySmall.copyWith(
          color: RantiColors.getTextSecondary(context),
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateToSearch() {
    context.push('/delivery/search');
  }

  void _navigateToCategory(String categoryId) {
    if (categoryId == 'transport') {
      // Navigate to ADVANCED transport route tracking
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<LocationSearchBloc>()),
            ],
            child: const UberStyleBookingFlow(),
          ),
        ),
      );

      // LEGACY VERSION - MARK FOR DELETION
      /*
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => BlocProvider(
            create: (context) => GetIt.instance<RouteTrackingBloc>(),
            child: const UberRouteTrackingExamplePage(), // DELETE THIS
          ),
        ),
      );
      */
    } else {
      context.push('/delivery/category/$categoryId');
    }
  }

  void _navigateToRestaurant(String restaurantId) {
    context.push('/delivery/restaurant/$restaurantId');
  }

  void _navigateToAllRestaurants() {
    context.push('/delivery/restaurants');
  }

  void _navigateToPromotion(String promotionId) {
    context.push('/delivery/promotion/$promotionId');
  }

  void _handleReorder(String orderId) {
    // Handle reorder logic
    context.push('/delivery/reorder/$orderId');
  }

  void _navigateToOrderHistory() {
    context.push('/delivery/orders');
  }

  void _navigateToPopularRestaurants() {
    context.push('/delivery/popular');
  }

  void _navigateToAddAddress() {
    context.push('/delivery/address/add');
  }

  void _navigateToDeliveryList() {
    context.push('/delivery/list-with-filters');
  }

  void _navigateToAnalyticsDashboard() {
    context.push('/delivery/analytics');
  }

  Widget _buildBottomNavigation() {
    final List<NavigationItem> items = const [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      NavigationItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search',
      ),
      NavigationItem(
        icon: Icons.delivery_dining_outlined,
        activeIcon: Icons.delivery_dining,
        label: 'Orders',
      ),
      NavigationItem(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: 'Cart',
      ),
      NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    return DashboardBottomNavigation(
      items: items,
      currentIndex: 2, // Orders tab selected by default for delivery page
      onTap: (index) {
        switch (index) {
          case 0: // Home
            context.go('/dashboard');
            break;
          case 1: // Search
            _navigateToSearch();
            break;
          case 2: // Orders - Current page
            // Already on delivery page
            break;
          case 3: // Cart
            context.push('/delivery/cart');
            break;
          case 4: // Profile
            context.go('/rantipay-settings');
            break;
        }
      },
      showLabel: false,
      backgroundColor: RantiColors.getSurface(context),
      selectedColor: RantiColors.getPrimary(context),
      unselectedColor: RantiColors.getTextSecondary(context),
      enableScaleAnimation: true,
      enableHapticFeedback: true,
      showTopBorder: true,
    );
  }

  // Mock data methods - TODO: Replace with actual data from repositories
  List<RestaurantEntity> _getMockRestaurants() {
    return [
      RestaurantEntity.create(
        name: 'Burger King',
        description: 'Home of the Whopper',
        category: RestaurantCategory.burger,
        address: const DeliveryAddress(
          street: 'Av. Principal 123',
          city: 'Quito',
          district: 'Norte',
          postalCode: '170101',
          latitude: -0.1807,
          longitude: -78.4678,
        ),
        phoneNumber: '+593991234567',
        website: 'https://burgerking.ec',
        deliveryRadius: 5.0,
        minimumOrderAmount: 10.0,
        deliveryFee: 2.99,
        cuisineTypes: ['Fast Food', 'Burgers', 'American'],
        businessHours: BusinessHours.alwaysOpen(),
        tags: ['Popular', 'Fast Delivery', 'Promo'],
      ).copyWith(
          rating: 4.5, reviewCount: 342, isCurrentlyOpen: true, imageUrl: ''),
      RestaurantEntity.create(
        name: 'Pizza Hut',
        description: 'Nobody out pizzas the hut',
        category: RestaurantCategory.pizza,
        address: const DeliveryAddress(
          street: 'Av. Amazonas 456',
          city: 'Quito',
          district: 'Centro',
          postalCode: '170102',
          latitude: -0.1907,
          longitude: -78.4778,
        ),
        phoneNumber: '+593991234568',
        website: 'https://pizzahut.ec',
        deliveryRadius: 6.0,
        minimumOrderAmount: 15.0,
        deliveryFee: 0,
        cuisineTypes: ['Pizza', 'Italian', 'Pasta'],
        businessHours: BusinessHours.alwaysOpen(),
        tags: ['Free Delivery', 'Family'],
      ).copyWith(
          rating: 4.3, reviewCount: 523, isCurrentlyOpen: true, imageUrl: ''),
      RestaurantEntity.create(
        name: 'KFC',
        description: 'Finger lickin\' good',
        category: RestaurantCategory.fastFood,
        address: const DeliveryAddress(
          street: 'Mall El Jardín',
          city: 'Quito',
          district: 'Norte',
          postalCode: '170103',
          latitude: -0.1707,
          longitude: -78.4578,
        ),
        phoneNumber: '+593991234569',
        website: 'https://kfc.ec',
        deliveryRadius: 4.0,
        minimumOrderAmount: 8.0,
        deliveryFee: 1.99,
        cuisineTypes: ['Fast Food', 'Chicken', 'American'],
        businessHours: BusinessHours.alwaysOpen(),
        tags: ['Quick', 'Popular'],
      ).copyWith(
          rating: 4.2, reviewCount: 278, isCurrentlyOpen: true, imageUrl: ''),
    ];
  }

  List<PromotionEntity> _getMockPromotions() {
    return [
      PromotionEntity(
        id: '1',
        title: '30% OFF',
        description: 'En tu primera orden',
        discountPercentage: 30,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        restaurantId: '1',
        restaurantName: 'Burger King',
        imageUrl: '',
        isActive: true,
      ),
      PromotionEntity(
        id: '2',
        title: 'Envío Gratis',
        description: 'En pedidos mayores a \$20',
        discountPercentage: 0,
        discountAmount: 2.99,
        validUntil: DateTime.now().add(const Duration(days: 3)),
        restaurantId: '2',
        restaurantName: 'Pizza Hut',
        imageUrl: '',
        isActive: true,
      ),
      PromotionEntity(
        id: '3',
        title: '2x1',
        description: 'En combos familiares',
        discountPercentage: 50,
        validUntil: DateTime.now().add(const Duration(days: 1)),
        restaurantId: '3',
        restaurantName: 'KFC',
        imageUrl: '',
        isActive: true,
      ),
    ];
  }

  Widget _buildActiveDeliveriesSection(List<DeliveryEntity> deliveries) {
    final activeDeliveries = deliveries
        .where((d) =>
            d.deliveryStatus != DeliveryStatus.DELIVERED &&
            d.deliveryStatus != DeliveryStatus.CANCELLED)
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Active Deliveries X',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Public Sans',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (activeDeliveries.isEmpty)
            _buildEmptyDeliveriesMessage()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activeDeliveries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final delivery = activeDeliveries[index];
                return _buildDeliveryCard(delivery);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryEntity delivery) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RantiColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${delivery.trackingNumber ?? 'N/A'}',
                style: TextStyle(
                  color: RantiColors.getPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(delivery.deliveryStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  delivery.deliveryStatus.displayName,
                  style: TextStyle(
                    color: RantiColors.getTextOnPrimary(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            delivery.customerName,
            style: TextStyle(
              color: RantiColors.getTextPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${delivery.deliveryType.displayName} • \$${delivery.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: RantiColors.getTextSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: RantiColors.getTextPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Primera fila de acciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.add,
                label: 'New Order',
                onTap: () => _createNewDelivery(),
              ),
              _buildQuickActionButton(
                icon: Icons.search,
                label: 'Track Order',
                onTap: () => _trackOrder(),
              ),
              _buildQuickActionButton(
                icon: Icons.history,
                label: 'History',
                onTap: () => _viewHistory(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda fila de acciones - Nuevas funcionalidades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.live_tv,
                label: 'Live Track',
                onTap: () => _goToLiveTracking(),
              ),
              _buildQuickActionButton(
                icon: Icons.local_shipping,
                label: 'Orders',
                onTap: () => _goToAvailableOrders(),
              ),
              _buildQuickActionButton(
                icon: Icons.restaurant,
                label: 'Restaurants',
                onTap: () => _goToRestaurants(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: RantiColors.getSurfaceLight(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: RantiColors.getPrimary(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: RantiColors.getTextPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(List<DeliveryEntity> deliveries) {
    final recentDeliveries = deliveries
        .where((d) => d.deliveryStatus == DeliveryStatus.DELIVERED)
        .take(2)
        .toList();

    if (recentDeliveries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Deliveries',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recentDeliveries.map((delivery) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRecentDeliveryItem(delivery),
              )),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveryItem(DeliveryEntity delivery) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RantiColors.getSurfaceLight(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: RantiColors.getSuccess(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.customerName,
                  style: TextStyle(
                    color: RantiColors.getTextPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  delivery.deliveryType.displayName,
                  style: TextStyle(
                    color: RantiColors.getTextSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${delivery.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: RantiColors.getTextPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeliveriesMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping,
            size: 64,
            color: RantiColors.getTextSecondary(context).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No active deliveries',
            style: TextStyle(
              color: RantiColors.getTextPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first delivery to get started.',
            style: TextStyle(
              color: RantiColors.getTextSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.PENDING:
        return RantiColors.getWarning(context);
      case DeliveryStatus.CONFIRMED:
      case DeliveryStatus.PREPARING:
        return RantiColors.getPrimary(context);
      case DeliveryStatus.READY_FOR_PICKUP:
      case DeliveryStatus.PICKED_UP:
      case DeliveryStatus.IN_TRANSIT:
        return RantiColors.getInfo(context);
      case DeliveryStatus.DELIVERED:
        return RantiColors.getSuccess(context);
      case DeliveryStatus.CANCELLED:
      case DeliveryStatus.FAILED:
        return RantiColors.getError(context);
      case DeliveryStatus.ACTIVE:
        return RantiColors.getSuccess(context);
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: RantiColors.getTextSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Service Unavailable',
              style: TextStyle(
                color: RantiColors.getTextPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We're experiencing technical difficulties.\nPlease try again in a moment.",
              style: TextStyle(
                color: RantiColors.getTextSecondary(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: RantiColors.getPrimary(context),
                foregroundColor: RantiColors.getTextOnPrimary(context),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadInitialData();
    } else {
      // Search deliveries by customer name or tracking number
      context.read<DeliveryBloc>().filterByCustomer(query);
    }
  }

  void _onSearchSubmitted(String query) {
    // Try to search by tracking number first, then by customer name
    if (query.toUpperCase().startsWith(RegExp('[A-Z0-9]{2}'))) {
      context.read<DeliveryBloc>().searchByTrackingNumber(query);
    } else {
      context.read<DeliveryBloc>().filterByCustomer(query);
    }
  }

  void _onCategorySelected(DeliveryFilterCategory category) {
    setState(() {
      // _selectedCategory = category;
    });

    // Filter deliveries by status based on category
    if (category != DeliveryFilterCategory.all) {
      final status = _mapCategoryToDeliveryStatus(category);
      if (status != null) {
        context.read<DeliveryBloc>().loadDeliveriesByStatus(status);
      }
    } else {
      _loadInitialData();
    }
  }

  DeliveryStatus? _mapCategoryToDeliveryStatus(
      DeliveryFilterCategory category) {
    switch (category) {
      case DeliveryFilterCategory.active:
        return DeliveryStatus.IN_TRANSIT;
      case DeliveryFilterCategory.pending:
        return DeliveryStatus.PENDING;
      case DeliveryFilterCategory.completed:
        return DeliveryStatus.DELIVERED;
      case DeliveryFilterCategory.all:
        return null;
    }
  }

  // Quick action methods
  void _createNewDelivery() {
    context.push('/delivery/create');
  }

  void _trackOrder() {
    // Open tracking dialog or page
    showDialog<void>(
      context: context,
      builder: (context) => _buildTrackingDialog(),
    );
  }

  void _viewHistory() {
    context.push('/delivery/history');
  }

  // Nuevos métodos de navegación
  void _goToLiveTracking() {
    // Get the first active delivery for demo, or show selection dialog
    final deliveryBloc = context.read<DeliveryBloc>();
    final deliveries = deliveryBloc.state.dataState.data ?? <DeliveryEntity>[];
    final activeDeliveries = deliveries
        .where((d) =>
            d.deliveryStatus != DeliveryStatus.DELIVERED &&
            d.deliveryStatus != DeliveryStatus.CANCELLED)
        .toList();

    if (activeDeliveries.isNotEmpty) {
      // Navigate to live tracking of first active delivery
      // DeliveryNavigation.goToLiveTrack(
      //    context, activeDeliveries.first.id.uniqueKey);
    } else {
      // Show dialog to enter delivery ID
      _showDeliverySelectionDialog();
    }
  }

  void _goToAvailableOrders() {
    // Navigate to available orders for current driver
    // In a real app, you would get the current driver ID from auth state
    const currentDriverId = 'driver-123'; // Placeholder
    // DeliveryNavigation.goToAvailableOrders(context, currentDriverId);
  }

  void _goToRestaurants() {
    // DeliveryNavigation.goToRestaurants(context);
  }

  void _showDeliverySelectionDialog() {
    final deliveryIdController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RantiColors.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Live Tracking',
          style: TextStyle(color: RantiColors.getTextPrimary(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter delivery ID for live tracking:',
              style: TextStyle(color: RantiColors.getTextSecondary(context)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deliveryIdController,
              style: TextStyle(color: RantiColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Delivery ID',
                hintStyle:
                    TextStyle(color: RantiColors.getTextSecondary(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: RantiColors.getBorder(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: RantiColors.getBorder(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: RantiColors.getPrimary(context)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: RantiColors.getTextSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final deliveryId = deliveryIdController.text.trim();
              if (deliveryId.isNotEmpty) {
                Navigator.of(context).pop();
                //DeliveryNavigation.goToLiveTrack(context, deliveryId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RantiColors.getPrimary(context),
            ),
            child: Text(
              'Start Tracking',
              style: TextStyle(color: RantiColors.getTextOnPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingDialog() {
    final trackingController = TextEditingController();

    return AlertDialog(
      backgroundColor: RantiColors.getSurface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Track Order',
        style: TextStyle(color: RantiColors.getTextPrimary(context)),
      ),
      content: TextField(
        controller: trackingController,
        style: TextStyle(color: RantiColors.getTextPrimary(context)),
        decoration: InputDecoration(
          hintText: 'Enter tracking number',
          hintStyle: TextStyle(color: RantiColors.getTextSecondary(context)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: RantiColors.getBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: RantiColors.getBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: RantiColors.getPrimary(context)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: RantiColors.getTextSecondary(context)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final trackingNumber = trackingController.text.trim();
            if (trackingNumber.isNotEmpty) {
              context
                  .read<DeliveryBloc>()
                  .searchByTrackingNumber(trackingNumber);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: RantiColors.getPrimary(context),
          ),
          child: Text(
            'Track',
            style: TextStyle(color: RantiColors.getTextOnPrimary(context)),
          ),
        ),
      ],
    );
  }

  void _navigateToCart() {
    context.push('/delivery/cart');
  }

  /// Función para poblar la base de datos con datos de prueba
  Future<void> _populateTestData() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 Poblando base de datos con datos de prueba...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Obtener la instancia de la base de datos
      final database = GetIt.instance<RantiPayDatabase>();

      // Poblar los datos
      await LocalDataPopulator.populateDatabase(database);

      // Recargar los datos en los BLoCs
      if (mounted) {
        context.read<RestaurantBloc>().add(
              LoadFeaturedRestaurantsEvent(),
            );
        context.read<RestaurantBloc>().add(
              LoadOpenRestaurantsEvent(),
            );
        context.read<DeliveryBloc>().add(
              GetRecentDeliveriesEvent(
                pagination: Pagination(page: 1, pageSize: 50),
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ¡Datos de prueba creados exitosamente!'),
            backgroundColor: RantiColors.getSuccess(context),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on Exception catch (e, stackTrace) {
      debugPrint('❌ Error poblando datos: $e');
      debugPrint('📋 Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error poblando datos: $e'),
            backgroundColor: RantiColors.getError(context),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Helper methods for BLoC integration
  bool _isRestaurantLoading(RestaurantState state) {
    return state is RestaurantLoadingState;
  }

  bool _isRestaurantError(RestaurantState state) {
    return state is RestaurantErrorState;
  }

  String _getRestaurantErrorMessage(RestaurantState state) {
    if (state is RestaurantErrorState) {
      return state.message;
    }
    return 'Restaurant loading error';
  }

  List<RestaurantEntity> _getRestaurantsFromState(RestaurantState state) {
    if (state is RestaurantLoadedState) {
      return state.restaurants;
    }
    return _getMockRestaurants(); // Fallback to mock data
  }

  /// Construye una lista compacta de deliveries activos
  Widget _buildActiveDeliveriesList(
      BaseCrudState<DeliveryEntity> deliveryState) {
    final deliveries = deliveryState.dataState.data ?? [];
    print('🔍 UI: Processing ${deliveries.length} deliveries for display');

    // Show recent deliveries instead of just active ones
    final recentDeliveries = deliveries.take(3).toList();

    // Debug: print status of each delivery
    for (int i = 0; i < recentDeliveries.length; i++) {
      print(
          '📦 UI: Delivery ${i + 1}: ${recentDeliveries[i].trackingNumber} - Status: ${recentDeliveries[i].deliveryStatus.displayName}');
    }

    if (recentDeliveries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(RantiDesignTokens.spaceXL),
        decoration: BoxDecoration(
          color: RantiColors.getSurfaceLight(context),
          borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
          border: Border.all(
            color: RantiColors.getBorder(context),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: RantiColors.getTextSecondary(context),
            ),
            const SizedBox(height: RantiDesignTokens.spaceM),
            Text(
              'No deliveries found',
              style: RantiTextStyles.body(context).copyWith(
                fontWeight: RantiDesignTokens.weightMedium,
              ),
            ),
            const SizedBox(height: RantiDesignTokens.spaceS),
            Text(
              'Deliveries will appear here when loaded',
              style: RantiTextStyles.caption(context).copyWith(
                color: RantiColors.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentDeliveries.map((delivery) {
        return Padding(
          padding: const EdgeInsets.only(bottom: RantiDesignTokens.spaceS),
          child: DeliveryListItem(
            delivery: delivery,
            isCompact: true,
            onTap: () => _navigateToDeliveryDetail(delivery.id.uniqueKey),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToDeliveryDetail(String deliveryId) {
    context.push('/delivery/detail-uber/$deliveryId');
  }

  /// Build Uber-style Map Access Section
  Widget _buildUberMapAccessSection() {
    return Container(
      margin: const EdgeInsets.all(RantiDesignTokens.spaceM),
      padding: const EdgeInsets.all(RantiDesignTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RantiColors.getPrimary(context),
            RantiColors.getPrimary(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusXL),
        boxShadow: [
          BoxShadow(
            color: RantiColors.getPrimary(context).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Map Icon and Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(RantiDesignTokens.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(RantiDesignTokens.radiusL),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    color: RantiColors.getTextOnPrimary(context),
                    size: RantiDesignTokens.iconSizeL,
                  ),
                ),
                const SizedBox(height: RantiDesignTokens.spaceM),
                Text(
                  'Quick Delivery',
                  style: RantiTextStyles.headline(context).copyWith(
                    color: RantiColors.getTextOnPrimary(context),
                    fontWeight: RantiDesignTokens.weightBold,
                  ),
                ),
                const SizedBox(height: RantiDesignTokens.spaceS),
                Text(
                  'Get anything delivered\nfast and easy',
                  style: RantiTextStyles.body(context).copyWith(
                    color: RantiColors.getTextOnPrimary(context)
                        .withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          Column(
            children: [
              GestureDetector(
                onTap: _openUberStyleMap,
                child: Container(
                  padding: const EdgeInsets.all(RantiDesignTokens.spaceL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(RantiDesignTokens.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: RantiColors.getPrimary(context),
                    size: RantiDesignTokens.iconSizeM,
                  ),
                ),
              ),
              const SizedBox(height: RantiDesignTokens.spaceS),
              Text(
                'Open Map',
                style: RantiTextStyles.caption(context).copyWith(
                  color: RantiColors.getTextOnPrimary(context)
                      .withValues(alpha: 0.8),
                  fontWeight: RantiDesignTokens.weightMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Open Uber-style Delivery Map
  void _openUberStyleMap() {
    // Navigate to dedicated map page using GoRouter push
    //context.push(RoutePaths.deliveryUberMap);
  }

  /// Build Delivery Domains Selection Section
  /// Allows users to choose between Food, Package, Taxi, and Express delivery types
  Widget _buildDeliveryDomainsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RantiDesignTokens.spaceL,
        vertical: RantiDesignTokens.spaceM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'What would you like to deliver? y',
            style: RantiTextStyles.title(context).copyWith(
              fontWeight: FontWeight.bold,
              color: RantiColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: RantiDesignTokens.spaceS),
          Text(
            'Choose your delivery service',
            style: RantiTextStyles.body(context).copyWith(
              color: RantiColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: RantiDesignTokens.spaceL),

          // Domain Cards Grid - 2x3 layout con Driver Dashboard
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: RantiDesignTokens.spaceM,
            crossAxisSpacing: RantiDesignTokens.spaceM,
            childAspectRatio: 1.2,
            children: [
              RantiCardIconDetail(
                  title: 'Food Delivery',
                  description: 'Restaurants & meals',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  onTap: () => _navigateToFoodDelivery()),
              RantiCardIconDetail(
                  title: 'Package Delivery',
                  description: 'Documents & packages',
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                  onTap: () => _navigateToPackageDelivery()),
              RantiCardIconDetail(
                  title: 'Taxi Rides',
                  description: 'Passenger transport',
                  icon: Icons.local_taxi,
                  color: Colors.green,
                  onTap: () => _navigateToTaxiRides()),
              RantiCardIconDetail(
                  title: 'Driver Dashboard',
                  description: 'Conductor mode',
                  icon: Icons.drive_eta,
                  color: const Color(0xFF1E88E5), // Uber blue
                  onTap: () => _navigateToDriverDashboard()),
              RantiCardIconDetail(
                  title: 'Express',
                  description: 'Fast delivery',
                  icon: Icons.flash_on,
                  color: Colors.purple,
                  onTap: () => _createNewDelivery()),
            ],
          ),
        ],
      ),
    );
  }

  /// Navigation methods for delivery domains
  void _navigateToFoodDelivery() {
    context.push('/food-delivery');
  }

  void _navigateToPackageDelivery() {
    context.push('/package-delivery');
  }

  void _navigateToTaxiRides() {
    // Navigate to the integrated taxi dashboard (passenger mode)
    context.push('/taxi-rides', extra: {'driverMode': false});
  }

  /// Navegar al Dashboard de Conductor (EnhancedUberDriverDashboardPage)
  ///
  /// Integración completa con:
  /// - Obtención automática del usuario desde RantiPayAuthBloc (GetIt)
  /// - Conversión automática con AuthToDriverMapper
  /// - Sin necesidad de pasar datos manualmente
  void _navigateToDriverDashboard() {
    // Usar push para permitir retorno a delivery home
    // La ruta '/taxi-rides/driver-dashboard' está registrada en integrated_taxi_routes.dart
    // y automáticamente obtiene el usuario autenticado + lo convierte a DriverUser
    context.push('/taxi-rides/driver-dashboard');
  }

  /// Test method for favorites and search history functionality
  /*  void _testFavoritesFeature() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeliveryLocationTestPage(),
      ),
    );
  } */
}
