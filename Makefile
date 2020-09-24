# Copyright (C) 2019-2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

APP = kzenv

VERSION = 1.2.0

GITHUB_API_TOKEN ?=

SHELL = /bin/bash -o pipefail

DIR = $(shell pwd)

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
INFO_COLOR=\033[34;01m

MAKE_COLOR=\033[33;01m%-20s\033[0m

.DEFAULT_GOAL := help

OK=[✅]
KO=[❌]
WARN=[⚠️]

.PHONY: help
help:
	@echo -e "$(OK_COLOR)==== $(APP) [ $(VERSION) ]====$(NO_COLOR)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(MAKE_COLOR) : %s\n", $$1, $$2}'

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "$(ERROR_COLOR)Environment variable $* not set$(NO_COLOR)"; \
		exit 1; \
	fi

check-%:
	@if $$(hash $* 2> /dev/null); then \
		echo -e "$(OK_COLOR)$(OK)$(NO_COLOR) $*"; \
	else \
		echo -e "$(ERROR_COLOR)$(KO)$(NO_COLOR) $*"; \
	fi

.PHONY: check
check: check-bash ## Check requirements

.PHONY: clean
clean: ## Cleanup environment
	rm -fr rm kzenv-*

.PHONY: test
test: ## Run tests
	@echo -e "$(OK_COLOR)[$(APP)] Execute tests$(NO_COLOR)"
	./test/run.sh

.PHONY: dist
dist: ## Create a distribution
	@rm -fr $(APP)-$(VERSION) checksums.txt ; \
		mkdir -p $(APP)-$(VERSION) ; \
		cp ./LICENSE $(APP)-$(VERSION) ; \
		cp ./README.md $(APP)-$(VERSION) ; \
		cp ./CHANGELOG.md $(APP)-$(VERSION) ; \
		cp -r ./bin $(APP)-$(VERSION) ; \
		cp -r ./libexec $(APP)-$(VERSION) ; \
		tar -zcf $(APP)-v${VERSION}.tar.gz $(APP)-$(VERSION) ; \
		zip -r $(APP)-v${VERSION}.zip $(APP)-$(VERSION)
	@for f in $(APP)-v$(VERSION).{tar.gz,zip} ; do \
		sha256sum "$${f}"  | awk '{print $$1}' > "$${f}.sha256" ; \
	done

.PHONY: pkg-archlinux
pkg-archlinux: ## Create Archlinux package
	@cp $(APP)-v$(VERSION).tar.gz packaging/archlinux \
		&& cd packaging/archlinux \
		&& tar zxvf $(APP)-v$(VERSION).tar.gz -C src \
		&& makepkg -f --skipchecksums \
		&& mv kzenv-$(VERSION)*.tar.zst ../../
		# kzenv-*-x86_64.pkg.tar.xz ../../
