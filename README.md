<p align="center">
<img src="./share/img/logo.svg"
width="300px" height="300px" />
</p>

# QRgen - A QR generation library

QRgen is a QR generation library fully written in Nim without any external
dependencies.

[![Run Tests](https://github.com/aruZeta/QRgen/actions/workflows/tests.yaml/badge.svg)](https://github.com/aruZeta/QRgen/actions/workflows/tests.yaml)
[![Gen Docs](https://github.com/aruZeta/QRgen/actions/workflows/gendocs.yaml/badge.svg)](https://github.com/aruZeta/QRgen/actions/workflows/gendocs.yaml)
## Prerequisites

`nim --version` > `x.x.x`

## Installation

`nimble install QRgen`

## Features

- Supports all QR versions: from `1` to `40`.
- Supports all EC (Error Correction) levels: `L`, `M`, `Q` and `H`.
- Supports `numeric mode`, `alphanumeric mode` and `byte mode`.
- Supports printing a QR code on your terminal via standard output.
- Supports printing a QR code to SVG, with custom colors and rounded
alignment patterns.

## Usage

```nim
import QRgen
let myQR = newQR("https://github.com/aruZeta/QRgen")
```

<table>
  <thead>
    <tr>
      <th align="center">Terminal</th>
      <th align="center">SVG</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printTerminal</pre>
        <img src="./share/img/terminal-example.png" width="200px" height="200px"/>
      </td>
      <td align="center">
        <pre>myQR.printSvg</pre>
        <img src="./share/img/svg-example.svg" width="200px" height="200px" />
      </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th align="center">SVG with colors</th>
      <th align="center">SVG with circles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printSvg("#1d2021","#98971a")</pre>
        <img src="./share/img/svg-colors-example.svg" width="200px" height="200px" />
      </td>
      <td align="center">
        <pre>myQR.printSvg("#1d2021","#98971a",2)</pre>
        <img src="./share/img/svg-rounded-example.svg" width="200px" height="200px"/>
      </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th align="center">Svg with too much circles</th>
      <th align="center"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <pre>myQR.printSvg("#1d2021","#98971a",3.5,0.4)</pre>
        <img src="./share/img/svg-very-rounded-example.svg" width="200px" height="200px" />
      </td>
      <td align="center">
      </td>
    </tr>
  </tbody>
</table>

Note: in SVGs, colors are optional and default to white background and black
modules.

Since the generated SVGs have css classes, we can do stuff like this:

https://user-images.githubusercontent.com/68018085/188283528-45b2daf7-ff61-4930-a757-fd6d0846939c.mp4

Also, check the [docs](https://aruzeta.github.io/QRgen/develop/QRgen.html) to
know more about the main API.

# License

Distributed under the MIT License. See `LICENSE` for more information.
