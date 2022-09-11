import
  std/[unittest]

export
  unittest

when defined(benchmark):
  import benchy
  export benchy

template benchmarkTest*(name: string, body: untyped) =
  when defined(benchmark):
    timeIt name:
      body
  else:
    test name:
      body

template benchmark*(name: string, body: untyped) =
  when defined(benchmark):
    timeIt name:
      body

template test*(name: string, body: untyped) =
  when not defined(benchmark):
    test name:
      body
