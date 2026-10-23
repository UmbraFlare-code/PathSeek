import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'page_header.dart';

/// One application shell, predictable back navigation and a readable form width.
class FormPageLayout extends StatelessWidget {
  const FormPageLayout({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.backPath,
    required this.child,
  });
  final String title, description, backPath;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = constraints.maxWidth < 600 ? 16.0 : 32.0;
      return SingleChildScrollView(
        padding: EdgeInsets.all(gutter),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go(backPath),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al listado'),
                  ),
                ),
                const SizedBox(height: 16),
                PageHeader(title: title, description: description, icon: icon),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(padding: EdgeInsets.all(gutter), child: child),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
