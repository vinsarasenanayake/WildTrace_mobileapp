// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/wild_trace_hero.dart';
import '../widgets/section_title.dart';
import '../widgets/milestone_card.dart';
import '../widgets/photographer_card.dart';

// --- Screen ---
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                _buildTimelineSection(),
                _buildTeamSection(),
                _buildImpactSection(),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.transparent,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildHeroSection() {
    return const WildTraceHero(
      imagePath: 'assets/images/heroimageaboutus.jpg',
      title: 'OUR STORY',
      mainText1: 'INTO THE',
      mainText2: 'WILD',
      description: 'WildTrace began with a single shutter click in the heart of Sri Lanka. Today, we are\na bunch of photographers dedicated to preserving the wild through art.',
      height: 500,
    );
  }

  Widget _buildTimelineSection() {
    final List<Map<String, String>> timelineEvents = [
      {
        'year': '2018',
        'title': 'The Beginning',
        'description': 'Founded by lead photographer Vinsara with a humble exhibition in Colombo, showcasing the untamed beauty of the island.',
      },
      {
        'year': '2020',
        'title': 'Global Recognition',
        'description': 'Featured in National Geographic\'s "Best of Wildlife" series for documenting the endangered Snow Leopard.',
      },
      {
        'year': '2023',
        'title': 'Trace Foundation',
        'description': 'Launched our conservation arm, dedicating 10% of all profits to wildlife protection units across Sri Lanka.',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 20,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          Column(
            children: timelineEvents
                .map((event) => _buildTimelineItem(
                      year: event['year']!,
                      title: event['title']!,
                      description: event['description']!,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5), // Align with the year text
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFF2ECC71),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: MilestoneCard(
              year: year,
              title: title,
              description: description,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1B1B),
      ),
      child: Column(
        children: [
          const SectionTitle(title: 'PHOTOGRAPHERS'),
          const SizedBox(height: 16),
          Text(
            'The Eyes Behind the Lens',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'A diverse team of passionate visual storytellers united by a love for the wild.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 520,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: const PhotographerCard(
                    name: 'Vinsara Senanayake',
                    role: 'FOUNDER & LEAD',
                    quote: 'Nature doesn\'t need a filter, it just needs a witness.',
                    achievement: 'CANON AMBASSADOR',
                    badgeText: 'DJMPC WINNER',
                    imagePath: 'assets/images/teammember1.jpg',
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: const PhotographerCard(
                    name: 'Kavindu Gunawardhane',
                    role: 'WILDLIFE PHOTOGRAPHER',
                    quote: 'Every shutter click is a promise to protect what we see.',
                    achievement: 'NAT GEO FEATURED',
                    badgeText: 'DJMPC WINNER',
                    imagePath: 'assets/images/teammember2.jpg',
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: const PhotographerCard(
                    name: 'Kumara Senanayake',
                    role: 'WILDLIFE PHOTOGRAPHER',
                    quote: 'I don\'t just take pictures; I collect stories of survival.',
                    achievement: 'NIKON AMBASSADOR',
                    badgeText: 'DJMPC WINNER',
                    imagePath: 'assets/images/teammember3.jpg',
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 20),
                  child: const PhotographerCard(
                    name: 'Ravi Shanker',
                    role: 'WILDLIFE PHOTOGRAPHER',
                    quote: 'From above, the earth tells a fragile story.',
                    achievement: 'BBC EARTH FEATURED',
                    badgeText: 'DJMPC WINNER',
                    imagePath: 'assets/images/teammember4.jpg',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/communitywork2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.92),
        ),
        child: Column(
          children: [
            const SectionTitle(title: 'COMMUNITY IMPACT'),
            const SizedBox(height: 16),
            Text(
              'Empowering Locals,\nProtecting Nature',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'We believe that true conservation happens when local communities are\nempowered. WildTrace works directly with local stakeholders to ensure the survival\nof our planet\'s ecosystems.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
              padding: EdgeInsets.zero,
              children: [
                _buildImpactCard('Reforestation projects'),
                _buildImpactCard('Wildlife photography workshops'),
                _buildImpactCard('Calendar sponsorships'),
                _buildImpactCard('Wildlife department collaboration'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2ECC71).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF2ECC71),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}




