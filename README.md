# Bring

Bring is a binary file tracking extension for git. Binary files have checksums tracked in the host git repository,
versions of each binary file can be tied to each git commit by checking in the corresponding hashfile.

## Design

Each binary file should be ignored in the host git repo, the corresponding ascii hash files should be tracked.
For a binary file named "${FOO}", the corresponding hash file is "${FOO}.brhash".

In the root of the git repo, a config file (`.bringrc`) specifies the repo's canonical binary store. Binary stores can
be tracked using named file system stores, or an s3 compatible store.

## Planned Features

- [ ] Status
- [ ] Update gitignore
- [ ] Checkout
- [ ] Ensure Sync
- [ ] Sync
- [ ] Init
- [ ] Add

## UI

```
$ bring status
$ bring update-gitignore
$ bring checkout HEAD~ foo/bar/data.bin
$ bring ensure-sync # return 0 iff all checksums in current worktree are present on bring remote 
$ bring sync
```
