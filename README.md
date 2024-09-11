# typ :printer:

A small [Zig](https://ziglang.org/) ⚡ module, as a convenience for me when writing [Typst](https://typst.app/) WebAssembly [plugins](https://typst.app/docs/reference/foundations/plugin/).

> [!Note]
> Initially based on the [hello.zig](https://github.com/astrale-sharp/wasm-minimal-protocol/blob/master/examples/hello_zig/hello.zig) example in [wasm-minimal-protocol](https://github.com/astrale-sharp/wasm-minimal-protocol/).

## Requirements

You will want to have a fairly recent [Zig](https://ziglang.org/download/#release-master) as well as the [Typst CLI](https://github.com/typst/typst?tab=readme-ov-file#installation).

> [!IMPORTANT]
> Right now I had to `rustup default 1.79.0` when compiling the latest `typst` since there were some breaking change in `1.80.0`

## Usage

You can have `zig build` use the `typ` module if you `zig fetch` it :)
