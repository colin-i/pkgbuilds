
# Maintainer: Costin Botescu <costin.botescu@gmail.com>
pkgname=edor
pkgver=1.x63
pkgrel=1
pkgdesc="CUI text editor"
arch=(x86_64 aarch64)
url="https://github.com/colin-i/edor"
license=('GPL')
groups=()
depends=('ncurses')
makedepends=('ncurses')
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
source=('git+http://github.com/colin-i/edor.git#tag=1-x63')
noextract=()
sha256sums=('SKIP')

prepare() {
	cd "$pkgname"
	a=`git ls-remote --tags --sort='v:refname' | tail -n1 | sed 's/.*\///; s/\^{}//; s/\-/./'`
	#patch from 1.x63 to current version
	echo -n ${a} > version.txt
	cat version.txt
}

pkgver() {
	cd "$pkgname"
	cat version.txt
}

build() {
	cd "$pkgname"
	autoreconf -i
	./configure --prefix=/usr
	make
}

check() {
	cd "$pkgname"
	make test
}

package() {
	cd "$pkgname"
	make DESTDIR="$pkgdir/" install
}
