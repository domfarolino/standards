# whatwg
Notes to keep track of the things I learn while working on and learning about web standards

# Working on Fetch domintro boxes

While working on the fetch standard's domintro boxes (https://github.com/whatwg/fetch/issues/543) I
ran down a few rabbit holes. While reading the description of the
[`Request`](https://fetch.spec.whatwg.org/#requests) object I had noticed it mentioned that a `Request`
is the input to the fetch API. I had obviously used a regular string as the first (and sometimes only)
parameter to the fetch API before as have many people, so upon reading the spec I was confused as to how
this worked. I had also vaguely recalled seeing a `URL` object being used as the input parameter for the
fetch API, which added to the confusion. A member of the whatwg organization pointed out over IRC that
step 2 of the [fetch method](https://fetch.spec.whatwg.org/#fetch-method) section of the spec indicated
that whatever we passed in as `input` always went through the
[`Request` constructor](https://fetch.spec.whatwg.org/#dom-request) to sort of sanitize the input. This means
that the following calls to fetch:

 - fetch('https://domfarolino.com')
 - fetch(new URL('https://domfarolino.com'))
 - fetch(new Request('https://domfarolino.com'))

Are the same as:

 - fetch(new Request('https://domfarolino.com'))
 - fetch(new Request(new URL('https://domfarolino.com')))
 - fetch(new Request(new Request('https://domfarolino.com')))

At this point, my confusion about being able to pass in a string, a `URL` object, and a `Request` object still
existed, but had just shifted focus to the `Request` constructor as opposed to the fetch API. What in spec-land
allows us to handle this? When looking at this constructor, I noticed that step 5 handles the case where `input`
is a string, while step `6` handles the case where `input` is an object of type `Request`. So here I wondered how,
if we accept strings and `Request` objects, are we able to accept something like a `URL` object. The answer is
that WebIDL stringifies everything that gets passed into a method taking a `DOMString`/`USVString`, and the `URL`
object has a custom [stringifier](https://url.spec.whatwg.org/#URL-stringification-behavior) which determines its
value when coerced to a string.

So the next question I had was "how would we ever be allowed to perform `step 6` in the `Request` constructor if
request objects passed in could just be coerced to a string (via default stringification) since that's the first
type of object we're looking for?". Well it seems that the `Request` constructor does indeed take multiple types
of input objects, and it was pointed out to me that to convert an object in this type of scenario, the
[ES-Union](https://heycam.github.io/webidl/#es-union) algorithm will be used. In short, this algorithm defines the
steps to run when we convert an object to one of several target types as opposed to a single type. These target
types are specified in WebIDL as a [union type](https://heycam.github.io/webidl/#idl-union). The `Request` class
IDL in the fetch spec defines [RequestInfo](https://fetch.spec.whatwg.org/#requestinfo) as a union type of
`Request or USVString`. The WebIDL es-union algorithm will first convert some object to a type found in the union
of the Ecmascript object implements one of the types. As a result, we'll see if we'll if input objects to the
`Request` constructor are also `Request` objects (step 4, substep 1) **before** we try converting to a string type
(step 11).
