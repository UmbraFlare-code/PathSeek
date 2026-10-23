import 'package:flutter/material.dart';

import 'empty_view.dart';
import 'error_view.dart';
import 'loading_indicator.dart';
import 'page_header.dart';

/// Shared scroll surface for operational catalogs, with naturally sized cards.
class CatalogLayout extends StatelessWidget {
  const CatalogLayout({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actions,
    required this.isLoading,
    required this.loadingMessage,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
    required this.totalCount,
    this.toolbar,
    this.errorMessage,
    this.onRetry,
  });

  final String title, description, loadingMessage, emptyMessage;
  final IconData icon;
  final List<Widget> actions;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? toolbar;
  final int itemCount, totalCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
      final width = constraints.maxWidth - gutter * 2;
      final columns = MediaQuery.textScalerOf(context).scale(16) > 22
          ? 1
          : (width / 360).floor().clamp(1, 3);
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(gutter),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: title,
                    description: description,
                    icon: icon,
                    actions: actions,
                  ),
                  if (toolbar != null) ...[
                    const SizedBox(height: 24),
                    toolbar!,
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        '$itemCount de $totalCount registros',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingIndicator(message: loadingMessage),
            )
          else if (errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorView(message: errorMessage!, onRetry: onRetry),
            )
          else if (itemCount == 0)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(message: emptyMessage, icon: icon),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, gutter),
              sliver: SliverList.builder(
                itemCount: (itemCount / columns).ceil(),
                itemBuilder: (context, row) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var column = 0; column < columns; column++) ...[
                        if (column > 0) const SizedBox(width: 16),
                        Expanded(
                          child: row * columns + column < itemCount
                              ? itemBuilder(context, row * columns + column)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
