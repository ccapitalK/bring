// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.stores.s3;

static import cS3 = stores._s3;

import bring.config;
import bring.context;

// FIXME: Better initialization.
shared bool awsInitialized;
bool initAws() {
    synchronized {
        if (awsInitialized) {
            return true;
        }
        auto allocator = cS3.aws_default_allocator();
        cS3.aws_s3_library_init(allocator);
        awsInitialized = true;
        return true;
    }
}

struct AWSCBridge {
    bool destroyed;
    cS3.aws_event_loop_group *el_group;
    cS3.aws_host_resolver *host_resolver;
    cS3.aws_client_bootstrap *bootstrap;
    cS3.aws_credentials_provider *creds;
}

AWSCBridge initBridge(UserBringConfig *config) {
    auto bridge = AWSCBridge();
    cS3.aws_host_resolver_default_options *resolver_opts;
    cS3.aws_credentials_provider_chain_default_options cred_opts;
    return bridge;
}

class S3Store : Store {
    AWSCBridge bridge;

    this(UserBringConfig *config) {
        bridge = initBridge(config);
    }

    bool[] has(string[] hashes) {
        // TODO
        return new bool[hashes.length];
    }

    void getStream(string hash, void delegate(ubyte[]) onChunk) {
        // TODO
    }

    void putStream(string hash, ubyte[] delegate() putChunk) {
        // TODO
    }

    void close() {
        if (!bridge.destroyed) {
        }
    }
}
