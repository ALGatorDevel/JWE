#!/usr/bin/perl

use modules::Tools;

my $urlPrefix = "http://kepa.fri.uni-lj.si/jwe/jwe.pl?aaa=";

if ($#ARGV < 2){
  print "\nUsage: $0 projectID entityType entityName p1 p2 p3 p4 p5 p6\n\n";
  exit(42);
}


print $urlPrefix . Tools::getJWELink(@ARGV);