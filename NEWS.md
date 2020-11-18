# Changes in ResizableArrays package

## Version 0.3.0

- Internally, `getfield` and `setfield!` are directly called so that the syntax
  `A.key` is no longer used for any resizable array `A`.  Therefore
  `getproperty` and `setproperty!` can be extended for resizable arrays.

- Benchmark tests are provided to assert that indexing a resizable array is as
  fast as indexing a regular array.
