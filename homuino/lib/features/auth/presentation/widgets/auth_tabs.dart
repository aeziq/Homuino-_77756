import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:homuino/features/auth/presentation/widgets/sign_up_form.dart';

class AuthTabs extends ConsumerStatefulWidget {
  const AuthTabs({Key? key}) : super(key: key);

  @override
  _AuthTabsState createState() => _AuthTabsState();
}

class _AuthTabsState extends ConsumerState<AuthTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: Colors.blue,
              ),
            ),
            tabs: const [
              Tab(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              SignUpForm(),
              SignInForm(),
            ],
          ),
        ),
      ],
    );
  }
}