💯% 😷 Safe Rust 🦀

Uses the design patterns featured in [https://github.com/Speykious/cve-rs](https://github.com/Speykious/cve-rs) to safely get pointers to (x64 ELF) C stdlib functions by safely reading program instruction memory as a &[u8] and looking for the PLT stubs, then computing the GOT addresses from the offsets encoded in the JMP/CALL instructions. ~~After demoing, safely double frees for a 🥵 blazingly 🔥 fast core dump to show that Rust can still get close to the metal while providing airtight memory safety guarantees.~~

Works on my machine, but may segfault safely for numerous reasons relating to the exact memory layout of the program binary when run.
