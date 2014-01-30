mock-api-server
===============

A flexible and powerful stand-in API server.

This server is meant to be booted quickly (for example, inside a test suite)
in a Node.js process.

## Booting

From the command-line:

    ./node_modules/.bin/mock-api-server --port PORT

To boot once for a test:

```javascript
var MockApi = require('mock-api-server');
var api = new MockApi({"port": 7000});
api.start(function(err) {
  // ... do stuff ...
  api.stop();
})
```

See `test/server_test.coffee` for more detailed examples.<!-- x_ -->

If you are using Mocha, you can also boot the server in a `before` clause.
It's also possible to boot the server once at the beginning of the test
suite.

## Options

The `MockApi` supports the following options:

<table>
<tr>
  <th>Option</th>
  <th>Description</th>
</tr>
<tr>
  <td>`port`</td>
  <td>The IP port on which the mock server listens.  Must be specified.</td>
</tr>
<tr>
  <td>`logToConsole`</td>
  <td>If `true`, requests will be logged to the console.  Default: `false`.</td>
</tr>
<tr>
  <td>`logToFile`</td>
  <td>If set to a filename, requests will be logged to the specified file.
  If `null` or omitted, no file logging is done.</td>
</tr>
</table>

## Canned Responses

Canned responses live in your project's `test/mock-api` directory.  This
directory and its subdirectories has the same structure as your API.  For
example, to serve an endpoint `/v2/foobizzle`, populate the file
`test/mock-api/GET/v2/foobizzle.json`.

### Responsing to HTTP Methods

Files in the `test/mock-api/GET` subdirectory are used for GET requests.  Files
in `test/mock-api/PUT` subdirectory are used for PUT requests, and so forth.

### Responding to Query Parameters

If you have these three files:

    test/mock-api/GET/v2/foobizzle.json
    test/mock-api/GET/v2/foobizzle.json?type=search
    test/mock-api/GET/v2/foobizzle.json?type=search&s=foo

then `mock-api-server` will serve the third one when `type=search` and `s=foo`
are provided as query parameters.  If only `type=search` is provided, the second
one will be served--`mock-api-server` will take the most specific matching file.

`*` can be used to match zero or more characters.  For example, the following
file:

    test/mock-api/GET/v2/foobizzle.json?type=*search*

Will match requests with a query parameter `type` containing a value "search"
or "index,search" or "search,index".

Note that most shells will interpret `?`, `*`, and `&`, so to create these
files, you will have to backslash them.  For example:

    $ touch test/mock-api/GET/v2/foobizzle.json\?type=\*search\*\&s=foo
