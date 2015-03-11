# CT-NG Notes

To restart a build its RESTART, not START.

## Mac OS X to x86_64-unknown-linux-gnu

### libintl (gettext) problems under glibc

Some build-time tool under sunrpc (cross-rpcgen) requires gettext.

Homebrew installs gettext to /usr/local/opt/gettext, for whatever dumb
reason. So you need to add that to `CT_EXTRA_CFLAGS_FOR_BUILD` and
`CT_EXTRA_LDFLAGS_FOR_BUILD`.

Also, ct-ng doesn't pass extra build-machine CFLAGS and LDFLAGS to glibc.  I
couldn't find an way to pass them to configure, but they can be passed to make
as `BUILD_LDFLAGS` and `BUILD_CFLAGS`.  Patch to ct-ng is here
https://github.com/smoofra/crosstool-ng/tree/buildflags

### `elf.h` missing for linux headers_install

Linux's headers_install uses a few glibc-specific headers.  I ported the
required headers to Mac OS X. https://github.com/smoofra/fake-glibc

### Mac OS doesn't support static binaries

So just disable those in the config.
