# Interoperability with C++ (via C Wrapper)

> **Prerequisites:** [03-c-advanced](../03-c-advanced/) (Callbacks), [01-c-basic](../01-c-basic/) (Basic FFI).

## Goal

Learn how to interoperate with C++ code from Scala Native.

## Description

Scala Native uses the C ABI (Application Binary Interface) for interoperability. C++, while powerful, has features like name mangling, classes, and exceptions that are not directly compatible with the C ABI. To call C++ from Scala Native, we must bridge the two worlds using a C-compatible wrapper.

In this example:
1.  **C++ Class**: We define a standard C++ class `Greeter` in `cpp_greeter.cpp`.
2.  **C Wrapper**: We use an `extern "C"` block to define functions that create (`greeter_new`), use (`greeter_greet`), and destroy (`greeter_delete`) the C++ object. The `extern "C"` linkage tells the C++ compiler to use the C ABI for these specific functions, preventing name mangling.
3.  **Opaque Pointers**: Since Scala Native doesn't understand the internal layout of a C++ object, we treat it as an opaque pointer (`void*` in C, `Ptr[Byte]` in Scala).
4.  **Manual Lifecycle**: Because C++ objects are allocated on the heap (using `new`), they must be explicitly destroyed (using `delete`) when they are no longer needed.

## Build and Run Commands

To build and run the binary:

```bash
$ cd examples/03-interop/04-cpp
$ bazel run //:main
```

The output will be:

```
Starting C++ Interop Example...
Scala says: Creating C++ object via C wrapper...
Creating C++ object...
Calling C++ method...
C++ Greeter says: Hello, Scala Native User!
Deleting C++ object...
--- Done ---
```

## Key Concepts

-   **`extern "C"`**: A directive used in C++ to specify that functions follow the C linkage and calling convention. This is essential for preventing name mangling, which would otherwise make it impossible for Scala Native to find the symbols.
-   **Opaque Pointers (`Ptr[Byte]`)**: A way to handle complex native objects whose internal structure is unknown to Scala. We pass the pointer back and forth, but only interact with the object through C-wrapped functions.
-   **Heap Management**: Unlike `Zone` or `stackalloc`, C++ objects created with `new` have a lifetime managed manually by the developer. Failing to call the corresponding `delete` wrapper would result in a memory leak.

## Code Highlights

### cpp_greeter.cpp

```cpp
#include <iostream>
#include <string>

class Greeter {
public:
    Greeter(const std::string& name) : name_(name) {}
    void greet() const {
        std::cout << "C++ Greeter says: Hello, " << name_ << "!" << std::endl;
    }
private:
    std::string name_;
};

extern "C" {
    void* greeter_new(const char* name) {
        return new Greeter(name);
    }
    void greeter_greet(void* greeter) {
        static_cast<Greeter*>(greeter)->greet();
    }
    void greeter_delete(void* greeter) {
        delete static_cast<Greeter*>(greeter);
    }
}
```

### CppInterop.scala

```scala
package examples
import scala.scalanative.unsafe.*

@extern
object CppGreeter:
    @name("greeter_new")
    def greeter_new(name: CString): Ptr[Byte] = extern
    @name("greeter_greet")
    def greeter_greet(greeter: Ptr[Byte]): Unit = extern
    @name("greeter_delete")
    def greeter_delete(greeter: Ptr[Byte]): Unit = extern

@main
def cppInteropExample(): Unit =
  Zone:
    val name = toCString("Scala Native User")
    val greeter = CppGreeter.greeter_new(name)
    CppGreeter.greeter_greet(greeter)
    CppGreeter.greeter_delete(greeter)
```

### BUILD.bazel

```python
cc_library(
    name = "cpp_greeter_lib",
    srcs = ["cpp_greeter.cpp"],
)

scala_native_library(
    name = "scala_cpp_interop",
    srcs = ["CppInterop.scala"],
)

scala_native_binary(
    name = "main",
    main_class = "examples.cppInteropExample",
    deps = [
        ":cpp_greeter_lib",
        ":scala_cpp_interop",
    ],
)
```

## Next Steps

→ [05-rust](../05-rust/): Interoperating with Rust using `extern "C"` and the C ABI.
