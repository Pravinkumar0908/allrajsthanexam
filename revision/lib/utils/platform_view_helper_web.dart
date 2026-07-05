import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createWebIframe(String url) {
  final String viewType = 'pdf-iframe-${url.hashCode}';
  
  // Register view factory for the iframe
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) => html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );
  
  return HtmlElementView(viewType: viewType);
}
