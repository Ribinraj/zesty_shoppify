// // lib/screens/checkout_screen.dart
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:zestyvibe/core/colors.dart';

// class CheckoutScreen extends StatefulWidget {
//   final String checkoutUrl;
//   final VoidCallback? onCheckoutComplete;

//   const CheckoutScreen({
//     Key? key,
//     required this.checkoutUrl,
//     this.onCheckoutComplete,
//   }) : super(key: key);

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   String _currentUrl = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//   }

//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//               _currentUrl = url;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               _isLoading = false;
//               _currentUrl = url;
//             });

//             // Check if checkout is complete
//             if (url.contains('/thank_you') || 
//                 url.contains('/orders/') ||
//                 url.contains('checkout/thank_you')) {
//               _handleCheckoutComplete();
//             }
//           },
//           onWebResourceError: (WebResourceError error) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Error loading page: ${error.description}'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.checkoutUrl));
//   }

//   void _handleCheckoutComplete() {
//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Order placed successfully!'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );

//     // Delay navigation to show the message
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         widget.onCheckoutComplete?.call();
//         Navigator.of(context).pop(true); // Return true to indicate success
//       }
//     });
//   }

//   Future<bool> _onWillPop() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//       return false;
//     }
    
//     // Show confirmation dialog
//     final shouldPop = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cancel Checkout?'),
//         content: const Text('Are you sure you want to leave checkout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
    
//     return shouldPop ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Checkout'),
//           backgroundColor: Appcolors.kprimarycolor,
//           actions: [
//             if (_isLoading)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   child: SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         body: Stack(
//           children: [
//             WebViewWidget(controller: _controller),
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zestyvibe/core/colors.dart';

class CheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final VoidCallback? onCheckoutComplete;

  const CheckoutScreen({
    Key? key,
    required this.checkoutUrl,
    this.onCheckoutComplete,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _initialLoadComplete = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Only show loading for navigation after initial load
            if (_initialLoadComplete) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
              });
            } else {
              setState(() {
                _currentUrl = url;
              });
            }
          },
          onPageFinished: (String url) {
            // Use a small delay to ensure page is actually rendered
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _initialLoadComplete = true;
                  _currentUrl = url;
                });
              }
            });

            // Check if checkout is complete
            if (url.contains('/thank_you') || 
                url.contains('/orders/') ||
                url.contains('checkout/thank_you') ||
                url.contains('/checkouts/') && url.contains('/thank_you')) {
              _handleCheckoutComplete();
            }
          },
          onProgress: (int progress) {
            // Hide loading indicator once we reach 80% to improve UX
            if (progress >= 80 && _isLoading && !_initialLoadComplete) {
              setState(() {
                _isLoading = false;
                _initialLoadComplete = true;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only show errors for main frame (ignore subresource errors like ORB)
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.timeout ||
                error.errorType == WebResourceErrorType.connect) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connection error: ${error.description}'),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () {
                        _controller.reload();
                      },
                    ),
                  ),
                );
              }
            }
            // Ignore ORB and other subresource errors silently
            
            // Still mark loading as complete on error
            if (mounted && _isLoading) {
              setState(() {
                _isLoading = false;
                _initialLoadComplete = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleCheckoutComplete() {
    // Prevent multiple calls
    if (!mounted) return;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Delay navigation to show the message
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onCheckoutComplete?.call();
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    });
  }

  Future<bool> _onWillPop() async {
    // Don't allow back navigation while processing checkout completion
    if (_currentUrl.contains('/thank_you') || 
        _currentUrl.contains('/orders/')) {
      return false;
    }

    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    
    // Show confirmation dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Checkout?'),
        content: const Text('Are you sure you want to leave checkout? Your cart will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Secure Checkout'),
          backgroundColor: Appcolors.kprimarycolor,
          elevation: 0,
          actions: [
            // Show a subtle loading indicator in app bar
            if (_isLoading && !_initialLoadComplete)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            // Add refresh button
            if (_initialLoadComplete)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _controller.reload();
                  setState(() {
                    _isLoading = true;
                  });
                },
                tooltip: 'Refresh',
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            // Only show full-screen loading on initial load
            if (_isLoading && !_initialLoadComplete)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading secure checkout...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}