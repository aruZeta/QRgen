# Package

version       = "3.1.0"
author        = "aruZeta"
description   = "A QR code generation library."
license       = "MIT"
srcDir        = "src"
skipFiles     = @["generateRepoImages.nim"]

# Dependencies

requires "nim >= 1.6.0"

# Tasks

import std/[strformat, strutils]
from os import walkDir, extractFilename

const repo = "https://github.com/aruZeta/QRgen"
const branches = ["develop", "main"]
const mainFile = "src/QRgen.nim"

task gendocs, "Generate documentation in docs folder":
  proc getName: string =
    for param in commandLineParams:
      if param[0] != '-': return param
    quit("You have to pass a name as the directory to store the generated docs")
  let dir = getName()
  if not(dir in branches or dir[0] == 'v'):
    quit("The name can only be a branch name or tag name")
  let flags = [
    "--project",
    &"--git.url:\"{repo}\"",
    (if dir == "develop": "--docInternal"
     else: ""),
    &"--git.commit:{dir}",
  ].join " "
  exec &"nim doc {flags} --path:.. --outdir:docs/QRgen src/QRgen/renderer.nim"
  exec &"nim doc {flags} --path:. --outdir:docs {mainFile}"

task test, "Run tests on /test":
  let flags = [
    "--colors:on",
    "--verbosity:2",
    "--hints:off",
    "--hint:GCStats:on",
    "--hint:LineTooLong:on",
    "--hint:XDeclaredButNotUsed:on",
    "-w:on",
    "--styleCheck:hint",
    "--spellsuggest:auto",
    "-f"
  ].join " "
  for file in walkDir("tests/"):
    let fileName = file.path.extractFilename
    if fileName[0..3] == "test" and fileName[^4..^1] == ".nim":
      exec &"nim c -r {flags} {file.path}"

task benchmark, "Run benchmarks on /test":
  let flags = [
    "--colors:on",
    "--verbosity:0",
    "--hints:off",
    "-w:off",
    "-f",
    "-d:benchmark",
    "--mm:orc",
    "-d:lto"
  ].join " "
  for file in walkDir("tests/"):
    let fileName = file.path.extractFilename
    if fileName[0..3] == "test" and fileName[^4..^1] == ".nim":
      exec &"nim c -r {flags} {file.path}"
