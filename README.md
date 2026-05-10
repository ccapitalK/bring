# Bring

Bring is a binary file tracking extension for git. Binary files have checksums tracked in the host git repository,
versions of each binary file can be tied to each git commit by checking in the corresponding hashfile.


**NOTE: Bring is currently in early development, a lot of the below design is aspirational and yet to be implemnted.
I want to get the UX right first before ironing out parts of the implementation, so please don't assume the current
data model/data layout will be the final one. Use at your own risk**


## Intended Design

Each binary file should be ignored in the host git repo, the corresponding ascii hash files should be tracked.
For a binary file named "${FOO}", the corresponding hash file is "${FOO}.brhash".

In the root of the git repo, a config file (`.bringrc`) specifies the repo's canonical binary store. Binary stores can
be tracked using named file system stores, an s3 compatible store, or over ssh (planned, currently hardcode user wide
fs store).

## Planned Features

- [x] Status
- [x] Checkout
- [x] Add
- [ ] Update gitignore
- [ ] Ensure Sync
- [ ] Sync
- [ ] Init
- [ ] Store management

## Intended UI

```
$ bring status
$ bring update-gitignore
$ bring checkout HEAD~ foo/bar/data.bin
$ bring ensure-sync # return 0 iff all checksums in current worktree are present on bring remote 
$ bring sync
$ bring init-local-store
```
