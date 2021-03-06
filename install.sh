#!/bin/bash

bin="$(basename $0)"
pkg_root="$HOME/pkg"
makepkgargs="-si"
url="https://aur.archlinux.org/cgit/aur.git/snapshot"
verbose=0
fake=0

function help()
{
	echo "Usage: $bin [OPTION ...] PACKAGE ..."
	echo
	echo "downloads, builds, and installs packages from the AUR"
	echo
	echo "OPTIONS:"
	echo "	-a ARGS		arguments to pass to makepkg when building (default '$makepkgargs')"
	echo "	-d DIR		use DIR as the package root (default '\$HOME/pkg')"
	echo "	-h		display this text and exit"
	echo
	echo "Any number of packages may be specified as arguments."
	echo "$bin will download and build them in the order they appear."
	echo
	echo "After downloading and extracting a package tarball, the user may edit PKGBUILD."
	echo "$bin uses \$EDITOR to do this."
	echo
	echo "After PKGBUILD has been inspected, the user has the option to not build a package." 
	echo "This is useful if the user wants to manually check or edit a source file."
}

while getopts ":a:d:h" option; do
	case "${option}" in
		a)
			makepkgargs="$OPTARG"
			;;
		d)
			pkg_root="$OPTARG"
			;;
		h)
			help
			exit 0
			;;
		\?)
			echo "$bin: invalid option -$OPTARG"
			echo
			exit 1
			;;
		:)
			echo "$bin: option -$OPTARG requires an argument"
			echo
			exit 1
			;;
	esac
done

echo "package root = $pkg_root"
echo "makepkg arguments = $makepkgargs"
echo

shift $((OPTIND-1))

if [ $# -eq 0 ]; then
	echo "$bin: must specify at least one package"
	exit 1
fi

cd "$pkg_root/"

old="$OLDPWD"

for pkg_name in "$@"; do
	echo "fetching '$pkg_name'"
		
	# probably a better way to get / verify this file?
	curl -L -O "$url/$pkg_name.tar.gz" 2> /dev/null

	tar xvf "$pkg_name.tar.gz" 2> /dev/null

	if [ $? -ne 0 ]; then
		echo "$bin: package '$pkg_name' does not exist or has been removed"
		rm "$pkg_name.tar.gz"
		continue
	fi
	# end block

	echo -n "extraction complete. delete tarball? [y/N]: "

    line = "y"
	if [ "$line" = "y" ]; then
		rm -v "$pkg_name.tar.gz"
	fi


	echo -n "continue building '$pkg_name?' [Y/n]: "

    line = "y"
	if [ "$line" = "n" ]; then
		echo "package '$pkg_name' has NOT been built. you may edit source files in '$pkg_root/$pkg_name'"
		echo "run 'makepkg $makepkgargs' in that directory to build and install"
		continue
	fi

	cd "$pkg_name/"
	makepkg "$makepkgargs"
	cd "$pkg_root"
	
	echo -n "delete extracted package contents? [y/N]: "

    line = "y"
	if [ "$line" == "y" ]; then
		rm -rfv "$pkg_name"
	fi
	
	echo
done

cd "$old"
