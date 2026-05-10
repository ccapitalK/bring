# Maintainer: Sahan Fernando <sahan.h.fernando@gmail.com>

pkgname=bring
pkgver=0.1.1
pkgrel=1
arch=('x86_64')
pkgdesc="Binary file store and synchronization tool for git"
url="https://www.github.com/ccapitalk/bring"
license=('GPL-2.0-only')
depends=('git')
makedepends=('ldc' 'dub')
source=("git+https://github.com/ccapitalk/bring")
sha256sums=('SKIP')
options=('!debug' '!strip')

# prepare() {
#     cd "$pkgname-$pkgver"
#     patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
# }

build() {
    cd "$pkgname"
    dub build -b release --compiler=ldc
}

check() {
    cd "$pkgname"
    dub test
}

package() {
    cd "$pkgname"
    install -Dm644 LICENSE.md "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
    install -Dm755 ${pkgname} "${pkgdir}/usr/bin/${pkgname}"
}
