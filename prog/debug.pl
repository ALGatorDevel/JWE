#!/usr/bin/perl

use CGI;

#td ... debug
print "Content-type: text/html\n\n JWE is great!";
my $key;
print "<pre>";
for $key (keys(%ENV)){
	print "$key = $ENV{$key}\n";
}
print "</pre>";