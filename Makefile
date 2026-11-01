SHELL := /bin/bash
SCRIPT_FILES := $(wildcard scripts/*.sh) ota-publish.sh

.PHONY: help check shell phone-test ship-gate stable-install phone-session test

help: ## list targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/^([a-z-]+):.*## (.*)/\1\t\2/'
check: shell phone-test ## the single green gate: script syntax/lint, phone tooling tests, unit tests
	scripts/run-tests.sh unit
test: ## unit + UI tests on a simulator (~2 min)
	scripts/run-tests.sh
shell: ## bash -n (and shellcheck when installed) on every script
	@for f in $(SCRIPT_FILES); do bash -n "$$f" || exit 1; done
	@if command -v shellcheck >/dev/null; then shellcheck -x $(SCRIPT_FILES); fi
phone-test: ## phone tooling: lock, phone-reach, stable-install and ship-gate refusals (phone-reach, xcodebuild, devicectl stubbed)
	scripts/test-phone.sh
ship-gate: ## prove HEAD (clean tree, tests green) and write build/ship-pass/<sha>.json; never touches the phone
	scripts/ship-gate.sh
stable-install: ## install HEAD on the captain's iPhone over Tailscale, no link, no tap; REFUSES without a ship-gate pass
	scripts/stable-install.sh
phone-session: ## run CMD under the phone lock with DEVICE_ID from phone-reach
	@test -n "$$CMD" || { echo "usage: make phone-session CMD='...'" >&2; exit 2; }
	scripts/phone-session.sh bash -c "$$CMD"
