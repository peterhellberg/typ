# typ :printer:

A small [Zig](https://ziglang.org/) ⚡ module, as a convenience for me when writing WebAssembly
[plugins](https://typst.app/docs/reference/foundations/plugin/) for [Typst](https://typst.app/)

> [!NOTE]
> Initially based on the [hello.zig](https://github.com/astrale-sharp/wasm-minimal-protocol/blob/master/examples/hello_zig/hello.zig)
> example in [wasm-minimal-protocol](https://github.com/astrale-sharp/wasm-minimal-protocol/)

## Requirements

You will want to have a fairly recent [Zig](https://ziglang.org/download/#release-master)
as well as the [Typst CLI](https://github.com/typst/typst?tab=readme-ov-file#installation)

> [!IMPORTANT]
> I had to `rustup default 1.79.0` when compiling the latest `typst`
> as there were some breaking change in `1.80.0`

> [!TIP]
> Some of the software that I have installed for a pretty
> nice **Typst** workflow in [Neovim](https://neovim.io/):
>
> - https://github.com/nvarner/typst-lsp
> - https://github.com/kaarmu/typst.vim
> - https://github.com/chomosuke/typst-preview.nvim

## Usage

Use `zig fetch` to add a `.typ` to the `.dependencies` in your `build.zig.zon`

```console
zig fetch --save https://github.com/peterhellberg/typ/archive/refs/tags/v0.0.6.tar.gz
```

> [!NOTE]
> You should now be able to update your `build.zig` as described below.

#### `build.zig`
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const hello = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("hello.zig"),
        .strip = true,
        .target = target,
        .optimize = .ReleaseSmall,
    });

    const typ = b.dependency("typ", .{}).module("typ");

    hello.root_module.addImport("typ", typ);
    hello.entry = .disabled;
    hello.rdynamic = true;

    b.installArtifact(hello);
}
```

#### `hello.zig`
```zig
const typ = @import("typ");

export fn hello() i32 {
    const msg = "*Hello* from `hello.wasm` written in Zig!";

    return typ.ok(msg);
}

export fn echo(len: usize) i32 {
    var res = typ.alloc(u8, len * 2) catch return 1;
    defer typ.free(res);

    typ.in(res.ptr);

    for (0..len) |i| {
        res[i + len] = res[i];
    }

    return typ.ok(res);
}
```

#### `hello.typ`
```typst
#set page(width: 10cm, height: 10cm)
#set text(font: "Inter")

== A WebAssembly plugin for Typst

#line(length: 100%)

#emph[Typst is capable of interfacing with plugins compiled to WebAssembly.]

#line(length: 100%)

#let p = plugin("zig-out/bin/hello.wasm")

#eval(str(p.hello()), mode: "markup")

#eval(str(p.echo(bytes("1+2"))), mode: "code")
```

#### Expected output

![hello.png](https://github.com/user-attachments/assets/a1cd9c86-ef94-4d1f-a44c-b958475f79b0)
