#!/usr/bin/perl -w

# windows
# !c:/Perl/bin/perl.exe -w

use lib ".";

use lib "/opt/local/lib/perl5/site_perl/5.16.3";
use HTML::Template;

use modules::JsonHelper;
use modules::Entities;
use modules::Tools;

use modules::Pages;
use modules::Actions;

use Data::Dumper;

use Cwd;

use strict;
use warnings;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use File::Path qw(make_path rmtree);
use File::Basename;
use File::Spec;

use MIME::Base64;
use URI::Escape;

#################################################
#
# Get input from "param" via CGI.pm.
#
#################################################

my $pwd = cwd();

my $query = new CGI;

my $action = $query->param("performAction");
my $aaa              = $query->param("aaa");

my $decoded;

my $pId   = $query->param("pId");
my $eType = $query->param("eType");
my $eName = $query->param("eName");
my $p1    = $query->param("\$1");
my $p2    = $query->param("\$2");
my $p3    = $query->param("\$3");
my $p4    = $query->param("\$4");
my $p5    = $query->param("\$5");
my $p6    = $query->param("\$6");

Tools::Log("------------------------------------------------------------");


my $editSingleEntity = 0;

if ( defined($aaa) ) {

	Tools::Log("Parameter aaa: $aaa");
	
	$editSingleEntity = 1; 
	
	($pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6) = Tools::getParametersFromJWELink($aaa);

}

Tools::Log("action: $action") if defined($action);
Tools::Log("pId   : $pId")    if defined($pId);
Tools::Log("eType : $eType")  if defined($eType);
Tools::Log("eName : $eName")  if defined($eName);
Tools::Log("p1    : $p1")     if defined($p1);
Tools::Log("p2    : $p2")     if defined($p2);
Tools::Log("p3    : $p3")     if defined($p3);
Tools::Log("p4    : $p4")     if defined($p4);
Tools::Log("p5    : $p5")     if defined($p5);
Tools::Log("p6    : $p6")     if defined($p6);
Tools::Log(" ");

#################################################
#
# Main program
#
#################################################

my $loginStatus = 1;

# check if project id or action are defined
if (defined($pId) || defined($action)) {

	$loginStatus = 1;
}

# if unsuccessful report error and exit
if ( $loginStatus == 0 ) {

	print $query->header();
	print "JWE is great!<br><br>To bad no parameters were used. :) ";

	exit;
}

# if action is defined, ignore other parameters
if ( defined($action) ) {

	Actions::PerformAction( $action, $pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6, $editSingleEntity, $query );

	exit;
}

# if project id is not defined it means list of main projects should be displayed
if ( !defined($pId) ) {

    #Pages::ShowProjectsPage();

	Pages::showEmptyPage();

	exit;
}

# if entity type is not defined list of defined projects should be displayed
if ( !defined($eType) ) {

	Pages::ShowOverviewPage($pId);

	exit;
}

# all parameters are defined => edit of entity is required
if (defined($eName)) {
	
	Pages::EditEntity( $pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6, $editSingleEntity );

	exit;
}

1;
