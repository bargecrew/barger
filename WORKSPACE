load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# rust

http_archive(
    name = "rules_rust",
    strip_prefix = "rules_rust-336e1934b07211fb8736c19749919ef94df4df68",
    urls = [
        "https://github.com/bazelbuild/rules_rust/archive/336e1934b07211fb8736c19749919ef94df4df68.tar.gz",
    ],
)

load("@rules_rust//rust:repositories.bzl", "rust_repositories")

rust_repositories()
