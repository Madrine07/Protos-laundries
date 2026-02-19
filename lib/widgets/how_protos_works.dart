import 'package:flutter/material.dart';

class HowItWorksCarousel extends StatefulWidget {
  const HowItWorksCarousel({super.key});

  @override
  State<HowItWorksCarousel> createState() => _HowItWorksCarouselState();
}

class _HowItWorksCarouselState extends State<HowItWorksCarousel> {

  // Controller for sliding pages
  final PageController _controller = PageController(viewportFraction: 0.92);

  int _currentPage = 0;

  final List<Map<String, String>> steps = [
    {
      "title": "Schedule a pickup",
      "subtitle": "Choose your own time",
      "image": "images/pick.png",
      "number": "1"
    },
    {
      "title": "We wash & clean",
      "subtitle": "Expert cleaning",
      "image": "images/wash_fold.png",
      "number": "2"
    },
    {
      "title": "Delivered to you",
      "subtitle": "Fresh laundry to your door",
      "image": "images/pickup.png",
      "number": "3"
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoSlide();
  }

  // =========================================================
  // AUTO SLIDE
  // =========================================================
  void _autoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      int next = _currentPage + 1;
      if (next >= steps.length) next = 0;

      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6A1B9A);

    return Column(
      children: [

        // =====================================================
        // CAROUSEL
        // =====================================================
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _controller,
            itemCount: steps.length,

            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },

            itemBuilder: (context, index) {
              final step = steps[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(18),
                ),

                // MAIN ROW
                child: Row(
                  children: [

                    // LEFT TEXT SIDE
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // STEP NUMBER
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: purple,
                              child: Text(
                                step["number"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // TITLE
                            Text(
                              step["title"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // SUBTITLE
                            Text(
                              step["subtitle"]!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =================================================
                    // IMAGE SIDE (fills card perfectly)
                    // =================================================
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      child: SizedBox(
                        width: 120,
                        height: double.infinity,
                        child: Image.asset(
                          step["image"]!,
                          fit: BoxFit.cover, // 🔥 fills perfectly
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // =====================================================
        // DOT INDICATOR
        // =====================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            steps.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? purple
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
