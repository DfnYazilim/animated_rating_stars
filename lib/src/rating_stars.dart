import 'package:flutter/material.dart';

/// A customizable animated rating bar widget.
///
/// Users can interact with this widget to provide a rating.
class AnimatedRatingStars extends StatefulWidget {
  final double initialRating;
  final double minRating;
  final double maxRating;
  final Color filledColor;
  final Color emptyColor;
  final Widget filledIcon;
  final Widget halfFilledIcon;
  final Widget emptyIcon;
  final Function(double) onChanged;
  final bool displayRatingValue;
  final bool interactiveTooltips;
  final Widget customFilledIcon;
  final Widget customHalfFilledIcon;
  final Widget customEmptyIcon;
  final double starSize;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool readOnly;

  const AnimatedRatingStars({
    super.key,
    this.initialRating = 0.0,
    this.minRating = 0.0,
    this.maxRating = 5.0,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
    this.filledIcon = const Icon(Icons.star),
    this.halfFilledIcon = const Icon(Icons.star_half),
    this.emptyIcon = const Icon(Icons.star_border),
    required this.onChanged,
    this.displayRatingValue = true,
    this.interactiveTooltips = false,
    required this.customFilledIcon,
    required this.customHalfFilledIcon,
    required this.customEmptyIcon,
    this.starSize = 30.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.readOnly = false,
  });

  @override
  _AnimatedRatingStarsState createState() => _AnimatedRatingStarsState();
}

class _AnimatedRatingStarsState extends State<AnimatedRatingStars> {
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating.toInt(), (index) {
        return GestureDetector(
          onTap: () {
            if (!widget.readOnly) {
              double selectedRating = index.toDouble() + 1.0;
              if (_rating == selectedRating && widget.interactiveTooltips) {
                _rating -= 0.5;
              } else {
                _rating = selectedRating;
              }
              widget.onChanged(_rating);
              setState(() {});
            }
          },
          child: AnimatedStar(
            filled: _rating >= index + 1,
            halfFilled: widget.interactiveTooltips && _rating == index + 0.5,
            filledColor: widget.filledColor,
            emptyColor: widget.emptyColor,
            filledIcon: widget.customFilledIcon,
            halfFilledIcon: widget.customHalfFilledIcon,
            emptyIcon: widget.customEmptyIcon,
            starSize: widget.starSize,
            animationDuration: widget.animationDuration,
            animationCurve: widget.animationCurve,
          ),
        );
      }),
    );
  }
}

class AnimatedStar extends StatefulWidget {
  final bool filled;
  final bool halfFilled;
  final Color filledColor;
  final Color emptyColor;
  final Widget filledIcon;
  final Widget halfFilledIcon;
  final Widget emptyIcon;
  final double starSize;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedStar({
    super.key,
    this.filled = false,
    this.halfFilled = false,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
    this.filledIcon = const Icon(Icons.star),
    this.halfFilledIcon = const Icon(Icons.star_half),
    this.emptyIcon = const Icon(Icons.star_border),
    this.starSize = 30.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  _AnimatedStarState createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    if (widget.filled || widget.halfFilled) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filled != oldWidget.filled ||
        widget.halfFilled != oldWidget.halfFilled) {
      if (widget.filled || widget.halfFilled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Icon() içine Widget koyamayız.
        // Bunun yerine animasyon değerlerini IconTheme ile altındaki Widget'a aktarıyoruz.
        return IconTheme(
          data: IconThemeData(
            color: Color.lerp(
              widget.emptyColor,
              widget.filledColor,
              _animation.value,
            ),
            size: widget.starSize + (8.0 * _animation.value),
          ),
          child: widget.filled
              ? widget.filledIcon
              : widget.halfFilled
              ? widget.halfFilledIcon
              : widget.emptyIcon,
        );
      },
    );
  }
}