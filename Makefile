.DEFAULT_GOAL := build

.PHONY: build
## Builds multi-arch images
build: build-mangosd build-realmd

.PHONY: debug
debug: build-debug run-debug

.PHONY: run-debug
## Creates interactive debug container
run-debug:
	docker run -it --rm ziermmar/cmangos-classic-debug:dev

.PHONY: build-debug
## Builds multi-arch images
build-debug:
	docker build --tag ziermmar/cmangos-classic-debug:dev \
	--file Dockerfile.debug .

.PHONY: build-mangosd
## Builds multi-arch images
build-mangosd:
	docker buildx build --push \
	--platform=linux/arm64,linux/amd64 \
	--tag ziermmar/cmangos-classic-mangosd:dev \
	--file Dockerfile.mangosd \
	--target runner .

.PHONY: build-realmd
## Builds multi-arch images
build-realmd:
	docker buildx build --push \
	--platform=linux/arm64,linux/amd64 \
	--tag ziermmar/cmangos-classic-realmd:dev \
	--file Dockerfile.realmd \
	--target runner .

.PHONY: login
## dockerhub login
login:
	docker login

################################################################################

.PHONY: help
## Shows this help
help: show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained: see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) == Darwin && echo '--no-init --raw-control-chars')

