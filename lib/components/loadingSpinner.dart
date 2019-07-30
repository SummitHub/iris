import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';




class LoadingSpinner extends StatelessWidget {
LoadingSpinner(this.isWhite);
final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        width: 50,
         child: FlareActor('assets/images/loading.flr',
          animation: 'spin',
          color: isWhite ? Colors.white : Color(0xFFFF3E88),
        ),
      ),
    );
  }
}