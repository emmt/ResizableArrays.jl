# Resizable arrays for Julia

In Julia only uni-dimensional arrays (of type `Vector`) are resizable.
This package provides multi-dimensional arrays which are resizable and
which are intended to be as efficient as Julia arrays.

Resizable arrays may be useful in a variety of situations.  For instance to
avoid re-creating arrays and therefore limit the calls to the garbage
collector which may be very costly for real-time applications.

Unlike [ElasticArrays](https://github.com/JuliaArrays/ElasticArrays.jl)
which can grow and shrink, but only in their last dimension, any dimensions
of ResizableArrays can be changed.  The number of dimensions must however
remain the same.
