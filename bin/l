#!/usr/bin/perl -w 

use IPC::Run qw/run/ ;

die "huh?\n" unless @ARGV; 

if ($ENV{INSIDE_EMACS}) { 
  run \@ARGV, '2>&1', '|', ['eless'], '>', \*STDOUT, '2>', \*STDERR;
} else {
  run \@ARGV, '2>&1', '|', ['less'], '>', \*STDOUT, '2>', \*STDERR;
}






