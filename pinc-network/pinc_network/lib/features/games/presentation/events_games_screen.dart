import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tracking/pinc_tracking_service.dart';
import '../../core/events/pinc_events_service.dart';
import '../../core/games/pinc_games_service.dart';

/// Events & Games Home Screen
class EventsGamesScreen extends ConsumerStatefulWidget {
  const EventsGamesScreen({super.key});

  @override
  ConsumerState<EventsGamesScreen> createState() => _EventsGamesScreenState();
}

class _EventsGamesScreenState extends ConsumerState<EventsGamesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Events & Games'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentCyan,
          labelColor: AppTheme.accentCyan,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Games'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Leagues'),
            Tab(icon: Icon(Icons.track_changes), text: 'Tracking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EventsTab(),
          GamesTab(),
          LeaguesTab(),
          TrackingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        backgroundColor: AppTheme.accentCyan,
        icon: const Icon(Icons.add, color: AppTheme.primaryDark),
        label: const Text('Create', style: TextStyle(color: AppTheme.primaryDark)),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create New',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCreateOption(
              icon: Icons.event,
              title: 'Global Event',
              subtitle: 'Competition, tournament, or challenge',
              onTap: () {
                Navigator.pop(context);
                _showCreateEventDialog(context);
              },
            ),
            _buildCreateOption(
              icon: Icons.sports_esports,
              title: 'Game Match',
              subtitle: 'Challenge friends to a game',
              onTap: () {
                Navigator.pop(context);
                _showCreateGameDialog(context);
              },
            ),
            _buildCreateOption(
              icon: Icons.emoji_events,
              title: 'League',
              subtitle: 'Create a league up to 50 players',
              onTap: () {
                Navigator.pop(context);
                _showCreateLeagueDialog(context);
              },
            ),
            _buildCreateOption(
              icon: Icons.attach_money,
              title: 'Custom Bet',
              subtitle: 'Bet with friends and family',
              onTap: () {
                Navigator.pop(context);
                _showCreateBetDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.accentCyan.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.accentCyan),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textTertiary, size: 16),
      onTap: onTap,
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text('Create Global Event', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Entry Fee (PINC)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Max Participants'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event created! All users notified.')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text('Start Game', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a game:', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildGameChip('Chess', '♔'),
                _buildGameChip('Checkers', '⭕'),
                _buildGameChip('Tetris', '🧱'),
                _buildGameChip('Snake', '🐍'),
                _buildGameChip('Pong', '🏓'),
                _buildGameChip('Wordle', '📝'),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Bet Amount (PINC)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game created! Waiting for opponent...')),
              );
            },
            child: const Text('Create Match'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameChip(String name, String icon) {
    return ActionChip(
      avatar: Text(icon),
      label: Text(name),
      backgroundColor: AppTheme.surfaceColor,
      labelStyle: const TextStyle(color: AppTheme.textPrimary),
      onPressed: () {},
    );
  }

  void _showCreateLeagueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text('Create League', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'League Name'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Game'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Entry Fee (PINC)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Max Players (up to 50)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('League created! Winners take all.')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateBetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text('Create Custom Bet', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Bet Question'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Option A'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Option B'),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Bet Amount (PINC)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bet created! Share with friends.')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Events Tab
class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample events data
    final events = [
      {'title': 'Global Chess Tournament', 'players': '45/50', 'fee': '100 PINC', 'status': 'Active'},
      {'title': 'Tetris High Score Challenge', 'players': '200+', 'fee': '10 PINC', 'status': 'Active'},
      {'title': 'PINC League Season 1', 'players': '30/50', 'fee': '500 PINC', 'status': 'Starting Soon'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, String> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events, color: AppTheme.accentCyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title']!,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          event['players']!,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.monetization_on, size: 14, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          event['fee']!,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event['status']!,
                  style: const TextStyle(color: AppTheme.success, fontSize: 12),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Join', style: TextStyle(color: AppTheme.primaryDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Games Tab
class GamesTab extends StatelessWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'Chess', 'icon': '♔', 'players': '1,234'},
      {'name': 'Checkers', 'icon': '⭕', 'players': '856'},
      {'name': 'Tetris', 'icon': '🧱', 'players': '2,456'},
      {'name': 'Snake', 'icon': '🐍', 'players': '1,789'},
      {'name': 'Pong', 'icon': '🏓', 'players': '543'},
      {'name': 'Wordle', 'icon': '📝', 'players': '3,210'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(context, game);
      },
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, String> game) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              game['icon']!,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              game['name']!,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${game['players']} players',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leagues Tab
class LeaguesTab extends StatelessWidget {
  const LeaguesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Active Leagues',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildLeagueCard(),
        const SizedBox(height: 24),
        const Text(
          'Create Your Own League',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCreateLeagueCard(context),
      ],
    );
  }

  Widget _buildLeagueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: AppTheme.primaryDark),
              SizedBox(width: 8),
              Text(
                'PINC Championship',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '50 Players • 5,000 PINC Prize Pool',
            style: TextStyle(color: AppTheme.primaryDark, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLeagueStat('Players', '32/50'),
              const SizedBox(width: 16),
              _buildLeagueStat('Entry', '100 PINC'),
              const SizedBox(width: 16),
              _buildLeagueStat('Ends', '7 days'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
              ),
              child: const Text('Join League', style: TextStyle(color: AppTheme.accentCyan)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.primaryDark, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateLeagueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentCyan, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.add_circle_outline, color: AppTheme.accentCyan, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Create League',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Up to 50 players • Winners take all',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Create Now'),
          ),
        ],
      ),
    );
  }
}

/// Tracking Tab
class TrackingTab extends ConsumerWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(PincTrackingService().isTrackingEnabled ? Provider() : Provider());
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_on, color: AppTheme.accentCyan, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Device Tracking',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your device is protected. Track location if lost.',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTrackingButton(
                    icon: Icons.lock,
                    label: 'Lock',
                    onTap: () {},
                  ),
                  _buildTrackingButton(
                    icon: Icons.volume_up,
                    label: 'Alarm',
                    onTap: () {},
                  ),
                  _buildTrackingButton(
                    icon: Icons.delete_forever,
                    label: 'Wipe',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Anti-Theft Features
        const Text(
          'Anti-Theft Features',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureTile(
          icon: Icons.power_settings_new,
          title: 'Shutdown Protection',
          subtitle: 'Prevent device from being turned off',
          enabled: true,
        ),
        _buildFeatureTile(
          icon: Icons.gps_fixed,
          title: 'Location Tracking',
          subtitle: 'Track device location in real-time',
          enabled: true,
        ),
        _buildFeatureTile(
          icon: Icons.camera_alt,
          title: 'Remote Photo',
          subtitle: 'Take photo to identify thief',
          enabled: true,
        ),
        _buildFeatureTile(
          icon: Icons.message,
          title: 'Display Message',
          subtitle: 'Show message on lock screen',
          enabled: true,
        ),
        
        const SizedBox(height: 24),
        
        // Movement History
        const Text(
          'Movement Map',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, color: AppTheme.textTertiary, size: 40),
                SizedBox(height: 8),
                Text(
                  'Movement data will appear here',
                  style: TextStyle(color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentCyan),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {},
            activeColor: AppTheme.accentCyan,
          ),
        ],
      ),
    );
  }
}