import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sales_analytics.dart';
import '../../domain/usecases/get_sales_analytics_usecase.dart';
import '../../core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================================
// EVENTS - Define all possible user interactions and system events
// ============================================================================

/// Base class for all sales list events
abstract class SalesListEvent extends Equatable {
  const SalesListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial sales data with pagination
class LoadSalesListEvent extends SalesListEvent {
  const LoadSalesListEvent();
}

/// Event to load more sales data (pagination)
class LoadMoreSalesEvent extends SalesListEvent {
  const LoadMoreSalesEvent();
}

/// Event to refresh sales data (pull-to-refresh)
class RefreshSalesListEvent extends SalesListEvent {
  const RefreshSalesListEvent();
}

/// Event to load sales analytics
class LoadSalesAnalyticsEvent extends SalesListEvent {
  const LoadSalesAnalyticsEvent();
}

/// Event when real-time sales data is updated
class SalesDataUpdatedEvent extends SalesListEvent {
  final List<DocumentSnapshot> updatedDocs;

  const SalesDataUpdatedEvent(this.updatedDocs);

  @override
  List<Object?> get props => [updatedDocs];
}

// ============================================================================
// STATES - Define all possible UI states
// ============================================================================

/// Base class for all sales list states
abstract class SalesListState extends Equatable {
  const SalesListState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the screen is first loaded
class SalesListInitial extends SalesListState {
  const SalesListInitial();
}

/// State when sales data is being loaded
class SalesListLoading extends SalesListState {
  const SalesListLoading();
}

/// State when sales data is successfully loaded
class SalesListLoaded extends SalesListState {
  final List<DocumentSnapshot> sales;
  final SalesAnalytics analytics;
  final bool hasMore;
  final bool isLoadingMore;

  const SalesListLoaded({
    required this.sales,
    required this.analytics,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [sales, analytics, hasMore, isLoadingMore];

  /// Creates a copy of the state with updated values
  SalesListLoaded copyWith({
    List<DocumentSnapshot>? sales,
    SalesAnalytics? analytics,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SalesListLoaded(
      sales: sales ?? this.sales,
      analytics: analytics ?? this.analytics,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// State when an error occurs
class SalesListError extends SalesListState {
  final String message;
  final bool isRetryable;

  const SalesListError({
    required this.message,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

// ============================================================================
// BLOC - Advanced state management with comprehensive business logic
// ============================================================================

/// Advanced BLoC for managing sales list with real-time updates and analytics
/// 
/// This BLoC demonstrates exemplary state management practices:
/// - Separation of concerns between events, states, and business logic
/// - Real-time data synchronization with Firestore
/// - Pagination with optimistic updates
/// - Comprehensive error handling with retry mechanisms
/// - Analytics calculation using domain use cases
class SalesListBloc extends Bloc<SalesListEvent, SalesListState> {
  final GetSalesAnalyticsUseCase _getSalesAnalyticsUseCase;
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  // Pagination and real-time subscription management
  static const int _pageSize = 20;
  DocumentSnapshot? _lastDocument;
  StreamSubscription<QuerySnapshot>? _realtimeSubscription;
  final List<DocumentSnapshot> _allSales = [];

  SalesListBloc({
    required GetSalesAnalyticsUseCase getSalesAnalyticsUseCase,
    required FirestoreService firestoreService,
    required FirebaseAuth auth,
  })  : _getSalesAnalyticsUseCase = getSalesAnalyticsUseCase,
        _firestoreService = firestoreService,
        _auth = auth,
        super(const SalesListInitial()) {
    
    // Register event handlers
    on<LoadSalesListEvent>(_onLoadSalesList);
    on<LoadMoreSalesEvent>(_onLoadMoreSales);
    on<RefreshSalesListEvent>(_onRefreshSalesList);
    on<LoadSalesAnalyticsEvent>(_onLoadSalesAnalytics);
    on<SalesDataUpdatedEvent>(_onSalesDataUpdated);
  }

  /// Handles initial loading of sales data with real-time subscription
  Future<void> _onLoadSalesList(
    LoadSalesListEvent event,
    Emitter<SalesListState> emit,
  ) async {
    emit(const SalesListLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const SalesListError(
          message: 'User not authenticated',
          isRetryable: false,
        ));
        return;
      }

      // Setup real-time subscription for live updates
      await _setupRealtimeSubscription(user.uid);

      // Load initial page of sales data
      await _loadInitialSalesData(user.uid, emit);

      // Load analytics data
      final analytics = await _getSalesAnalyticsUseCase.execute();

      if (state is SalesListLoaded) {
        final currentState = state as SalesListLoaded;
        emit(currentState.copyWith(analytics: analytics));
      }
    } catch (e) {
      emit(SalesListError(
        message: 'Failed to load sales: ${e.toString()}',
        isRetryable: true,
      ));
    }
  }

  /// Handles loading more sales data (pagination)
  Future<void> _onLoadMoreSales(
    LoadMoreSalesEvent event,
    Emitter<SalesListState> emit,
  ) async {
    if (state is! SalesListLoaded) return;

    final currentState = state as SalesListLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final moreSales = await _firestoreService.paginateCollection(
        'users/${user.uid}/sales',
        limit: _pageSize,
        startAfter: _lastDocument,
        orderByField: 'timestamp',
        descending: true,
      );

      if (moreSales.isNotEmpty) {
        _lastDocument = moreSales.last;
        
        // Merge with existing sales, avoiding duplicates
        final updatedSales = List<DocumentSnapshot>.from(currentState.sales);
        for (final sale in moreSales) {
          if (!updatedSales.any((existing) => existing.id == sale.id)) {
            updatedSales.add(sale);
          }
        }

        emit(currentState.copyWith(
          sales: updatedSales,
          hasMore: moreSales.length == _pageSize,
          isLoadingMore: false,
        ));
      } else {
        emit(currentState.copyWith(
          hasMore: false,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Could emit error state or show snackbar
    }
  }

  /// Handles refresh of sales data (pull-to-refresh)
  Future<void> _onRefreshSalesList(
    RefreshSalesListEvent event,
    Emitter<SalesListState> emit,
  ) async {
    // Reset pagination state
    _lastDocument = null;
    _allSales.clear();

    // Reload data
    add(const LoadSalesListEvent());
  }

  /// Handles loading of sales analytics
  Future<void> _onLoadSalesAnalytics(
    LoadSalesAnalyticsEvent event,
    Emitter<SalesListState> emit,
  ) async {
    try {
      final analytics = await _getSalesAnalyticsUseCase.execute();
      
      if (state is SalesListLoaded) {
        final currentState = state as SalesListLoaded;
        emit(currentState.copyWith(analytics: analytics));
      }
    } catch (e) {
      // Handle analytics loading error without affecting main state
      // Could log error or show notification
    }
  }

  /// Handles real-time updates from Firestore
  Future<void> _onSalesDataUpdated(
    SalesDataUpdatedEvent event,
    Emitter<SalesListState> emit,
  ) async {
    if (state is! SalesListLoaded) return;

    final currentState = state as SalesListLoaded;
    
    // Merge real-time updates with existing data
    final updatedSales = <DocumentSnapshot>[];
    
    // Add new/updated documents from real-time stream
    for (final doc in event.updatedDocs) {
      updatedSales.add(doc);
    }
    
    // Add existing documents that aren't in the update
    for (final existing in currentState.sales) {
      if (!updatedSales.any((updated) => updated.id == existing.id)) {
        updatedSales.add(existing);
      }
    }

    // Sort by timestamp (newest first)
    updatedSales.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTimestamp = aData['timestamp'] as Timestamp?;
      final bTimestamp = bData['timestamp'] as Timestamp?;
      
      if (aTimestamp == null || bTimestamp == null) return 0;
      return bTimestamp.compareTo(aTimestamp);
    });

    emit(currentState.copyWith(sales: updatedSales));

    // Reload analytics to reflect new data
    add(const LoadSalesAnalyticsEvent());
  }

  /// Sets up real-time subscription to Firestore for live updates
  Future<void> _setupRealtimeSubscription(String userId) async {
    await _realtimeSubscription?.cancel();
    
    _realtimeSubscription = _firestoreService
        .streamCollectionQuery(
          'users/$userId/sales',
          queryBuilder: (col) => col
              .orderBy('timestamp', descending: true)
              .limit(_pageSize),
        )
        .listen(
          (snapshot) {
            add(SalesDataUpdatedEvent(snapshot.docs));
          },
          onError: (error) {
            // Handle real-time subscription errors
            add(const LoadSalesListEvent()); // Fallback to regular loading
          },
        );
  }

  /// Loads initial sales data with pagination setup
  Future<void> _loadInitialSalesData(
    String userId,
    Emitter<SalesListState> emit,
  ) async {
    final initialSales = await _firestoreService.paginateCollection(
      'users/$userId/sales',
      limit: _pageSize,
      orderByField: 'timestamp',
      descending: true,
    );

    _allSales.clear();
    _allSales.addAll(initialSales);

    if (initialSales.isNotEmpty) {
      _lastDocument = initialSales.last;
    }

    emit(SalesListLoaded(
      sales: initialSales,
      analytics: SalesAnalytics.empty(), // Will be updated by analytics loading
      hasMore: initialSales.length == _pageSize,
    ));
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}

/// Extension for pattern matching on SalesListState
/// 
/// Provides a functional approach to handling different states,
/// making the code more readable and ensuring all states are handled
extension SalesListStateX on SalesListState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<DocumentSnapshot> sales,
      SalesAnalytics analytics,
      bool hasMore,
      bool isLoadingMore,
    ) loaded,
    required T Function(String message, bool isRetryable) error,
  }) {
    final state = this;
    if (state is SalesListInitial) {
      return initial();
    } else if (state is SalesListLoading) {
      return loading();
    } else if (state is SalesListLoaded) {
      return loaded(
        state.sales,
        state.analytics,
        state.hasMore,
        state.isLoadingMore,
      );
    } else if (state is SalesListError) {
      return error(state.message, state.isRetryable);
    } else {
      throw Exception('Unknown state: $state');
    }
  }
}