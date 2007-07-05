


package Utils;


require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(croak ssystem);

sub croak {
  if (scalar @_) {
    my $m = shift;
    die "$m: $!\n";
  } else {
    die "$!\n";
  }
}

sub ssystem  {
  my $name = $_[0];
  my @args = @_;
  my $tmp = "/tmp/delicious_update$$";
  my $pid = fork();
  my ($fh ,$nh);
  open $nh, "<", "/dev/null" or croak;
  open $fh, ">", $tmp or croak;
  my $fd = fileno $fh;
  my $nd = fileno $nh;
  if ($pid) {
    close $fh;
    waitpid $pid,0;
    unless (0==$?) {
      system qw/cat/, $tmp;
      unlink $tmp;
      die "$name failed\n";
    }
    unlink $tmp or croak;
  } else {
    POSIX::close(0);
    POSIX::close(1);
    POSIX::close(2);
    POSIX::dup2($nd, 0);
    POSIX::dup2($fd, 2);
    POSIX::dup2($fd, 1); 
    exec @args;    
  }
}




1;
