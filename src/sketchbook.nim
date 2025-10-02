import std/asynchttpserver, std/asyncdispatch
import nimja/parser
import os, random # Used in templates

type Sketch = object
  title: string
  file_name: string
  tags: seq[string]
  date: string

proc render_index(title: string, sketches: seq[Sketch]): string =
  compile_template_file("../templates/index.nimja", base_dir = get_script_dir())

proc main() {.async.} =
  var server = new_async_http_server()

  proc cb(req: Request) {.async.} =
    # Hardcoded data for the template (could come from a DB in a real app)
    let sketches: seq[Sketch] =
      @[
        Sketch(
          title: "Sketch 1",
          file_name: "sketch.png",
          tags: @["sketches"],
          date: "2025-10-01",
        )
      ]
    let html = render_index("Brad's Sketchbook", sketches)
    await req.respond(Http200, html)

  server.listen(Port(8081))
  echo "Server listening on http://localhost:8081/"
  while true:
    if server.should_accept_request():
      await server.accept_request(cb)
    else:
      poll()

async_check main()
run_forever()
