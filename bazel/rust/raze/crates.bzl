"""
@generated
cargo-raze generated Bazel file.

DO NOT EDIT! Replaced on runs of cargo-raze
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

# EXPERIMENTAL -- MAY CHANGE AT ANY TIME: A mapping of package names to a set of normal dependencies for the Rust targets of that package.
_DEPENDENCIES = {
    "/client": {
        "clap": "@raze__clap__2_33_3//:clap",
        "dirs": "@raze__dirs__3_0_1//:dirs",
        "jsonwebtoken": "@raze__jsonwebtoken__7_2_0//:jsonwebtoken",
        "reqwest": "@raze__reqwest__0_11_2//:reqwest",
        "serde": "@raze__serde__1_0_125//:serde",
        "tokio": "@raze__tokio__1_4_0//:tokio",
        "toml": "@raze__toml__0_5_8//:toml",
    },
    "/server": {
        "actix-cors": "@raze__actix_cors__0_5_4//:actix_cors",
        "actix-web": "@raze__actix_web__3_3_2//:actix_web",
        "actix-web-httpauth": "@raze__actix_web_httpauth__0_5_1//:actix_web_httpauth",
        "chrono": "@raze__chrono__0_4_19//:chrono",
        "diesel": "@raze__diesel__1_4_6//:diesel",
        "dotenv": "@raze__dotenv__0_15_0//:dotenv",
        "jsonwebtoken": "@raze__jsonwebtoken__7_2_0//:jsonwebtoken",
        "serde": "@raze__serde__1_0_125//:serde",
    },
}

# EXPERIMENTAL -- MAY CHANGE AT ANY TIME: A mapping of package names to a set of proc_macro dependencies for the Rust targets of that package.
_PROC_MACRO_DEPENDENCIES = {
    "/client": {
        "serde_derive": "@raze__serde_derive__1_0_125//:serde_derive",
    },
    "/server": {
    },
}

# EXPERIMENTAL -- MAY CHANGE AT ANY TIME: A mapping of package names to a set of normal dev dependencies for the Rust targets of that package.
_DEV_DEPENDENCIES = {
    "/client": {
    },
    "/server": {
        "actix-rt": "@raze__actix_rt__2_1_0//:actix_rt",
    },
}

# EXPERIMENTAL -- MAY CHANGE AT ANY TIME: A mapping of package names to a set of proc_macro dev dependencies for the Rust targets of that package.
_DEV_PROC_MACRO_DEPENDENCIES = {
    "/client": {
    },
    "/server": {
    },
}

def crate_deps(deps, package_name = None):
    """EXPERIMENTAL -- MAY CHANGE AT ANY TIME: Finds the fully qualified label of the requested crates for the package where this macro is called.

    WARNING: This macro is part of an expeirmental API and is subject to change.

    Args:
        deps (list): The desired list of crate targets.
        package_name (str, optional): The package name of the set of dependencies to look up.
            Defaults to `native.package_name()`.
    Returns:
        list: A list of labels to cargo-raze generated targets (str)
    """

    if not package_name:
        package_name = native.package_name()

    # Join both sets of dependencies
    dependencies = _flatten_dependency_maps([
        _DEPENDENCIES,
        _PROC_MACRO_DEPENDENCIES,
        _DEV_DEPENDENCIES,
        _DEV_PROC_MACRO_DEPENDENCIES,
    ])

    if not deps:
        return []

    missing_crates = []
    crate_targets = []
    for crate_target in deps:
        if crate_target not in dependencies[package_name]:
            missing_crates.append(crate_target)
        else:
            crate_targets.append(dependencies[package_name][crate_target])

    if missing_crates:
        fail("Could not find crates `{}` among dependencies of `{}`. Available dependencies were `{}`".format(
            missing_crates,
            package_name,
            dependencies[package_name],
        ))

    return crate_targets

def all_crate_deps(normal = False, normal_dev = False, proc_macro = False, proc_macro_dev = False, package_name = None):
    """EXPERIMENTAL -- MAY CHANGE AT ANY TIME: Finds the fully qualified label of all requested direct crate dependencies \
    for the package where this macro is called.

    If no parameters are set, all normal dependencies are returned. Setting any one flag will
    otherwise impact the contents of the returned list.

    Args:
        normal (bool, optional): If True, normal dependencies are included in the
            output list. Defaults to False.
        normal_dev (bool, optional): If True, normla dev dependencies will be
            included in the output list. Defaults to False.
        proc_macro (bool, optional): If True, proc_macro dependencies are included
            in the output list. Defaults to False.
        proc_macro_dev (bool, optional): If True, dev proc_macro dependencies are
            included in the output list. Defaults to False.
        package_name (str, optional): The package name of the set of dependencies to look up.
            Defaults to `native.package_name()`.

    Returns:
        list: A list of labels to cargo-raze generated targets (str)
    """

    if not package_name:
        package_name = native.package_name()

    # Determine the relevant maps to use
    all_dependency_maps = []
    if normal:
        all_dependency_maps.append(_DEPENDENCIES)
    if normal_dev:
        all_dependency_maps.append(_DEV_DEPENDENCIES)
    if proc_macro:
        all_dependency_maps.append(_PROC_MACRO_DEPENDENCIES)
    if proc_macro_dev:
        all_dependency_maps.append(_DEV_PROC_MACRO_DEPENDENCIES)

    # Default to always using normal dependencies
    if not all_dependency_maps:
        all_dependency_maps.append(_DEPENDENCIES)

    dependencies = _flatten_dependency_maps(all_dependency_maps)

    if not dependencies:
        return []

    return dependencies[package_name].values()

def _flatten_dependency_maps(all_dependency_maps):
    """Flatten a list of dependency maps into one dictionary.

    Dependency maps have the following structure:

    ```python
    DEPENDENCIES_MAP = {
        # The first key in the map is a Bazel package
        # name of the workspace this file is defined in.
        "package_name": {

            # An alias to a crate target.     # The label of the crate target the
            # Aliases are only crate names.   # alias refers to.
            "alias":                          "@full//:label",
        }
    }
    ```

    Args:
        all_dependency_maps (list): A list of dicts as described above

    Returns:
        dict: A dictionary as described above
    """
    dependencies = {}

    for dep_map in all_dependency_maps:
        for pkg_name in dep_map:
            if pkg_name not in dependencies:
                # Add a non-frozen dict to the collection of dependencies
                dependencies.setdefault(pkg_name, dict(dep_map[pkg_name].items()))
                continue

            duplicate_crate_aliases = [key for key in dependencies[pkg_name] if key in dep_map[pkg_name]]
            if duplicate_crate_aliases:
                fail("There should be no duplicate crate aliases: {}".format(duplicate_crate_aliases))

            dependencies[pkg_name].update(dep_map[pkg_name])

    return dependencies

def raze_fetch_remote_crates():
    """This function defines a collection of repos and should be called in a WORKSPACE file"""
    maybe(
        http_archive,
        name = "raze__actix_codec__0_3_0",
        url = "https://crates.io/api/v1/crates/actix-codec/0.3.0/download",
        type = "tar.gz",
        sha256 = "78d1833b3838dbe990df0f1f87baf640cf6146e898166afe401839d1b001e570",
        strip_prefix = "actix-codec-0.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-codec-0.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_connect__2_0_0",
        url = "https://crates.io/api/v1/crates/actix-connect/2.0.0/download",
        type = "tar.gz",
        sha256 = "177837a10863f15ba8d3ae3ec12fac1099099529ed20083a27fdfe247381d0dc",
        strip_prefix = "actix-connect-2.0.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-connect-2.0.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_cors__0_5_4",
        url = "https://crates.io/api/v1/crates/actix-cors/0.5.4/download",
        type = "tar.gz",
        sha256 = "36b133d8026a9f209a9aeeeacd028e7451bcca975f592881b305d37983f303d7",
        strip_prefix = "actix-cors-0.5.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-cors-0.5.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_http__2_2_0",
        url = "https://crates.io/api/v1/crates/actix-http/2.2.0/download",
        type = "tar.gz",
        sha256 = "452299e87817ae5673910e53c243484ca38be3828db819b6011736fc6982e874",
        strip_prefix = "actix-http-2.2.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-http-2.2.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_macros__0_1_3",
        url = "https://crates.io/api/v1/crates/actix-macros/0.1.3/download",
        type = "tar.gz",
        sha256 = "b4ca8ce00b267af8ccebbd647de0d61e0674b6e61185cc7a592ff88772bed655",
        strip_prefix = "actix-macros-0.1.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-macros-0.1.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_macros__0_2_0",
        url = "https://crates.io/api/v1/crates/actix-macros/0.2.0/download",
        type = "tar.gz",
        sha256 = "dbcb2b608f0accc2f5bcf3dd872194ce13d94ee45b571487035864cf966b04ef",
        strip_prefix = "actix-macros-0.2.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-macros-0.2.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_router__0_2_7",
        url = "https://crates.io/api/v1/crates/actix-router/0.2.7/download",
        type = "tar.gz",
        sha256 = "2ad299af73649e1fc893e333ccf86f377751eb95ff875d095131574c6f43452c",
        strip_prefix = "actix-router-0.2.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-router-0.2.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_rt__1_1_1",
        url = "https://crates.io/api/v1/crates/actix-rt/1.1.1/download",
        type = "tar.gz",
        sha256 = "143fcc2912e0d1de2bcf4e2f720d2a60c28652ab4179685a1ee159e0fb3db227",
        strip_prefix = "actix-rt-1.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-rt-1.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_rt__2_1_0",
        url = "https://crates.io/api/v1/crates/actix-rt/2.1.0/download",
        type = "tar.gz",
        sha256 = "0b4e57bc1a3915e71526d128baf4323700bd1580bc676239e2298a4c5b001f18",
        strip_prefix = "actix-rt-2.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-rt-2.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_server__1_0_4",
        url = "https://crates.io/api/v1/crates/actix-server/1.0.4/download",
        type = "tar.gz",
        sha256 = "45407e6e672ca24784baa667c5d32ef109ccdd8d5e0b5ebb9ef8a67f4dfb708e",
        strip_prefix = "actix-server-1.0.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-server-1.0.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_service__1_0_6",
        url = "https://crates.io/api/v1/crates/actix-service/1.0.6/download",
        type = "tar.gz",
        sha256 = "0052435d581b5be835d11f4eb3bce417c8af18d87ddf8ace99f8e67e595882bb",
        strip_prefix = "actix-service-1.0.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-service-1.0.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_testing__1_0_1",
        url = "https://crates.io/api/v1/crates/actix-testing/1.0.1/download",
        type = "tar.gz",
        sha256 = "47239ca38799ab74ee6a8a94d1ce857014b2ac36f242f70f3f75a66f691e791c",
        strip_prefix = "actix-testing-1.0.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-testing-1.0.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_threadpool__0_3_3",
        url = "https://crates.io/api/v1/crates/actix-threadpool/0.3.3/download",
        type = "tar.gz",
        sha256 = "d209f04d002854b9afd3743032a27b066158817965bf5d036824d19ac2cc0e30",
        strip_prefix = "actix-threadpool-0.3.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-threadpool-0.3.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_tls__2_0_0",
        url = "https://crates.io/api/v1/crates/actix-tls/2.0.0/download",
        type = "tar.gz",
        sha256 = "24789b7d7361cf5503a504ebe1c10806896f61e96eca9a7350e23001aca715fb",
        strip_prefix = "actix-tls-2.0.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-tls-2.0.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_utils__2_0_0",
        url = "https://crates.io/api/v1/crates/actix-utils/2.0.0/download",
        type = "tar.gz",
        sha256 = "2e9022dec56632d1d7979e59af14f0597a28a830a9c1c7fec8b2327eb9f16b5a",
        strip_prefix = "actix-utils-2.0.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-utils-2.0.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_web__3_3_2",
        url = "https://crates.io/api/v1/crates/actix-web/3.3.2/download",
        type = "tar.gz",
        sha256 = "e641d4a172e7faa0862241a20ff4f1f5ab0ab7c279f00c2d4587b77483477b86",
        strip_prefix = "actix-web-3.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-web-3.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_web_codegen__0_4_0",
        url = "https://crates.io/api/v1/crates/actix-web-codegen/0.4.0/download",
        type = "tar.gz",
        sha256 = "ad26f77093333e0e7c6ffe54ebe3582d908a104e448723eec6d43d08b07143fb",
        strip_prefix = "actix-web-codegen-0.4.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-web-codegen-0.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__actix_web_httpauth__0_5_1",
        url = "https://crates.io/api/v1/crates/actix-web-httpauth/0.5.1/download",
        type = "tar.gz",
        sha256 = "0c3b11a07a3df3f7970fd8bd38cc66998b5549f507c54cc64c6e843bc82d6358",
        strip_prefix = "actix-web-httpauth-0.5.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.actix-web-httpauth-0.5.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__adler__1_0_2",
        url = "https://crates.io/api/v1/crates/adler/1.0.2/download",
        type = "tar.gz",
        sha256 = "f26201604c87b1e01bd3d98f8d5d9a8fcbb815e8cedb41ffccbeb4bf593a35fe",
        strip_prefix = "adler-1.0.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.adler-1.0.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__aho_corasick__0_7_15",
        url = "https://crates.io/api/v1/crates/aho-corasick/0.7.15/download",
        type = "tar.gz",
        sha256 = "7404febffaa47dac81aa44dba71523c9d069b1bdc50a77db41195149e17f68e5",
        strip_prefix = "aho-corasick-0.7.15",
        build_file = Label("//bazel/rust/raze/remote:BUILD.aho-corasick-0.7.15.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ansi_term__0_11_0",
        url = "https://crates.io/api/v1/crates/ansi_term/0.11.0/download",
        type = "tar.gz",
        sha256 = "ee49baf6cb617b853aa8d93bf420db2383fab46d314482ca2803b40d5fde979b",
        strip_prefix = "ansi_term-0.11.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ansi_term-0.11.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__arrayref__0_3_6",
        url = "https://crates.io/api/v1/crates/arrayref/0.3.6/download",
        type = "tar.gz",
        sha256 = "a4c527152e37cf757a3f78aae5a06fbeefdb07ccc535c980a3208ee3060dd544",
        strip_prefix = "arrayref-0.3.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.arrayref-0.3.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__arrayvec__0_5_2",
        url = "https://crates.io/api/v1/crates/arrayvec/0.5.2/download",
        type = "tar.gz",
        sha256 = "23b62fc65de8e4e7f52534fb52b0f3ed04746ae267519eef2a83941e8085068b",
        strip_prefix = "arrayvec-0.5.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.arrayvec-0.5.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__async_trait__0_1_48",
        url = "https://crates.io/api/v1/crates/async-trait/0.1.48/download",
        type = "tar.gz",
        sha256 = "36ea56748e10732c49404c153638a15ec3d6211ec5ff35d9bb20e13b93576adf",
        strip_prefix = "async-trait-0.1.48",
        build_file = Label("//bazel/rust/raze/remote:BUILD.async-trait-0.1.48.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__atty__0_2_14",
        url = "https://crates.io/api/v1/crates/atty/0.2.14/download",
        type = "tar.gz",
        sha256 = "d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8",
        strip_prefix = "atty-0.2.14",
        build_file = Label("//bazel/rust/raze/remote:BUILD.atty-0.2.14.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__autocfg__1_0_1",
        url = "https://crates.io/api/v1/crates/autocfg/1.0.1/download",
        type = "tar.gz",
        sha256 = "cdb031dd78e28731d87d56cc8ffef4a8f36ca26c38fe2de700543e627f8a464a",
        strip_prefix = "autocfg-1.0.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.autocfg-1.0.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__awc__2_0_3",
        url = "https://crates.io/api/v1/crates/awc/2.0.3/download",
        type = "tar.gz",
        sha256 = "b381e490e7b0cfc37ebc54079b0413d8093ef43d14a4e4747083f7fa47a9e691",
        strip_prefix = "awc-2.0.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.awc-2.0.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__base_x__0_2_8",
        url = "https://crates.io/api/v1/crates/base-x/0.2.8/download",
        type = "tar.gz",
        sha256 = "a4521f3e3d031370679b3b140beb36dfe4801b09ac77e30c61941f97df3ef28b",
        strip_prefix = "base-x-0.2.8",
        build_file = Label("//bazel/rust/raze/remote:BUILD.base-x-0.2.8.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__base64__0_12_3",
        url = "https://crates.io/api/v1/crates/base64/0.12.3/download",
        type = "tar.gz",
        sha256 = "3441f0f7b02788e948e47f457ca01f1d7e6d92c693bc132c22b087d3141c03ff",
        strip_prefix = "base64-0.12.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.base64-0.12.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__base64__0_13_0",
        url = "https://crates.io/api/v1/crates/base64/0.13.0/download",
        type = "tar.gz",
        sha256 = "904dfeac50f3cdaba28fc6f57fdcddb75f49ed61346676a78c4ffe55877802fd",
        strip_prefix = "base64-0.13.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.base64-0.13.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__bitflags__1_2_1",
        url = "https://crates.io/api/v1/crates/bitflags/1.2.1/download",
        type = "tar.gz",
        sha256 = "cf1de2fe8c75bc145a2f577add951f8134889b4795d47466a54a5c846d691693",
        strip_prefix = "bitflags-1.2.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.bitflags-1.2.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__blake2b_simd__0_5_11",
        url = "https://crates.io/api/v1/crates/blake2b_simd/0.5.11/download",
        type = "tar.gz",
        sha256 = "afa748e348ad3be8263be728124b24a24f268266f6f5d58af9d75f6a40b5c587",
        strip_prefix = "blake2b_simd-0.5.11",
        build_file = Label("//bazel/rust/raze/remote:BUILD.blake2b_simd-0.5.11.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__block_buffer__0_9_0",
        url = "https://crates.io/api/v1/crates/block-buffer/0.9.0/download",
        type = "tar.gz",
        sha256 = "4152116fd6e9dadb291ae18fc1ec3575ed6d84c29642d97890f4b4a3417297e4",
        strip_prefix = "block-buffer-0.9.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.block-buffer-0.9.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__brotli_sys__0_3_2",
        url = "https://crates.io/api/v1/crates/brotli-sys/0.3.2/download",
        type = "tar.gz",
        sha256 = "4445dea95f4c2b41cde57cc9fee236ae4dbae88d8fcbdb4750fc1bb5d86aaecd",
        strip_prefix = "brotli-sys-0.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.brotli-sys-0.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__brotli2__0_3_2",
        url = "https://crates.io/api/v1/crates/brotli2/0.3.2/download",
        type = "tar.gz",
        sha256 = "0cb036c3eade309815c15ddbacec5b22c4d1f3983a774ab2eac2e3e9ea85568e",
        strip_prefix = "brotli2-0.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.brotli2-0.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__bumpalo__3_6_1",
        url = "https://crates.io/api/v1/crates/bumpalo/3.6.1/download",
        type = "tar.gz",
        sha256 = "63396b8a4b9de3f4fdfb320ab6080762242f66a8ef174c49d8e19b674db4cdbe",
        strip_prefix = "bumpalo-3.6.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.bumpalo-3.6.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__byteorder__1_4_3",
        url = "https://crates.io/api/v1/crates/byteorder/1.4.3/download",
        type = "tar.gz",
        sha256 = "14c189c53d098945499cdfa7ecc63567cf3886b3332b312a5b4585d8d3a6a610",
        strip_prefix = "byteorder-1.4.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.byteorder-1.4.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__bytes__0_5_6",
        url = "https://crates.io/api/v1/crates/bytes/0.5.6/download",
        type = "tar.gz",
        sha256 = "0e4cec68f03f32e44924783795810fa50a7035d8c8ebe78580ad7e6c703fba38",
        strip_prefix = "bytes-0.5.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.bytes-0.5.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__bytes__1_0_1",
        url = "https://crates.io/api/v1/crates/bytes/1.0.1/download",
        type = "tar.gz",
        sha256 = "b700ce4376041dcd0a327fd0097c41095743c4c8af8887265942faf1100bd040",
        strip_prefix = "bytes-1.0.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.bytes-1.0.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__bytestring__1_0_0",
        url = "https://crates.io/api/v1/crates/bytestring/1.0.0/download",
        type = "tar.gz",
        sha256 = "90706ba19e97b90786e19dc0d5e2abd80008d99d4c0c5d1ad0b5e72cec7c494d",
        strip_prefix = "bytestring-1.0.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.bytestring-1.0.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__cc__1_0_67",
        url = "https://crates.io/api/v1/crates/cc/1.0.67/download",
        type = "tar.gz",
        sha256 = "e3c69b077ad434294d3ce9f1f6143a2a4b89a8a2d54ef813d85003a4fd1137fd",
        strip_prefix = "cc-1.0.67",
        build_file = Label("//bazel/rust/raze/remote:BUILD.cc-1.0.67.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__cfg_if__0_1_10",
        url = "https://crates.io/api/v1/crates/cfg-if/0.1.10/download",
        type = "tar.gz",
        sha256 = "4785bdd1c96b2a846b2bd7cc02e86b6b3dbf14e7e53446c4f54c92a361040822",
        strip_prefix = "cfg-if-0.1.10",
        build_file = Label("//bazel/rust/raze/remote:BUILD.cfg-if-0.1.10.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__cfg_if__1_0_0",
        url = "https://crates.io/api/v1/crates/cfg-if/1.0.0/download",
        type = "tar.gz",
        sha256 = "baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd",
        strip_prefix = "cfg-if-1.0.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.cfg-if-1.0.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__chrono__0_4_19",
        url = "https://crates.io/api/v1/crates/chrono/0.4.19/download",
        type = "tar.gz",
        sha256 = "670ad68c9088c2a963aaa298cb369688cf3f9465ce5e2d4ca10e6e0098a1ce73",
        strip_prefix = "chrono-0.4.19",
        build_file = Label("//bazel/rust/raze/remote:BUILD.chrono-0.4.19.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__clap__2_33_3",
        url = "https://crates.io/api/v1/crates/clap/2.33.3/download",
        type = "tar.gz",
        sha256 = "37e58ac78573c40708d45522f0d80fa2f01cc4f9b4e2bf749807255454312002",
        strip_prefix = "clap-2.33.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.clap-2.33.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__const_fn__0_4_5",
        url = "https://crates.io/api/v1/crates/const_fn/0.4.5/download",
        type = "tar.gz",
        sha256 = "28b9d6de7f49e22cf97ad17fc4036ece69300032f45f78f30b4a4482cdc3f4a6",
        strip_prefix = "const_fn-0.4.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.const_fn-0.4.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__constant_time_eq__0_1_5",
        url = "https://crates.io/api/v1/crates/constant_time_eq/0.1.5/download",
        type = "tar.gz",
        sha256 = "245097e9a4535ee1e3e3931fcfcd55a796a44c643e8596ff6566d68f09b87bbc",
        strip_prefix = "constant_time_eq-0.1.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.constant_time_eq-0.1.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__convert_case__0_4_0",
        url = "https://crates.io/api/v1/crates/convert_case/0.4.0/download",
        type = "tar.gz",
        sha256 = "6245d59a3e82a7fc217c5828a6692dbc6dfb63a0c8c90495621f7b9d79704a0e",
        strip_prefix = "convert_case-0.4.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.convert_case-0.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__cookie__0_14_4",
        url = "https://crates.io/api/v1/crates/cookie/0.14.4/download",
        type = "tar.gz",
        sha256 = "03a5d7b21829bc7b4bf4754a978a241ae54ea55a40f92bb20216e54096f4b951",
        strip_prefix = "cookie-0.14.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.cookie-0.14.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__copyless__0_1_5",
        url = "https://crates.io/api/v1/crates/copyless/0.1.5/download",
        type = "tar.gz",
        sha256 = "a2df960f5d869b2dd8532793fde43eb5427cceb126c929747a26823ab0eeb536",
        strip_prefix = "copyless-0.1.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.copyless-0.1.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__core_foundation__0_9_1",
        url = "https://crates.io/api/v1/crates/core-foundation/0.9.1/download",
        type = "tar.gz",
        sha256 = "0a89e2ae426ea83155dccf10c0fa6b1463ef6d5fcb44cee0b224a408fa640a62",
        strip_prefix = "core-foundation-0.9.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.core-foundation-0.9.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__core_foundation_sys__0_8_2",
        url = "https://crates.io/api/v1/crates/core-foundation-sys/0.8.2/download",
        type = "tar.gz",
        sha256 = "ea221b5284a47e40033bf9b66f35f984ec0ea2931eb03505246cd27a963f981b",
        strip_prefix = "core-foundation-sys-0.8.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.core-foundation-sys-0.8.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__cpuid_bool__0_1_2",
        url = "https://crates.io/api/v1/crates/cpuid-bool/0.1.2/download",
        type = "tar.gz",
        sha256 = "8aebca1129a03dc6dc2b127edd729435bbc4a37e1d5f4d7513165089ceb02634",
        strip_prefix = "cpuid-bool-0.1.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.cpuid-bool-0.1.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__crc32fast__1_2_1",
        url = "https://crates.io/api/v1/crates/crc32fast/1.2.1/download",
        type = "tar.gz",
        sha256 = "81156fece84ab6a9f2afdb109ce3ae577e42b1228441eded99bd77f627953b1a",
        strip_prefix = "crc32fast-1.2.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.crc32fast-1.2.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__crossbeam_utils__0_8_3",
        url = "https://crates.io/api/v1/crates/crossbeam-utils/0.8.3/download",
        type = "tar.gz",
        sha256 = "e7e9d99fa91428effe99c5c6d4634cdeba32b8cf784fc428a2a687f61a952c49",
        strip_prefix = "crossbeam-utils-0.8.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.crossbeam-utils-0.8.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__derive_more__0_99_13",
        url = "https://crates.io/api/v1/crates/derive_more/0.99.13/download",
        type = "tar.gz",
        sha256 = "f82b1b72f1263f214c0f823371768776c4f5841b942c9883aa8e5ec584fd0ba6",
        strip_prefix = "derive_more-0.99.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.derive_more-0.99.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__diesel__1_4_6",
        url = "https://crates.io/api/v1/crates/diesel/1.4.6/download",
        type = "tar.gz",
        sha256 = "047bfc4d5c3bd2ef6ca6f981941046113524b9a9f9a7cbdfdd7ff40f58e6f542",
        strip_prefix = "diesel-1.4.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.diesel-1.4.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__diesel_derives__1_4_1",
        url = "https://crates.io/api/v1/crates/diesel_derives/1.4.1/download",
        type = "tar.gz",
        sha256 = "45f5098f628d02a7a0f68ddba586fb61e80edec3bdc1be3b921f4ceec60858d3",
        strip_prefix = "diesel_derives-1.4.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.diesel_derives-1.4.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__digest__0_9_0",
        url = "https://crates.io/api/v1/crates/digest/0.9.0/download",
        type = "tar.gz",
        sha256 = "d3dd60d1080a57a05ab032377049e0591415d2b31afd7028356dbf3cc6dcb066",
        strip_prefix = "digest-0.9.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.digest-0.9.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__dirs__3_0_1",
        url = "https://crates.io/api/v1/crates/dirs/3.0.1/download",
        type = "tar.gz",
        sha256 = "142995ed02755914747cc6ca76fc7e4583cd18578746716d0508ea6ed558b9ff",
        strip_prefix = "dirs-3.0.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.dirs-3.0.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__dirs_sys__0_3_5",
        url = "https://crates.io/api/v1/crates/dirs-sys/0.3.5/download",
        type = "tar.gz",
        sha256 = "8e93d7f5705de3e49895a2b5e0b8855a1c27f080192ae9c32a6432d50741a57a",
        strip_prefix = "dirs-sys-0.3.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.dirs-sys-0.3.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__discard__1_0_4",
        url = "https://crates.io/api/v1/crates/discard/1.0.4/download",
        type = "tar.gz",
        sha256 = "212d0f5754cb6769937f4501cc0e67f4f4483c8d2c3e1e922ee9edbe4ab4c7c0",
        strip_prefix = "discard-1.0.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.discard-1.0.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__dotenv__0_15_0",
        url = "https://crates.io/api/v1/crates/dotenv/0.15.0/download",
        type = "tar.gz",
        sha256 = "77c90badedccf4105eca100756a0b1289e191f6fcbdadd3cee1d2f614f97da8f",
        strip_prefix = "dotenv-0.15.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.dotenv-0.15.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__either__1_6_1",
        url = "https://crates.io/api/v1/crates/either/1.6.1/download",
        type = "tar.gz",
        sha256 = "e78d4f1cc4ae33bbfc157ed5d5a5ef3bc29227303d595861deb238fcec4e9457",
        strip_prefix = "either-1.6.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.either-1.6.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__encoding_rs__0_8_28",
        url = "https://crates.io/api/v1/crates/encoding_rs/0.8.28/download",
        type = "tar.gz",
        sha256 = "80df024fbc5ac80f87dfef0d9f5209a252f2a497f7f42944cff24d8253cac065",
        strip_prefix = "encoding_rs-0.8.28",
        build_file = Label("//bazel/rust/raze/remote:BUILD.encoding_rs-0.8.28.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__enum_as_inner__0_3_3",
        url = "https://crates.io/api/v1/crates/enum-as-inner/0.3.3/download",
        type = "tar.gz",
        sha256 = "7c5f0096a91d210159eceb2ff5e1c4da18388a170e1e3ce948aac9c8fdbbf595",
        strip_prefix = "enum-as-inner-0.3.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.enum-as-inner-0.3.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__flate2__1_0_20",
        url = "https://crates.io/api/v1/crates/flate2/1.0.20/download",
        type = "tar.gz",
        sha256 = "cd3aec53de10fe96d7d8c565eb17f2c687bb5518a2ec453b5b1252964526abe0",
        strip_prefix = "flate2-1.0.20",
        build_file = Label("//bazel/rust/raze/remote:BUILD.flate2-1.0.20.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__fnv__1_0_7",
        url = "https://crates.io/api/v1/crates/fnv/1.0.7/download",
        type = "tar.gz",
        sha256 = "3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1",
        strip_prefix = "fnv-1.0.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.fnv-1.0.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__foreign_types__0_3_2",
        url = "https://crates.io/api/v1/crates/foreign-types/0.3.2/download",
        type = "tar.gz",
        sha256 = "f6f339eb8adc052cd2ca78910fda869aefa38d22d5cb648e6485e4d3fc06f3b1",
        strip_prefix = "foreign-types-0.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.foreign-types-0.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__foreign_types_shared__0_1_1",
        url = "https://crates.io/api/v1/crates/foreign-types-shared/0.1.1/download",
        type = "tar.gz",
        sha256 = "00b0228411908ca8685dba7fc2cdd70ec9990a6e753e89b6ac91a84c40fbaf4b",
        strip_prefix = "foreign-types-shared-0.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.foreign-types-shared-0.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__form_urlencoded__1_0_1",
        url = "https://crates.io/api/v1/crates/form_urlencoded/1.0.1/download",
        type = "tar.gz",
        sha256 = "5fc25a87fa4fd2094bffb06925852034d90a17f0d1e05197d4956d3555752191",
        strip_prefix = "form_urlencoded-1.0.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.form_urlencoded-1.0.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__fuchsia_zircon__0_3_3",
        url = "https://crates.io/api/v1/crates/fuchsia-zircon/0.3.3/download",
        type = "tar.gz",
        sha256 = "2e9763c69ebaae630ba35f74888db465e49e259ba1bc0eda7d06f4a067615d82",
        strip_prefix = "fuchsia-zircon-0.3.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.fuchsia-zircon-0.3.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__fuchsia_zircon_sys__0_3_3",
        url = "https://crates.io/api/v1/crates/fuchsia-zircon-sys/0.3.3/download",
        type = "tar.gz",
        sha256 = "3dcaa9ae7725d12cdb85b3ad99a434db70b468c09ded17e012d86b5c1010f7a7",
        strip_prefix = "fuchsia-zircon-sys-0.3.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.fuchsia-zircon-sys-0.3.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures__0_3_13",
        url = "https://crates.io/api/v1/crates/futures/0.3.13/download",
        type = "tar.gz",
        sha256 = "7f55667319111d593ba876406af7c409c0ebb44dc4be6132a783ccf163ea14c1",
        strip_prefix = "futures-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_channel__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-channel/0.3.13/download",
        type = "tar.gz",
        sha256 = "8c2dd2df839b57db9ab69c2c9d8f3e8c81984781937fe2807dc6dcf3b2ad2939",
        strip_prefix = "futures-channel-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-channel-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_core__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-core/0.3.13/download",
        type = "tar.gz",
        sha256 = "15496a72fabf0e62bdc3df11a59a3787429221dd0710ba8ef163d6f7a9112c94",
        strip_prefix = "futures-core-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-core-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_io__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-io/0.3.13/download",
        type = "tar.gz",
        sha256 = "d71c2c65c57704c32f5241c1223167c2c3294fd34ac020c807ddbe6db287ba59",
        strip_prefix = "futures-io-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-io-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_macro__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-macro/0.3.13/download",
        type = "tar.gz",
        sha256 = "ea405816a5139fb39af82c2beb921d52143f556038378d6db21183a5c37fbfb7",
        strip_prefix = "futures-macro-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-macro-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_sink__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-sink/0.3.13/download",
        type = "tar.gz",
        sha256 = "85754d98985841b7d4f5e8e6fbfa4a4ac847916893ec511a2917ccd8525b8bb3",
        strip_prefix = "futures-sink-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-sink-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_task__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-task/0.3.13/download",
        type = "tar.gz",
        sha256 = "fa189ef211c15ee602667a6fcfe1c1fd9e07d42250d2156382820fba33c9df80",
        strip_prefix = "futures-task-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-task-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__futures_util__0_3_13",
        url = "https://crates.io/api/v1/crates/futures-util/0.3.13/download",
        type = "tar.gz",
        sha256 = "1812c7ab8aedf8d6f2701a43e1243acdbcc2b36ab26e2ad421eb99ac963d96d1",
        strip_prefix = "futures-util-0.3.13",
        build_file = Label("//bazel/rust/raze/remote:BUILD.futures-util-0.3.13.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__fxhash__0_2_1",
        url = "https://crates.io/api/v1/crates/fxhash/0.2.1/download",
        type = "tar.gz",
        sha256 = "c31b6d751ae2c7f11320402d34e41349dd1016f8d5d45e48c4312bc8625af50c",
        strip_prefix = "fxhash-0.2.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.fxhash-0.2.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__generic_array__0_14_4",
        url = "https://crates.io/api/v1/crates/generic-array/0.14.4/download",
        type = "tar.gz",
        sha256 = "501466ecc8a30d1d3b7fc9229b122b2ce8ed6e9d9223f1138d4babb253e51817",
        strip_prefix = "generic-array-0.14.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.generic-array-0.14.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__getrandom__0_1_16",
        url = "https://crates.io/api/v1/crates/getrandom/0.1.16/download",
        type = "tar.gz",
        sha256 = "8fc3cb4d91f53b50155bdcfd23f6a4c39ae1969c2ae85982b135750cccaf5fce",
        strip_prefix = "getrandom-0.1.16",
        build_file = Label("//bazel/rust/raze/remote:BUILD.getrandom-0.1.16.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__getrandom__0_2_2",
        url = "https://crates.io/api/v1/crates/getrandom/0.2.2/download",
        type = "tar.gz",
        sha256 = "c9495705279e7140bf035dde1f6e750c162df8b625267cd52cc44e0b156732c8",
        strip_prefix = "getrandom-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.getrandom-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__h2__0_2_7",
        url = "https://crates.io/api/v1/crates/h2/0.2.7/download",
        type = "tar.gz",
        sha256 = "5e4728fd124914ad25e99e3d15a9361a879f6620f63cb56bbb08f95abb97a535",
        strip_prefix = "h2-0.2.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.h2-0.2.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__h2__0_3_2",
        url = "https://crates.io/api/v1/crates/h2/0.3.2/download",
        type = "tar.gz",
        sha256 = "fc018e188373e2777d0ef2467ebff62a08e66c3f5857b23c8fbec3018210dc00",
        strip_prefix = "h2-0.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.h2-0.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__hashbrown__0_9_1",
        url = "https://crates.io/api/v1/crates/hashbrown/0.9.1/download",
        type = "tar.gz",
        sha256 = "d7afe4a420e3fe79967a00898cc1f4db7c8a49a9333a29f8a4bd76a253d5cd04",
        strip_prefix = "hashbrown-0.9.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.hashbrown-0.9.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__heck__0_3_2",
        url = "https://crates.io/api/v1/crates/heck/0.3.2/download",
        type = "tar.gz",
        sha256 = "87cbf45460356b7deeb5e3415b5563308c0a9b057c85e12b06ad551f98d0a6ac",
        strip_prefix = "heck-0.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.heck-0.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__hermit_abi__0_1_18",
        url = "https://crates.io/api/v1/crates/hermit-abi/0.1.18/download",
        type = "tar.gz",
        sha256 = "322f4de77956e22ed0e5032c359a0f1273f1f7f0d79bfa3b8ffbc730d7fbcc5c",
        strip_prefix = "hermit-abi-0.1.18",
        build_file = Label("//bazel/rust/raze/remote:BUILD.hermit-abi-0.1.18.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__hostname__0_3_1",
        url = "https://crates.io/api/v1/crates/hostname/0.3.1/download",
        type = "tar.gz",
        sha256 = "3c731c3e10504cc8ed35cfe2f1db4c9274c3d35fa486e3b31df46f068ef3e867",
        strip_prefix = "hostname-0.3.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.hostname-0.3.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__http__0_2_3",
        url = "https://crates.io/api/v1/crates/http/0.2.3/download",
        type = "tar.gz",
        sha256 = "7245cd7449cc792608c3c8a9eaf69bd4eabbabf802713748fd739c98b82f0747",
        strip_prefix = "http-0.2.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.http-0.2.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__http_body__0_4_1",
        url = "https://crates.io/api/v1/crates/http-body/0.4.1/download",
        type = "tar.gz",
        sha256 = "5dfb77c123b4e2f72a2069aeae0b4b4949cc7e966df277813fc16347e7549737",
        strip_prefix = "http-body-0.4.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.http-body-0.4.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__httparse__1_3_5",
        url = "https://crates.io/api/v1/crates/httparse/1.3.5/download",
        type = "tar.gz",
        sha256 = "615caabe2c3160b313d52ccc905335f4ed5f10881dd63dc5699d47e90be85691",
        strip_prefix = "httparse-1.3.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.httparse-1.3.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__httpdate__0_3_2",
        url = "https://crates.io/api/v1/crates/httpdate/0.3.2/download",
        type = "tar.gz",
        sha256 = "494b4d60369511e7dea41cf646832512a94e542f68bb9c49e54518e0f468eb47",
        strip_prefix = "httpdate-0.3.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.httpdate-0.3.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__hyper__0_14_4",
        url = "https://crates.io/api/v1/crates/hyper/0.14.4/download",
        type = "tar.gz",
        sha256 = "e8e946c2b1349055e0b72ae281b238baf1a3ea7307c7e9f9d64673bdd9c26ac7",
        strip_prefix = "hyper-0.14.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.hyper-0.14.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__hyper_tls__0_5_0",
        url = "https://crates.io/api/v1/crates/hyper-tls/0.5.0/download",
        type = "tar.gz",
        sha256 = "d6183ddfa99b85da61a140bea0efc93fdf56ceaa041b37d553518030827f9905",
        strip_prefix = "hyper-tls-0.5.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.hyper-tls-0.5.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__idna__0_2_2",
        url = "https://crates.io/api/v1/crates/idna/0.2.2/download",
        type = "tar.gz",
        sha256 = "89829a5d69c23d348314a7ac337fe39173b61149a9864deabd260983aed48c21",
        strip_prefix = "idna-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.idna-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__indexmap__1_6_2",
        url = "https://crates.io/api/v1/crates/indexmap/1.6.2/download",
        type = "tar.gz",
        sha256 = "824845a0bf897a9042383849b02c1bc219c2383772efcd5c6f9766fa4b81aef3",
        strip_prefix = "indexmap-1.6.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.indexmap-1.6.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__instant__0_1_9",
        url = "https://crates.io/api/v1/crates/instant/0.1.9/download",
        type = "tar.gz",
        sha256 = "61124eeebbd69b8190558df225adf7e4caafce0d743919e5d6b19652314ec5ec",
        strip_prefix = "instant-0.1.9",
        build_file = Label("//bazel/rust/raze/remote:BUILD.instant-0.1.9.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__iovec__0_1_4",
        url = "https://crates.io/api/v1/crates/iovec/0.1.4/download",
        type = "tar.gz",
        sha256 = "b2b3ea6ff95e175473f8ffe6a7eb7c00d054240321b84c57051175fe3c1e075e",
        strip_prefix = "iovec-0.1.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.iovec-0.1.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ipconfig__0_2_2",
        url = "https://crates.io/api/v1/crates/ipconfig/0.2.2/download",
        type = "tar.gz",
        sha256 = "f7e2f18aece9709094573a9f24f483c4f65caa4298e2f7ae1b71cc65d853fad7",
        strip_prefix = "ipconfig-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ipconfig-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ipnet__2_3_0",
        url = "https://crates.io/api/v1/crates/ipnet/2.3.0/download",
        type = "tar.gz",
        sha256 = "47be2f14c678be2fdcab04ab1171db51b2762ce6f0a8ee87c8dd4a04ed216135",
        strip_prefix = "ipnet-2.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ipnet-2.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__itoa__0_4_7",
        url = "https://crates.io/api/v1/crates/itoa/0.4.7/download",
        type = "tar.gz",
        sha256 = "dd25036021b0de88a0aff6b850051563c6516d0bf53f8638938edbb9de732736",
        strip_prefix = "itoa-0.4.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.itoa-0.4.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__js_sys__0_3_49",
        url = "https://crates.io/api/v1/crates/js-sys/0.3.49/download",
        type = "tar.gz",
        sha256 = "dc15e39392125075f60c95ba416f5381ff6c3a948ff02ab12464715adf56c821",
        strip_prefix = "js-sys-0.3.49",
        build_file = Label("//bazel/rust/raze/remote:BUILD.js-sys-0.3.49.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__jsonwebtoken__7_2_0",
        url = "https://crates.io/api/v1/crates/jsonwebtoken/7.2.0/download",
        type = "tar.gz",
        sha256 = "afabcc15e437a6484fc4f12d0fd63068fe457bf93f1c148d3d9649c60b103f32",
        strip_prefix = "jsonwebtoken-7.2.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.jsonwebtoken-7.2.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__kernel32_sys__0_2_2",
        url = "https://crates.io/api/v1/crates/kernel32-sys/0.2.2/download",
        type = "tar.gz",
        sha256 = "7507624b29483431c0ba2d82aece8ca6cdba9382bff4ddd0f7490560c056098d",
        strip_prefix = "kernel32-sys-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.kernel32-sys-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__language_tags__0_2_2",
        url = "https://crates.io/api/v1/crates/language-tags/0.2.2/download",
        type = "tar.gz",
        sha256 = "a91d884b6667cd606bb5a69aa0c99ba811a115fc68915e7056ec08a46e93199a",
        strip_prefix = "language-tags-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.language-tags-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__lazy_static__1_4_0",
        url = "https://crates.io/api/v1/crates/lazy_static/1.4.0/download",
        type = "tar.gz",
        sha256 = "e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646",
        strip_prefix = "lazy_static-1.4.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.lazy_static-1.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__libc__0_2_91",
        url = "https://crates.io/api/v1/crates/libc/0.2.91/download",
        type = "tar.gz",
        sha256 = "8916b1f6ca17130ec6568feccee27c156ad12037880833a3b842a823236502e7",
        strip_prefix = "libc-0.2.91",
        build_file = Label("//bazel/rust/raze/remote:BUILD.libc-0.2.91.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__linked_hash_map__0_5_4",
        url = "https://crates.io/api/v1/crates/linked-hash-map/0.5.4/download",
        type = "tar.gz",
        sha256 = "7fb9b38af92608140b86b693604b9ffcc5824240a484d1ecd4795bacb2fe88f3",
        strip_prefix = "linked-hash-map-0.5.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.linked-hash-map-0.5.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__lock_api__0_4_2",
        url = "https://crates.io/api/v1/crates/lock_api/0.4.2/download",
        type = "tar.gz",
        sha256 = "dd96ffd135b2fd7b973ac026d28085defbe8983df057ced3eb4f2130b0831312",
        strip_prefix = "lock_api-0.4.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.lock_api-0.4.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__log__0_4_14",
        url = "https://crates.io/api/v1/crates/log/0.4.14/download",
        type = "tar.gz",
        sha256 = "51b9bbe6c47d51fc3e1a9b945965946b4c44142ab8792c50835a980d362c2710",
        strip_prefix = "log-0.4.14",
        build_file = Label("//bazel/rust/raze/remote:BUILD.log-0.4.14.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__lru_cache__0_1_2",
        url = "https://crates.io/api/v1/crates/lru-cache/0.1.2/download",
        type = "tar.gz",
        sha256 = "31e24f1ad8321ca0e8a1e0ac13f23cb668e6f5466c2c57319f6a5cf1cc8e3b1c",
        strip_prefix = "lru-cache-0.1.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.lru-cache-0.1.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__match_cfg__0_1_0",
        url = "https://crates.io/api/v1/crates/match_cfg/0.1.0/download",
        type = "tar.gz",
        sha256 = "ffbee8634e0d45d258acb448e7eaab3fce7a0a467395d4d9f228e3c1f01fb2e4",
        strip_prefix = "match_cfg-0.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.match_cfg-0.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__matches__0_1_8",
        url = "https://crates.io/api/v1/crates/matches/0.1.8/download",
        type = "tar.gz",
        sha256 = "7ffc5c5338469d4d3ea17d269fa8ea3512ad247247c30bd2df69e68309ed0a08",
        strip_prefix = "matches-0.1.8",
        build_file = Label("//bazel/rust/raze/remote:BUILD.matches-0.1.8.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__memchr__2_3_4",
        url = "https://crates.io/api/v1/crates/memchr/2.3.4/download",
        type = "tar.gz",
        sha256 = "0ee1c47aaa256ecabcaea351eae4a9b01ef39ed810004e298d2511ed284b1525",
        strip_prefix = "memchr-2.3.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.memchr-2.3.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__mime__0_3_16",
        url = "https://crates.io/api/v1/crates/mime/0.3.16/download",
        type = "tar.gz",
        sha256 = "2a60c7ce501c71e03a9c9c0d35b861413ae925bd979cc7a4e30d060069aaac8d",
        strip_prefix = "mime-0.3.16",
        build_file = Label("//bazel/rust/raze/remote:BUILD.mime-0.3.16.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__miniz_oxide__0_4_4",
        url = "https://crates.io/api/v1/crates/miniz_oxide/0.4.4/download",
        type = "tar.gz",
        sha256 = "a92518e98c078586bc6c934028adcca4c92a53d6a958196de835170a01d84e4b",
        strip_prefix = "miniz_oxide-0.4.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.miniz_oxide-0.4.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__mio__0_6_23",
        url = "https://crates.io/api/v1/crates/mio/0.6.23/download",
        type = "tar.gz",
        sha256 = "4afd66f5b91bf2a3bc13fad0e21caedac168ca4c707504e75585648ae80e4cc4",
        strip_prefix = "mio-0.6.23",
        build_file = Label("//bazel/rust/raze/remote:BUILD.mio-0.6.23.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__mio__0_7_11",
        url = "https://crates.io/api/v1/crates/mio/0.7.11/download",
        type = "tar.gz",
        sha256 = "cf80d3e903b34e0bd7282b218398aec54e082c840d9baf8339e0080a0c542956",
        strip_prefix = "mio-0.7.11",
        build_file = Label("//bazel/rust/raze/remote:BUILD.mio-0.7.11.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__mio_uds__0_6_8",
        url = "https://crates.io/api/v1/crates/mio-uds/0.6.8/download",
        type = "tar.gz",
        sha256 = "afcb699eb26d4332647cc848492bbc15eafb26f08d0304550d5aa1f612e066f0",
        strip_prefix = "mio-uds-0.6.8",
        build_file = Label("//bazel/rust/raze/remote:BUILD.mio-uds-0.6.8.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__miow__0_2_2",
        url = "https://crates.io/api/v1/crates/miow/0.2.2/download",
        type = "tar.gz",
        sha256 = "ebd808424166322d4a38da87083bfddd3ac4c131334ed55856112eb06d46944d",
        strip_prefix = "miow-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.miow-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__miow__0_3_7",
        url = "https://crates.io/api/v1/crates/miow/0.3.7/download",
        type = "tar.gz",
        sha256 = "b9f1c5b025cda876f66ef43a113f91ebc9f4ccef34843000e0adf6ebbab84e21",
        strip_prefix = "miow-0.3.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.miow-0.3.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__native_tls__0_2_7",
        url = "https://crates.io/api/v1/crates/native-tls/0.2.7/download",
        type = "tar.gz",
        sha256 = "b8d96b2e1c8da3957d58100b09f102c6d9cfdfced01b7ec5a8974044bb09dbd4",
        strip_prefix = "native-tls-0.2.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.native-tls-0.2.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__net2__0_2_37",
        url = "https://crates.io/api/v1/crates/net2/0.2.37/download",
        type = "tar.gz",
        sha256 = "391630d12b68002ae1e25e8f974306474966550ad82dac6886fb8910c19568ae",
        strip_prefix = "net2-0.2.37",
        build_file = Label("//bazel/rust/raze/remote:BUILD.net2-0.2.37.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ntapi__0_3_6",
        url = "https://crates.io/api/v1/crates/ntapi/0.3.6/download",
        type = "tar.gz",
        sha256 = "3f6bb902e437b6d86e03cce10a7e2af662292c5dfef23b65899ea3ac9354ad44",
        strip_prefix = "ntapi-0.3.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ntapi-0.3.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__num_bigint__0_2_6",
        url = "https://crates.io/api/v1/crates/num-bigint/0.2.6/download",
        type = "tar.gz",
        sha256 = "090c7f9998ee0ff65aa5b723e4009f7b217707f1fb5ea551329cc4d6231fb304",
        strip_prefix = "num-bigint-0.2.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.num-bigint-0.2.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__num_integer__0_1_44",
        url = "https://crates.io/api/v1/crates/num-integer/0.1.44/download",
        type = "tar.gz",
        sha256 = "d2cc698a63b549a70bc047073d2949cce27cd1c7b0a4a862d08a8031bc2801db",
        strip_prefix = "num-integer-0.1.44",
        build_file = Label("//bazel/rust/raze/remote:BUILD.num-integer-0.1.44.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__num_traits__0_2_14",
        url = "https://crates.io/api/v1/crates/num-traits/0.2.14/download",
        type = "tar.gz",
        sha256 = "9a64b1ec5cda2586e284722486d802acf1f7dbdc623e2bfc57e65ca1cd099290",
        strip_prefix = "num-traits-0.2.14",
        build_file = Label("//bazel/rust/raze/remote:BUILD.num-traits-0.2.14.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__num_cpus__1_13_0",
        url = "https://crates.io/api/v1/crates/num_cpus/1.13.0/download",
        type = "tar.gz",
        sha256 = "05499f3756671c15885fee9034446956fff3f243d6077b91e5767df161f766b3",
        strip_prefix = "num_cpus-1.13.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.num_cpus-1.13.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__once_cell__1_7_2",
        url = "https://crates.io/api/v1/crates/once_cell/1.7.2/download",
        type = "tar.gz",
        sha256 = "af8b08b04175473088b46763e51ee54da5f9a164bc162f615b91bc179dbf15a3",
        strip_prefix = "once_cell-1.7.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.once_cell-1.7.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__opaque_debug__0_3_0",
        url = "https://crates.io/api/v1/crates/opaque-debug/0.3.0/download",
        type = "tar.gz",
        sha256 = "624a8340c38c1b80fd549087862da4ba43e08858af025b236e509b6649fc13d5",
        strip_prefix = "opaque-debug-0.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.opaque-debug-0.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__openssl__0_10_33",
        url = "https://crates.io/api/v1/crates/openssl/0.10.33/download",
        type = "tar.gz",
        sha256 = "a61075b62a23fef5a29815de7536d940aa35ce96d18ce0cc5076272db678a577",
        strip_prefix = "openssl-0.10.33",
        build_file = Label("//bazel/rust/raze/remote:BUILD.openssl-0.10.33.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__openssl_probe__0_1_2",
        url = "https://crates.io/api/v1/crates/openssl-probe/0.1.2/download",
        type = "tar.gz",
        sha256 = "77af24da69f9d9341038eba93a073b1fdaaa1b788221b00a69bce9e762cb32de",
        strip_prefix = "openssl-probe-0.1.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.openssl-probe-0.1.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__openssl_sys__0_9_61",
        url = "https://crates.io/api/v1/crates/openssl-sys/0.9.61/download",
        type = "tar.gz",
        sha256 = "313752393519e876837e09e1fa183ddef0be7735868dced3196f4472d536277f",
        strip_prefix = "openssl-sys-0.9.61",
        build_file = Label("//bazel/rust/raze/remote:BUILD.openssl-sys-0.9.61.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__parking_lot__0_11_1",
        url = "https://crates.io/api/v1/crates/parking_lot/0.11.1/download",
        type = "tar.gz",
        sha256 = "6d7744ac029df22dca6284efe4e898991d28e3085c706c972bcd7da4a27a15eb",
        strip_prefix = "parking_lot-0.11.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.parking_lot-0.11.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__parking_lot_core__0_8_3",
        url = "https://crates.io/api/v1/crates/parking_lot_core/0.8.3/download",
        type = "tar.gz",
        sha256 = "fa7a782938e745763fe6907fc6ba86946d72f49fe7e21de074e08128a99fb018",
        strip_prefix = "parking_lot_core-0.8.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.parking_lot_core-0.8.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pem__0_8_3",
        url = "https://crates.io/api/v1/crates/pem/0.8.3/download",
        type = "tar.gz",
        sha256 = "fd56cbd21fea48d0c440b41cd69c589faacade08c992d9a54e471b79d0fd13eb",
        strip_prefix = "pem-0.8.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pem-0.8.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__percent_encoding__2_1_0",
        url = "https://crates.io/api/v1/crates/percent-encoding/2.1.0/download",
        type = "tar.gz",
        sha256 = "d4fd5641d01c8f18a23da7b6fe29298ff4b55afcccdf78973b24cf3175fee32e",
        strip_prefix = "percent-encoding-2.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.percent-encoding-2.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_project__0_4_27",
        url = "https://crates.io/api/v1/crates/pin-project/0.4.27/download",
        type = "tar.gz",
        sha256 = "2ffbc8e94b38ea3d2d8ba92aea2983b503cd75d0888d75b86bb37970b5698e15",
        strip_prefix = "pin-project-0.4.27",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-project-0.4.27.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_project__1_0_6",
        url = "https://crates.io/api/v1/crates/pin-project/1.0.6/download",
        type = "tar.gz",
        sha256 = "bc174859768806e91ae575187ada95c91a29e96a98dc5d2cd9a1fed039501ba6",
        strip_prefix = "pin-project-1.0.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-project-1.0.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_project_internal__0_4_27",
        url = "https://crates.io/api/v1/crates/pin-project-internal/0.4.27/download",
        type = "tar.gz",
        sha256 = "65ad2ae56b6abe3a1ee25f15ee605bacadb9a764edaba9c2bf4103800d4a1895",
        strip_prefix = "pin-project-internal-0.4.27",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-project-internal-0.4.27.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_project_internal__1_0_6",
        url = "https://crates.io/api/v1/crates/pin-project-internal/1.0.6/download",
        type = "tar.gz",
        sha256 = "a490329918e856ed1b083f244e3bfe2d8c4f336407e4ea9e1a9f479ff09049e5",
        strip_prefix = "pin-project-internal-1.0.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-project-internal-1.0.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_project_lite__0_1_12",
        url = "https://crates.io/api/v1/crates/pin-project-lite/0.1.12/download",
        type = "tar.gz",
        sha256 = "257b64915a082f7811703966789728173279bdebb956b143dbcd23f6f970a777",
        strip_prefix = "pin-project-lite-0.1.12",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-project-lite-0.1.12.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_project_lite__0_2_6",
        url = "https://crates.io/api/v1/crates/pin-project-lite/0.2.6/download",
        type = "tar.gz",
        sha256 = "dc0e1f259c92177c30a4c9d177246edd0a3568b25756a977d0632cf8fa37e905",
        strip_prefix = "pin-project-lite-0.2.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-project-lite-0.2.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pin_utils__0_1_0",
        url = "https://crates.io/api/v1/crates/pin-utils/0.1.0/download",
        type = "tar.gz",
        sha256 = "8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184",
        strip_prefix = "pin-utils-0.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pin-utils-0.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pkg_config__0_3_19",
        url = "https://crates.io/api/v1/crates/pkg-config/0.3.19/download",
        type = "tar.gz",
        sha256 = "3831453b3449ceb48b6d9c7ad7c96d5ea673e9b470a1dc578c2ce6521230884c",
        strip_prefix = "pkg-config-0.3.19",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pkg-config-0.3.19.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ppv_lite86__0_2_10",
        url = "https://crates.io/api/v1/crates/ppv-lite86/0.2.10/download",
        type = "tar.gz",
        sha256 = "ac74c624d6b2d21f425f752262f42188365d7b8ff1aff74c82e45136510a4857",
        strip_prefix = "ppv-lite86-0.2.10",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ppv-lite86-0.2.10.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__pq_sys__0_4_6",
        url = "https://crates.io/api/v1/crates/pq-sys/0.4.6/download",
        type = "tar.gz",
        sha256 = "6ac25eee5a0582f45a67e837e350d784e7003bd29a5f460796772061ca49ffda",
        strip_prefix = "pq-sys-0.4.6",
        build_file = Label("//bazel/rust/raze/remote:BUILD.pq-sys-0.4.6.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__proc_macro_hack__0_5_19",
        url = "https://crates.io/api/v1/crates/proc-macro-hack/0.5.19/download",
        type = "tar.gz",
        sha256 = "dbf0c48bc1d91375ae5c3cd81e3722dff1abcf81a30960240640d223f59fe0e5",
        strip_prefix = "proc-macro-hack-0.5.19",
        build_file = Label("//bazel/rust/raze/remote:BUILD.proc-macro-hack-0.5.19.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__proc_macro_nested__0_1_7",
        url = "https://crates.io/api/v1/crates/proc-macro-nested/0.1.7/download",
        type = "tar.gz",
        sha256 = "bc881b2c22681370c6a780e47af9840ef841837bc98118431d4e1868bd0c1086",
        strip_prefix = "proc-macro-nested-0.1.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.proc-macro-nested-0.1.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__proc_macro2__1_0_24",
        url = "https://crates.io/api/v1/crates/proc-macro2/1.0.24/download",
        type = "tar.gz",
        sha256 = "1e0704ee1a7e00d7bb417d0770ea303c1bccbabf0ef1667dae92b5967f5f8a71",
        strip_prefix = "proc-macro2-1.0.24",
        build_file = Label("//bazel/rust/raze/remote:BUILD.proc-macro2-1.0.24.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__quick_error__1_2_3",
        url = "https://crates.io/api/v1/crates/quick-error/1.2.3/download",
        type = "tar.gz",
        sha256 = "a1d01941d82fa2ab50be1e79e6714289dd7cde78eba4c074bc5a4374f650dfe0",
        strip_prefix = "quick-error-1.2.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.quick-error-1.2.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__quote__1_0_9",
        url = "https://crates.io/api/v1/crates/quote/1.0.9/download",
        type = "tar.gz",
        sha256 = "c3d0b9745dc2debf507c8422de05d7226cc1f0644216dfdfead988f9b1ab32a7",
        strip_prefix = "quote-1.0.9",
        build_file = Label("//bazel/rust/raze/remote:BUILD.quote-1.0.9.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand__0_7_3",
        url = "https://crates.io/api/v1/crates/rand/0.7.3/download",
        type = "tar.gz",
        sha256 = "6a6b1679d49b24bbfe0c803429aa1874472f50d9b363131f0e89fc356b544d03",
        strip_prefix = "rand-0.7.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand-0.7.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand__0_8_3",
        url = "https://crates.io/api/v1/crates/rand/0.8.3/download",
        type = "tar.gz",
        sha256 = "0ef9e7e66b4468674bfcb0c81af8b7fa0bb154fa9f28eb840da5c447baeb8d7e",
        strip_prefix = "rand-0.8.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand-0.8.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand_chacha__0_2_2",
        url = "https://crates.io/api/v1/crates/rand_chacha/0.2.2/download",
        type = "tar.gz",
        sha256 = "f4c8ed856279c9737206bf725bf36935d8666ead7aa69b52be55af369d193402",
        strip_prefix = "rand_chacha-0.2.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand_chacha-0.2.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand_chacha__0_3_0",
        url = "https://crates.io/api/v1/crates/rand_chacha/0.3.0/download",
        type = "tar.gz",
        sha256 = "e12735cf05c9e10bf21534da50a147b924d555dc7a547c42e6bb2d5b6017ae0d",
        strip_prefix = "rand_chacha-0.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand_chacha-0.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand_core__0_5_1",
        url = "https://crates.io/api/v1/crates/rand_core/0.5.1/download",
        type = "tar.gz",
        sha256 = "90bde5296fc891b0cef12a6d03ddccc162ce7b2aff54160af9338f8d40df6d19",
        strip_prefix = "rand_core-0.5.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand_core-0.5.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand_core__0_6_2",
        url = "https://crates.io/api/v1/crates/rand_core/0.6.2/download",
        type = "tar.gz",
        sha256 = "34cf66eb183df1c5876e2dcf6b13d57340741e8dc255b48e40a26de954d06ae7",
        strip_prefix = "rand_core-0.6.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand_core-0.6.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand_hc__0_2_0",
        url = "https://crates.io/api/v1/crates/rand_hc/0.2.0/download",
        type = "tar.gz",
        sha256 = "ca3129af7b92a17112d59ad498c6f81eaf463253766b90396d39ea7a39d6613c",
        strip_prefix = "rand_hc-0.2.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand_hc-0.2.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rand_hc__0_3_0",
        url = "https://crates.io/api/v1/crates/rand_hc/0.3.0/download",
        type = "tar.gz",
        sha256 = "3190ef7066a446f2e7f42e239d161e905420ccab01eb967c9eb27d21b2322a73",
        strip_prefix = "rand_hc-0.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rand_hc-0.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__redox_syscall__0_1_57",
        url = "https://crates.io/api/v1/crates/redox_syscall/0.1.57/download",
        type = "tar.gz",
        sha256 = "41cc0f7e4d5d4544e8861606a285bb08d3e70712ccc7d2b84d7c0ccfaf4b05ce",
        strip_prefix = "redox_syscall-0.1.57",
        build_file = Label("//bazel/rust/raze/remote:BUILD.redox_syscall-0.1.57.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__redox_syscall__0_2_5",
        url = "https://crates.io/api/v1/crates/redox_syscall/0.2.5/download",
        type = "tar.gz",
        sha256 = "94341e4e44e24f6b591b59e47a8a027df12e008d73fd5672dbea9cc22f4507d9",
        strip_prefix = "redox_syscall-0.2.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.redox_syscall-0.2.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__redox_users__0_3_5",
        url = "https://crates.io/api/v1/crates/redox_users/0.3.5/download",
        type = "tar.gz",
        sha256 = "de0737333e7a9502c789a36d7c7fa6092a49895d4faa31ca5df163857ded2e9d",
        strip_prefix = "redox_users-0.3.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.redox_users-0.3.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__regex__1_4_5",
        url = "https://crates.io/api/v1/crates/regex/1.4.5/download",
        type = "tar.gz",
        sha256 = "957056ecddbeba1b26965114e191d2e8589ce74db242b6ea25fc4062427a5c19",
        strip_prefix = "regex-1.4.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.regex-1.4.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__regex_syntax__0_6_23",
        url = "https://crates.io/api/v1/crates/regex-syntax/0.6.23/download",
        type = "tar.gz",
        sha256 = "24d5f089152e60f62d28b835fbff2cd2e8dc0baf1ac13343bef92ab7eed84548",
        strip_prefix = "regex-syntax-0.6.23",
        build_file = Label("//bazel/rust/raze/remote:BUILD.regex-syntax-0.6.23.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__remove_dir_all__0_5_3",
        url = "https://crates.io/api/v1/crates/remove_dir_all/0.5.3/download",
        type = "tar.gz",
        sha256 = "3acd125665422973a33ac9d3dd2df85edad0f4ae9b00dafb1a05e43a9f5ef8e7",
        strip_prefix = "remove_dir_all-0.5.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.remove_dir_all-0.5.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__reqwest__0_11_2",
        url = "https://crates.io/api/v1/crates/reqwest/0.11.2/download",
        type = "tar.gz",
        sha256 = "bf12057f289428dbf5c591c74bf10392e4a8003f993405a902f20117019022d4",
        strip_prefix = "reqwest-0.11.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.reqwest-0.11.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__resolv_conf__0_7_0",
        url = "https://crates.io/api/v1/crates/resolv-conf/0.7.0/download",
        type = "tar.gz",
        sha256 = "52e44394d2086d010551b14b53b1f24e31647570cd1deb0379e2c21b329aba00",
        strip_prefix = "resolv-conf-0.7.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.resolv-conf-0.7.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ring__0_16_20",
        url = "https://crates.io/api/v1/crates/ring/0.16.20/download",
        type = "tar.gz",
        sha256 = "3053cf52e236a3ed746dfc745aa9cacf1b791d846bdaf412f60a8d7d6e17c8fc",
        strip_prefix = "ring-0.16.20",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ring-0.16.20.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rust_argon2__0_8_3",
        url = "https://crates.io/api/v1/crates/rust-argon2/0.8.3/download",
        type = "tar.gz",
        sha256 = "4b18820d944b33caa75a71378964ac46f58517c92b6ae5f762636247c09e78fb",
        strip_prefix = "rust-argon2-0.8.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rust-argon2-0.8.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__rustc_version__0_2_3",
        url = "https://crates.io/api/v1/crates/rustc_version/0.2.3/download",
        type = "tar.gz",
        sha256 = "138e3e0acb6c9fb258b19b67cb8abd63c00679d2851805ea151465464fe9030a",
        strip_prefix = "rustc_version-0.2.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.rustc_version-0.2.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ryu__1_0_5",
        url = "https://crates.io/api/v1/crates/ryu/1.0.5/download",
        type = "tar.gz",
        sha256 = "71d301d4193d031abdd79ff7e3dd721168a9572ef3fe51a1517aba235bd8f86e",
        strip_prefix = "ryu-1.0.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ryu-1.0.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__schannel__0_1_19",
        url = "https://crates.io/api/v1/crates/schannel/0.1.19/download",
        type = "tar.gz",
        sha256 = "8f05ba609c234e60bee0d547fe94a4c7e9da733d1c962cf6e59efa4cd9c8bc75",
        strip_prefix = "schannel-0.1.19",
        build_file = Label("//bazel/rust/raze/remote:BUILD.schannel-0.1.19.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__scopeguard__1_1_0",
        url = "https://crates.io/api/v1/crates/scopeguard/1.1.0/download",
        type = "tar.gz",
        sha256 = "d29ab0c6d3fc0ee92fe66e2d99f700eab17a8d57d1c1d3b748380fb20baa78cd",
        strip_prefix = "scopeguard-1.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.scopeguard-1.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__security_framework__2_1_2",
        url = "https://crates.io/api/v1/crates/security-framework/2.1.2/download",
        type = "tar.gz",
        sha256 = "d493c5f39e02dfb062cd8f33301f90f9b13b650e8c1b1d0fd75c19dd64bff69d",
        strip_prefix = "security-framework-2.1.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.security-framework-2.1.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__security_framework_sys__2_1_1",
        url = "https://crates.io/api/v1/crates/security-framework-sys/2.1.1/download",
        type = "tar.gz",
        sha256 = "dee48cdde5ed250b0d3252818f646e174ab414036edb884dde62d80a3ac6082d",
        strip_prefix = "security-framework-sys-2.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.security-framework-sys-2.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__semver__0_9_0",
        url = "https://crates.io/api/v1/crates/semver/0.9.0/download",
        type = "tar.gz",
        sha256 = "1d7eb9ef2c18661902cc47e535f9bc51b78acd254da71d375c2f6720d9a40403",
        strip_prefix = "semver-0.9.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.semver-0.9.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__semver_parser__0_7_0",
        url = "https://crates.io/api/v1/crates/semver-parser/0.7.0/download",
        type = "tar.gz",
        sha256 = "388a1df253eca08550bef6c72392cfe7c30914bf41df5269b68cbd6ff8f570a3",
        strip_prefix = "semver-parser-0.7.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.semver-parser-0.7.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__serde__1_0_125",
        url = "https://crates.io/api/v1/crates/serde/1.0.125/download",
        type = "tar.gz",
        sha256 = "558dc50e1a5a5fa7112ca2ce4effcb321b0300c0d4ccf0776a9f60cd89031171",
        strip_prefix = "serde-1.0.125",
        build_file = Label("//bazel/rust/raze/remote:BUILD.serde-1.0.125.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__serde_derive__1_0_125",
        url = "https://crates.io/api/v1/crates/serde_derive/1.0.125/download",
        type = "tar.gz",
        sha256 = "b093b7a2bb58203b5da3056c05b4ec1fed827dcfdb37347a8841695263b3d06d",
        strip_prefix = "serde_derive-1.0.125",
        build_file = Label("//bazel/rust/raze/remote:BUILD.serde_derive-1.0.125.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__serde_json__1_0_64",
        url = "https://crates.io/api/v1/crates/serde_json/1.0.64/download",
        type = "tar.gz",
        sha256 = "799e97dc9fdae36a5c8b8f2cae9ce2ee9fdce2058c57a93e6099d919fd982f79",
        strip_prefix = "serde_json-1.0.64",
        build_file = Label("//bazel/rust/raze/remote:BUILD.serde_json-1.0.64.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__serde_urlencoded__0_7_0",
        url = "https://crates.io/api/v1/crates/serde_urlencoded/0.7.0/download",
        type = "tar.gz",
        sha256 = "edfa57a7f8d9c1d260a549e7224100f6c43d43f9103e06dd8b4095a9b2b43ce9",
        strip_prefix = "serde_urlencoded-0.7.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.serde_urlencoded-0.7.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__sha_1__0_9_4",
        url = "https://crates.io/api/v1/crates/sha-1/0.9.4/download",
        type = "tar.gz",
        sha256 = "dfebf75d25bd900fd1e7d11501efab59bc846dbc76196839663e6637bba9f25f",
        strip_prefix = "sha-1-0.9.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.sha-1-0.9.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__sha1__0_6_0",
        url = "https://crates.io/api/v1/crates/sha1/0.6.0/download",
        type = "tar.gz",
        sha256 = "2579985fda508104f7587689507983eadd6a6e84dd35d6d115361f530916fa0d",
        strip_prefix = "sha1-0.6.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.sha1-0.6.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__signal_hook_registry__1_3_0",
        url = "https://crates.io/api/v1/crates/signal-hook-registry/1.3.0/download",
        type = "tar.gz",
        sha256 = "16f1d0fef1604ba8f7a073c7e701f213e056707210e9020af4528e0101ce11a6",
        strip_prefix = "signal-hook-registry-1.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.signal-hook-registry-1.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__simple_asn1__0_4_1",
        url = "https://crates.io/api/v1/crates/simple_asn1/0.4.1/download",
        type = "tar.gz",
        sha256 = "692ca13de57ce0613a363c8c2f1de925adebc81b04c923ac60c5488bb44abe4b",
        strip_prefix = "simple_asn1-0.4.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.simple_asn1-0.4.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__slab__0_4_2",
        url = "https://crates.io/api/v1/crates/slab/0.4.2/download",
        type = "tar.gz",
        sha256 = "c111b5bd5695e56cffe5129854aa230b39c93a305372fdbb2668ca2394eea9f8",
        strip_prefix = "slab-0.4.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.slab-0.4.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__smallvec__1_6_1",
        url = "https://crates.io/api/v1/crates/smallvec/1.6.1/download",
        type = "tar.gz",
        sha256 = "fe0f37c9e8f3c5a4a66ad655a93c74daac4ad00c441533bf5c6e7990bb42604e",
        strip_prefix = "smallvec-1.6.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.smallvec-1.6.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__socket2__0_3_19",
        url = "https://crates.io/api/v1/crates/socket2/0.3.19/download",
        type = "tar.gz",
        sha256 = "122e570113d28d773067fab24266b66753f6ea915758651696b6e35e49f88d6e",
        strip_prefix = "socket2-0.3.19",
        build_file = Label("//bazel/rust/raze/remote:BUILD.socket2-0.3.19.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__spin__0_5_2",
        url = "https://crates.io/api/v1/crates/spin/0.5.2/download",
        type = "tar.gz",
        sha256 = "6e63cff320ae2c57904679ba7cb63280a3dc4613885beafb148ee7bf9aa9042d",
        strip_prefix = "spin-0.5.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.spin-0.5.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__standback__0_2_17",
        url = "https://crates.io/api/v1/crates/standback/0.2.17/download",
        type = "tar.gz",
        sha256 = "e113fb6f3de07a243d434a56ec6f186dfd51cb08448239fe7bcae73f87ff28ff",
        strip_prefix = "standback-0.2.17",
        build_file = Label("//bazel/rust/raze/remote:BUILD.standback-0.2.17.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__stdweb__0_4_20",
        url = "https://crates.io/api/v1/crates/stdweb/0.4.20/download",
        type = "tar.gz",
        sha256 = "d022496b16281348b52d0e30ae99e01a73d737b2f45d38fed4edf79f9325a1d5",
        strip_prefix = "stdweb-0.4.20",
        build_file = Label("//bazel/rust/raze/remote:BUILD.stdweb-0.4.20.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__stdweb_derive__0_5_3",
        url = "https://crates.io/api/v1/crates/stdweb-derive/0.5.3/download",
        type = "tar.gz",
        sha256 = "c87a60a40fccc84bef0652345bbbbbe20a605bf5d0ce81719fc476f5c03b50ef",
        strip_prefix = "stdweb-derive-0.5.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.stdweb-derive-0.5.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__stdweb_internal_macros__0_2_9",
        url = "https://crates.io/api/v1/crates/stdweb-internal-macros/0.2.9/download",
        type = "tar.gz",
        sha256 = "58fa5ff6ad0d98d1ffa8cb115892b6e69d67799f6763e162a1c9db421dc22e11",
        strip_prefix = "stdweb-internal-macros-0.2.9",
        build_file = Label("//bazel/rust/raze/remote:BUILD.stdweb-internal-macros-0.2.9.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__stdweb_internal_runtime__0_1_5",
        url = "https://crates.io/api/v1/crates/stdweb-internal-runtime/0.1.5/download",
        type = "tar.gz",
        sha256 = "213701ba3370744dcd1a12960caa4843b3d68b4d1c0a5d575e0d65b2ee9d16c0",
        strip_prefix = "stdweb-internal-runtime-0.1.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.stdweb-internal-runtime-0.1.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__strsim__0_8_0",
        url = "https://crates.io/api/v1/crates/strsim/0.8.0/download",
        type = "tar.gz",
        sha256 = "8ea5119cdb4c55b55d432abb513a0429384878c15dde60cc77b1c99de1a95a6a",
        strip_prefix = "strsim-0.8.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.strsim-0.8.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__syn__1_0_64",
        url = "https://crates.io/api/v1/crates/syn/1.0.64/download",
        type = "tar.gz",
        sha256 = "3fd9d1e9976102a03c542daa2eff1b43f9d72306342f3f8b3ed5fb8908195d6f",
        strip_prefix = "syn-1.0.64",
        build_file = Label("//bazel/rust/raze/remote:BUILD.syn-1.0.64.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tempfile__3_2_0",
        url = "https://crates.io/api/v1/crates/tempfile/3.2.0/download",
        type = "tar.gz",
        sha256 = "dac1c663cfc93810f88aed9b8941d48cabf856a1b111c29a40439018d870eb22",
        strip_prefix = "tempfile-3.2.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tempfile-3.2.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__textwrap__0_11_0",
        url = "https://crates.io/api/v1/crates/textwrap/0.11.0/download",
        type = "tar.gz",
        sha256 = "d326610f408c7a4eb6f51c37c330e496b08506c9457c9d34287ecc38809fb060",
        strip_prefix = "textwrap-0.11.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.textwrap-0.11.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__thiserror__1_0_24",
        url = "https://crates.io/api/v1/crates/thiserror/1.0.24/download",
        type = "tar.gz",
        sha256 = "e0f4a65597094d4483ddaed134f409b2cb7c1beccf25201a9f73c719254fa98e",
        strip_prefix = "thiserror-1.0.24",
        build_file = Label("//bazel/rust/raze/remote:BUILD.thiserror-1.0.24.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__thiserror_impl__1_0_24",
        url = "https://crates.io/api/v1/crates/thiserror-impl/1.0.24/download",
        type = "tar.gz",
        sha256 = "7765189610d8241a44529806d6fd1f2e0a08734313a35d5b3a556f92b381f3c0",
        strip_prefix = "thiserror-impl-1.0.24",
        build_file = Label("//bazel/rust/raze/remote:BUILD.thiserror-impl-1.0.24.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__threadpool__1_8_1",
        url = "https://crates.io/api/v1/crates/threadpool/1.8.1/download",
        type = "tar.gz",
        sha256 = "d050e60b33d41c19108b32cea32164033a9013fe3b46cbd4457559bfbf77afaa",
        strip_prefix = "threadpool-1.8.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.threadpool-1.8.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__time__0_1_44",
        url = "https://crates.io/api/v1/crates/time/0.1.44/download",
        type = "tar.gz",
        sha256 = "6db9e6914ab8b1ae1c260a4ae7a49b6c5611b40328a735b21862567685e73255",
        strip_prefix = "time-0.1.44",
        build_file = Label("//bazel/rust/raze/remote:BUILD.time-0.1.44.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__time__0_2_26",
        url = "https://crates.io/api/v1/crates/time/0.2.26/download",
        type = "tar.gz",
        sha256 = "08a8cbfbf47955132d0202d1662f49b2423ae35862aee471f3ba4b133358f372",
        strip_prefix = "time-0.2.26",
        build_file = Label("//bazel/rust/raze/remote:BUILD.time-0.2.26.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__time_macros__0_1_1",
        url = "https://crates.io/api/v1/crates/time-macros/0.1.1/download",
        type = "tar.gz",
        sha256 = "957e9c6e26f12cb6d0dd7fc776bb67a706312e7299aed74c8dd5b17ebb27e2f1",
        strip_prefix = "time-macros-0.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.time-macros-0.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__time_macros_impl__0_1_1",
        url = "https://crates.io/api/v1/crates/time-macros-impl/0.1.1/download",
        type = "tar.gz",
        sha256 = "e5c3be1edfad6027c69f5491cf4cb310d1a71ecd6af742788c6ff8bced86b8fa",
        strip_prefix = "time-macros-impl-0.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.time-macros-impl-0.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tinyvec__1_1_1",
        url = "https://crates.io/api/v1/crates/tinyvec/1.1.1/download",
        type = "tar.gz",
        sha256 = "317cca572a0e89c3ce0ca1f1bdc9369547fe318a683418e42ac8f59d14701023",
        strip_prefix = "tinyvec-1.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tinyvec-1.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tinyvec_macros__0_1_0",
        url = "https://crates.io/api/v1/crates/tinyvec_macros/0.1.0/download",
        type = "tar.gz",
        sha256 = "cda74da7e1a664f795bb1f8a87ec406fb89a02522cf6e50620d016add6dbbf5c",
        strip_prefix = "tinyvec_macros-0.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tinyvec_macros-0.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tokio__0_2_25",
        url = "https://crates.io/api/v1/crates/tokio/0.2.25/download",
        type = "tar.gz",
        sha256 = "6703a273949a90131b290be1fe7b039d0fc884aa1935860dfcbe056f28cd8092",
        strip_prefix = "tokio-0.2.25",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tokio-0.2.25.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tokio__1_4_0",
        url = "https://crates.io/api/v1/crates/tokio/1.4.0/download",
        type = "tar.gz",
        sha256 = "134af885d758d645f0f0505c9a8b3f9bf8a348fd822e112ab5248138348f1722",
        strip_prefix = "tokio-1.4.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tokio-1.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tokio_macros__1_1_0",
        url = "https://crates.io/api/v1/crates/tokio-macros/1.1.0/download",
        type = "tar.gz",
        sha256 = "caf7b11a536f46a809a8a9f0bb4237020f70ecbf115b842360afb127ea2fda57",
        strip_prefix = "tokio-macros-1.1.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tokio-macros-1.1.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tokio_native_tls__0_3_0",
        url = "https://crates.io/api/v1/crates/tokio-native-tls/0.3.0/download",
        type = "tar.gz",
        sha256 = "f7d995660bd2b7f8c1568414c1126076c13fbb725c40112dc0120b78eb9b717b",
        strip_prefix = "tokio-native-tls-0.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tokio-native-tls-0.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tokio_util__0_3_1",
        url = "https://crates.io/api/v1/crates/tokio-util/0.3.1/download",
        type = "tar.gz",
        sha256 = "be8242891f2b6cbef26a2d7e8605133c2c554cd35b3e4948ea892d6d68436499",
        strip_prefix = "tokio-util-0.3.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tokio-util-0.3.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tokio_util__0_6_5",
        url = "https://crates.io/api/v1/crates/tokio-util/0.6.5/download",
        type = "tar.gz",
        sha256 = "5143d049e85af7fbc36f5454d990e62c2df705b3589f123b71f441b6b59f443f",
        strip_prefix = "tokio-util-0.6.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tokio-util-0.6.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__toml__0_5_8",
        url = "https://crates.io/api/v1/crates/toml/0.5.8/download",
        type = "tar.gz",
        sha256 = "a31142970826733df8241ef35dc040ef98c679ab14d7c3e54d827099b3acecaa",
        strip_prefix = "toml-0.5.8",
        build_file = Label("//bazel/rust/raze/remote:BUILD.toml-0.5.8.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tower_service__0_3_1",
        url = "https://crates.io/api/v1/crates/tower-service/0.3.1/download",
        type = "tar.gz",
        sha256 = "360dfd1d6d30e05fda32ace2c8c70e9c0a9da713275777f5a4dbb8a1893930c6",
        strip_prefix = "tower-service-0.3.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tower-service-0.3.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tracing__0_1_25",
        url = "https://crates.io/api/v1/crates/tracing/0.1.25/download",
        type = "tar.gz",
        sha256 = "01ebdc2bb4498ab1ab5f5b73c5803825e60199229ccba0698170e3be0e7f959f",
        strip_prefix = "tracing-0.1.25",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tracing-0.1.25.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tracing_core__0_1_17",
        url = "https://crates.io/api/v1/crates/tracing-core/0.1.17/download",
        type = "tar.gz",
        sha256 = "f50de3927f93d202783f4513cda820ab47ef17f624b03c096e86ef00c67e6b5f",
        strip_prefix = "tracing-core-0.1.17",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tracing-core-0.1.17.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__tracing_futures__0_2_5",
        url = "https://crates.io/api/v1/crates/tracing-futures/0.2.5/download",
        type = "tar.gz",
        sha256 = "97d095ae15e245a057c8e8451bab9b3ee1e1f68e9ba2b4fbc18d0ac5237835f2",
        strip_prefix = "tracing-futures-0.2.5",
        build_file = Label("//bazel/rust/raze/remote:BUILD.tracing-futures-0.2.5.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__trust_dns_proto__0_19_7",
        url = "https://crates.io/api/v1/crates/trust-dns-proto/0.19.7/download",
        type = "tar.gz",
        sha256 = "1cad71a0c0d68ab9941d2fb6e82f8fb2e86d9945b94e1661dd0aaea2b88215a9",
        strip_prefix = "trust-dns-proto-0.19.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.trust-dns-proto-0.19.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__trust_dns_resolver__0_19_7",
        url = "https://crates.io/api/v1/crates/trust-dns-resolver/0.19.7/download",
        type = "tar.gz",
        sha256 = "710f593b371175db53a26d0b38ed2978fafb9e9e8d3868b1acd753ea18df0ceb",
        strip_prefix = "trust-dns-resolver-0.19.7",
        build_file = Label("//bazel/rust/raze/remote:BUILD.trust-dns-resolver-0.19.7.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__try_lock__0_2_3",
        url = "https://crates.io/api/v1/crates/try-lock/0.2.3/download",
        type = "tar.gz",
        sha256 = "59547bce71d9c38b83d9c0e92b6066c4253371f15005def0c30d9657f50c7642",
        strip_prefix = "try-lock-0.2.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.try-lock-0.2.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__typenum__1_13_0",
        url = "https://crates.io/api/v1/crates/typenum/1.13.0/download",
        type = "tar.gz",
        sha256 = "879f6906492a7cd215bfa4cf595b600146ccfac0c79bcbd1f3000162af5e8b06",
        strip_prefix = "typenum-1.13.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.typenum-1.13.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__unicode_bidi__0_3_4",
        url = "https://crates.io/api/v1/crates/unicode-bidi/0.3.4/download",
        type = "tar.gz",
        sha256 = "49f2bd0c6468a8230e1db229cff8029217cf623c767ea5d60bfbd42729ea54d5",
        strip_prefix = "unicode-bidi-0.3.4",
        build_file = Label("//bazel/rust/raze/remote:BUILD.unicode-bidi-0.3.4.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__unicode_normalization__0_1_17",
        url = "https://crates.io/api/v1/crates/unicode-normalization/0.1.17/download",
        type = "tar.gz",
        sha256 = "07fbfce1c8a97d547e8b5334978438d9d6ec8c20e38f56d4a4374d181493eaef",
        strip_prefix = "unicode-normalization-0.1.17",
        build_file = Label("//bazel/rust/raze/remote:BUILD.unicode-normalization-0.1.17.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__unicode_segmentation__1_7_1",
        url = "https://crates.io/api/v1/crates/unicode-segmentation/1.7.1/download",
        type = "tar.gz",
        sha256 = "bb0d2e7be6ae3a5fa87eed5fb451aff96f2573d2694942e40543ae0bbe19c796",
        strip_prefix = "unicode-segmentation-1.7.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.unicode-segmentation-1.7.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__unicode_width__0_1_8",
        url = "https://crates.io/api/v1/crates/unicode-width/0.1.8/download",
        type = "tar.gz",
        sha256 = "9337591893a19b88d8d87f2cec1e73fad5cdfd10e5a6f349f498ad6ea2ffb1e3",
        strip_prefix = "unicode-width-0.1.8",
        build_file = Label("//bazel/rust/raze/remote:BUILD.unicode-width-0.1.8.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__unicode_xid__0_2_1",
        url = "https://crates.io/api/v1/crates/unicode-xid/0.2.1/download",
        type = "tar.gz",
        sha256 = "f7fe0bb3479651439c9112f72b6c505038574c9fbb575ed1bf3b797fa39dd564",
        strip_prefix = "unicode-xid-0.2.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.unicode-xid-0.2.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__untrusted__0_7_1",
        url = "https://crates.io/api/v1/crates/untrusted/0.7.1/download",
        type = "tar.gz",
        sha256 = "a156c684c91ea7d62626509bce3cb4e1d9ed5c4d978f7b4352658f96a4c26b4a",
        strip_prefix = "untrusted-0.7.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.untrusted-0.7.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__url__2_2_1",
        url = "https://crates.io/api/v1/crates/url/2.2.1/download",
        type = "tar.gz",
        sha256 = "9ccd964113622c8e9322cfac19eb1004a07e636c545f325da085d5cdde6f1f8b",
        strip_prefix = "url-2.2.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.url-2.2.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__vcpkg__0_2_11",
        url = "https://crates.io/api/v1/crates/vcpkg/0.2.11/download",
        type = "tar.gz",
        sha256 = "b00bca6106a5e23f3eee943593759b7fcddb00554332e856d990c893966879fb",
        strip_prefix = "vcpkg-0.2.11",
        build_file = Label("//bazel/rust/raze/remote:BUILD.vcpkg-0.2.11.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__vec_map__0_8_2",
        url = "https://crates.io/api/v1/crates/vec_map/0.8.2/download",
        type = "tar.gz",
        sha256 = "f1bddf1187be692e79c5ffeab891132dfb0f236ed36a43c7ed39f1165ee20191",
        strip_prefix = "vec_map-0.8.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.vec_map-0.8.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__version_check__0_9_3",
        url = "https://crates.io/api/v1/crates/version_check/0.9.3/download",
        type = "tar.gz",
        sha256 = "5fecdca9a5291cc2b8dcf7dc02453fee791a280f3743cb0905f8822ae463b3fe",
        strip_prefix = "version_check-0.9.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.version_check-0.9.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__want__0_3_0",
        url = "https://crates.io/api/v1/crates/want/0.3.0/download",
        type = "tar.gz",
        sha256 = "1ce8a968cb1cd110d136ff8b819a556d6fb6d919363c61534f6860c7eb172ba0",
        strip_prefix = "want-0.3.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.want-0.3.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasi__0_10_0_wasi_snapshot_preview1",
        url = "https://crates.io/api/v1/crates/wasi/0.10.0+wasi-snapshot-preview1/download",
        type = "tar.gz",
        sha256 = "1a143597ca7c7793eff794def352d41792a93c481eb1042423ff7ff72ba2c31f",
        strip_prefix = "wasi-0.10.0+wasi-snapshot-preview1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasi-0.10.0+wasi-snapshot-preview1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasi__0_9_0_wasi_snapshot_preview1",
        url = "https://crates.io/api/v1/crates/wasi/0.9.0+wasi-snapshot-preview1/download",
        type = "tar.gz",
        sha256 = "cccddf32554fecc6acb585f82a32a72e28b48f8c4c1883ddfeeeaa96f7d8e519",
        strip_prefix = "wasi-0.9.0+wasi-snapshot-preview1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasi-0.9.0+wasi-snapshot-preview1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasm_bindgen__0_2_72",
        url = "https://crates.io/api/v1/crates/wasm-bindgen/0.2.72/download",
        type = "tar.gz",
        sha256 = "8fe8f61dba8e5d645a4d8132dc7a0a66861ed5e1045d2c0ed940fab33bac0fbe",
        strip_prefix = "wasm-bindgen-0.2.72",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasm-bindgen-0.2.72.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasm_bindgen_backend__0_2_72",
        url = "https://crates.io/api/v1/crates/wasm-bindgen-backend/0.2.72/download",
        type = "tar.gz",
        sha256 = "046ceba58ff062da072c7cb4ba5b22a37f00a302483f7e2a6cdc18fedbdc1fd3",
        strip_prefix = "wasm-bindgen-backend-0.2.72",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasm-bindgen-backend-0.2.72.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasm_bindgen_futures__0_4_22",
        url = "https://crates.io/api/v1/crates/wasm-bindgen-futures/0.4.22/download",
        type = "tar.gz",
        sha256 = "73157efb9af26fb564bb59a009afd1c7c334a44db171d280690d0c3faaec3468",
        strip_prefix = "wasm-bindgen-futures-0.4.22",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasm-bindgen-futures-0.4.22.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasm_bindgen_macro__0_2_72",
        url = "https://crates.io/api/v1/crates/wasm-bindgen-macro/0.2.72/download",
        type = "tar.gz",
        sha256 = "0ef9aa01d36cda046f797c57959ff5f3c615c9cc63997a8d545831ec7976819b",
        strip_prefix = "wasm-bindgen-macro-0.2.72",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasm-bindgen-macro-0.2.72.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasm_bindgen_macro_support__0_2_72",
        url = "https://crates.io/api/v1/crates/wasm-bindgen-macro-support/0.2.72/download",
        type = "tar.gz",
        sha256 = "96eb45c1b2ee33545a813a92dbb53856418bf7eb54ab34f7f7ff1448a5b3735d",
        strip_prefix = "wasm-bindgen-macro-support-0.2.72",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasm-bindgen-macro-support-0.2.72.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__wasm_bindgen_shared__0_2_72",
        url = "https://crates.io/api/v1/crates/wasm-bindgen-shared/0.2.72/download",
        type = "tar.gz",
        sha256 = "b7148f4696fb4960a346eaa60bbfb42a1ac4ebba21f750f75fc1375b098d5ffa",
        strip_prefix = "wasm-bindgen-shared-0.2.72",
        build_file = Label("//bazel/rust/raze/remote:BUILD.wasm-bindgen-shared-0.2.72.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__web_sys__0_3_49",
        url = "https://crates.io/api/v1/crates/web-sys/0.3.49/download",
        type = "tar.gz",
        sha256 = "59fe19d70f5dacc03f6e46777213facae5ac3801575d56ca6cbd4c93dcd12310",
        strip_prefix = "web-sys-0.3.49",
        build_file = Label("//bazel/rust/raze/remote:BUILD.web-sys-0.3.49.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__widestring__0_4_3",
        url = "https://crates.io/api/v1/crates/widestring/0.4.3/download",
        type = "tar.gz",
        sha256 = "c168940144dd21fd8046987c16a46a33d5fc84eec29ef9dcddc2ac9e31526b7c",
        strip_prefix = "widestring-0.4.3",
        build_file = Label("//bazel/rust/raze/remote:BUILD.widestring-0.4.3.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winapi__0_2_8",
        url = "https://crates.io/api/v1/crates/winapi/0.2.8/download",
        type = "tar.gz",
        sha256 = "167dc9d6949a9b857f3451275e911c3f44255842c1f7a76f33c55103a909087a",
        strip_prefix = "winapi-0.2.8",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winapi-0.2.8.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winapi__0_3_9",
        url = "https://crates.io/api/v1/crates/winapi/0.3.9/download",
        type = "tar.gz",
        sha256 = "5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419",
        strip_prefix = "winapi-0.3.9",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winapi-0.3.9.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winapi_build__0_1_1",
        url = "https://crates.io/api/v1/crates/winapi-build/0.1.1/download",
        type = "tar.gz",
        sha256 = "2d315eee3b34aca4797b2da6b13ed88266e6d612562a0c46390af8299fc699bc",
        strip_prefix = "winapi-build-0.1.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winapi-build-0.1.1.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winapi_i686_pc_windows_gnu__0_4_0",
        url = "https://crates.io/api/v1/crates/winapi-i686-pc-windows-gnu/0.4.0/download",
        type = "tar.gz",
        sha256 = "ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6",
        strip_prefix = "winapi-i686-pc-windows-gnu-0.4.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winapi-i686-pc-windows-gnu-0.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winapi_x86_64_pc_windows_gnu__0_4_0",
        url = "https://crates.io/api/v1/crates/winapi-x86_64-pc-windows-gnu/0.4.0/download",
        type = "tar.gz",
        sha256 = "712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f",
        strip_prefix = "winapi-x86_64-pc-windows-gnu-0.4.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winapi-x86_64-pc-windows-gnu-0.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winreg__0_6_2",
        url = "https://crates.io/api/v1/crates/winreg/0.6.2/download",
        type = "tar.gz",
        sha256 = "b2986deb581c4fe11b621998a5e53361efe6b48a151178d0cd9eeffa4dc6acc9",
        strip_prefix = "winreg-0.6.2",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winreg-0.6.2.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__winreg__0_7_0",
        url = "https://crates.io/api/v1/crates/winreg/0.7.0/download",
        type = "tar.gz",
        sha256 = "0120db82e8a1e0b9fb3345a539c478767c0048d842860994d96113d5b667bd69",
        strip_prefix = "winreg-0.7.0",
        build_file = Label("//bazel/rust/raze/remote:BUILD.winreg-0.7.0.bazel"),
    )

    maybe(
        http_archive,
        name = "raze__ws2_32_sys__0_2_1",
        url = "https://crates.io/api/v1/crates/ws2_32-sys/0.2.1/download",
        type = "tar.gz",
        sha256 = "d59cefebd0c892fa2dd6de581e937301d8552cb44489cdff035c6187cb63fa5e",
        strip_prefix = "ws2_32-sys-0.2.1",
        build_file = Label("//bazel/rust/raze/remote:BUILD.ws2_32-sys-0.2.1.bazel"),
    )
