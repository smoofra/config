#!/usr/bin/perl -w


use POSIX;





my $fd = POSIX::open("/dev/null", 0);

die "error; $?\n" if $fd == -1;


POSIX::close(1);
POSIX::close(2);
POSIX::dup2($fd, 1);
POSIX::dup2($fd, 2);


exec @ARGV;
