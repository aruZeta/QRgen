# Package

version       = "1.0.1"
author        = "aruZeta"
description   = "A QR code generation library."
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.6.0"

# Tasks

import std/[strformat, strutils]
from os import walkDir, extractFilename

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

task test, "Run tests on /test":
  let flags = [
    "--colors:on",
    "--verbosity:2",
    "--hints:off",
    "--hint:GCStats:on",
    "--hint:LineTooLong:on",
    "--hint:XDeclaredButNotUsed:on",
    "-w:on",
    "--styleCheck:error",
    "--spellsuggest:auto",
    "-f"
  ].join " "
  for file in walkDir("tests/"):
    let fileName = file.path.extractFilename
    if fileName[0..3] == "test" and fileName[^4..^1] == ".nim":
      exec &"nim c -r {flags} {file.path}"
