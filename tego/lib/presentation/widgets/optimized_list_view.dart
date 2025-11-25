import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Highly optimized ListView for large datasets
/// 
/// Implements advanced performance optimizations:
/// - Viewport-based rendering for memory efficiency
/// - Item recycling to reduce widget creation
/// - Lazy loading with intelligent prefetching
/// - Smooth scrolling with physics tuning
class OptimizedListView extends StatefulWidget {
  final List<DocumentSnapshot> items;
  final Widget Function(BuildContext, DocumentSnapshot, int) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final EdgeInsets? padding;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.padding,
  });

  @override
  State<OptimizedListView> createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  late ScrollController _scrollController;
  static const double _loadMoreThreshold = 200.0; // Pixels from bottom

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Intelligent load more triggering
    if (!widget.isLoading && 
        widget.hasMore && 
        widget.onLoadMore != null &&
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - _loadMoreThreshold) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      // Performance optimizations
      physics: const BouncingScrollPhysics(), // Smooth scrolling
      cacheExtent: 500, // Cache items outside viewport
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Load more indicator
        if (index >= widget.items.length) {
          return _buildLoadMoreIndicator();
        }

        // Regular item with performance optimizations
        return RepaintBoundary(
          key: ValueKey(widget.items[index].id), // Stable keys for recycling
          child: widget.itemBuilder(context, widget.items[index], index),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: widget.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox.shrink(),
    );
  }
}