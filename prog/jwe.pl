#!/usr/bin/perl -w

use lib ".";

use lib "/opt/local/lib/perl5/site_perl/5.16.3";
use HTML::Template;

use modules::JsonHelper;
use modules::EntityTools;
use modules::Tools;
use URI::Escape;

use Data::Dumper; 

use feature qw(switch);

use Cwd;
use CGI qw(redirect referer);

use strict;
use warnings;
 
use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use MIME::Base64;

#################################################
#
# Get input from "param" via CGI.pm.
#
#################################################

my $query = new CGI;

my $decoded;


my $pId       = $query->param("pId");
my $eType     = $query->param("eType");
my $eName     = $query->param("eName");
my $p1        = $query->param("\$1");
my $p2        = $query->param("\$2");
my $p3        = $query->param("\$3");
my $p4        = $query->param("\$4");
my $p5        = $query->param("\$5");
my $p6        = $query->param("\$6");

my $action    = $query->param("action");

my $pwd = cwd();

my $aaa       = $query->param("aaa");
my $editSingleEntity = 0;

if (defined($aaa))
{
	$editSingleEntity = 1;
	
	my $tempString = $aaa;
	
	$tempString =~ s/WERTYYTREW/\+/g;
	$tempString =~ s/ERTYUUYTRE/\//g;
	$tempString =~ s/QWERTTREWQ/\=/g;
	
	$decoded = decode_base64($tempString);
	
	my @tokens = split(/\&/, $decoded);
	
	foreach my $token (@tokens)
	{
		my @tokens2 = split(/=/, $token);
		
		my $param = $tokens2[0];
		my $value = $tokens2[1];
		
		if (lc $param eq "pid")
		{
			$pId = $value;
		}

		if (lc $param eq "etype")
		{
			$eType = $value;
		}

		if (lc $param eq "ename")
		{
			$eName = $value;
		}

		if (lc $param eq "\$1")
		{
			$p1 = $value;
		}

		if (lc $param eq "\$2")
		{
			$p2 = $value;
		}

		if (lc $param eq "\$3")
		{
			$p3 = $value;
		}

		if (lc $param eq "\$4")
		{
			$p4 = $value;
		}

		if (lc $param eq "\$5")
		{
			$p5 = $value;
		}

		if (lc $param eq "\$6")
		{
			$p6 = $value;
		}
	}
}

#################################################
#
# Function: listMainProjects
#
# Description:
# 	Function reads all projects from config file
#
#################################################

sub listMainProjects
{
	# get configuration settings from common configuration file
	my $data = EntityTools::getConfigSettings();
	
	my @val = $data;
	my @loop_data = ();
	
	# list all projects from config file
	foreach my $element (@val)
	{
		# list all properties for current project in alphabetical order
		for my $key (sort(keys(%$element)))
		{
			# get property value
			my $value = $element->{$key};
			
			# skip if value cannot be found
			if (!defined($value))
			{
				continue;
			}
			
			# get project name and id
			my $projectName = $value->{Name};
			my $projectId   = $value->{Id};
			
			# skip if project name or project id is not defined
			if (!defined($projectName) || !defined($projectId))
			{
				continue;
			}
			
			# add project to the project list
			my %row_data;
		
	     	$row_data{PROJECT_NAME} = $projectName;
	     	$row_data{PROJECT_ID}   = $projectId;
		     
	     	push(@loop_data, \%row_data);
		}
	}

	# return list of defined main projects
    return @loop_data;
}

#################################################
#
# Function: listProjects
#
# Description:
# 	Function reads all projects from config file
#
#################################################

sub listProjects
{
	my $projectId       = $_[0];

	# get list of projects defined in current main project
	#td: vrstico odstranim - glej komentar spodaj
	#my $val = EntityTools::getProjectList($projectId);

	#td
	#ni mi vsec, da se projekti berejo iz konfiguracijske datoteke; namesto 
	# tega bom projekte prebral iz datotecnega sistema (vse mape PROJ-*) 
	my $projectSettings = EntityTools::getProjectSettings($projectId);
	my $projectPath = $projectSettings->{ProjectsRoot};
	my @val = `ls $projectPath/Projects/`;
	
	my @loop_data = ();
	
	# parse all projects and add them to the list
	                    #td: @$ spremenim v @
	foreach my $element (@val)
	{
		#td
		chomp $element;
		$element =~ s/PROJ-//;
		
		my %row_data;

     	$row_data{PROJECT_ID}   = $projectId;
     	$row_data{ENTITY_TYPE}  = "Project";
     	$row_data{ENTITY_NAME}  = $element;
     
     	push(@loop_data, \%row_data);
	}

    return @loop_data;
}

#################################################
#
# Function: listSchemeProperties
#
# Description:
# 	Function reads all scheme settings from config file
#
#################################################

sub listSchemeProperties
{
    my $projectId   = $_[0];
    my $entityType  = $_[1];
    my $entityName  = $_[2];
    my $p1          = $_[3];
    my $p2          = $_[4];
    my $p3          = $_[5];
    my $p4          = $_[6];
    my $p5          = $_[7];
    my $p6          = $_[8];

	my @loop_data = ();
	
	my $data = EntityTools::getEntitySchemeData($projectId, $entityType);
	
	if (!defined($data))
	{
		return @loop_data;
	}
	
	foreach my $key (sort(keys(%$data)))
	{
		my $val = $data->{$key};
				
		if (ref($val) eq "ARRAY")
		{
		}
		elsif (ref($val) eq "HASH")
		{
			my @loop_data2 = ();

			foreach my $key2 (sort(keys(%$val)))
			{
				my $val2 = $val->{$key2};

				if (ref($val2) eq "HASH")
				{
					my @loop_data3 = ();
					
					foreach my $key3 (sort(keys(%$val2)))
					{
						my $val3 = $val2->{$key3};
						
						my %row_data;
								
					 	$row_data{KEY} = $key3;
					 	$row_data{HASH} = 0;
					 	
					 	if (ref($val3) eq "ARRAY")
					 	{
						 	$row_data{HASH} = 1;
						 	
							my @loop_data4 = ();
		
						 	foreach my $parameter (@$val3)
						 	{
								my %row_data;
										
							 	$row_data{VALUE} = $parameter;

							 	push(@loop_data4, \%row_data);
						 	}

					 		$row_data{VALUE2} = \@loop_data4;
					 	}
					 	else
					 	{
					 		$row_data{VALUE} = $val3;
					 	}
					
					 	push(@loop_data3, \%row_data);
					}

					my %row_data;
							
					$row_data{ARRAY} = 0;
					$row_data{HASH} = 1;
				 	$row_data{KEY} = $key2;
				 	$row_data{VALUE} = $val2;
				 	$row_data{CHILDREN} = \@loop_data3;
				
				 	push(@loop_data2, \%row_data);
				}
				else
				{
					my %row_data;
							
					$row_data{ARRAY} = 0;
					$row_data{HASH} = 0;
				 	$row_data{KEY} = $key;
				 	$row_data{VALUE} = $val;
				
				 	push(@loop_data2, \%row_data);
				}
			}

			my %row_data;
					
			$row_data{ARRAY} = 0;
			$row_data{HASH} = 1;
		 	$row_data{KEY} = $key;
		 	$row_data{VALUE} = $val;
		 	$row_data{CHILDREN} = \@loop_data2;
		
		 	push(@loop_data, \%row_data);
			
		}
		else
		{
			my %row_data;
					
			$row_data{ARRAY} = 0;
			$row_data{HASH} = 0;
		 	$row_data{KEY} = $key;
		 	$row_data{VALUE} = $val;
		
		 	push(@loop_data, \%row_data);
		}
	}
	
	return @loop_data;
}

#################################################
#
# Function: showProjectsPage
#
# Description:
# 	Function generates and displays list of all projects
#
#################################################

sub showProjectsPage
{
	my $filename = $pwd . '/conf/projects.html'; 

	my $template = HTML::Template->new(filename => $filename);

	$template->param(PAGE_TITLE => "Spletni urejevalnik JSON datotek");

	my @loop_data = listMainProjects();

	$template->param(PROJECTS => \@loop_data);
	
	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();
}

#################################################
#
# Function: showOverviewPage
#
# Description:
# 	Function generates and displays overview page
#
#################################################

sub showOverviewPage
{
	my $projectId   = $_[0];

	my $projectRootPath = EntityTools::getProjectRootPath($projectId);
	
	my $filename = $projectRootPath . "/Conf/overview.html"; 

	my $template = HTML::Template->new(filename => $filename);
	
	$template->param(PAGE_TITLE => "Spletni urejevalnik JSON datotek");
	$template->param(PROJECT_ID => $projectId);
	
	my @loop_data = listProjects($projectId);
	$template->param(PROJECTS => \@loop_data);
	
	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();
}

#################################################
#
# Function: editEntity
#
# Description:
# 	Function generates and displays page for
#	editing project settings
#
#################################################

sub editEntity
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	my $entityName = $_[2];
	my $p1         = $_[3];
	my $p2         = $_[4];
	my $p3         = $_[5];
	my $p4         = $_[6];
	my $p5         = $_[7];
	my $p6         = $_[8];
	my $index;
	
	my $filename = "/Conf/Entity2.html";
	
	if ($editSingleEntity == 1)
	{
		$filename = "/Conf/Entity2 - clean.html";
	}
	
	$filename = EntityTools::getProjectRootPath($projectId) . $filename; 
	
	my $template = HTML::Template->new(filename => $filename, loop_context_vars => 1, die_on_bad_params => 0);

	$template->param(PAGE_TITLE   => "Spletni urejevalnik JSON datotek");
	$template->param(PROJECT_ID   => $projectId);
	$template->param(ENTITY_TYPE  => $entityType);
	$template->param(ENTITY_NAME  => $entityName);
	$template->param(P1           => $p1);
	$template->param(P2           => $p2);
	$template->param(P3           => $p3);
	$template->param(P4           => $p4);
	$template->param(P5           => $p5);
	$template->param(P6           => $p6);
	
	my ($maxIndex, @loop_data) = EntityTools::listEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6, $index, "1");

	$template->param(SETTINGS => \@loop_data);
	
	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();
	
	#td: print "DECODED:" . $decoded;
}

#################################################
#
# Function: createEntity
#
# Description:
# 	Function generates and displays page for
#	editing project settings
#
#################################################

sub createEntity
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	my $entityName = $_[2];
	my $p1         = $_[3];
	my $p2         = $_[4];
	my $p3         = $_[5];
	my $p4         = $_[6];
	my $p5         = $_[7];
	my $p6         = $_[8];

	EntityTools::createEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6);

	EntityTools::addProject($projectId, $entityName);

	editEntity($projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6);
}

#################################################
#
# Function: listSchemes
#
# Description:
# 	Function reads all schemes defined
#
#################################################

sub listSchemes
{
	my $projectId  = $_[0];

	my $schemesRootPath = EntityTools::getEntitySchemeRootPath($projectId); 

	my @loop_data = ();
	
	if (!defined($schemesRootPath))
	{
		return @loop_data;
	}

	opendir my($dh), $schemesRootPath or die "Couldn't open dir '$schemesRootPath': $!";
	my @files = grep { !/^\.\.?$/ && /(.*)\.atjs/} readdir $dh;
	closedir $dh;
	
	foreach my $element (@files)
	{
		my %row_data;
		
		my $schemeName = $element;
		
		$schemeName =~ s/(.*)\.atjs/$1/g;

     	$row_data{PROJECT_ID}  = $projectId;
     	$row_data{ENTITY_TYPE} = $schemeName;
     
     	push(@loop_data, \%row_data);
	}

    return @loop_data;
}

#################################################
#
# Function: editSchemes
#
# Description:
# 	Function generates list of existing schemes
#
#################################################

sub editSchemes
{
	my $projectId  = $_[0];

	my $filename = EntityTools::getProjectRootPath($projectId) . "/Conf/EditSchemes.html"; 
	
	my $template = HTML::Template->new(filename => $filename);

	$template->param(PAGE_TITLE   => "Spletni urejevalnik JSON datotek");
#	$template->param(PROJECT_ID   => $projectId);
	
	my @loop_data = listSchemes($projectId);
	$template->param(SCHEMES => \@loop_data);
	
	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();
}

#################################################
#
# Function: editScheme
#
# Description:
# 	Function allows to edit scheme
#
#################################################

sub editScheme
{
	my $projectId  = $_[0];
	my $entityType = $_[1];

	my $filename = EntityTools::getProjectRootPath($projectId) . "/Conf/EditScheme.html"; 

	my $template = HTML::Template->new(filename => $filename);
	
	$template->param(PAGE_TITLE   => "Spletni urejevalnik JSON datotek");
#	$template->param(PROJECT_ID   => $projectId);
	$template->param(ENTITY_TYPE  => $entityType);
	
	my @loop_data = listSchemeProperties($projectId, $entityType);
	
	$template->param(SCHEME_PROPERTIES => \@loop_data);
	
	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();
}

#################################################
#
# Function: editScheme
#
# Description:
# 	Function allows to edit scheme
#
#################################################

sub startFileManager
{
	my $projectId  = $_[0];

	my $uploadFolder = EntityTools::getProjectRootPath($projectId);
	
	my $filename = $pwd . "/conf/FileManager.html"; 

	my $template = HTML::Template->new(filename => $filename);

	$template->param(PAGE_TITLE    => "Spletni urejevalnik JSON datotek");
#	$template->param(PROJECT_ID   => $projectId);
	$template->param(UPLOAD_FOLDER => $uploadFolder);
	
	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();
}

#################################################
#
# Function: performAction
#
# Description:
# 	Function starts required action
#
#################################################

sub performAction
{
	my $action     = $_[0];
	my $projectId  = $_[1];
	my $entityType = $_[2];
	my $entityName = $_[3];
	my $p1         = $_[4];
	my $p2         = $_[5];
	my $p3         = $_[6];
	my $p4         = $_[7];
	my $p5         = $_[8];
	my $p6         = $_[9];

	given($action)
	{
		when('EditScheme')
		{
			editScheme($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
		}
		when('EditSchemes')
		{
			editSchemes($projectId);
		}
		when('CreateEntity')
		{
			createEntity($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
		}
		when ('FileManager')
		{
			startFileManager($projectId);
		}
		default {}
	}
}

#################################################
#
# Main program
#
#################################################

my $loginStatus = 1;


#td: preprecim klic programa brez parametrov (iz varnostnih razlogov)
#my @pars = $query->param;;
#if (($#pars == -1) || (!defined($pId))){
#	print "Content-type: text/html\n\n JWE is great!";
#	exit;
#}

if ($loginStatus == 1)
{
	if (defined($action))
	{
		performAction($action, $pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6);
	}
	else
	{
		# if project name is not defined it means we have just logged in
		if (!defined($pId))
		{
			showProjectsPage();
		}
		else
		{
			# if entity type is not defined we are editing project settings
			if (!defined($eType))
			{
				showOverviewPage($pId);
			}
			else
			{
				editEntity($pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6);
			}
		}
	}
}
else
{
	# error or empty page
}

1;