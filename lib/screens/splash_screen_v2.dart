import 'package:flutter/material.dart';
import 'package:gst_profit_app/constants/app_colors.dart';
import 'package:gst_profit_app/constants/app_values.dart';
import 'package:gst_profit_app/screens/v2_calculation_screen.dart';

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({Key? key}) : super(key: key);

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppValues.splashDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(AppValues.navigationDuration, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CalculationScreenV2()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary, // Solid Excel green background
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.2 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/icon/app-icon2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppValues.paddingLarge),
              FadeTransition(
                opacity: _animation,
                child: const Text(
                  'Profit Calculator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
