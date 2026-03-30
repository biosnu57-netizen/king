import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tracking/pinc_tracking_service.dart';
import '../../core/events/pinc_events_service.dart';
import '../../core/games/pinc_games_service.dart';

/// Premium Events & Games Home Screen
/// Modern design with smooth animations and premium feel
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            EventsTab(),
            GamesTab(),
            LeaguesTab(),
            TrackingTab(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0E14), Color(0xFF121820)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatCard('Events', '24', Icons.event),
                      const SizedBox(width: 12),
                      _buildStatCard('Players', '1.2K', Icons.people),
                      const SizedBox(width: 12),
                      _buildStatCard('PINC', '50K', Icons.monetization_on),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppTheme.primaryDark,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.accentCyan,
            indicatorWeight: 3,
            labelColor: AppTheme.accentCyan,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: const [
              Tab(icon: Icon(Icons.celebration), text: 'EVENTS'),
              Tab(icon: Icon(Icons.sports_esports), text: 'GAMES'),
              Tab(icon: Icon(Icons.emoji_events), text: 'LEAGUES'),
              Tab(icon: Icon(Icons.shield), text: 'SECURITY'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryDark, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: const Row(
          children: [
            Icon(Icons.add, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text('Create', style: TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CreateOptionsSheet(),
    );
  }
}

/// Custom Create Options Bottom Sheet
class _CreateOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Something New',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose what you want to create',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),
                _buildOptionTile(context, Icons.celebration, const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]), 'Global Event', 'Tournaments, competitions, challenges'),
                _buildOptionTile(context, Icons.sports_esports, const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]), 'Game Match', 'Challenge friends to a game'),
                _buildOptionTile(context, Icons.emoji_events, const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]), 'League', 'Create league up to 50 players'),
                _buildOptionTile(context, Icons.attach_money, const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]), 'Custom Bet', 'Bet with friends and family'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, LinearGradient gradient, String title, String subtitle) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showCreateDialog(context, title);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create $type', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Entry Fee (PINC)'), keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Create'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Events Tab with premium design
class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      {'title': 'Global Chess Championship', 'players': '45/50', 'fee': '500 PINC', 'prize': '10,000', 'status': 'Live'},
      {'title': 'Tetris Speed Run', 'players': '234', 'fee': '25 PINC', 'prize': '2,500', 'status': 'Starting Soon'},
      {'title': 'PINC League Season 3', 'players': '30/50', 'fee': '1,000 PINC', 'prize': '50,000', 'status': 'Registration'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildSectionHeader('Live Events');
        return _buildEventCard(events[index - 1]);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    Color statusColor = event['status'] == 'Live' ? AppTheme.success : AppTheme.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.emoji_events, color: AppTheme.primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title']!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${event['players']} • ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          Text(event['fee']!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(event['status']!, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.surfaceColor.withValues(alpha: 0.5), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppTheme.warning, size: 18),
                    const SizedBox(width: 6),
                    Text('Prize: ${event['prize']} PINC', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Join Now', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Games Tab with premium design
class GamesTab extends StatelessWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'name': 'Chess', 'icon': '♔', 'players': '1,234', 'color': const Color(0xFF8B4513)},
      {'name': 'Checkers', 'icon': '⭕', 'players': '856', 'color': const Color(0xFFDC143C)},
      {'name': 'Tetris', 'icon': '🧱', 'players': '2,456', 'color': const Color(0xFF00CED1)},
      {'name': 'Snake', 'icon': '🐍', 'players': '1,789', 'color': const Color(0xFF32CD32)},
      {'name': 'Pong', 'icon': '🏓', 'players': '543', 'color': const Color(0xFFFF6347)},
      {'name': 'Wordle', 'icon': '📝', 'players': '3,210', 'color': const Color(0xFFFFD700)},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final color = game['color'] as Color? ?? AppTheme.accentCyan;
        return _buildGameCard(context, game, color);
      },
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, String> game, Color color) {
    return InkWell(
      onTap: () => _showGameDialog(context, game),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withValues(alpha: 0.3), AppTheme.cardColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Text(game['icon']!, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text(game['name']!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${game['players']} players', style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('Play', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameDialog(BuildContext context, Map<String, String> game) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(game['icon']!, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(game['name']!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(labelText: 'Bet Amount (PINC)', prefixIcon: Icon(Icons.monetization_on))),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Find Match'))),
                ],
              ),
            ],
          ),
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
        _buildFeaturedLeague(),
        const SizedBox(height: 24),
        const Text('Your Leagues', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildLeagueCard('Chess League', '12 players', '50 PINC'),
        _buildLeagueCard('Tetris Masters', '8 players', '100 PINC'),
        const SizedBox(height: 24),
        _buildCreateLeagueCard(context),
      ],
    );
  }

  Widget _buildFeaturedLeague() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF00FF94)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.accentCyan.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primaryDark.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.emoji_events, color: AppTheme.primaryDark, size: 28),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primaryDark.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                child: const Text('FEATURED', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('PINC Championship', style: TextStyle(color: AppTheme.primaryDark, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('50 Players • Winners Take All', style: TextStyle(color: AppTheme.primaryDark, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat('Prize', '50,000 PINC'),
              const SizedBox(width: 24),
              _buildStat('Players', '32/50'),
              const SizedBox(width: 24),
              _buildStat('Ends', '7 days'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDark, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Join Championship', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.primaryDark.withValues(alpha: 0.7), fontSize: 11)),
        Text(value, style: const TextStyle(color: AppTheme.primaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLeagueCard(String name, String players, String fee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.emoji_events, color: AppTheme.accentCyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                Text('$players • $fee', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
        ],
      ),
    );
  }

  Widget _buildCreateLeagueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.add_circle_outline, color: AppTheme.accentCyan, size: 40),
          const SizedBox(height: 12),
          const Text('Create Your Own League', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Up to 50 players • Winners take all', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create League'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: AppTheme.primaryDark, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }
}

/// Tracking/Security Tab
class TrackingTab extends ConsumerWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.divider)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(gradient: AppTheme.accentGradient, shape: BoxShape.circle),
                child: const Icon(Icons.shield, color: AppTheme.primaryDark, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Device Security', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your device is protected. Track location if lost.', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSecurityButton(Icons.lock, 'Lock'),
                  _buildSecurityButton(Icons.volume_up, 'Alarm'),
                  _buildSecurityButton(Icons.camera_alt, 'Capture'),
                  _buildSecurityButton(Icons.delete_forever, 'Wipe'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Anti-Theft Features', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildFeatureCard(Icons.power_settings_new, 'Shutdown Protection', 'Device cannot be turned off without PIN', true),
        _buildFeatureCard(Icons.gps_fixed, 'Location Tracking', 'Real-time location updates', true),
        _buildFeatureCard(Icons.map, 'Movement Map', 'View movement history', true),
        _buildFeatureCard(Icons.camera_alt, 'Remote Photo', 'Capture photo to identify thief', true),
        _buildFeatureCard(Icons.message, 'Display Message', 'Show message on lock screen', true),
      ],
    );
  }

  Widget _buildSecurityButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.error),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.accentCyan),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: enabled ? AppTheme.success.withValues(alpha: 0.2) : AppTheme.error.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(enabled ? Icons.check : Icons.close, color: enabled ? AppTheme.success : AppTheme.error, size: 16),
          ),
        ],
      ),
    );
  }
}