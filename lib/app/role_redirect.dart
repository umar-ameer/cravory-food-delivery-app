import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/user_model.dart';

void redirectUserByRole(BuildContext context, UserModel user) {
  if (user.role == 'admin') {
    context.go('/admin-dashboard');
    return;
  }

  if (user.role == 'delivery') {
    context.go('/delivery-dashboard');
    return;
  }

  context.go('/');
}