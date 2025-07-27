# Piglet Playground

Interactive web Piglet environment

## Databases

Redis and PostgreSQL:

```
docker compose up
bin/dev psql < schema.sql
```

## REPL / runtime

To work on the frontend:

```
pig run backend start -- --port 4501
```

Open http://localhost:4501 , you get a PDP connection from your browser.

To work on the backend:

Comment out these two lines in backend.pig, so the frontend doesn't try to connect via PDP.

```
'(await (require 'https://piglet-lang.org/packages/piglet:pdp-client))
'(piglet:pdp-client:connect! "ws://127.0.0.1:17017")
```

Then run

```
pig pdp
```

eval backend.pig, including the comment at the bottom, `(cmd-start! {:port 4501})`.
