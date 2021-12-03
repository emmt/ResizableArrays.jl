# User visible changes in `ResizableArrays` package

## Version 0.3.2

- Use package `ArrayTools`.

- Extend testing to Julia 1.7.


## Version 0.3.1

- Fix `setindex!` to return its first argument (as for any other Julia's
  arrays).


## Version 0.3.0

- Internally, `getfield` and `setfield!` are directly called so that the syntax
  `A.key` is no longer used for any resizable array `A`.  Therefore
  `getproperty` and `setproperty!` can be extended for resizable arrays.

- Benchmark tests are provided to assert that indexing a resizable array is as
  fast as indexing a regular array.
