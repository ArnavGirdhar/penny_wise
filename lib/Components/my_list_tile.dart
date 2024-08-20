import 'package:chat_app_final/Helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final String currMon;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const MyListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.currMon,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            //edit pressed
            SlidableAction(
              onPressed: onEditPressed,
              icon: Icons.settings,
              backgroundColor: Colors.blue.shade300,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            //delete pressed
            SlidableAction(
              onPressed: onDeletePressed,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          //margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          child: Column(
            children: [
              ListTile(
                title: Text(title),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(trailing),
                    Text(
                      currMon,
                      style:GoogleFonts.bebasNeue(textStyle: const TextStyle(fontSize: 12,color: Colors.brown),)
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
