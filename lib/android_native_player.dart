import 'package:flutter/material.dart';

class AndroidNativePlayer extends StatelessWidget{
  const AndroidNativePlayer({super.key});
  static const _androidViewType = "exoplayer_view";


  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: AndroidView(viewType: _androidViewType),
    );
  }

}
