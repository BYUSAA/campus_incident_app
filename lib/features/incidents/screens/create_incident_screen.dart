import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../widgets/incident_form.dart';

class CreateIncidentScreen extends StatelessWidget {
  const CreateIncidentScreen({super.key});

  // The bottom navigation opens this screen with `go`, which replaces the
  // stack, so there may be nothing to pop. Fall back to the home screen.
  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android's system back gesture would otherwise close the app when this
      // screen is the only one on the stack.
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRouter.home);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report an Incident'),
          leading: BackButton(onPressed: () => _leave(context)),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: IncidentForm(
              onSuccess: () => _leave(context),
            ),
          ),
        ),
      ),
    );
  }
}
