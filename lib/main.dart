import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/app_data_source.dart';
import 'data/repositories/app_repository_impl.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/product/product_event.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_event.dart';
import 'presentation/blocs/wishlist/wishlist_bloc.dart';
import 'presentation/blocs/wishlist/wishlist_event.dart';
import 'presentation/blocs/checkout/checkout_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';
import 'presentation/blocs/address/address_cubit.dart';

import 'firebase_options.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  final dataSource = AppDataSource();
  final repository = AppRepositoryImpl(dataSource: dataSource);

  runApp(FunFillersApp(repository: repository));
}

class FunFillersApp extends StatelessWidget {
  final AppRepositoryImpl repository;

  const FunFillersApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppRepositoryImpl>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(repository: repository)..add(CheckAuthStatus()),
          ),
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(repository: repository)..add(LoadProducts()),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(repository: repository)..add(LoadCart()),
          ),
          BlocProvider<WishlistBloc>(
            create: (context) => WishlistBloc(repository: repository)..add(LoadWishlist()),
          ),
          BlocProvider<CheckoutBloc>(
            create: (context) => CheckoutBloc(),
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(repository: repository),
          ),
          BlocProvider<AddressCubit>(
            create: (context) => AddressCubit(repository: repository)..loadAddresses(),
          ),
        ],
        child: MaterialApp.router(
          title: 'FunFillers Toys',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
