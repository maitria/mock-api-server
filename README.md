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

See `test/server_test.coffee` for more detailed examples.

If you are using Mocha, you can also boot the server in a `before` clause.
It's also possible to boot the server once at the beginning of the test
suite.

## Canned Responses

Canned responses live in your project's `test/mock-api` directory.  This
directory and its subdirectories has the same structure as your API.  For
example, to serve an endpoint `/v2/foobizzle`, populate the file
`test/mock-api/v2/foobizzle.json`.

### Responding to Query Parameters

If you have these these three files:

    test/mock-api/v2/foobizzle.json
    test/mock-api/v2/foobizzle.json?type=search
    test/mock-api/v2/foobizzle.json?type=search&s=foo

then `mock-api-server` will serve the third one when `type=search` and `s=foo`
are provided as query parameters.  If only `type=search` is provided, the second
one will be served--`mock-api-server` will take the most specific matching file.

`*` can be used to match zero or more characters.  For example, the following
file:

    test/mock-api/v2/foobizzle.json?type=*search*

Will match requests with a query parameter `type` containing a value "search"
or "index,search" or "search,index".

Note that most shells will interpret `?`, `*`, and `&`, so to create these
files, you will have to backslash them.  For example:

    $ touch test/mock-api/v2/foobizzle.json\?type=\*search\*\&s=foo
