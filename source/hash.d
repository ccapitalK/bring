// SPDX-License-Identifier: GPL-2.0-only

module bring.hash;

import std.array;
import std.datetime;
import std.digest.sha;
import std.exception;
static import std.file;
static import std.stdio;
import std.string;

import bring.context;
import bring.util;

enum HashAlgorithm {
    sha1,
}

struct BringHash {
    HashAlgorithm algorithm;
    string hashHex;
}

BringHash hashFileContents(string path) {
    auto digest = makeDigest!SHA1();
    auto file = std.stdio.File(path);
    foreach (chunk; file.byChunk(8192)) {
        digest.put(chunk);
    }
    const hash = digest.finish();
    return BringHash(
        algorithm: HashAlgorithm.sha1,
        hashHex: hash.toHexString().idup,
    );
}

string serialize(BringHash hash) {
    enforce(hash.algorithm == HashAlgorithm.sha1);
    return "BRING:SHA1:" ~ hash.hashHex;
}

BringHash readBringHash(string path) {
    auto data = std.file.readText(path);
    enforce(data.startsWith("BRING"), "Invalid magic for hashfile");
    auto parts = data.split(':');
    enforce(parts.length == 3, "Invalid hashfile");
    enforce(parts[0] == "BRING", "Invalid magic");
    enforce(parts[1] == "SHA1", "Unknown hash algorithm");
    return BringHash(
        algorithm: HashAlgorithm.sha1,
        hashHex: parts[2].strip,
    );
}

// FIXME: Rewrite this using raw syscalls
SysTime mTime(string path) {
    return std.file.timeLastModified(path);
}

BringHash getFileDataHashWithCaching(string path) {
    enforce(!path.endsWith(BRHASH_FILE_EXT_WITH_DOT));
    auto hashFilePath = path ~ BRHASH_FILE_EXT_WITH_DOT;
    auto fileMTime = path.mTime;
    auto hashFileMTime = hashFilePath.mTime;
    return hashFileMTime >= fileMTime ? path.hashFileContents : hashFilePath.readBringHash;
}
