<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/logo.svg"
width="300px" height="300px" />
</p>

# QRgen - A QR generation library

QRgen is a QR generation library fully written in Nim that only uses a small
amount of pure-nim stdlib modules.

[![Run Tests](https://github.com/aruZeta/QRgen/actions/workflows/tests.yaml/badge.svg)](https://github.com/aruZeta/QRgen/actions/workflows/tests.yaml)
[![Gen Docs](https://github.com/aruZeta/QRgen/actions/workflows/gendocs.yaml/badge.svg)](https://github.com/aruZeta/QRgen/actions/workflows/gendocs.yaml)
[![Run Benchmarks](https://github.com/aruZeta/QRgen/actions/workflows/benchmarks.yaml/badge.svg)](https://github.com/aruZeta/QRgen/actions/workflows/benchmarks.yaml)

## Prerequisites

`nim --version` >= `1.6.0`

## Installation

`nimble install qrgen`

## Features

- Supports all QR versions: from `1` to `40`.
- Supports all EC (Error Correction) levels: `L`, `M`, `Q` and `H`.
- Supports `numeric mode`, `alphanumeric mode` and `byte mode`.
- Supports printing a QR code on your terminal via standard output.
- Supports printing a QR code to SVG, with custom colors, using circles,
embedding SVG logos etc.
- Supports rendering a QR code to pixie's `Image`, with the same features
as SVG (but can embed more image formats). `Image` can be exported to
various formats, like PNG.

## Usage

```nim
import QRgen
let myQR = newQR("https://github.com/aruZeta/QRgen")
```

### Terminal

```nim
myQR.printTerminal
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/terminal-example.png" width="200px" height="200px"/>
</p>

---

### SVG

#### Generic QR with white background and black foreground

```nim
myQR.printSvg
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-example.svg" width="200px" height="200px" />
</p>

---

#### Changing the background and foreground colors

```nim
myQR.printSvg("#1d2021","#98971a")
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-colors-example.svg" width="200px" height="200px" />
</p>

`"#1d2021"` sets the "light" or "background" color.
`"#98971a"` sets the "dark" or "foreground" color.

---

#### Making the alignment patterns rounded

```nim
myQR.printSvg("#1d2021","#98971a",60)
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-rounded-example.svg" width="200px" height="200px"/>
</p>

`60` sets the alignment patterns' roundness to 60%.

---

#### Making the modules rounded

```nim
myQR.printSvg("#1d2021","#98971a",100,100,25)
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-very-rounded-example.svg" width="200px" height="200px" />
</p>

The first `100` sets the alignment patterns' roundness to 100%
while the second `100` sets the module's roundness to 100% too
and the last `25` sets the separation of the modules to 25%, so they are not
next to each other.

---

#### Changing the separation of the modules

```nim
myQR.printSvg("#1d2021","#98971a",100,100,50)
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-separation-example.svg" width="200px" height="200px" />
</p>

The last `50` sets the module's separation to 50%.

---

#### Embedding another SVG in the generated QR code

Here we will need the highest EC level, for a better result (bigger logo):

```nim
let myQR = newQR("https://github.com/aruZeta/QRgen", ecLevel=qrECH)
```

```nim
myQR.printSvg("#1d2021","#98971a",100,100,25,svgImg=readFile("QRgen-logo.svg"))
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-embed-example.svg" width="200px" height="200px" />
</p>

`svgImg` adds an SVG image embed in the center of generated
QR code, so we can pass it the contents of an SVG file, here a logo, and
the result as you can see is the actual QRgen logo.

---

Since the generated SVGs have css classes, we can do stuff like this:

https://user-images.githubusercontent.com/68018085/190470749-66090814-08fe-45b5-881d-a96b272374be.mp4

https://user-images.githubusercontent.com/68018085/190470760-8a5b5a30-5812-4777-8e05-8d2b250a9113.mp4

---

### PNG

Note: The PNG renderer is not exported with `QRgen` since it depends on `pixie`
([check pixie here](https://github.com/treeform/pixie)). To use it you will need
to add this import:

```nim
import QRgen/renderer
```

And obviously install and import `pixie` too.

Note: `renderImg` returns an `Image` which to the save as let's say a PNG, you
will need to do:

```nim
let myQRImg = renderImg(...)
writeFile(myQRImg, "path/to/save/it.png")
```

You can check [pixie](https://github.com/treeform/pixie) to learn about more
formats you can save an `Image` as.

---

#### Generic QR with white background and black foreground

```nim
myQR.renderImg
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/png-example.png" width="200px" height="200px" />
</p>

---

#### Changing the background and foreground colors

```nim
myQR.renderImg("#1d2021","#98971a")
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/png-colors-example.png" width="200px" height="200px" />
</p>

`"#1d2021"` sets the "light" or "background" color.
`"#98971a"` sets the "dark" or "foreground" color.

---

#### Making the alignment patterns rounded

```nim
myQR.renderImg("#1d2021","#98971a",60)
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/png-rounded-example.png" width="200px" height="200px"/>
</p>

`60` sets the alignment patterns' roundness to 60%.

---

#### Making the modules rounded

```nim
myQR.renderImg("#1d2021","#98971a",100,100,25)
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/png-very-rounded-example.png" width="200px" height="200px" />
</p>

The first `100` sets the alignment patterns' roundness to 100%
while the second `100` sets the module's roundness to 100% too
and the last `25` sets the separation of the modules to 25%, so they are not
next to each other.

---

#### Changing the separation of the modules

```nim
myQR.renderImg("#1d2021","#98971a",100,100,50)
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/png-separation-example.png" width="200px" height="200px" />
</p>

The last `50` sets the module's separation to 50%.

---

#### Embedding another PNG in the generated QR code

Here we will need the highest EC level, for a better result (bigger logo):

```nim
let myQR = newQR("https://github.com/aruZeta/QRgen", ecLevel=qrECH)
```

```nim
myQR.renderImg("#1d2021","#98971a",100,100,25,img=readImage("QRgen-logo.png"))
```

<p align="center">
<img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/png-embed-example.png" width="200px" height="200px" />
</p>

`img` embeds an `Image` in the center of the generated QR code,
so we can use pixie's `readImage` to read a PNG file, here a logo,
and the result as you can see is the actual QRgen logo.

---

Note that you can change the resolution of the generated image by setting
`pixels` to a higher value, by default it's set to 512 pixels
(both width and height).

---

## Documentation

Check the [docs](https://aruzeta.github.io/QRgen/develop/QRgen.html) to
know more about the main API.

## More examples

Check my simple terminal app's code, [QRterm](https://github.com/aruZeta/QRterm),
which uses this library to generate QR codes from your terminal, and also it's
[logo generator](https://github.com/aruZeta/QRterm/blob/main/src/generateLogo.nim).

## License

Distributed under the MIT License. See `LICENSE` for more information.
