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
- Supports printing a QR code to SVG, with custom colors, using circles, etc.

## Usage

```nim
import QRgen
let myQR = newQR("https://github.com/aruZeta/QRgen")
```

<table>
  <thead>
    <tr>
      <th align="center">Terminal</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printTerminal</pre>
        <img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/terminal-example.png" width="200px" height="200px"/>
      </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th align="center">SVG</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printSvg</pre>
        <img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-example.svg" width="200px" height="200px" />
        <p>Generic QR with white background and black foreground.</p>
      </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th align="center">SVG with colors</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printSvg("#1d2021","#98971a")</pre>
        <img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-colors-example.svg" width="200px" height="200px" />
        <p><code>"#1d2021"</code> is the "light" or "background" color</p>
        <p><code>"#98971a"</code> is the "dark" or "foreground" color</p>
      </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th align="center">SVG with circles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printSvg("#1d2021","#98971a",60)</pre>
        <img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-rounded-example.svg" width="200px" height="200px"/>
        <p><code>60</code> sets the alignment pattern's roundness to 60%</p>
      </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th align="center">Svg with too much circles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printSvg("#1d2021","#98971a",100,100)</pre>
        <img src="https://github.com/aruZeta/QRgen/blob/develop/share/img/svg-very-rounded-example.svg" width="200px" height="200px" />
        <p>The last <code>100</code> sets the module's roundness to 100%
        (a perfect circle)</p>
      </td>
    </tr>
  </tbody>
</table>

Since the generated SVGs have css classes, we can do stuff like this:

https://user-images.githubusercontent.com/68018085/190470749-66090814-08fe-45b5-881d-a96b272374be.mp4

https://user-images.githubusercontent.com/68018085/190470760-8a5b5a30-5812-4777-8e05-8d2b250a9113.mp4

Also, check the [docs](https://aruzeta.github.io/QRgen/develop/QRgen.html) to
know more about the main API.

# License

Distributed under the MIT License. See `LICENSE` for more information.
