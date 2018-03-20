SHELL=/bin/bash -o pipefail

local: index.bs
	bikeshed spec index.bs index.html

watch: index.bs
	bikeshed watch index.bs index.html

remote: index.bs
	curl https://api.csswg.org/bikeshed/ -f -F file=@index.bs > index.html

# Don't confuse make given we have files called "local" or "remote" in our root dir
.PHONY: local remote
