# Resizable arrays for Julia

[![License][license-img]][license-url]
[![Stable][doc-stable-img]][doc-stable-url]
[![Dev][doc-dev-img]][doc-dev-url]
[![Build Status][github-ci-img]][github-ci-url]
[![Build Status][appveyor-img]][appveyor-url]
[![Coverage][codecov-img]][codecov-url]

The `ResizableArrays` package provides multi-dimensional arrays which are
resizable and which are intended to be as efficient as Julia arrays.  This
circumvents the Julia limitation that only uni-dimensional arrays (of type
`Vector`) are resizable.  The only restriction is that the number of dimensions
of a resizable array must be left unchanged (in order to preserve
type-stability).

Resizable arrays may be useful in a variety of situations.  For instance to
avoid re-creating arrays and therefore to limit the calls to Julia garbage
collector which may be very costly for real-time applications.

Unlike [ElasticArrays](https://github.com/JuliaArrays/ElasticArrays.jl) which
provides arrays that can grow and shrink, but only in their last dimension, any
dimensions of `ResizableArray` instances can be changed (providing the number
of dimensions remain the same).  Another difference is that you may use a
custom Julia object to store the elements of a resizable array, not just a
`Vector{T}`.

[doc-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[doc-stable-url]: https://emmt.github.io/ResizableArrays.jl/stable

[doc-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[doc-dev-url]: https://emmt.github.io/ResizableArrays.jl/dev

[license-url]: ./LICENSE.md
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat

[github-ci-img]: https://github.com/emmt/ResizableArrays.jl/actions/workflows/CI.yml/badge.svg?branch=master
[github-ci-url]: https://github.com/emmt/ResizableArrays.jl/actions/workflows/CI.yml?query=branch%3Amaster

[appveyor-img]: https://ci.appveyor.com/api/projects/status/github/emmt/ResizableArrays.jl?branch=master
[appveyor-url]: https://ci.appveyor.com/project/emmt/ResizableArrays-jl/branch/master

[codecov-img]: http://codecov.io/github/emmt/ResizableArrays.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/emmt/ResizableArrays.jl?branch=master
