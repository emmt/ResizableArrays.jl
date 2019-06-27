# Resizable arrays for Julia

In Julia only uni-dimensional arrays (of type `Vector`) are resizable.
This package provides multi-dimensional arrays which are resizable and
which are intended to be as efficient as Julia arrays.

Resizable arrays may be useful in a variety of situations.  For instance to
avoid re-creating arrays and therefore limit the calls to the garbage
collector which may be very costly for real-time applications.
