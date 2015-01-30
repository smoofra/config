#!/usr/bin/perl -w

use strict;

my $ldap_server = "localhost";
my $BASEDN      = "ou=larry,ou=personal_addressbook,dc=elder-gods,dc=org"; 

# The fields to match against
my @fields = qw(cn mail sn givenname);

die "Usage: $0 <name_to_query>, [[<other_name_to_query>], ...]\n"
    if ! @ARGV;

$/ = '';	# Paragraph mode for input.
my @results;

foreach my $askfor ( @ARGV ) {

    $askfor =~ s/,$//;	# Remove optional trailing comma.

    my $query = join '', map { "($_=$askfor*)" } @fields;
    $query =~ s/'/'\\''/g; 
    my $command = "ldapsearch -h $ldap_server -b '$BASEDN' -x '(|$query)'" .
                  " sn cn givenName mail telephoneNumber mobile";

    #print $command, "\n";

    open( LDAPQUERY, "$command |" ) or die "LDAP query error: $!"; 

    while ( <LDAPQUERY> ) {
	next if ! /^mail: (.*)$/im;

	my $email = $1;
	my $phone = /^telephoneNumber: (.*)$/im ? $1 : '';
	my $mobile = /^mobile: (.*)$/im ? $1 : '';
	my ( @name ) = ( /^cn: (.*)$/im, /^sn: (.*)$/im );
	my $other = ($phone eq '' ? $mobile : $phone);

	push @results, "$email\t@name\t$other\n";
    }

    close( LDAPQUERY ) or die "ldapsearch failed: $!\n";
}

print "LDAP query: found ", scalar(@results), "\n", @results;
exit 1 if ! @results;
