# 8cc.cr

8cc.cr is **compile-time C Compiler** implemented as [Crystal][crystal-lang] macros. This is a port of [8cc][rui314/8cc] built on [ELVM Infrastructure][shinh/elvm].

Crystal macros are compile-time evaluation feature to avoid boilerplate code. There are `if`-sentences, `for`-loops, integers, strings, arrays, hashes, some control structures and data structures in Crystal macros. We can program on it enough!

For example, you have such a C code as `hello.c`:

```c
int putchar(int c);

int main(void) {
  char *s = "Hello, World!\n";
  for (; *s; s++) {
    putchar(*s);
  }
  return 0;
}
```

You can compile it by those commands (by the way, this process wants too long time. You can drink 10 or more cups of tee :-)

```console
$ # Compile C code to assembly language (EIR, ELVM intermediate representation).
$ cat hello.c | crystal build --no-codegen src/8cc.cr > hello.eir

$ # Then, generate binary from this assembly.
$ (echo x86; cat hello.eir) | crystal build --no-codegen src/elc.cr > hello

$ # Run it!
$ chmod +x hello; ./hello
Hello, World!
```

Surprising point is passing `--no-codegen` flag to `crystal build` command, this flag lets `crystal build` not generate binary, only compile. In short, `src/8cc.cr` and `src/elc.cr` are working on only **compile-time**.

And I made `bin/8cc.cr` simple shell script, which is compiler-driver for `src/8cc.cr` and `src/elc.cr`. It compiles C code and generate binary (or some language codes) automatically. I recommend to use it instead of typing above commands.

## Usage

```console
$ ./bin/8cc.cr -h
usage: ./bin/8cc.cr [-s] [-S] [-t target] [-o output] source

options:
  -s               display statistics
  -S               only compile C to ELVM IR, not generate code
  -t target        specify target to compile (i.e. x86, c, cr, js...) [default: c]
  -o output        specify output file name                           [default: ${source%.*}.$target]
  source           specify compiled source file name                  [required]

$ ./bin/8cc.cr -t x86 -o hello hello.c
$ chmod +x hello; ./hello
Hello, World!
```

**NOTE**: `x86` binary is only worked on Linux.

## How was 8cc.cr generated?

You know, I didn't create `src/8cc.cr` and `src/elc.cr` by hand-writing. It is just generated.

[ELVM][shinh/elvm] (EsoLang VM Compiler Infrastructure) project is awesome. It provides `8cc`, which is compiler from C to EIR, and `elc`, which is generator from EIR to some programming languages code. I wrote Crystal macros target driver for `elc` at first, then compiled `8cc` by `8cc` (first `8cc` is compiled by usual C compiler like `gcc`) and generated Crystal code of `8cc` by `elc` (first `elc` is also compiled).

## Author

TSUYUSATO "MakeNowJust" Kitsune <make.just.on@gmail.com>

## More interesting

  - [rui314/8cc][] - Small C11 compiler
  - [shinh/elvm][] - EsoLang VM Compiler Infrastructure
  - variations of 8cc port
    * [rhysd/8cc.vim][] - port for Vim script
    * [hak7a3/8cc.tex][] - port for TeX
    * [kw-udon/constexpr-8cc][] - port for C++ constexpr

Thank you all!

[crystal-lang]: https://crystal-lang.org
[rui314/8cc]: https://github.com/rui313/8cc
[shinh/elvm]: https://github.com/shinh/elvm
[rhysd/8cc.vim]: https://github.com/rhysd/8cc.vim
[hak7a3/8cc.tex]: https://github.com/hak7a3/8cc.tex
[kw-udon/constexpr-8cc]: https://github.com/kw-udon/constexpr-8cc
