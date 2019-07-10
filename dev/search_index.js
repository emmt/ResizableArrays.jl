var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "The ResizableArray package provides multi-dimensional arrays which are resizable and which are intended to be as efficient as Julia arrays.  This circumvents the Julia limitation that only uni-dimensional arrays (of type Vector) are resizable.  The only restriction is that the number of dimensions of a resizable array must be left unchanged.Resizable arrays may be useful in a variety of situations.  For instance to avoid re-creating arrays and therefore to limit the calls to Julia garbage collector which may be very costly for real-time applications.Unlike ElasticArrays which provides arrays that can grow and shrink, but only in their last dimension, any dimensions of ResizableArray instances can be changed (providing the number of dimensions remain the same).  Another difference is that you may use a custom Julia object to store the elements of a resizable array, not just a Vector{T}.The source code of ResizableArrays is available on GitHub."
},

{
    "location": "#Table-of-contents-1",
    "page": "Introduction",
    "title": "Table of contents",
    "category": "section",
    "text": "Pages = [\"install.md\", \"usage.md\", \"library.md\"]"
},

{
    "location": "#Index-1",
    "page": "Introduction",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "install/#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "install/#Installation-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": "ResizableArrays is not yet an offical Julia package but it is easy to install it from Julia as explained here."
},

{
    "location": "install/#Using-the-package-manager-1",
    "page": "Installation",
    "title": "Using the package manager",
    "category": "section",
    "text": "At the REPL of Julia, hit the ] key to switch to the package manager REPL (you should get a ... pkg> prompt) and type:pkg> add https://github.com/emmt/ResizableArrays.jlwhere pkg> represents the package manager prompt and https protocol has been assumed; if ssh is more suitable for you, then type:pkg> add git@github.com:emmt/ResizableArrays.jlinstead.  To check whether the ResizableArrays package works correctly, type:pkg> test ResizableArraysLater, to update to the last version (and run tests), you can type:pkg> update ResizableArrays\npkg> build ResizableArrays\npkg> test ResizableArraysIf something goes wrong, it may be because you already have an old version of ResizableArrays.  Uninstall ResizableArrays as follows:pkg> rm ResizableArrays\npkg> gc\npkg> add https://github.com/emmt/ResizableArrays.jlbefore re-installing.To revert to Julia\'s REPL, hit the Backspace key at the ... pkg> prompt."
},

{
    "location": "install/#Installation-in-scripts-1",
    "page": "Installation",
    "title": "Installation in scripts",
    "category": "section",
    "text": "To install ResizableArrays in a Julia script, write:if VERSION >= v\"0.7.0-\"; using Pkg; end\nPkg.add(PackageSpec(url=\"https://github.com/emmt/ResizableArrays.jl\", rev=\"master\"));or with url=\"git@github.com:emmt/ResizableArrays.jl\" if you want to use ssh.This also works from the Julia REPL."
},

{
    "location": "usage/#",
    "page": "Usage of resizable arrays",
    "title": "Usage of resizable arrays",
    "category": "page",
    "text": ""
},

{
    "location": "usage/#Usage-of-resizable-arrays-1",
    "page": "Usage of resizable arrays",
    "title": "Usage of resizable arrays",
    "category": "section",
    "text": "Instances of ResizableArray can be used as any other Julia multi-dimensional arrays (sub-types of AbstractArray).  More specifically and like instances of Julia Array, resizable arrays store their elements contiguously in column-major storage order and implement fast linear-indexing, .  Resizable arrays should be as efficient as instances of Array and can be used wherever an Array instance makes sense including calls to external libraries via the ccall method."
},

{
    "location": "usage/#Creating-a-resizable-array-1",
    "page": "Usage of resizable arrays",
    "title": "Creating a resizable array",
    "category": "section",
    "text": "An unitialized resizable array with elements of type T and dimensions dims is created by:ResizableArray{T}(undef, dims)Dimensions may be a tuple of integers or a a list of integers.  The number N of dimensions may be explicitly specified:ResizableArray{T,N}(undef, dims)For convenience, ResizableVector{T} and ResizableMatrix{T} are provided as aliases to ResizableArray{T,1} and ResizableArray{T,2}.Since a resizable array is resizable its dimensions may be specified at any time (before using its contents).  An empty resizable array is simply created by:ResizableArray{T,N}()The number of dimensions N must be specified in this case.  The element type T and the number of dimensions N are part of the signature of the type and cannot be changed without creating a new instance.The ResizableArray constructor can be called to create a new resizable array from an existing array A of any kind:ResizableArray(A)yields a resizable array of same size and element type as A and whose contents is initially copied from that of A.Element type T and number of dimensions N may be specified:ResizableArray{T}(A)\nResizableArray{T,N}(A)where N must match ndims(A) but T may be different from eltype(A).The convert method can be called to convert an existing array A of any kind to a resizable array.  There are 3 possibilities:convert(ResizableArray, A)\nconvert(ResizableArray{T}, A)\nconvert(ResizableArray{T,N}, A)where N must match ndims(A) but T may be different from eltype(A). Unlike the ResizableArray constructor which always returns a new instance, the convert method just returns its argument A if it is already a resizable array whose type has the requested signature.  Otherwise, the convert method behaves as the ResizableArray constructor.The call copy(ResizableArray,A) yields a copy of A which is a resizable array of same element type as A.  Call copy(ResizableArray{T},A) to specify a possibly different element type T.  The number of dimensions N may also be specified but it must be the same as A: copy(ResizableArray{T,N},A)."
},

{
    "location": "usage/#Resizing-dimensions-1",
    "page": "Usage of resizable arrays",
    "title": "Resizing dimensions",
    "category": "section",
    "text": "The dimensions of a resizable array A may be changed by:resize!(A, dims)with dims the new dimensions.  The number of dimensions must remain unchanged but the length of the array may change.  Depending on the type of the object backing the storage of the array, it may be possible or not to augment the number of elements of the array.  When array elements are stored in a regular Julia vector, the number of elements can always be augmented (unless too big to fit in memory).  When such a resizable array is resized, its previous contents is preserved if only the last dimension is changed.Resizable arrays are designed to re-use storage if possible to avoid calling the garbage collector.  This may be useful for real-time applications.  As a consequence, the storage used by a resizable array A can only grow unless skrink!(A) is called to reduce the storage to the minimum."
},

{
    "location": "usage/#Append-or-prepend-contents-1",
    "page": "Usage of resizable arrays",
    "title": "Append or prepend contents",
    "category": "section",
    "text": "Calling:append!(A, B) -> Aappends the elements of array B to a resizable array A and, as you may guess, calling:prepend!(A, B) -> Ainserts the elements of B before those of A.  Assuming A has N dimensions, array B may have N or N-1 dimensions.  The N-1 first dimensions of B must match the leading dimensions of A, these dimensions are left unchanged in the result.  If B has the same number of dimensions as A, the last dimension of the result is the sum of the last dimensions of A and B; otherwise, the last dimension of the result is one plus the last dimension of A.The grow! method is able to either append or prepend the elements of an array B to a resizable array A:grow!(A, B, prepend=false) -> ABy default or if argument prepend is false, the elements of B are inserted after those of A; otherwise, the elements of B are inserted before those of A.To improve performances of these operations, you can indicate the minimum number of elements for a resizable array A:sizehint!(A, len) -> AThe argument(s) after A may also be a list of dimensions:sizehint!(A, dims) -> AThe method maxlength(A) yields the maximum number of elements that can be stored in array A without resizing its internal buffer."
},

{
    "location": "usage/#Custom-storage-1",
    "page": "Usage of resizable arrays",
    "title": "Custom storage",
    "category": "section",
    "text": "The default storage of the elements of a resizable array is provided by a regular Julia vector.  To use an object buf to store the elements of a resizable array, use one of the following:A = ResizableArray(buf, dims)\nA = ResizableArray{T}(buf, dims)\nA = ResizableArray{T,N}(buf, dims)The buffer buf must store its elements contiguously using linear indexing style with 1-based indices and have element type T, that is IndexStyle(typeof(buf)) and eltype(buf) must yield IndexLinear() and T respectively.  The methods, IndexStyle, eltype, length, getindex and setindex! must be applicable for the type of buf.  If the method resize! is applicable for buf, the number of elements of A can be augmented; otherwise the maximum number of elements of A is length(buf).warning: Warning\nWhen explictely providing a resizable buffer buf for backing the storage of a resizable array A, you have the responsibility to make sure that the same buffer is not resized elsewhere.  Otherwise a segmentation fault may occur because A might assume a wrong buffer size.  To avoid this, the best is to make sure that only A owns buf and only A manages its size.When using the convert method or the ResizableArray constructor to convert an array into a resizable array, the buffer for backing storage is always an instance of Vector{T}."
},

{
    "location": "library/#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "library/#ResizableArrays.ResizableArray",
    "page": "Reference",
    "title": "ResizableArrays.ResizableArray",
    "category": "type",
    "text": "ResizableArray{T}(undef, dims)\n\nyields a resizable array with uninitialized elements of type T and dimensions dims.  Dimensions may be a tuple of integers or a a list of integers.  The number N of dimensions may be explicitly specified:\n\nResizableArray{T,N}(undef, dims)\n\nTo create an empty resizable array of given rank and element type, call:\n\nResizableArray{T,N}()\n\nThe dimensions of a resizable array A may be changed by calling resize!(A,dims) with dims the new dimensions.  The number of dimensions must remain unchanged but the length of the array may change.  Depending on the type of the object backing the storage of the array, it may be possible or not to augment the number of elements of the array.  When array elements are stored in a regular Julia vector, the number of element can always be augmented. Changing only the last dimension of a resizable array preserves its contents.\n\nResizable arrays are designed to re-use storage if possible to avoid calling the garbage collector.  This may be useful for real-time applications.  As a consequence, the storage used by a resizable array A can only grow unless skrink!(A) is called to reduce the storage to the minimum.  The call copy(ResizableArray,A) yields a copy of A which is a resizable array.\n\nTo improve performances, call sizehint!(A,n) to indicate the minimum number of elements to preallocate for A (n can be a number of elements or array dimensions).\n\nThe ResizableArray constructor and the convert method can be used to to convert an array A to a resizable array:\n\nResizableArray(A)\nconvert(ResizableArray, A)\n\nElement type T and number of dimensions N may be specified:\n\nResizableArray{T[,N]}(A)\nconvert(ResizableArray{T[,N]}, A)\n\nN must match ndims(A) but T may be different from eltype(A).  If possible, the convert method returns the input array while the ResizableArray constructor always returns a new instance.\n\nThe default storage for the elements of a resizable array is provided by a regular Julia vector.  To use an object buf to store the elements of a resizable array, use one of the following:\n\nA = ResizableArray(buf, dims)\nA = ResizableArray{T}(buf, dims)\nA = ResizableArray{T,N}(buf, dims)\n\nThe buffer buf must store its elements contiguously using linear indexing style with 1-based indices and have element type T, that is IndexStyle(typeof(buf)) and eltype(buf) must yield IndexLinear() and T respectively.  The methods, IndexStyle, eltype, length, getindex and setindex! must be applicable for the type of buf.  If the method resize! is applicable for buf, the number of elements of A can be augmented; otherwise the maximum number of elements of A is length(buf).\n\nwarning: Warning\nWhen explictely providing a resizable buffer buf for backing the storage of a resizable array A, you have the responsibility to make sure that the same buffer is not resized elsewhere.  Otherwise a segmentation fault may occur because A might assume a wrong buffer size.  To avoid this, the best is to make sure that only A owns buf and only A manages its size.  In the current implementation, the size of the internal buffer is never reduced so the same buffer may be safely shared by different resizable arrays.\n\n\n\n\n\n"
},

{
    "location": "library/#ResizableArrays.ResizableMatrix",
    "page": "Reference",
    "title": "ResizableArrays.ResizableMatrix",
    "category": "type",
    "text": "ResizableMatrix{T}\n\nSupertype for two-dimensional resizable arrays with elements of type T. Alias for ResizableArray{T,2}.\n\n\n\n\n\n"
},

{
    "location": "library/#ResizableArrays.ResizableVector",
    "page": "Reference",
    "title": "ResizableArrays.ResizableVector",
    "category": "type",
    "text": "ResizableVector{T}\n\nSupertype for one-dimensional resizable arrays with elements of type T. Alias for ResizableArray{T,1}.\n\n\n\n\n\n"
},

{
    "location": "library/#ResizableArrays.isgrowable",
    "page": "Reference",
    "title": "ResizableArrays.isgrowable",
    "category": "function",
    "text": "isgrowable(x) -> boolean\n\nyields whether x is a growable object, that is its size can be augmented.\n\n\n\n\n\n"
},

{
    "location": "library/#ResizableArrays.maxlength",
    "page": "Reference",
    "title": "ResizableArrays.maxlength",
    "category": "function",
    "text": "maxlength(A)\n\nyields the maximum number of elements which can be stored in resizable array A without resizing its internal buffer.\n\nSee also: ResizableArray.\n\n\n\n\n\n"
},

{
    "location": "library/#ResizableArrays.shrink!",
    "page": "Reference",
    "title": "ResizableArrays.shrink!",
    "category": "function",
    "text": "shrink!(A) -> A\n\nshrinks as much as possible the storage of resizable array A and returns A. Call copy(ResizableArray,A) to make a copy of A which is a resizable array with skrinked storage.\n\n\n\n\n\n"
},

{
    "location": "library/#Reference-1",
    "page": "Reference",
    "title": "Reference",
    "category": "section",
    "text": "The following provides detailled documentation about types and methods provided by the ResizableArrays package.  This information is also available from the REPL by typing ? followed by the name of a method or a type.ResizableArrays.ResizableArrayResizableArrays.ResizableMatrixResizableArrays.ResizableVectorResizableArrays.isgrowableResizableArrays.maxlengthResizableArrays.shrink!"
},

]}
