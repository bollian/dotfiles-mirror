#!/bin/sh

lnr() {
	mkdir -p `dirname "$2"` || true
	ln -sf `pwd`/"$1" "$2"
}

lnr DotFiles/.bashrc .bashrc
lnr DotFiles/.config/bash .config/bash
lnr DotFiles/.config/git .config/git
lnr DotFiles/.hgrc .hgrc
