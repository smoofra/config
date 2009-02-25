


package Utils;


require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(slurp slurpdir croak);



sub croak {
  if (scalar @_) {
    my $m = shift;
    die "$m: $!\n";
  } else {
    die "$!\n";
  }
}


sub slurpdir {
  my $dn = shift;
  my $fh;
  opendir $fh, $dn or croak;
  my @x = grep {$_ ne '.' && $_ ne '..'} readdir $fh;
  close $fh;
  return @x;
}
 
sub slurp {
  my $fn = shift;
  my $fh;
  open $fh, $fn or croak;
  my $r = join '', <$fh>;
  close $fh;
  return $r;
}




1;
