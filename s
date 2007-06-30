#!/usr/bin/perl -w

@vars = qw/ DISPLAY /;

sub croak {
  if (scalar @_) {
    my $m = shift;
    die "$m: $!\n";
  } else {
    die "$!\n";
  }
}

  

open $fh, ">", "$ENV{HOME}/.transient-environment" or croak;
for $v (@vars) {
  print $fh "export $v=$ENV{$v}\n" if defined $ENV{$v};
}
close $fh or croak;

exec qw/screen -dRR/ or croak;





