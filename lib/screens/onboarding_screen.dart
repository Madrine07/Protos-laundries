import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

/// OnboardingScreen
/// This widget manages the entire onboarding flow:
/// - Shows multiple pages of onboarding content
/// - Lets the user swipe between pages
/// - Shows page indicators
/// - Shows a CTA (“Get Started”) on the last page
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// _OnboardingScreenState
/// Holds state for:
/// - PageController to control the PageView
/// - Current page index
/// - A boolean to detect if user is on the last page
class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // Controller for handling page changes
  final PageController _controller = PageController();

  // Index of the currently visible onboarding page
  int currentPage = 0;

  // Whether the last page is currently active
  bool isLastPage = false;

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Background of the entire onboarding screen
      /// Using a light gradient for a modern, clean aesthetic
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFF2F2F7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        /// SafeArea ensures UI elements don't overlap system notches or status bar
        child: SafeArea(
          child: Column(
            children: [
              /// Skip button appears only on pages 0 and 1
              if (!isLastPage)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: () => _controller.jumpToPage(2),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              else
                // Placeholder to maintain spacing when Skip is hidden
                const SizedBox(height: 60),

              /// The PageView that displays all onboarding pages
              /// Wrapped in Expanded so it takes all remaining vertical space
              Expanded(
                child: PageView(
                  controller: _controller,

                  /// Update page index and detect last page
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                      isLastPage = index == 2;
                    });
                  },

                  /// Each onboarding page is built using buildPage()
                  children: [
                    buildPage(
                      imagePath: 'images/african-american-man-doing-laundry.png',
                      title: 'Welcome to Protos Laundries App',
                      description: 'Have your laundry done, any time, anywhere.',
                    ),
                    buildPage(
                      imagePath: 'images/images.png',
                      title: 'We Pickup, Wash & Deliver',
                      description: 'We move right to your doorstep.',
                    ),
                    buildPage(
                      imagePath: 'images/image.png',
                      title: 'Track Your Order Status',
                      description: 'Receive real-time updates on your laundry.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// Page indicators (3 dots)
              /// The active one becomes wider for visibility
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? Colors.deepPurple
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Main bottom button area:
              /// - On last page → “Get Started”
              /// - Other pages → FloatingActionButton (next)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: isLastPage
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),

                          /// Move to Login screen once done
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : FloatingActionButton(
                          backgroundColor: Colors.deepPurple,
                          onPressed: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                          child: const Icon(Icons.arrow_forward),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// buildPage()
  ///
  /// This method builds a single onboarding page with:
  /// - Custom image (instead of icon)
  /// - Title
  /// - Description
  ///
  /// The layout remains consistent across all onboarding steps.
  Widget buildPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        const SizedBox(height: 40),

        /// Circular image container
        /// This becomes the main visual per page
        Container(
          height: 180,
          width: 180,
          decoration: const BoxDecoration(
            color: Color(0xFFEFEFEF), // soft neutral background
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),

            /// Loads and displays your custom image from assets
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // ensures image scales correctly
            ),
          ),
        ),

        const SizedBox(height: 40),

        /// Title text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// Description text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
