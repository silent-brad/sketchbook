import std/asynchttpserver, std/asyncdispatch

#import nimja/parser
from pkgs/nimja/nimja import compile_template_file, get_script_dir

import std/sequtils, std/paths, std/strutils
import os, random

type Sketch = object #title: string
  title: string
  file_name: string
  #tags: seq[string] # detect from subdir and only have 1
  #date: string

proc render_index(title: string, sketches: seq[Sketch]): string =
  compile_template_file("../templates/index.nimja", base_dir = get_script_dir())

proc cb(req: Request) {.async.} =
  var sketches: seq[Sketch] = @[]
  for _, file in walk_dir("sketches/"):
    let filename = file.split("/")[1]
    sketches.add(
      Sketch(title: filename.split(".")[0].replace("_", " "), file_name: filename)
    )

  let html = render_index("Brad's Sketchbook", sketches)
  await req.respond(Http200, html)

proc serve_static_file(req: Request, filename: string) {.async.} =
  # exist -> have access -> can open
  let path = "sketches/" / filename

  # whether exists file
  if not file_exists(path):
    await req.respond(Http404, "File doesn't exist.", newHttpHeaders())

  # whether has access to file
  var filePermission = getFilePermissions(path)
  if fpOthersRead notin filePermission:
    await req.respond(Http403, "You have no access to the file.", newHttpHeaders())

  # whether can open file
  try:
    let content = readFile(path)
    await req.respond(Http200, content, newHttpHeaders())
  except IOError:
    await req.respond(Http404, "404 Not Found.", newHttpHeaders())

proc main() {.async.} =
  var server = new_async_http_server()

  proc handler(req: Request) {.async.} =
    var path = req.url.path
    if path.split("/sketches/").len == 2:
      await serve_static_file(req, path.split("/sketches/")[1])

    case path
    of "/":
      await cb(req)
    else:
      await req.respond(Http404, "404 Not Found.", newHttpHeaders())

  #server.listen(Port(8081))
  wait_for server.serve(Port(8081), handler)
  echo "Server listening on http://localhost:8081/"
  while true:
    if server.should_accept_request():
      await server.accept_request(cb)
    else:
      poll()

async_check main()
run_forever()
