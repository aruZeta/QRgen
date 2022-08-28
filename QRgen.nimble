# Package

version       = "0.0.1"
author        = "aruZeta"
description   = "A QR code generation library written in nim."
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.6.6"

# Tasks

task gendocs, "Generate documentation in docs folder":
  exec "nim doc --project --git.url:\"https://github.com/aruZeta/QRgen\" --git.commit:develop --docInternal --outdir:docs --path:src src/QRgen.nim"
