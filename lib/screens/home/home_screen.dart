import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_wallet/providers/card_provider.dart';
import 'package:loyalty_card_wallet/providers/settings_provider.dart';
import 'package:loyalty_card_wallet/screens/cards/add_card_screen.dart';
import 'package:loyalty_card_wallet/screens/cards/card_detail_screen.dart';
import 'package:loyalty_card_wallet/screens/settings/settings_screen.dart';
import 'package:loyalty_card_wallet/widgets/card_grid_item.dart';
import 'package:loyalty_card_wallet/widgets/card_list_item.dart';
import 'package:loyalty_card_wallet/widgets/empty_state.dart';
import 'package:loyalty_card_wallet/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _sortOptions = ['name', 'date', 'expiry'];
  String _currentSortOption = 'name';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardProvider>(context, listen: false).loadCards();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by'),
                tileColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              ...List.generate(_sortOptions.length, (index) {
                final option = _sortOptions[index];
                String title;
                IconData icon;
                
                switch (option) {
                  case 'name':
                    title = 'Name';
                    icon = Icons.sort_by_alpha;
                    break;
                  case 'date':
                    title = 'Date Added';
                    icon = Icons.calendar_today;
                    break;
                  case 'expiry':
                    title = 'Expiry Date';
                    icon = Icons.timer;
                    break;
                  default:
                    title = option;
                    icon = Icons.sort;
                }
                
                return ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  trailing: _currentSortOption == option
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _currentSortOption = option;
                    });
                    Provider.of<CardProvider>(context, listen: false)
                        .setSortBy(option);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everyday Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          if (index == 1) {
            Provider.of<CardProvider>(context, listen: false).toggleShowFavoritesOnly();
          } else if (_currentIndex == 1 && Provider.of<CardProvider>(context, listen: false).showFavoritesOnly) {
            Provider.of<CardProvider>(context, listen: false).toggleShowFavoritesOnly();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'All Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 2) {
      return const NotificationsTab();
    }
    
    return Consumer2<CardProvider, SettingsProvider>(
      builder: (context, cardProvider, settingsProvider, _) {
        if (cardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final cards = cardProvider.cards;
        
        if (cards.isEmpty) {
          return EmptyState(
            icon: Icons.credit_card,
            title: 'No Cards Yet',
            message: 'Add your first loyalty card to get started',
            buttonText: 'Add Card',
            onButtonPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCardScreen()),
              );
            },
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentIndex == 0 ? 'Your Cards' : 'Favorites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(
                      settingsProvider.cardViewMode == 'grid'
                          ? Icons.view_list
                          : Icons.grid_view,
                    ),
                    onPressed: () {
                      settingsProvider.setCardViewMode(
                        settingsProvider.cardViewMode == 'grid' ? 'list' : 'grid',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: settingsProvider.cardViewMode == 'grid'
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return CardGridItem(
                            card: card,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CardDetailScreen(cardId: card.id),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: cards.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return CardListItem(
                            card: card,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CardDetailScreen(cardId: card.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, _) {
        final expiringCards = cardProvider.getExpiringCards();
        
        if (expiringCards.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'No Notifications',
            message: 'You don\'t have any notifications at the moment',
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: expiringCards.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final card = expiringCards[index];
            final daysLeft = card.expiryDate!.difference(DateTime.now()).inDays;
            
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(card.name),
              subtitle: Text(
                'Expires in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}',
                style: TextStyle(
                  color: daysLeft <= 7
                      ? Colors.red
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailScreen(cardId: card.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Provider.of<CardProvider>(context, listen: false).setSearchQuery(query);
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Provider.of<CardProvider>(context, listen: false).setSearchQuery(query);
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, _) {
        final cards = cardProvider.cards;
        
        if (cards.isEmpty) {
          return const Center(
            child: Text('No cards found'),
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cards.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final card = cards[index];
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: card.cardColor != null
                      ? Color(int.parse(card.cardColor!))
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card),
              ),
              title: Text(card.name),
              subtitle: Text(card.cardNumber),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailScreen(cardId: card.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
