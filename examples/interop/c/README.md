# Advanced C Interoperability

This directory demonstrates advanced C interoperability features using Scala Native. 

## Showcases
- **`advanced_c_bin`**: Shows how to seamlessly pass complex data structures between Scala and C across the C-ABI boundary using `CStruct2` and `CString` pointers. 
- It passes a Scala-allocated struct pointer directly into a C function, allowing the C code to modify fields (like incrementing `age`), which is then safely read back from the Scala Native side. 

### How to Run
```bash
bazel run //interop/c:advanced_c_bin
```
