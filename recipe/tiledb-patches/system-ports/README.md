## vcpkg system ports for TileDB

This folder contains empty port overlays for the dependencies that are already provided by conda-forge. This is [the recommended way to use system dependencies with vcpkg](https://devblogs.microsoft.com/cppblog/using-system-package-manager-dependencies-with-vcpkg/).

### Which ports should be added

This folder should contain port overlays only for direct dependencies, as specified in [TileDB's `vcpkg.json` file](https://github.com/TileDB-Inc/TileDB/blob/dev/vcpkg.json), that also exist in conda-forge. Transitive dependencies (like `aws-crt-cpp` which is used by `aws-sdk-cpp`) should not be included.

### How to add a port/feature

When TileDB adds a new dependency that exists in conda-forge, a new port overlay should be added to this folder. The overlay should only contain two files: `portfile.cmake` and `vcpkg.json`.

The `portfile.cmake` should contain the following single line:

```cmake
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
```

The `vcpkg.json` should contain:

1. A `name` field with a value equal to the port's name.
2. A `version-string` field with a value equal to `system`.
3. A `features` field with a list of the port's features that TileDB uses, with each feature containing only the `description` field.

To show an example, suppose TileDB started depending on package `foo`, that also exists in conda-forge. This is the `vcpkg.json` file as exists in the vcpkg repo:

```json
{
  "name": "foo",
  "version": "1.2.3",
  "default-features": [
    "foo"
  ],
  "features": [
    "foo": {
      "description": "foo feature",
      "dependencies": [
        "name": "openssl",
        "platform": "!windows"
      ]
    },
    "bar": {
      "description": "bar feature"
    }
  ]
}
```

After applying the rules above, `tiledb-patches/system-ports/foo/vcpkg.json` should look like this:

```json
{
  "name": "foo",
  "version-string": "system",
  "features": [
    "foo": {
      "description": "foo feature"
    },
    "bar": {
      "description": "bar feature"
    }
  ]
}
```

If supposedly TileDB used only the `foo` feature, the system `vcpkg.json` should still contain the definition for the `bar` feature, to avoid churn in the feedstock if TileDB subsequently starts using `bar`. An exception can be made if the port contains too many features, like the AWS and Google Cloud SDKs.

If TileDB starts using a new feature of a port that does not exist in the port overlay, CI will fail, and the new feature should simply be added.
