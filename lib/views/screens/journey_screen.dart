import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../utils/responsive_helper.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/common/wild_trace_hero.dart';
import '../widgets/common/section_title.dart';
import '../widgets/cards/milestone_card.dart';
import '../widgets/cards/photographer_card.dart';
import '../widgets/common/battery_status_indicator.dart';

// brand story and timeline
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  // builds the narrative journey interface
  @override
  Widget build(BuildContext context) {
    // theme and layout configuration
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: Stack(
        children: [
          // scrollable content container
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
          // high-level navigation control
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: const BatteryStatusIndicator(),
          ),
        ],
      ),
    );
  }

  // builds the visual entry for the brand story
  Widget _buildHeroSection() {
    return Builder(
      builder: (context) {
        final isLandscape = ResponsiveHelper.isLandscape(context);
        final screenHeight = MediaQuery.of(context).size.height;
        
        return WildTraceHero(
          imagePath: 'assets/images/heroimageaboutus.jpg',
          title: 'OUR STORY',
          mainText1: 'INTO THE',
          mainText2: 'WILD',
          description: 'WildTrace began with a single shutter click in the heart of Sri Lanka. Today, we are\na bunch of photographers dedicated to preserving the wild through art.',
          height: isLandscape ? screenHeight * 0.85 : 500,
          alignment: Alignment.centerRight,
          verticalAlignment: isLandscape ? MainAxisAlignment.center : MainAxisAlignment.center,
        );
      }
    );
  }

  // builds the historical timeline using external content
  Widget _buildTimelineSection() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        // provides feedback for content synchronization
        if (contentProvider.isLoading && contentProvider.milestones.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF27AE60))));
        }
        
        final milestones = contentProvider.milestones;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Stack(
            children: [
              // vertical timeline guide line
              Positioned(
                left: 4,
                top: 20,
                bottom: 0,
                child: Container(
                  width: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              // list of historical markers
              Column(
                children: milestones.map((event) => _buildTimelineItem(
                      year: event.year,
                      title: event.title,
                      description: event.description,
                    )).toList(),
              ),
            ],
          ),
        );
      }
    );
  }

  // builds a singular milestone entry with indicator
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
          // visual status indicator
          Container(
            margin: const EdgeInsets.only(top: 5), 
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFF27AE60),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 24),
          // entry content card
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

  // builds the workforce presentation section
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
          // section identifier
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
          // group descriptive summary
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
          // dynamic builder for horizontal scroller
          Builder(
            builder: (context) {
              final isLandscape = ResponsiveHelper.isLandscape(context);
              return SizedBox(
                height: isLandscape ? 320 : 520,
                child: Consumer<ContentProvider>(
                  builder: (context, contentProvider, child) {
                    if (contentProvider.isLoading && contentProvider.photographers.isEmpty) {
                       return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    
                    final photographers = contentProvider.photographers;
                    
                    if (photographers.isEmpty) {
                      return const Center(child: Text('No photographers found', style: TextStyle(color: Colors.white)));
                    }

                    // renders biographies in a scrollable list
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: photographers.length,
                      itemBuilder: (context, index) {
                        final p = photographers[index];
                        return Container(
                          width: isLandscape ? 240 : 300,
                          margin: const EdgeInsets.only(right: 20),
                          child: PhotographerCard(
                            name: p.name,
                            role: p.profession, 
                            quote: p.quote,
                            achievement: p.achievement,
                            badgeText: p.post ?? '', 
                            imagePath: p.imageUrl,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  // builds the section highlighting conservation efforts
  Widget _buildImpactSection() {
    return Builder(
      builder: (context) {
        final isLandscape = ResponsiveHelper.isLandscape(context);
        final int gridColumns = 2;
        final double spacing = ResponsiveHelper.getSpacing(context, portrait: 16);
        
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
                // mission identifier
                Text(
                  isLandscape ? 'Empowering Locals, Protecting Nature' : 'Empowering Locals,\nProtecting Nature',
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
                // philosophical statement
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
                // core contributions grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isLandscape ? 60 : 0),
                  child: GridView.count(
                    crossAxisCount: gridColumns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: isLandscape ? 10 : spacing,
                    crossAxisSpacing: isLandscape ? 10 : spacing,
                    childAspectRatio: isLandscape ? 3.5 : 2.2,
                    padding: EdgeInsets.zero,
                    children: [
                      _buildImpactCard('Reforestation projects', isLandscape),
                      _buildImpactCard('Wildlife photography workshops', isLandscape),
                      _buildImpactCard('Calendar sponsorships', isLandscape),
                      _buildImpactCard('Wildlife department collaboration', isLandscape),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // builds a singular contribution marker for the impact grid
  Widget _buildImpactCard(String text, bool isLandscape) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 6 : 16, 
        vertical: isLandscape ? 4 : 12
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF27AE60).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // visual validation identifier
          Container(
            padding: EdgeInsets.all(isLandscape ? 3 : 6),
            decoration: const BoxDecoration(
              color: Color(0xFF27AE60),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: isLandscape ? 16 : 14,
            ),
          ),
          SizedBox(width: isLandscape ? 6 : 12),
          // descriptive textual information
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isLandscape ? 13 : 12,
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

