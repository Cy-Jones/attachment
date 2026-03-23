import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:ui';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // DOWNGRADE TYPE MATCH: We dropped the List<> wrapper.
    // The StreamBuilder now expects a single ConnectivityResult to match your plugin version.
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {

        // REWIRED LOGIC: Instead of checking a list array, we just do a direct hardware evaluation.
        final isOffline = snapshot.hasData && snapshot.data == ConnectivityResult.none;

        return Stack(
          children: [
            child,
            if (isOffline)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 24),
                          Text(
                            'Waiting for connection...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                              fontFamily: 'Inter', // UI Tier
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}