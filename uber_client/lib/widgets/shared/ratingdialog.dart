import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String title;
  final String description;
  final Function(int) onRated;

  const RatingDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onRated,
  });
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  late String _title = widget.title;
  late String _description = widget.description;

  bool pause = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_description),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++)
                InkWell(
                  onTap: () {
                    if (pause) return;

                    setState(() {
                      _rating = i;
                    });
                    widget.onRated(i);
                    _handleRating();
                  },
                  child: Icon(
                    i <= _rating ? Icons.star : Icons.star_border,
                    size: 36,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleRating() {
    setState(() {
      pause = true;
    });

    if (_rating == 1) {
      _title = "Bad Rating";
      _description = "We're sorry you had a bad experience.";
      Future.delayed(Duration(seconds: 4), () {
        Navigator.pop(context);
      });
    } else if (_rating == 5) {
      _title = "Thank you!";
      _description = "We're glad you had an amazing experience!";
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      _title = "Thank you!";
      _description = "We appreciate your feedback.";
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    }
  }
}
