# Package

version       = "0.0.1"
author        = "aruZeta"
description   = "A QR code generation library written in nim."
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.6.6"

# Tasks

import std/[strformat, strutils]

const repo = "https://github.com/aruZeta/QRgen"
const branches = ["develop", "main"]
const mainFile = "src/QRgen.nim"

task gendocs, "Generate documentation in docs folder":
  proc getBranch: string =
    for param in commandLineParams:
      if param[0] != '-': return param
    quit("You have to pass the branch to build docs from")
  let branch = getBranch()
  if branch notin branches:
    quit("Only the branches main and develop can be specified")
  let flags = [
    "--project",
    &"--git.url:\"{repo}\"",
    "--docInternal",
    "--outdir:docs",
    "--path:src",
    &"--git.commit:{branch}",
  ].join " "
  exec &"nim doc {flags} {mainFile}"
