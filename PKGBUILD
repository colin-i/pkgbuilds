
# Maintainer: Costin Botescu <costin.botescu@gmail.com>
pkgname=edor
pkgver=1.x68
pkgrel=1
pkgdesc="CUI text editor"
arch=(x86_64 aarch64)
url="https://github.com/colin-i/edor"
license=('0BSD')
groups=()
depends=('ncurses')
makedepends=('ncurses' 'bc')
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
	patches=( `cat ../patches/list` )
	cd $pkgname
	for var in "${patches[@]}"; do
		echo ${var}
		patch --strip=1 --input=../../patches/${var}
	done
}

pkgver() {
	cd "$pkgname"
	git ls-remote --tags --sort='v:refname' > version.txt 2>&1 #it is extra: From...
	cat version.txt | tail -n1 | sed 's/.*\///; s/\-/./'
	rm version.txt
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
