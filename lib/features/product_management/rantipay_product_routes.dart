/// RantiPay Products: Definición de rutas para marketplace de productos
library;

///
/// Requisitos:
/// - User Level: Variable según la ruta
/// - Permisos: Basados en funcionalidad de productos
///
/// Este archivo define todas las rutas del módulo de productos del marketplace

class RantiPayProductRoutes {
  RantiPayProductRoutes._();

  // ====== CONFIGURACIÓN BASE ======
  
  /// Ruta base del módulo de productos
  static const String base = '/rantipay-products';

  // ====== DASHBOARD & HOME ======
  
  /// Página principal del marketplace de productos
  static const String home = '$base/home';
  
  /// Dashboard de productos con analytics
  static const String dashboard = '$base/dashboard';
  
  /// Página de inicio rápido/onboarding
  static const String quickStart = '$base/quick-start';

  // ====== GESTIÓN DE PRODUCTOS ======
  
  /// Lista principal de productos (vista TikTok/Lista)
  static const String products = '$base/products';
  
  /// Lista de productos con filtros
  static const String productsList = '$products/list';
  
  /// Vista TikTok de productos
  static const String productsTikTok = '$products/tiktok';
  
  /// Detalle de producto específico
  static const String productDetail = '$products/:productId';
  
  /// Crear nuevo producto
  static const String productCreate = '$products/create';
  
  /// Editar producto existente
  static const String productEdit = '$products/:productId/edit';
  
  /// Duplicar producto
  static const String productDuplicate = '$products/:productId/duplicate';
  
  /// Vista previa del producto
  static const String productPreview = '$products/:productId/preview';

  // ====== BÚSQUEDA Y FILTROS ======
  
  /// Página de búsqueda avanzada
  static const String search = '$base/search';
  
  /// Resultados de búsqueda
  static const String searchResults = '$search/results';
  
  /// Filtros guardados
  static const String savedFilters = '$base/filters';
  
  /// Productos favoritos
  static const String favorites = '$base/favorites';

  // ====== CATEGORÍAS ======
  
  /// Gestión de categorías
  static const String categories = '$base/categories';
  
  /// Lista de categorías
  static const String categoriesList = '$categories/list';
  
  /// Detalle de categoría
  static const String categoryDetail = '$categories/:categoryId';
  
  /// Productos por categoría
  static const String categoryProducts = '$categories/:categoryId/products';
  
  /// Crear categoría
  static const String categoryCreate = '$categories/create';
  
  /// Editar categoría
  static const String categoryEdit = '$categories/:categoryId/edit';

  // ====== GESTIÓN DE INVENTARIO ======
  
  /// Dashboard de inventario
  static const String inventory = '$base/inventory';
  
  /// Stock bajo
  static const String lowStock = '$inventory/low-stock';
  
  /// Movimientos de inventario
  static const String stockMovements = '$inventory/movements';
  
  /// Ajuste de inventario
  static const String stockAdjustment = '$inventory/adjustment';
  
  /// Reservas de stock
  static const String stockReservations = '$inventory/reservations';

  // ====== ANALYTICS Y REPORTES ======
  
  /// Dashboard de analytics
  static const String analytics = '$base/analytics';
  
  /// Productos más vendidos
  static const String topSelling = '$analytics/top-selling';
  
  /// Reportes de productos
  static const String reports = '$base/reports';
  
  /// Métricas de performance
  static const String performance = '$analytics/performance';

  // ====== CONFIGURACIÓN ======
  
  /// Configuración del módulo
  static const String settings = '$base/settings';
  
  /// Configuración de precios
  static const String pricingSettings = '$settings/pricing';
  
  /// Configuración de impuestos
  static const String taxSettings = '$settings/taxes';
  
  /// Configuración de envío
  static const String shippingSettings = '$settings/shipping';

  // ====== BULK OPERATIONS ======
  
  /// Operaciones masivas
  static const String bulkOperations = '$base/bulk';
  
  /// Importar productos
  static const String bulkImport = '$bulkOperations/import';
  
  /// Exportar productos
  static const String bulkExport = '$bulkOperations/export';
  
  /// Actualización masiva
  static const String bulkUpdate = '$bulkOperations/update';

  // ====== HELPER METHODS PARA RUTAS DINÁMICAS ======

  /// Genera ruta de detalle de producto
  static String productDetailRoute(String productId) => '$products/$productId';

  /// Genera ruta de edición de producto
  static String productEditRoute(String productId) => '$products/$productId/edit';

  /// Genera ruta de duplicación de producto
  static String productDuplicateRoute(String productId) => '$products/$productId/duplicate';

  /// Genera ruta de vista previa de producto
  static String productPreviewRoute(String productId) => '$products/$productId/preview';

  /// Genera ruta de detalle de categoría
  static String categoryDetailRoute(String categoryId) => '$categories/$categoryId';

  /// Genera ruta de productos por categoría
  static String categoryProductsRoute(String categoryId) => '$categories/$categoryId/products';

  /// Genera ruta de edición de categoría
  static String categoryEditRoute(String categoryId) => '$categories/$categoryId/edit';

  // ====== HELPER METHODS PARA QUERY PARAMETERS ======

  /// Lista de productos con filtros
  static String productsListWithFilters({
    String? category,
    String? vendor,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String>[];
    
    if (category != null) params.add('category=${Uri.encodeComponent(category)}');
    if (vendor != null) params.add('vendor=${Uri.encodeComponent(vendor)}');
    if (minPrice != null) params.add('minPrice=$minPrice');
    if (maxPrice != null) params.add('maxPrice=$maxPrice');
    if (isActive != null) params.add('active=$isActive');
    if (status != null) params.add('status=${Uri.encodeComponent(status)}');
    if (sortBy != null) params.add('sortBy=${Uri.encodeComponent(sortBy)}');
    if (sortOrder != null) params.add('order=${Uri.encodeComponent(sortOrder)}');
    
    return params.isEmpty ? productsList : '$productsList?${params.join('&')}';
  }

  /// Búsqueda con query
  static String searchWithQuery(String query, {
    String? category,
    double? minPrice,
    double? maxPrice,
  }) {
    final params = <String>['q=${Uri.encodeComponent(query)}'];
    
    if (category != null) params.add('category=${Uri.encodeComponent(category)}');
    if (minPrice != null) params.add('minPrice=$minPrice');
    if (maxPrice != null) params.add('maxPrice=$maxPrice');
    
    return '$searchResults?${params.join('&')}';
  }

  /// Analytics con filtros de fecha
  static String analyticsWithDateRange({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
  }) {
    final params = <String>[];
    
    if (startDate != null) {
      params.add('start=${startDate.toIso8601String().split('T')[0]}');
    }
    if (endDate != null) {
      params.add('end=${endDate.toIso8601String().split('T')[0]}');
    }
    if (granularity != null) {
      params.add('granularity=${Uri.encodeComponent(granularity)}');
    }
    
    return params.isEmpty ? analytics : '$analytics?${params.join('&')}';
  }

  // ====== VALIDACIÓN DE RUTAS ======

  /// Verifica si es una ruta de productos
  static bool isProductRoute(String route) => route.startsWith(products);

  /// Verifica si es una ruta de categorías
  static bool isCategoryRoute(String route) => route.startsWith(categories);

  /// Verifica si es una ruta de inventario
  static bool isInventoryRoute(String route) => route.startsWith(inventory);

  /// Verifica si es una ruta de analytics
  static bool isAnalyticsRoute(String route) => route.startsWith(analytics);

  /// Verifica si es una ruta de configuración
  static bool isSettingsRoute(String route) => route.startsWith(settings);

  /// Extrae ID de producto de la ruta
  static String? extractProductId(String route) {
    final regex = RegExp(r'/products/([^/]+)');
    final match = regex.firstMatch(route);
    return match?.group(1);
  }

  /// Extrae ID de categoría de la ruta
  static String? extractCategoryId(String route) {
    final regex = RegExp(r'/categories/([^/]+)');
    final match = regex.firstMatch(route);
    return match?.group(1);
  }

  // ====== PERMISOS Y NIVELES DE USUARIO ======

  /// Mapeo de rutas a permisos requeridos
  static const Map<String, List<String>> routePermissions = {
    // Lectura básica
    home: ['product.read'],
    products: ['product.read'],
    productsList: ['product.read'],
    productDetail: ['product.read'],
    search: ['product.read'],
    categories: ['category.read'],
    
    // Escritura de productos
    productCreate: ['product.create'],
    productEdit: ['product.update'],
    productDuplicate: ['product.create'],
    
    // Gestión de categorías
    categoryCreate: ['category.create'],
    categoryEdit: ['category.update'],
    
    // Inventario
    inventory: ['inventory.read'],
    stockAdjustment: ['inventory.update'],
    stockReservations: ['inventory.manage'],
    
    // Analytics (nivel superior)
    analytics: ['analytics.read'],
    reports: ['reports.read'],
    
    // Configuración (admin)
    settings: ['settings.update'],
    pricingSettings: ['pricing.manage'],
    taxSettings: ['tax.manage'],
    
    // Operaciones masivas (admin)
    bulkOperations: ['bulk.manage'],
    bulkImport: ['bulk.import'],
    bulkExport: ['bulk.export'],
  };

  /// Mapeo de rutas a niveles de usuario mínimos requeridos
  static const Map<String, int> routeUserLevels = {
    // Nivel 1: Básico (solo lectura)
    home: 1,
    products: 1,
    productsList: 1,
    productDetail: 1,
    search: 1,
    categories: 1,
    
    // Nivel 2: Operador (CRUD básico)
    productCreate: 2,
    productEdit: 2,
    productDuplicate: 2,
    inventory: 2,
    
    // Nivel 3: Supervisor (gestión avanzada)
    categoryCreate: 3,
    categoryEdit: 3,
    analytics: 3,
    reports: 3,
    stockAdjustment: 3,
    
    // Nivel 4: Admin (configuración)
    settings: 4,
    pricingSettings: 4,
    taxSettings: 4,
    bulkOperations: 4,
    
    // Nivel 5: Super Admin (operaciones críticas)
    bulkImport: 5,
    bulkExport: 5,
  };

  // ====== RUTAS PUBLICAS (SIN AUTENTICACIÓN) ======

  /// Rutas que no requieren autenticación
  static const Set<String> publicRoutes = {
    // Solo el detalle público de productos para compartir
    // El resto requiere autenticación
  };

  // ====== MÉTODOS DE UTILIDAD ======

  /// Obtiene todas las rutas del módulo
  static List<String> getAllRoutes() {
    return [
      home, dashboard, quickStart,
      products, productsList, productsTikTok, productDetail, productCreate, productEdit,
      search, searchResults, savedFilters, favorites,
      categories, categoriesList, categoryDetail, categoryProducts, categoryCreate, categoryEdit,
      inventory, lowStock, stockMovements, stockAdjustment, stockReservations,
      analytics, topSelling, reports, performance,
      settings, pricingSettings, taxSettings, shippingSettings,
      bulkOperations, bulkImport, bulkExport, bulkUpdate,
    ];
  }

  /// Obtiene rutas por categoría
  static Map<String, List<String>> getRoutesByCategory() {
    return {
      'main': [home, dashboard, quickStart],
      'products': [products, productsList, productsTikTok, productDetail, productCreate, productEdit],
      'search': [search, searchResults, savedFilters, favorites],
      'categories': [categories, categoriesList, categoryDetail, categoryProducts, categoryCreate, categoryEdit],
      'inventory': [inventory, lowStock, stockMovements, stockAdjustment, stockReservations],
      'analytics': [analytics, topSelling, reports, performance],
      'settings': [settings, pricingSettings, taxSettings, shippingSettings],
      'bulk': [bulkOperations, bulkImport, bulkExport, bulkUpdate],
    };
  }
}