module bring.hash;

import std.digest.sha;
static import std.file;

import bring.context;
import bring.util;

enum HashAlgorithm {
    sha1,
}

struct BringHash {
    HashAlgorithm algorithm;
    string hashHex;
}

BringHash hashFromData(ubyte[] data) {
    // FIXME: Streaming hash, literally 5 lines
    auto digest = makeDigest!SHA1();
    digest.put(data);
    const hash = digest.finish();
    return BringHash(
        algorithm: HashAlgorithm.sha1,
        hashHex: hash.toHexString().idup,
    );
}

string serialize(BringHash hash) {
    return hash.hashHex;
}

BringHash readBringHash(string path) {
    return BringHash(
        algorithm: HashAlgorithm.sha1,
        hashHex: std.file.readText(path),
    );
}

