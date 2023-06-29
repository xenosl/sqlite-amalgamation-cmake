# sqlite-cmake

CMake project to download/build/install sqlite amalgamation distribution.

## Download

You can choose to download automatically download the sqlite3 amalgamation source or provide the source archive yourself
by the following CMake options.
- DOWNLOAD_SQLITE_ARCHIVE: Whether to automatically download the sqlite3 amalgamation archive.
- SQLITE_ARCHIVE_URL: The url of sqlite amalgamation source archive. Only available when DOWNLOAD_SQLITE_ARCHIVE is ON.
- SQLITE_ARCHIVE_HASH: The sha2256 hash string for the sqlite amalgamation source archive. Only available when
  DOWNLOAD_SQLITE_ARCHIVE is ON.
- SQLITE_ARCHIVE: Where the sqlite amalgamation source archive located. Set the value locate an existing sqlite
  amalgamation source archive when DOWNLOAD_SQLITE_ARCHIVE is OFF to skip download and let the project use the source
  archive you provided, or specify where the downloaded source archive is located when DOWNLOAD_SQLITE_ARCHIVE is ON.

## Examples

- On Windows with Visual Studio developer command prompt:
  ```bat
  > mkdir build
  > cd build
  > cmake -G"NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="../install" ../
  > cmake --build .
  > cmake --install .
  ```

- On Linux terminal:
  ```shell
  $ mkdir build
  $ cd build
  $ cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/user/libs/sqlite3
  $ cmake --build .
  $ cmake --install .
  ```

