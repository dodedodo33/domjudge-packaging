#!/bin/bash
/opt/domjudge/judgehost/bin/dj_make_chroot -i python,mono-mcs

cd /
tar -czvpf /chroot.tar.gz /chroot
tar -czvpf /judgehost.tar.gz /opt/domjudge/judgehost
