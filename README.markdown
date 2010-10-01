# Tween

Tween is a library for doing fluid motion in Ruby.  It's primarily a port of
Robert Penner's easing calculations to Ruby.  It has no dependencies, but it was
written for using with Gosu.

### What do they do?

Tweening is a technique for fluid animation.  It will find a number of steps
between two points, allows something to transition smoothly between point A and
point B.  While it's easy to code a linear interpolation yourself, there are a
number of **easings** in this library you can use.

An **easing** is a method of transitioning between two points *more* smoothly
than linear interpolation.  Linear interpolation has sudden starts and stops,
and a constant velocity.  Using an easing such as **Tween::Quart::InOut** will
make the object start moving slowly, accelerate, decelerate and arrive at its
destination gracefully.

For usage and a visual demonstration of what this really is, install Gosu
and run demo.rb in the examples directory.