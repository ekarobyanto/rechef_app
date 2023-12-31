import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/styles.dart';
import '../../../../core/repository/storage_repository.dart';
import '../../../../shared/circle_net_pic.dart';
import '../../../../shared/error_screen.dart';
import '../../../../shared/loading_screen.dart';
import '../../../../shared/recipe_card.dart';
import '../../../recipe/domain/recipe/recipe.dart';
import '../../blocs/account/account_cubit.dart';
import '../../blocs/account/account_state.dart';
import '../../repository/user_repository_impl.dart';
import 'widgets/account_header.dart';
import 'widgets/body_header.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountCubit(
        RepositoryProvider.of<UserRepositoryImpl>(context),
        RepositoryProvider.of<StorageRepository>(context),
      )..loadAccount(),
      child: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Scaffold(
              body: LoadingScreen(),
            );
          } else if (state is AccountLoadError) {
            return Scaffold(
              body: ErrorScreen(
                error: state.error,
                onRetry: () {
                  context.read<AccountCubit>().loadAccount();
                },
              ),
            );
          } else if (state is AccountLoaded) {
            return AccountCustomScroll(
              data: state.data,
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class AccountCustomScroll extends StatefulWidget {
  const AccountCustomScroll({super.key, required this.data});

  final data;

  @override
  State<AccountCustomScroll> createState() => _AccountCustomScrollState();
}

class _AccountCustomScrollState extends State<AccountCustomScroll> {
  late ScrollController _scrollController;
  double _scrollControllerOffset = 0;

  _scrollListener() {
    setState(() {
      _scrollControllerOffset = _scrollController.offset;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            toolbarHeight: 50,
            expandedHeight: 250,
            backgroundColor: Styles.color.primary,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 75,
                ),
                child: AccountHeader(
                  accountData: widget.data['user'],
                ),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                setState(() {
                  _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                });
              },
              child: Opacity(
                opacity: _scrollControllerOffset < 160 ? 0 : 1,
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: CircleNetPic(
                        img: widget.data['user']['image'],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.data['user']['username'],
                      style: Styles.font.bsm,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(
                            Icons.settings,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 10),
                          Text('Pengaturan'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 10),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ];
                },
              )
            ],
          ),
          SliverPersistentHeader(
            delegate: BodyHeader(),
            pinned: true,
          ),
          widget.data['recipes']['results'].length == 0
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Saat ini anda belum membuat resep',
                      style: Styles.font.bsm.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: widget.data['recipes']['results'].length as int,
                    (context, index) {
                      return RecipeCard(
                        recipe: Recipe.fromJson(
                          widget.data['recipes']['results'][index],
                        ),
                      );
                    },
                  ),
                )
        ],
      ),
    );
  }
}
