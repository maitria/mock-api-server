mock-api-server
===============

A flexible and powerful stand-in API server.

This server is meant to be booted quickly (for example, inside a test suite)
in a Node.js process.

## Booting

To boot once for a test:

```javascript
var mockApiServer = require('mock-api-server');
mockApiServer({"port": 7000}, function(err, server) {
  // ... do stuff ...
  server.stop();
});
```

See `test/server\_test.coffee` for more detailed examples.

If you are using Mocha, you can also boot the server in a `before` clause.
It's also possible to boot the server once at the beginning of the test
suite.

## Canned Responses

Canned responses live in your project's `test/mock-api` directory.  This
directory and its subdirectories has the same structure as your API.  For
example, to serve an endpoint `/v2/foobizzle`, populate the file
`test/mock-api/v2/foobizzle.json`.

### Responding to Query Parameters

If you have these two files:

    test/mock-api/v2/foobizzle.json
    test/mock-api/v2/type=search,foobizzle.json

then `mock-api-server` will serve the second one when `type=search` is provided
as a query parameter.  Multiple query parameters can be encoded in the filename.
`mock-api-server` will take the most specific matching file.

`%` can be used as a wildcard for query parameter values.  It will match zero
or more characters.  For example, the following file:

    test/mock-api/v2/type=%search%,foobizzle.json

Will match requests with a query parameter `type` containing a value "<search>"
or "index,search" or "search,index".
