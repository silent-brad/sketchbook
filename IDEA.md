# Idea
A site to host my digital sketches
- Use `convert-to-png` script (make run on krita file changes with `inotify-tools`) to convert drawings to pngs in png dir
- Use rsync over ssh to sync `png` dir with backend hosted on PC or Homelab
  - `rsync -avP ~/Pictures/Drawings/pngs root@server_ip:~/sketches-api/pngs`
- Write script that monitors when krita is open (run `pgrep "krita"` and POST data to backend with API KEY every 5 minutes on Hyprland)
- Make backend (sketckes-api) to display:
  - GET "/api/sketches" -> either JSON or HTML (HTMX) <= ??
  - GET "/api/status" -> Boolean (whether or not krita is open)
  - POST "/api/status" -> Boolean (for use to update status on home machine, requires API KEY)
  - GET "/api/sketches/:id" -> PNG
  - GET "/api/streak" -> Integer (for use to display streak on home machine, requires API KEY)
  - GET "/api/star-calendar" -> JSON (for use to display star calendar)
- Use SQLite DB and folder dir on backend API to store data
- Use minimal UI/pastel color scheme (Burgundy, Light Blue, Mint, Yellow?) (light/dark mode)
- Display star calendar, streak, drawings, status (host on `sketches.knightoffaith.systems`)
- RSS feed for art ???
- Opensource this or make a site others can sign-up for ??
