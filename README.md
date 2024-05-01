# Bazel `local_path_override` bug example

This reproduces a problem with using a [Bazel module][] within the same
repository that calls [load()][] on a top-level target. The problem happens with
both:

- [7.1.1][]: The most recent official release
- [8.0.0-pre.20240415.1]: The most recent prerelease build

Use [bazelisk][] and tweak [.bazelversion](./.bazelversion) to switch between
the two.

`third_party/vendored_module` is a trimmed down example based on a vendored copy
of the [bazel_skylib v1.5.0][] distribution used by my project. This example
module builds successfully with both Bazel versions in its own directory, both
with and without bzlmod.

## Without bzlmod

Configured via [local_repository][] in [WORKSPACE](./WORKSPACE):

```txt
% bazel build --nobuild --enable_bzlmod=false //...

INFO: Analyzed 0 targets (1 packages loaded, 0 targets configured).
INFO: Found 0 targets...
INFO: Elapsed time: 0.099s, Critical Path: 0.00s
INFO: 0 processes.
INFO: Build completed successfully, 0 total actions
```

## With bzlmod

Configured via [bazel_dep and local_path_override][] in
[MODULE.bazel](MODULE.bazel):

```txt
% bazel build --nobuild --enable_bzlmod=true //...

WARNING: Target pattern parsing failed.
ERROR: Skipping '//...': error loading package under directory '': error loading package 'third_party/vendored_module': cannot load '//:top_level_target.bzl': no such file
ERROR: error loading package under directory '': error loading package 'third_party/vendored_module': cannot load '//:top_level_target.bzl': no such file
INFO: Elapsed time: 0.054s
INFO: 0 processes.
ERROR: Build did NOT complete successfully
```

`local_path_override` and the bzmlod mechanism seem to assume the module will
not reside within the same repo. The [WORKSPACE or MODULE.bazel repository
boundary marker files][markers] don't appear to have an effect. (Neither do
artificially added REPO.bazel or WORKSPACE.bazel files.)

[Bazel module]: https://bazel.build/external/module
[load()]: https://bazel.build/concepts/build-files#load
[7.1.1]: https://github.com/bazelbuild/bazel/tree/7.1.1
[8.0.0-pre.20240415.1]: https://github.com/bazelbuild/bazel/tree/8.0.0-pre.20240415.1
[bazelisk]: https://github.com/bazelbuild/bazelisk
[bazel_skylib v1.5.0]: https://github.com/EngFlow/engflow/tree/v1.5.0
[local_repository]: https://bazel.build/reference/be/workspace#local_repository
[bazel_dep and local_path_override]: https://bazel.build/external/migration#introduce-local-deps
[markers]: https://bazel.build/concepts/build-ref#repositories
