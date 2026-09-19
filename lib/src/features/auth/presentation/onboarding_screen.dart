import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Connect.",
      "description":
          "A frictionless marketplace connecting families directly with ethical breeders and local rescuers.",
      "image":
          "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=800&auto=format&fit=crop",
    },
    {
      "title": "Discover.",
      "description":
          "Find your new best friend with active filtering and instant real-time chats with verified sellers.",
      "image":
          "https://images.unsplash.com/photo-1541364983171-a8ba01e95cfc?q=80&w=800&auto=format&fit=crop",
    },
    {
      "title": "Adopt.",
      "description":
          "Secure transactional gateways ensure safe transfers. Your next best friend is waiting.",
      "image":
          "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?q=80&w=800&auto=format&fit=crop",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _onboardingData[index]["image"]!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _onboardingData[index]["title"]!,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]["description"]!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70, height: 1.5),
                        ),
                        const SizedBox(height: 120), // Space for bottom buttons
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      context.go('/login');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
