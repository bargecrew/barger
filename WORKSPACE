load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# rust

http_archive(
    name = "rules_rust",
    sha256 = "d10dd5581f66ee169071ee06d52c52c8c7ca7467ac6266e301c0820d289b0f0b",
    strip_prefix = "rules_rust-336e1934b07211fb8736c19749919ef94df4df68",
    url = "https://github.com/bazelbuild/rules_rust/archive/336e1934b07211fb8736c19749919ef94df4df68.tar.gz",
)

load("@rules_rust//rust:repositories.bzl", "rust_repositories")

rust_repositories(
    edition = "2018",
    version = "1.51.0",
)

load("//bazel/rust/raze:crates.bzl", "raze_fetch_remote_crates")

raze_fetch_remote_crates()
