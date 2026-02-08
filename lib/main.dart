import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ZaghrosSparePartsApp());
}

class ZaghrosSparePartsApp extends StatelessWidget {
  const ZaghrosSparePartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFE74C3C);

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'زاگرس قطعات خودرو',
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: baseTheme.copyWith(
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
        ),
        textTheme: baseTheme.textTheme.copyWith(
          headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
          headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const DemoShell(),
    );
  }
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  final List<SparePart> _inventory = List.of(DemoData.parts);
  final List<PartRequest> _requests = List.of(DemoData.requests);
  final Set<int> _favoritePartIds = <int>{};

  int _tabIndex = 0;
  String _inventoryCategory = 'همه';
  String _inventorySearch = '';

  void _switchToInventory({String? category, String? query}) {
    setState(() {
      _tabIndex = 1;
      _inventoryCategory = category ?? _inventoryCategory;
      _inventorySearch = query ?? _inventorySearch;
    });
  }

  void _switchToRequest() {
    setState(() => _tabIndex = 2);
  }

  void _toggleFavorite(int partId) {
    setState(() {
      if (_favoritePartIds.contains(partId)) {
        _favoritePartIds.remove(partId);
      } else {
        _favoritePartIds.add(partId);
      }
    });
  }

  void _addPartRequest(NewPartRequestData data) {
    final request = PartRequest(
      id: 'RQ-${DateTime.now().millisecondsSinceEpoch}',
      customerName: data.customerName,
      phone: data.phone,
      city: data.city,
      vehicle: data.vehicle,
      partName: data.partName,
      quantity: data.quantity,
      urgency: data.urgency,
      notes: data.notes,
      vin: data.vin,
      createdAt: DateTime.now(),
      status: RequestStatus.pending,
    );

    setState(() {
      _requests.insert(0, request);
      _tabIndex = 3;
    });
  }

  void _updateRequestStatus(String requestId, RequestStatus status) {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) {
      return;
    }

    setState(() {
      _requests[index] = _requests[index].copyWith(status: status);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeLandingPage(
        inventory: _inventory,
        requests: _requests,
        favoritePartIds: _favoritePartIds,
        onCategoryTap: (category) => _switchToInventory(category: category),
        onSearchSubmitted: (query) => _switchToInventory(query: query),
        onRequestTap: _switchToRequest,
        onToggleFavorite: _toggleFavorite,
      ),
      InventoryPage(
        inventory: _inventory,
        selectedCategory: _inventoryCategory,
        searchQuery: _inventorySearch,
        favoritePartIds: _favoritePartIds,
        onCategoryChanged: (category) {
          setState(() => _inventoryCategory = category);
        },
        onSearchChanged: (query) {
          setState(() => _inventorySearch = query);
        },
        onToggleFavorite: _toggleFavorite,
      ),
      RequestPartPage(
        recentRequests: _requests,
        onSubmit: _addPartRequest,
      ),
      ManagementPage(
        inventory: _inventory,
        requests: _requests,
        onRequestStatusChanged: _updateRequestStatus,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          IndexedStack(index: _tabIndex, children: pages),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A101828),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _tabIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0x1AE74C3C),
            onDestinationSelected: (index) {
              setState(() => _tabIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'خانه',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'انبار',
              ),
              NavigationDestination(
                icon: Icon(Icons.request_page_outlined),
                selectedIcon: Icon(Icons.request_page_rounded),
                label: 'درخواست',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_customize_outlined),
                selectedIcon: Icon(Icons.dashboard_customize_rounded),
                label: 'مدیریت',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeLandingPage extends StatefulWidget {
  const HomeLandingPage({
    required this.inventory,
    required this.requests,
    required this.favoritePartIds,
    required this.onCategoryTap,
    required this.onSearchSubmitted,
    required this.onRequestTap,
    required this.onToggleFavorite,
    super.key,
  });

  final List<SparePart> inventory;
  final List<PartRequest> requests;
  final Set<int> favoritePartIds;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onRequestTap;
  final ValueChanged<int> onToggleFavorite;

  @override
  State<HomeLandingPage> createState() => _HomeLandingPageState();
}

class _HomeLandingPageState extends State<HomeLandingPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const categories = DemoData.categories;
    final featured = widget.inventory.where((part) => part.featured).toList();
    final totalStock =
        widget.inventory.fold<int>(0, (sum, part) => sum + part.stock);
    final pendingRequests = widget.requests
        .where((request) => request.status == RequestStatus.pending)
        .length;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE74C3C), Color(0xFFFF8A3C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.car_repair_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'هاب قطعات زاگرس',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              'بازار حرفه‌ای قطعات یدکی خودرو',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قطعه موردنیاز را در چند ثانیه پیدا کنید',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'موجودی باکیفیت، مشاهده زنده انبار و ارسال فوری درخواست برای قطعات کمیاب.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF475467),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: widget.onSearchSubmitted,
                          decoration: InputDecoration(
                            hintText:
                                'جستجو بر اساس نام قطعه، برند، کد کالا یا مدل خودرو',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => widget.onSearchSubmitted(
                                _searchController.text.trim(),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: '${widget.inventory.length}+ ',
                                label: 'کالاهای فعال',
                                color: const Color(0xFFE74C3C),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                value: '$totalStock',
                                label: 'تعداد موجودی',
                                color: const Color(0xFF0EA5E9),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                value: '$pendingRequests',
                                label: 'درخواست‌های باز',
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'دسته‌بندی‌های برتر',
                    actionLabel: 'مشاهده انبار',
                    onTap: () => widget.onCategoryTap('همه'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 114,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return InkWell(
                          onTap: () => widget.onCategoryTap(category.name),
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            width: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  colorWithOpacity(category.color, 0.18),
                                  Colors.white,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              border: Border.all(
                                color: colorWithOpacity(category.color, 0.35),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(category.icon, color: category.color),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  _SectionHeader(
                    title: 'پیشنهادهای ویژه',
                    actionLabel: 'مشاهده همه',
                    onTap: () => widget.onCategoryTap('همه'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 258,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final part = featured[index];
                        return SizedBox(
                          width: 205,
                          child: _DealCard(
                            part: part,
                            isFavorite:
                                widget.favoritePartIds.contains(part.id),
                            onFavorite: () => widget.onToggleFavorite(part.id),
                            onView: () => widget.onSearchSubmitted(part.name),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  _GlassCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF111827), Color(0xFF1D2939)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'به قطعه دقیق نیاز دارید؟',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'فرم درخواست را با VIN و مشخصات خودرو ثبت کنید تا قیمت و موجودی را سریع دریافت کنید.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFD0D5DD),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: widget.onRequestTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.playlist_add_check_rounded),
                            label: const Text('باز کردن فرم درخواست'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({
    required this.inventory,
    required this.selectedCategory,
    required this.searchQuery,
    required this.favoritePartIds,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onToggleFavorite,
    super.key,
  });

  final List<SparePart> inventory;
  final String selectedCategory;
  final String searchQuery;
  final Set<int> favoritePartIds;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onToggleFavorite;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  SortMode _sortMode = SortMode.popular;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(covariant InventoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = <String>{'همه'}
      ..addAll(widget.inventory.map((part) => part.category));

    final visibleParts = widget.inventory.where((part) {
      final categoryMatch = widget.selectedCategory == 'همه' ||
          part.category == widget.selectedCategory;
      final query = widget.searchQuery.trim().toLowerCase();
      final queryMatch = query.isEmpty ||
          [part.name, part.brand, part.sku, part.compatibility]
              .join(' ')
              .toLowerCase()
              .contains(query);
      return categoryMatch && queryMatch;
    }).toList();

    visibleParts.sort((a, b) {
      switch (_sortMode) {
        case SortMode.priceLowToHigh:
          return a.price.compareTo(b.price);
        case SortMode.priceHighToLow:
          return b.price.compareTo(a.price);
        case SortMode.stock:
          return b.stock.compareTo(a.stock);
        case SortMode.popular:
          return b.rating.compareTo(a.rating);
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ویترین انبار', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'موجودی زنده، فیلتر سریع و قیمت‌گذاری مناسب برای ارائه حرفه‌ای به مشتری.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'جستجو بر اساس قطعه، کد کالا یا سازگاری خودرو...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories.elementAt(index);
                  final selected = category == widget.selectedCategory;
                  return FilterChip(
                    selected: selected,
                    onSelected: (_) => widget.onCategoryChanged(category),
                    label: Text(category),
                    avatar: selected
                        ? const Icon(Icons.check_circle_rounded, size: 18)
                        : null,
                    selectedColor: const Color(0x1AE74C3C),
                    checkmarkColor: const Color(0xFFE74C3C),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${toPersianDigits(visibleParts.length)} کالا یافت شد',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                PopupMenuButton<SortMode>(
                  initialValue: _sortMode,
                  onSelected: (value) => setState(() => _sortMode = value),
                  itemBuilder: (context) => SortMode.values
                      .map(
                        (mode) => PopupMenuItem(
                          value: mode,
                          child: Text(mode.label),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_vert_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(_sortMode.label),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width >= 1180
                      ? 4
                      : width >= 860
                          ? 3
                          : width >= 600
                              ? 2
                              : 1;

                  if (visibleParts.isEmpty) {
                    return const Center(
                      child: _EmptyState(
                        title: 'قطعه‌ای پیدا نشد',
                        subtitle:
                            'کلیدواژه گسترده‌تر وارد کنید یا فیلتر دسته‌بندی را تغییر دهید.',
                        icon: Icons.inventory_2_outlined,
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: visibleParts.length,
                    itemBuilder: (context, index) {
                      final part = visibleParts[index];
                      return _InventoryCard(
                        part: part,
                        isFavorite: widget.favoritePartIds.contains(part.id),
                        onFavoriteTap: () => widget.onToggleFavorite(part.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestPartPage extends StatefulWidget {
  const RequestPartPage({
    required this.recentRequests,
    required this.onSubmit,
    super.key,
  });

  final List<PartRequest> recentRequests;
  final ValueChanged<NewPartRequestData> onSubmit;

  @override
  State<RequestPartPage> createState() => _RequestPartPageState();
}

class _RequestPartPageState extends State<RequestPartPage> {
  final _formKey = GlobalKey<FormState>();

  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _partNameController = TextEditingController();
  final _vinController = TextEditingController();
  final _notesController = TextEditingController();

  int _quantity = 1;
  UrgencyLevel _urgency = UrgencyLevel.normal;

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _vehicleController.dispose();
    _partNameController.dispose();
    _vinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = NewPartRequestData(
      customerName: _customerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      vehicle: _vehicleController.text.trim(),
      partName: _partNameController.text.trim(),
      quantity: _quantity,
      urgency: _urgency,
      notes: _notesController.text.trim(),
      vin: _vinController.text.trim(),
    );

    widget.onSubmit(request);

    _formKey.currentState!.reset();
    _customerNameController.clear();
    _phoneController.clear();
    _cityController.clear();
    _vehicleController.clear();
    _partNameController.clear();
    _vinController.clear();
    _notesController.clear();

    setState(() {
      _urgency = UrgencyLevel.normal;
      _quantity = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('درخواست ثبت شد و در صف مدیریت قرار گرفت.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = widget.recentRequests.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('فرم درخواست قطعه', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'نیاز مشتری را با اطلاعات خودرو و اولویت زمانی به‌صورت دقیق ثبت کنید.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475467),
                ),
              ),
              const SizedBox(height: 16),
              _GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildField(
                      controller: _customerNameController,
                      label: 'نام مشتری',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _phoneController,
                      label: 'شماره تماس',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _cityController,
                      label: 'شهر / محل تحویل',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _vehicleController,
                      label: 'خودرو (برند، مدل، سال)',
                      icon: Icons.directions_car_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _partNameController,
                      label: 'قطعه موردنیاز',
                      icon: Icons.settings_suggest_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _vinController,
                      label: 'VIN / کد OEM (اختیاری)',
                      icon: Icons.qr_code_scanner_rounded,
                      required: false,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<UrgencyLevel>(
                            value: _urgency,
                            decoration: const InputDecoration(
                              labelText: 'اولویت',
                              prefixIcon: Icon(Icons.priority_high_rounded),
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: UrgencyLevel.values
                                .map(
                                  (level) => DropdownMenuItem(
                                    value: level,
                                    child: Text(level.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() => _urgency = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'تعداد',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: _quantity > 1
                                      ? () => setState(() => _quantity -= 1)
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  toPersianDigits(_quantity),
                                  style: theme.textTheme.titleMedium,
                                ),
                                IconButton(
                                  onPressed: _quantity < 99
                                      ? () => setState(() => _quantity += 1)
                                      : null,
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'توضیحات تکمیلی (اختیاری)',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.edit_note_rounded),
                        filled: true,
                        fillColor: Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitRequest,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('ارسال درخواست به مدیریت'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('درخواست‌های اخیر', style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              if (recent.isEmpty)
                const _EmptyState(
                  title: 'درخواستی ثبت نشده است',
                  subtitle:
                      'درخواست‌های ثبت‌شده در این بخش نمایش داده می‌شوند.',
                  icon: Icons.request_page_outlined,
                )
              else
                ...recent.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecentRequestCard(request: request),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'تکمیل این فیلد الزامی است';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}

class ManagementPage extends StatefulWidget {
  const ManagementPage({
    required this.inventory,
    required this.requests,
    required this.onRequestStatusChanged,
    super.key,
  });

  final List<SparePart> inventory;
  final List<PartRequest> requests;
  final void Function(String requestId, RequestStatus status)
      onRequestStatusChanged;

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  RequestStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowStockItems =
        widget.inventory.where((part) => part.stock <= 4).toList();
    final visibleRequests = _statusFilter == null
        ? widget.requests
        : widget.requests
            .where((request) => request.status == _statusFilter)
            .toList();

    final pending = widget.requests
        .where((request) => request.status == RequestStatus.pending)
        .length;
    final quoteReady = widget.requests
        .where((request) => request.status == RequestStatus.quoteReady)
        .length;
    final delivered = widget.requests
        .where((request) => request.status == RequestStatus.delivered)
        .length;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('داشبورد مدیریت', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'پیگیری درخواست‌ها، ریسک کمبود موجودی و روند تحویل سفارش‌ها.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricCard(
                  label: 'کل کالاها',
                  value: '${widget.inventory.length}',
                  icon: Icons.category_rounded,
                  color: const Color(0xFF0EA5E9),
                ),
                _MetricCard(
                  label: 'در انتظار',
                  value: '$pending',
                  icon: Icons.hourglass_bottom_rounded,
                  color: const Color(0xFFF59E0B),
                ),
                _MetricCard(
                  label: 'پیش‌فاکتور آماده',
                  value: '$quoteReady',
                  icon: Icons.request_quote_rounded,
                  color: const Color(0xFFE74C3C),
                ),
                _MetricCard(
                  label: 'تحویل‌شده',
                  value: '$delivered',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF22C55E),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('فرآیند درخواست‌ها',
                          style: theme.textTheme.titleLarge),
                      const Spacer(),
                      PopupMenuButton<RequestStatus?>(
                        initialValue: _statusFilter,
                        onSelected: (value) {
                          setState(() => _statusFilter = value);
                        },
                        itemBuilder: (context) {
                          final items = <PopupMenuEntry<RequestStatus?>>[
                            const PopupMenuItem<RequestStatus?>(
                              value: null,
                              child: Text('همه وضعیت‌ها'),
                            ),
                          ];

                          for (final status in RequestStatus.values) {
                            items.add(
                              PopupMenuItem<RequestStatus?>(
                                value: status,
                                child: Text(status.label),
                              ),
                            );
                          }

                          return items;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _statusFilter?.label ?? 'همه وضعیت‌ها',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (visibleRequests.isEmpty)
                    const _EmptyState(
                      title: 'در این فیلتر درخواستی وجود ندارد',
                      subtitle:
                          'فیلتر وضعیت را تغییر دهید یا درخواست جدید ثبت کنید.',
                      icon: Icons.filter_alt_off_rounded,
                    )
                  else
                    ...visibleRequests.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ManagementRequestCard(
                          request: request,
                          onChangeStatus: (status) =>
                              widget.onRequestStatusChanged(
                            request.id,
                            status,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('هشدار کمبود موجودی', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  if (lowStockItems.isEmpty)
                    const _EmptyState(
                      title: 'وضعیت موجودی مناسب است',
                      subtitle: 'هیچ کالایی زیر حد آستانه نیست.',
                      icon: Icons.verified_rounded,
                    )
                  else
                    ...lowStockItems.map(
                      (part) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                            ),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0x1AE74C3C),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFE74C3C),
                              ),
                            ),
                            title: Text(part.name),
                            subtitle: Text(
                                '${toPersianDigits(part.stock)} عدد باقی‌مانده • ${part.warehouse}'),
                            trailing: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('شارژ موجودی'),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.part,
    required this.isFavorite,
    required this.onFavorite,
    required this.onView,
  });

  final SparePart part;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final discount =
        ((part.oldPrice - part.price) / part.oldPrice * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 290;
        final imageHeight = compact ? 58.0 : 88.0;
        final spacing = compact ? 6.0 : 10.0;

        return _GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x1AE74C3C),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${toPersianDigits(discount)}٪ تخفیف',
                        style: const TextStyle(
                          color: Color(0xFFE74C3C),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: compact ? VisualDensity.compact : null,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: compact ? 30 : 40,
                        height: compact ? 30 : 40,
                      ),
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border,
                        color: isFavorite ? const Color(0xFFE74C3C) : null,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorWithOpacity(part.categoryColor, 0.20),
                        Colors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.precision_manufacturing_rounded,
                    size: compact ? 30 : 38,
                    color: part.categoryColor,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  part.name,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${part.brand} • ${part.compatibility}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xFF667085)),
                  ),
                ],
                const Spacer(),
                if (!compact)
                  Text(
                    formatPrice(part.oldPrice),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: const Color(0xFF98A2B3),
                        ),
                  ),
                Text(
                  formatPrice(part.price),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFE74C3C),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: compact ? 4 : 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: compact
                        ? OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )
                        : null,
                    child: Text(compact ? 'جزئیات' : 'مشاهده جزئیات'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.part,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final SparePart part;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: part.stock > 5
                        ? const Color(0x1A22C55E)
                        : const Color(0x1AF59E0B),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    part.stock > 5 ? 'موجود' : 'رو به اتمام',
                    style: TextStyle(
                      color: part.stock > 5
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB45309),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onFavoriteTap,
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                    color: isFavorite
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colorWithOpacity(part.categoryColor, 0.25),
                    Colors.white,
                  ],
                ),
              ),
              child: Icon(
                Icons.build_circle_outlined,
                color: part.categoryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              part.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${part.brand} • کد ${part.sku}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              part.compatibility,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF475467),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.star_rounded,
                    color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 4),
                Text(toPersianDigits(part.rating.toStringAsFixed(1))),
                const Spacer(),
                Text(
                  formatPrice(part.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE74C3C),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRequestCard extends StatelessWidget {
  const _RecentRequestCard({required this.request});

  final PartRequest request;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: request.urgency.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(request.urgency.icon,
                color: request.urgency.foregroundColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.partName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${request.customerName} • ${request.vehicle}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: request.status.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              request.status.label,
              style: TextStyle(
                color: request.status.foregroundColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementRequestCard extends StatelessWidget {
  const _ManagementRequestCard({
    required this.request,
    required this.onChangeStatus,
  });

  final PartRequest request;
  final ValueChanged<RequestStatus> onChangeStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.partName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<RequestStatus>(
                  initialValue: request.status,
                  onSelected: onChangeStatus,
                  itemBuilder: (context) => RequestStatus.values
                      .map(
                        (status) => PopupMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: request.status.backgroundColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      request.status.label,
                      style: TextStyle(
                        color: request.status.foregroundColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _detailChip(Icons.person_outline, request.customerName),
                _detailChip(Icons.directions_car_outlined, request.vehicle),
                _detailChip(
                  Icons.numbers_rounded,
                  'تعداد ${toPersianDigits(request.quantity)}',
                ),
                _detailChip(
                    Icons.schedule_rounded, formatDate(request.createdAt)),
                _detailChip(Icons.local_shipping_outlined, request.city),
              ],
            ),
            if (request.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF475467),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF667085)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: child,
            ),
            child: Text(
              toPersianDigits(value),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667085),
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorWithOpacity(color, 0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toPersianDigits(value),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0x1AE74C3C),
            child: Icon(icon, color: const Color(0xFFE74C3C)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667085),
                ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final wrappedChild =
        padding == null ? child : Padding(padding: padding!, child: child);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? colorWithOpacity(Colors.white, 0.92) : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorWithOpacity(Colors.white, 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: wrappedChild,
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3F4F8), Color(0xFFEDEFF5)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -80,
            child: _ambientBlob(const Color(0x1AE74C3C), 260),
          ),
          Positioned(
            top: 120,
            left: -90,
            child: _ambientBlob(const Color(0x1A0EA5E9), 220),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: _ambientBlob(const Color(0x1AF59E0B), 260),
          ),
        ],
      ),
    );
  }

  Widget _ambientBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class NewPartRequestData {
  const NewPartRequestData({
    required this.customerName,
    required this.phone,
    required this.city,
    required this.vehicle,
    required this.partName,
    required this.quantity,
    required this.urgency,
    required this.notes,
    required this.vin,
  });

  final String customerName;
  final String phone;
  final String city;
  final String vehicle;
  final String partName;
  final int quantity;
  final UrgencyLevel urgency;
  final String notes;
  final String vin;
}

class SparePart {
  const SparePart({
    required this.id,
    required this.name,
    required this.brand,
    required this.sku,
    required this.category,
    required this.compatibility,
    required this.price,
    required this.oldPrice,
    required this.stock,
    required this.rating,
    required this.warehouse,
    required this.featured,
  });

  final int id;
  final String name;
  final String brand;
  final String sku;
  final String category;
  final String compatibility;
  final double price;
  final double oldPrice;
  final int stock;
  final double rating;
  final String warehouse;
  final bool featured;

  Color get categoryColor {
    switch (category) {
      case 'موتور':
        return const Color(0xFFE74C3C);
      case 'ترمز':
        return const Color(0xFFB45309);
      case 'برقی':
        return const Color(0xFF0EA5E9);
      case 'بدنه':
        return const Color(0xFF8B5CF6);
      case 'تعلیق':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF475467);
    }
  }
}

class PartRequest {
  const PartRequest({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.city,
    required this.vehicle,
    required this.partName,
    required this.quantity,
    required this.urgency,
    required this.notes,
    required this.vin,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String customerName;
  final String phone;
  final String city;
  final String vehicle;
  final String partName;
  final int quantity;
  final UrgencyLevel urgency;
  final String notes;
  final String vin;
  final DateTime createdAt;
  final RequestStatus status;

  PartRequest copyWith({
    RequestStatus? status,
  }) {
    return PartRequest(
      id: id,
      customerName: customerName,
      phone: phone,
      city: city,
      vehicle: vehicle,
      partName: partName,
      quantity: quantity,
      urgency: urgency,
      notes: notes,
      vin: vin,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

class PartCategory {
  const PartCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

enum UrgencyLevel {
  normal,
  high,
  critical,
}

enum RequestStatus {
  pending,
  quoteReady,
  processing,
  delivered,
  canceled,
}

enum SortMode {
  popular,
  priceLowToHigh,
  priceHighToLow,
  stock,
}

extension SortModeX on SortMode {
  String get label {
    switch (this) {
      case SortMode.popular:
        return 'بالاترین امتیاز';
      case SortMode.priceLowToHigh:
        return 'قیمت: کم به زیاد';
      case SortMode.priceHighToLow:
        return 'قیمت: زیاد به کم';
      case SortMode.stock:
        return 'بیشترین موجودی';
    }
  }
}

extension UrgencyLevelX on UrgencyLevel {
  String get label {
    switch (this) {
      case UrgencyLevel.normal:
        return 'عادی';
      case UrgencyLevel.high:
        return 'زیاد';
      case UrgencyLevel.critical:
        return 'فوری';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case UrgencyLevel.normal:
        return const Color(0x1A22C55E);
      case UrgencyLevel.high:
        return const Color(0x1AF59E0B);
      case UrgencyLevel.critical:
        return const Color(0x1AE74C3C);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case UrgencyLevel.normal:
        return const Color(0xFF15803D);
      case UrgencyLevel.high:
        return const Color(0xFFB45309);
      case UrgencyLevel.critical:
        return const Color(0xFFB42318);
    }
  }

  IconData get icon {
    switch (this) {
      case UrgencyLevel.normal:
        return Icons.check_circle_outline_rounded;
      case UrgencyLevel.high:
        return Icons.error_outline_rounded;
      case UrgencyLevel.critical:
        return Icons.warning_amber_rounded;
    }
  }
}

extension RequestStatusX on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'در انتظار';
      case RequestStatus.quoteReady:
        return 'پیش‌فاکتور آماده';
      case RequestStatus.processing:
        return 'در حال پردازش';
      case RequestStatus.delivered:
        return 'تحویل‌شده';
      case RequestStatus.canceled:
        return 'لغو شده';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0x1AF59E0B);
      case RequestStatus.quoteReady:
        return const Color(0x1A0EA5E9);
      case RequestStatus.processing:
        return const Color(0x1A8B5CF6);
      case RequestStatus.delivered:
        return const Color(0x1A22C55E);
      case RequestStatus.canceled:
        return const Color(0x1AE74C3C);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case RequestStatus.pending:
        return const Color(0xFFB45309);
      case RequestStatus.quoteReady:
        return const Color(0xFF0369A1);
      case RequestStatus.processing:
        return const Color(0xFF6D28D9);
      case RequestStatus.delivered:
        return const Color(0xFF15803D);
      case RequestStatus.canceled:
        return const Color(0xFFB42318);
    }
  }
}

class DemoData {
  static const categories = <PartCategory>[
    PartCategory(
      name: 'موتور',
      icon: Icons.settings,
      color: Color(0xFFE74C3C),
    ),
    PartCategory(
      name: 'ترمز',
      icon: Icons.album_outlined,
      color: Color(0xFFB45309),
    ),
    PartCategory(
      name: 'برقی',
      icon: Icons.electrical_services_rounded,
      color: Color(0xFF0EA5E9),
    ),
    PartCategory(
      name: 'بدنه',
      icon: Icons.car_rental_rounded,
      color: Color(0xFF8B5CF6),
    ),
    PartCategory(
      name: 'تعلیق',
      icon: Icons.waves_rounded,
      color: Color(0xFF0F766E),
    ),
  ];

  static const parts = <SparePart>[
    SparePart(
      id: 1,
      name: 'ست شمع بوش پلاتینیوم',
      brand: 'Bosch',
      sku: 'ENG-4481-BS',
      category: 'موتور',
      compatibility: 'سازگار با Toyota Corolla 2018-2022',
      price: 84,
      oldPrice: 109,
      stock: 14,
      rating: 4.8,
      warehouse: 'انبار مرکزی اربیل',
      featured: true,
    ),
    SparePart(
      id: 2,
      name: 'کیت لنت ترمز پرفورمنس',
      brand: 'Brembo',
      sku: 'BRK-2190-BR',
      category: 'ترمز',
      compatibility: 'سازگار با Hyundai Tucson 2019-2023',
      price: 142,
      oldPrice: 169,
      stock: 8,
      rating: 4.7,
      warehouse: 'هاب سلیمانیه',
      featured: true,
    ),
    SparePart(
      id: 3,
      name: 'باتری سنگین AGM دوازده ولت',
      brand: 'Varta',
      sku: 'ELE-5320-VT',
      category: 'برقی',
      compatibility: 'سازگار با Nissan Patrol 2016-2021',
      price: 188,
      oldPrice: 219,
      stock: 5,
      rating: 4.9,
      warehouse: 'انبار مرکزی اربیل',
      featured: true,
    ),
    SparePart(
      id: 4,
      name: 'دیاق سپر جلو',
      brand: 'TYG',
      sku: 'BDY-9021-TY',
      category: 'بدنه',
      compatibility: 'سازگار با Kia Sportage 2017-2021',
      price: 126,
      oldPrice: 152,
      stock: 3,
      rating: 4.4,
      warehouse: 'انبار دهوک',
      featured: false,
    ),
    SparePart(
      id: 5,
      name: 'جفت کمک‌فنر عقب',
      brand: 'Monroe',
      sku: 'SUS-3310-MN',
      category: 'تعلیق',
      compatibility: 'سازگار با Mitsubishi L200 2015-2022',
      price: 176,
      oldPrice: 210,
      stock: 9,
      rating: 4.6,
      warehouse: 'انبار مرکزی اربیل',
      featured: true,
    ),
    SparePart(
      id: 6,
      name: 'بسته فیلتر روغن اصلی',
      brand: 'Toyota',
      sku: 'ENG-0157-TY',
      category: 'موتور',
      compatibility: 'سازگار با Toyota Camry 2016-2023',
      price: 35,
      oldPrice: 44,
      stock: 26,
      rating: 4.5,
      warehouse: 'شعبه شریک کرکوک',
      featured: false,
    ),
    SparePart(
      id: 7,
      name: 'چراغ جلو ماتریکس LED',
      brand: 'Valeo',
      sku: 'ELE-8822-VA',
      category: 'برقی',
      compatibility: 'سازگار با Volkswagen Passat 2020-2024',
      price: 244,
      oldPrice: 279,
      stock: 4,
      rating: 4.7,
      warehouse: 'هاب سلیمانیه',
      featured: true,
    ),
    SparePart(
      id: 8,
      name: 'دیسک ترمز سرامیکی جلو',
      brand: 'TRW',
      sku: 'BRK-6621-TR',
      category: 'ترمز',
      compatibility: 'سازگار با Mazda CX-5 2018-2023',
      price: 120,
      oldPrice: 147,
      stock: 12,
      rating: 4.4,
      warehouse: 'انبار مرکزی اربیل',
      featured: false,
    ),
    SparePart(
      id: 9,
      name: 'شلنگ فشار توربوشارژر',
      brand: 'Mahle',
      sku: 'ENG-7720-MH',
      category: 'موتور',
      compatibility: 'سازگار با Ford Ranger 2019-2024',
      price: 98,
      oldPrice: 126,
      stock: 7,
      rating: 4.3,
      warehouse: 'انبار دهوک',
      featured: false,
    ),
    SparePart(
      id: 10,
      name: 'مجموعه سر جعبه فرمان',
      brand: 'Lemforder',
      sku: 'SUS-1144-LM',
      category: 'تعلیق',
      compatibility: 'سازگار با BMW X3 2017-2022',
      price: 159,
      oldPrice: 189,
      stock: 6,
      rating: 4.8,
      warehouse: 'هاب سلیمانیه',
      featured: false,
    ),
    SparePart(
      id: 11,
      name: 'مجموعه موتور آینه بغل',
      brand: 'Depo',
      sku: 'BDY-4808-DP',
      category: 'بدنه',
      compatibility: 'سازگار با Honda Civic 2019-2023',
      price: 92,
      oldPrice: 111,
      stock: 11,
      rating: 4.2,
      warehouse: 'شعبه شریک کرکوک',
      featured: false,
    ),
    SparePart(
      id: 12,
      name: 'ماژول رگولاتور دینام',
      brand: 'Denso',
      sku: 'ELE-5904-DE',
      category: 'برقی',
      compatibility: 'سازگار با Suzuki Vitara 2018-2022',
      price: 138,
      oldPrice: 166,
      stock: 2,
      rating: 4.5,
      warehouse: 'انبار مرکزی اربیل',
      featured: false,
    ),
  ];

  static final requests = <PartRequest>[
    PartRequest(
      id: 'RQ-1001',
      customerName: 'علی کریم',
      phone: '+9647501122334',
      city: 'اربیل',
      vehicle: 'Toyota Land Cruiser 2021',
      partName: 'ست بلبرینگ دیفرانسیل عقب',
      quantity: 1,
      urgency: UrgencyLevel.high,
      notes: 'نیاز به قطعه اصلی یا معادل باکیفیت دارد.',
      vin: 'JTMHV09J6M5423312',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: RequestStatus.pending,
    ),
    PartRequest(
      id: 'RQ-1002',
      customerName: 'سارا محمود',
      phone: '+9647717788990',
      city: 'سلیمانیه',
      vehicle: 'Kia Sorento 2019',
      partName: 'براکت سنسور رادار جلو',
      quantity: 2,
      urgency: UrgencyLevel.critical,
      notes: 'مشتری تحویل کمتر از ۴۸ ساعت می‌خواهد.',
      vin: 'KNAKU813BK5219077',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: RequestStatus.quoteReady,
    ),
    PartRequest(
      id: 'RQ-1003',
      customerName: 'گاراژ هاوال',
      phone: '+9647516677442',
      city: 'دهوک',
      vehicle: 'Hyundai Elantra 2020',
      partName: 'کمپرسور کامل کولر',
      quantity: 3,
      urgency: UrgencyLevel.normal,
      notes: 'نیاز به جزئیات دقیق گارانتی دارد.',
      vin: 'KMHD84LF7LU912345',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 7)),
      status: RequestStatus.processing,
    ),
    PartRequest(
      id: 'RQ-1004',
      customerName: 'بارز سرویس ناوگان',
      phone: '+9647709876543',
      city: 'کرکوک',
      vehicle: 'Mitsubishi Fuso 2018',
      partName: 'بسته نازل انژکتور سوخت',
      quantity: 6,
      urgency: UrgencyLevel.high,
      notes: 'خرید عمده است، لطفا قیمت همکاری ارسال شود.',
      vin: 'JL6AAN1S9JK004455',
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
      status: RequestStatus.delivered,
    ),
  ];
}

Color colorWithOpacity(Color color, double opacity) {
  final clampedOpacity = opacity.clamp(0.0, 1.0).toDouble();
  // ignore: deprecated_member_use
  final colorValue = color.value;
  return Color.fromRGBO(
    (colorValue >> 16) & 0xFF,
    (colorValue >> 8) & 0xFF,
    colorValue & 0xFF,
    clampedOpacity,
  );
}

String formatDate(DateTime date) {
  const months = [
    'ژانویه',
    'فوریه',
    'مارس',
    'آوریل',
    'مه',
    'ژوئن',
    'ژوئیه',
    'اوت',
    'سپتامبر',
    'اکتبر',
    'نوامبر',
    'دسامبر',
  ];

  return '${toPersianDigits(date.day)} ${months[date.month - 1]} ${toPersianDigits(date.year)}';
}

String formatPrice(double value) {
  final formatted = value.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  return '${toPersianDigits(formatted)} تومان';
}

String toPersianDigits(Object value) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  var result = value.toString();
  for (var i = 0; i < englishDigits.length; i++) {
    result = result.replaceAll(englishDigits[i], persianDigits[i]);
  }
  return result;
}
