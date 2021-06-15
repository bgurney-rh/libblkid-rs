RUST_2018_IDIOMS = -D bare-trait-objects \
                   -D ellipsis-inclusive-range-patterns \
                   -D unused-extern-crates

DENY = -D warnings -D future-incompatible -D unused ${RUST_2018_IDIOMS}

${HOME}/.cargo/bin/cargo-audit:
	cargo install cargo-audit

audit: ${HOME}/.cargo/bin/cargo-audit
	PATH=${HOME}/.cargo/bin:${PATH} cargo audit -D warnings

build:
	RUSTFLAGS="${DENY}" cargo build

build-deprecated:
	RUSTFLAGS="${DENY}" cargo build --features=deprecated

check-fedora-versions:
	`${COMPARE_FEDORA_VERSIONS} | jq '[.missing == ["libblkid-rs-sys"], .high == []] | all'`

check-fedora-versions-sys:
	`${COMPARE_FEDORA_VERSIONS} \
	--manifest-path=./libblkid-rs-sys/Cargo.toml \
	| jq '[.missing == [], .high == []] | all'`

clippy:
	cargo clippy --all-targets --all-features -- -D warnings -D clippy::needless_borrow -A clippy::upper_case_acronyms -A clippy::from_over_into

docs-rust:
	cargo doc --no-deps --package libblkid-rs --package libblkid-rs-sys

docs-travis: docs-rust

yamllint:
	yamllint --strict .github/workflows/*.yml

fmt:
	cargo fmt

fmt-travis:
	cargo fmt -- --check

release:
	RUSTFLAGS="${DENY}" cargo build --release

test:
	RUSTFLAGS="${DENY}" RUST_BACKTRACE=1 cargo test

.PHONY:
	build
	check-fedora-versions
	check-fedora-versions-sys
	clippy
	docs-rust
	docs-travis
	fmt
	fmt-travis
	release
	test
	yamllint
