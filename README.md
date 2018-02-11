# standards

Things I learn while working on web standards. This repository largely contains information about
things like [WebIDL](https://heycam.github.io/webidl/) and [Bikeshed](https://tabatkins.github.io/bikeshed/),
but also houses some interesting historical standards decisions made by WHATWG and W3C. For example,
see item #3 in the [Table of Contents](#table-of-contents).

# Table of Contents:

 - [Bikeshed `for=/`](#for)
 - [Utility of Request mode and redirect internal slots](#utility-of-request-mode-and-redirect-internal-slots)

---

# `for=/`

I wondered what the purpose of `for=/` was in `<a for=/>referrer policy</a>`. After a quick read of the bikeshed
documentation I learned that it was to link to a `<dfn>` which doesn't have a `for` attribute. We use it in cases
where there exist ambiguous `<dfn>` tags. In this particular case, both the
<a href=https://w3c.github.io/webappsec-referrer-policy/>referrer policy</a> and fetch specifications define the term
**referrer policy**. The referrer policy spec defines [it](https://w3c.github.io/webappsec-referrer-policy/#referrer-policy)
as a regular definition with no `for` attribute representing an enum, however fetch defines it as a concept associated with
"`request`" objects. Therefore later in the spec when we are referring to a value that must be of type `referrer policy`
(as in, a value that exists in the enum defined by the referrer policy spec) we must link our term to the correct definition
since there is a little ambiguity. We don't want to refer to the concept associated with (`for`) "`request`" objects, so we
explicitly tell bikeshed we want to be linked to the `<dfn>` that doesn't have a `for` attribute. Bam.

----

# Utility of Request `mode` and `redirect` internal slots

> This is a short explanation on the utility of Request's `{mode: "no-cors"}` and `{redirect: "manual"}` settings in the
> Fetch specification.

While reading the fetch standard, I was wondering what the point of Requests with things like `{mode: "no-cors"}`,
and `{redirect: "manual"}` were. Upon looking both things up independently, I learned that most had little or no
utility in general web application code, but existed because:

 - Web browsers make use of them internally for other requests (since the Fetch spec defines a general request object)
 - They could be of use when dealing with a ServiceWorker

I was a tad vexed to find that they both gave me similar findings (people saying typically you don't want to use them
unless doing something tricky/niche with a ServiceWorker), which made me curious as to why this was.
[This](https://stackoverflow.com/questions/42716082/fetch-api-whats-the-use-of-redirect-manual/42717388#42717388)
stackoverflow answer was particularly useful and helped me remember that yes, other standards (like HTML) use the
Fetch specification to make internal requests that are not directly exposed. For example, in a blog post, Jake Archibald
points out that `<img>` makes requests whose mode is `no-cors`, whereas `<img crossorigin>` makes requests whose mode is
`cors`. This is useful because a lot of CDN content is not familiar with the CORS protocol, so the `<img>` element is happy
with an opaque response so long as it can display it to the user without exposing it to application code. Prior to
ServiceWorkers, we wouldn't have much of a reason to kick off a request for an image via `fetch` that returns an opaque
response, however with ServiceWorkers, this becomes commonplace.
[This](https://github.com/domfarolino/pwa-meetup/blob/05-Full-Offline/public/sw.js#L3) example shows this behavior in action,
where we want to retrieve an image (or some x-origin) assets right when a ServiceWorker is registered so we can serve them
(opaquely) later in response to DOM requests for the same assets.

Furthermore, the GitHub issue in the above stackoverflow answer points out why a redirect mode of "manual" can be useful
in web application code in a few corner cases where ServiceWorkers need to handle redirects in a way that is consistent
with the rest of the platform.
