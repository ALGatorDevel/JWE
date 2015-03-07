# Pages.pm
package Pages;

use lib "../";

use modules::Configuration;
use modules::Entities;

use MIME::Base64;

use File::Path qw(make_path rmtree);
use File::Basename;
use File::Spec;


use strict;
use warnings;

#################################################
#
#
# Functions  for listing data for pages
#
#
#################################################


# ----------------------------------------------
# Function: listMainProjects
#
# Description:
# Function reads all projects from config file
# ----------------------------------------------

sub ListMainProjects {

	Tools::LogEnterFunction("ListMainProjects");

	# get configuration settings from common configuration file
	my $data = Configuration::GetConfigurationSettings();

	my @val       = $data;
	my @loop_data = ();

	# list all projects from config file
	foreach my $element (@val) {

		# list all properties for current project in alphabetical order
		for my $key ( sort( keys(%$element) ) ) {

			# get property value
			my $value = $element->{$key};

			# skip if value cannot be found
			if ( !defined($value) ) {
				
				Tools::Log("Skipped key $key because value is undefined.");
				
				next;
			}

			# get project name and id
			my $projectName = $value->{Name};
			my $projectId   = $value->{Id};

			# skip if project name or project id is not defined
			if ( !defined($projectName) || !defined($projectId) ) {
				
				Tools::Log("Skipped key $key because projectId or  projectName is undefined.");
				
				next;
			}

			# add project to the project list
			my %row_data;

			$row_data{PROJECT_NAME} = $projectName;
			$row_data{PROJECT_ID}   = $projectId;
			$row_data{PROJECT_DESC} = $value->{Desc};

			push( @loop_data, \%row_data );
			
			Tools::Log("Project: $projectName ($projectId)");
		}
	}

	Tools::LogExitFunction("ListMainProjects");

	# return list of defined main projects
	return @loop_data;
}

# ----------------------------------------------
# Function: ListProjects
#
# Description:
# Function reads all projects from config file
# ----------------------------------------------

sub ListProjects {
	
	my $projectId = $_[0];

	Tools::LogEnterFunction("ListProjects");

	my $projectPath = Configuration::GetProjectRootPath($projectId);

	Tools::Log("Read path $projectPath.");

	opendir my($dh), "$projectPath/projects";
	my @val = grep { !/^\.?$/ && !/^\.(.*)$/ } readdir $dh;
	closedir $dh;
	
	my @loop_data = ();

	# parse all projects and add them to the list
	foreach my $element (@val) {

		chomp $element;
		$element =~ s/PROJ-//;

		my %row_data;
		
		$row_data{PROJECT_ID}  = $projectId;
		$row_data{ENTITY_TYPE} = "Project";
		$row_data{ENTITY_NAME} = $element;
		
		my $propertyEType = "Project";
		my $currentEntityName = $element;
				
		my $tempLink = Tools::getJWELink($projectId, $propertyEType, $currentEntityName);
				
				
		$row_data{LINK} = $tempLink;

		push( @loop_data, \%row_data );
		
		Tools::Log("Project: $element ($projectId)");
	}

	Tools::LogExitFunction("ListProjects");

	return @loop_data;
}

# ----------------------------------------------
# Function: listEntitySettings
#
# Description:
# Function reads all entity settings from config file
# ----------------------------------------------

sub ListEntitySettings
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
    
    my $parentIndex = $_[9];
    
    my $addRow		= $_[10];
    
    my $level       = $_[11];
    
    $level = 0 if !defined $level;

	Tools::LogEnterFunction("ListEntitySettings");

    Tools::Log("Project Id : $projectId");
    Tools::Log("Entity Type: $entityType");
    Tools::Log("Entity Name: $entityName");
    
    Tools::Log("p1         : $p1") if defined($p1);
    Tools::Log("p2         : $p2") if defined($p2);
    Tools::Log("p3         : $p3") if defined($p3);
    Tools::Log("p4         : $p4") if defined($p4);
    Tools::Log("p5         : $p5") if defined($p5);
    Tools::Log("p6         : $p6") if defined($p6);

    if (!defined($parentIndex))
    {
    	$parentIndex = "";
    }
    else
    {
    	$parentIndex = $parentIndex . "_";
    }
    
    if (!defined($addRow))
    {
    	$addRow = "1";
    }
    
    my $projectRootPath = Configuration::GetProjectRootPath($projectId);
    
    my $index = 0;

	my $entityFileData   = Entities::GetEntityData($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6, $addRow);
	my $entitySchemeData = Entities::GetEntitySchemeData($projectId, $entityType);
			
	my @loop_data = ();
	
	my $schemeProperties = $entitySchemeData->{properties};
	my $propertyOrder    = $entitySchemeData->{Order};
	
	if (!defined($propertyOrder))
	{
		foreach my $propertyKey (sort(keys(%$schemeProperties)))
		{
			push(@$propertyOrder, $propertyKey);
		}
	}
	
	
	foreach my $propertyKey (@$propertyOrder)
	{
		my $propertyValue       = $schemeProperties->{$propertyKey};
		
		my $propertyType        = $propertyValue->{type};
		my $propertyDescription = $propertyValue->{description};

		my $notEmpty = 1;

		#td: dodan nov tip - Entity_Name (ime entitete; read-only field)
		if (uc($propertyType) eq "ENTITY_NAME")
		{
			my $value = $entityFileData->{$entityType}->{$propertyKey};
						
			my %row_data;
		
			$row_data{PARENT_INDEX}  = $parentIndex;
			$row_data{INDEX}         = $row_data{PARENT_INDEX} . $index;
			$row_data{ELEMENT_ID}    = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
			
			$row_data{PROJECT_ID}    = $projectId;
			
			
			$row_data{TYPE_ENTITIES} = 0;
			$row_data{TYPE_FILE}     = 0;
			$row_data{TYPE_FILES}    = 0;
			$row_data{TYPE_STRING}   = 0;
			$row_data{TYPE_ENTITY_NAME}   = 1;
			
			$row_data{KEY}             = $propertyKey;			
			$row_data{KEY_DESCRIPTION} = $propertyDescription;			
			$row_data{VALIDATION}      = 0;
			$row_data{ENTITY_TYPE}     = $entityType;
			
			$row_data{VALUE}           = $entityName;
			$row_data{ETYPE}           = "EntityName";
			
			
			push(@loop_data, \%row_data);
			
		    Tools::Log("Entity name : $entityName");
		    Tools::Log("Entity type : $entityType");
		    
			$index = $index + 1;
		}
		
		if (uc($propertyType) eq "STRING")
		{
			my $pattern = $propertyValue->{pattern};
			
			my $value = $entityFileData->{$entityType}->{$propertyKey};
			
			if (!defined($value))
			{
				$value = "";
			}
			
			if ($value eq "")
			{
				$notEmpty = 0;
			}
			
			my %row_data;
		
			$row_data{PARENT_INDEX}  = $parentIndex;
			$row_data{INDEX}         = $row_data{PARENT_INDEX} . $index;
			$row_data{ELEMENT_ID}    = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;

			$row_data{PROJECT_ID}    = $projectId;
			
			$row_data{TYPE_ENTITIES} = 0;
			$row_data{TYPE_FILE}     = 0;
			$row_data{TYPE_FILES}    = 0;
			$row_data{TYPE_STRING}   = 1;
			
			$row_data{KEY}             = $propertyKey;			
			$row_data{KEY_DESCRIPTION} = $propertyDescription;			
			$row_data{VALIDATION}      = 0;
			$row_data{ENTITY_TYPE}     = $entityType;
			
			$row_data{VALUE}           = $value;
			$row_data{ETYPE}           = "String";
						
			if (defined($pattern)) 
			{
				$row_data{VALIDATION} = 1;
				$row_data{PATTERN}    = $pattern;
			}
			
			push(@loop_data, \%row_data);
			
		    Tools::Log("Entity value : $value");
		    Tools::Log("Entity type  : $entityType");

			$index = $index + 1;
		}
		
		if (uc($propertyType) eq "FILE")
		{
			my $root = $propertyValue->{root};

			if (defined($root))
			{
				$root =~ s/\{\}/$entityName/g;
					
				$root =~ s/\$1/$p1/g if defined($p1);
				$root =~ s/\$2/$p2/g if defined($p2);
				$root =~ s/\$3/$p3/g if defined($p3);
				$root =~ s/\$4/$p4/g if defined($p4);
				$root =~ s/\$5/$p5/g if defined($p5);
				$root =~ s/\$6/$p6/g if defined($p6);
			}

			my $value = $entityFileData->{$entityType}->{$propertyKey};
			
			if (!defined($value))
			{
				$value = "";
			}
				
			if ($value eq "")
			{
				$notEmpty = 0;
			}
			
			my %row_data;
			
			$row_data{PARENT_INDEX}    = $parentIndex;
			$row_data{INDEX}           = $row_data{PARENT_INDEX} . $index;
			$row_data{ELEMENT_ID}      = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
				
			$row_data{PROJECT_ID}      = $projectId;

			$row_data{ENTITY_TYPE}     = $entityType;

			$row_data{TYPE_ENTITIES}   = 0;
			$row_data{TYPE_FILE}       = 1;
			$row_data{TYPE_FILES}      = 0;
			$row_data{TYPE_STRING}     = 0;
			
			$row_data{KEY}             = $propertyKey;			
			$row_data{KEY_DESCRIPTION} = $propertyDescription;			
			$row_data{VALUE}           = $value;
			$row_data{USE_ROOT}        = 0;
			$row_data{NOT_EMPTY} 	   = $notEmpty;	
			$row_data{ETYPE}           = "File";

			$row_data{P1}              = $p1;
			$row_data{P2}              = $p2;
			$row_data{P3}              = $p3;
			$row_data{P4}              = $p4;
			$row_data{P5}              = $p5;
			$row_data{P6}              = $p6;

			if (defined($root))
			{
				$row_data{USE_ROOT} = 1;

				$row_data{ROOT}     =  $root;
				
				$row_data{FM_ROOT}  = $projectRootPath . "/projects/". $root;
			}

			push(@loop_data, \%row_data);

		    Tools::Log("Entity value : $value");
		    Tools::Log("Entity type  : File");

			$index = $index + 1;
		}

		if (uc($propertyType) eq "FILES")
		{
			my $root = $projectRootPath . "/projects/" . $propertyValue->{root};

			if (defined($root))
			{
				$root =~ s/\{\}/$entityName/g;
					
				$root =~ s/\$1/$p1/g if defined($p1);
				$root =~ s/\$2/$p2/g if defined($p2);
				$root =~ s/\$3/$p3/g if defined($p3);
				$root =~ s/\$4/$p4/g if defined($p4);
				$root =~ s/\$5/$p5/g if defined($p5);
				$root =~ s/\$6/$p6/g if defined($p6);
			}

			my $value = $entityFileData->{$entityType}->{$propertyKey};

			my $tempKeyDescription = $propertyDescription;
			
			my @entities2 = ();
			my $tempIndex = 0;

			my $valueArray = "";

			foreach my $currentEntityName (@$value)
			{
				my %row_data;
		
				$row_data{PARENT_INDEX}    = $parentIndex . $index;
				$row_data{INDEX}           = $row_data{PARENT_INDEX} . "_" . $tempIndex;
				$row_data{ELEMENT_ID}      = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
				
				$row_data{PROJECT_ID}      = $projectId;
				
					
				$row_data{TYPE_ENTITIES}   = 0;
				$row_data{TYPE_FILE}       = 0;
				$row_data{TYPE_FILES}      = 1;
				$row_data{TYPE_STRING}     = 0;
				$row_data{ENTITY_TYPE}     = $entityType;
				$row_data{ADD_ROW}         = 0;
					
				$row_data{KEY}             = $propertyKey;			
				$row_data{KEY_DESCRIPTION} = $tempKeyDescription;			
				$row_data{VALUE}           = $currentEntityName;	
				$row_data{USE_ROOT}        = 0;
				
				$row_data{ETYPE}           = "File";
				$row_data{P1}              = $p1;
				$row_data{P2}              = $p2;
				$row_data{P3}              = $p3;
				$row_data{P4}              = $p4;
				$row_data{P5}              = $p5;
				$row_data{P6}              = $p6;
				

				if (defined($root))
				{
					$row_data{USE_ROOT} = 1;
		
					$row_data{ROOT}     = $root;
				}

				push(@entities2, \%row_data);

			    Tools::Log("Entity value : $currentEntityName");
			    Tools::Log("Entity type  : File");

				$tempIndex = $tempIndex + 1;
				$tempKeyDescription = "";

				if (length($valueArray) > 0)
				{
					$valueArray = $valueArray . ", ";
				}
				
				$valueArray = $valueArray . $currentEntityName;
			}

			if ($addRow eq "1")
			{
				my %row_data;

				$row_data{PROJECT_ID}      = $projectId;
	
				$row_data{PARENT_INDEX}    = $parentIndex . $index;
				$row_data{INDEX}           = $row_data{PARENT_INDEX} . "_998";
				$row_data{ELEMENT_ID}      = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
				
				$row_data{PROJECT_ID}      = $projectId;
				

				$row_data{TYPE_ENTITIES}   = 0;
				$row_data{TYPE_FILE}       = 0;
				$row_data{TYPE_FILES}      = 1;
				$row_data{TYPE_STRING}     = 0;
				$row_data{ENTITY_TYPE}     = $entityType;
				
				$row_data{ETYPE}           = $entityType;
				$row_data{P1}              = $p1;
				$row_data{P2}              = $p2;
				$row_data{P3}              = $p3;
				$row_data{P4}              = $p4;
				$row_data{P5}              = $p5;
				$row_data{P6}              = $p6;
				
				$row_data{ADD_ROW}         = 1;
						
				$row_data{KEY}             = $propertyKey;			
				$row_data{KEY_DESCRIPTION} = $tempKeyDescription;			
				$row_data{VALUE}           = "";	
				$row_data{USE_ROOT}        = 0;
	
				if (defined($root))
				{
					$row_data{USE_ROOT} = 1;
		
					$row_data{ROOT}     = $root;
				}
	
				push(@entities2, \%row_data);
			}

			my %row_data2;
		
			$row_data2{PROJECT_ID}          = $projectId;

			$row_data2{PARENT_INDEX}        = $parentIndex;
			$row_data2{INDEX}               = $row_data2{PARENT_INDEX} . $index;
			$row_data2{ELEMENT_ID}          = $row_data2{INDEX}        . "_" . $entityType . "_" . $propertyKey;

			$row_data2{TYPE_ENTITIES}       = 0;
			$row_data2{TYPE_FILE}           = 0;
			$row_data2{TYPE_FILES}          = 1;
			$row_data2{TYPE_STRING}         = 0;
			$row_data2{ENTITY_TYPE}         = $entityType;
			
			$row_data2{ETYPE}               = $entityType;
			$row_data2{P1}                  = $p1;
			$row_data2{P2}                  = $p2;
			$row_data2{P3}                  = $p3;
			$row_data2{P4}                  = $p4;
			$row_data2{P5}                  = $p5;
			$row_data2{P6}                  = $p6;
					
			$row_data2{KEY}                 = $propertyKey;			
			$row_data2{KEY_DESCRIPTION}     = $propertyDescription;			
			$row_data2{VALUES}              = \@entities2;
			$row_data2{VALUE}               = "[" . $valueArray . "]";

			push(@loop_data, \%row_data2);

			$index = $index + 1;
			$tempKeyDescription = "";
		}

		if (uc($propertyType) eq "ENTITY []")
		{
			my $propertyEType       = $propertyValue->{eType};
			my $propertyParameters  = $propertyValue->{parameters};
			
			my $value = $entityFileData->{$entityType}->{$propertyKey};
				
			my $pp1 = @$propertyParameters[0] if scalar(@$propertyParameters) > 0;
			my $pp2 = @$propertyParameters[1] if scalar(@$propertyParameters) > 1;
			my $pp3 = @$propertyParameters[2] if scalar(@$propertyParameters) > 2;
			my $pp4 = @$propertyParameters[3] if scalar(@$propertyParameters) > 3;
			my $pp5 = @$propertyParameters[4] if scalar(@$propertyParameters) > 4;
			my $pp6 = @$propertyParameters[5] if scalar(@$propertyParameters) > 5;
			
			$pp1 =~ s/\{\}/$entityName/g if defined($pp1);
			$pp2 =~ s/\{\}/$entityName/g if defined($pp2);
			$pp3 =~ s/\{\}/$entityName/g if defined($pp3);
			$pp4 =~ s/\{\}/$entityName/g if defined($pp4);
			$pp5 =~ s/\{\}/$entityName/g if defined($pp5);
			$pp6 =~ s/\{\}/$entityName/g if defined($pp6);
			
			$pp1 =~ s/\$1/$p1/g if defined($pp1);
			$pp2 =~ s/\$2/$p2/g if defined($pp2);
			$pp3 =~ s/\$3/$p3/g if defined($pp3);
			$pp4 =~ s/\$4/$p4/g if defined($pp4);
			$pp5 =~ s/\$5/$p5/g if defined($pp5);
			$pp6 =~ s/\$6/$p6/g if defined($pp6);

			my $tempKeyDescription = $propertyDescription;
			
			my @entities2 = ();
			my $tempIndex = 0;
			
			my $valueArray = "";
				
			foreach my $currentEntityName (@$value)
			{
#				my ($new_index, @entities) = ListEntitySettings($projectId, $propertyEType, $currentEntityName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6, $parentIndex . $index . "_" . $tempIndex, $addRow);
	
				my %row_data;

				$row_data{PARENT_INDEX}    = $parentIndex . $index;
				$row_data{INDEX}           = $row_data{PARENT_INDEX} . "_" . $tempIndex;
				$row_data{ELEMENT_ID}      = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
				
				$row_data{PROJECT_ID}      = $projectId;
				
					
				$row_data{TYPE_ENTITIES}   = 1;
				$row_data{TYPE_FILE}       = 0;
				$row_data{TYPE_FILES}      = 0;
				$row_data{TYPE_STRING}     = 0;
				$row_data{ENTITY_TYPE}     = $entityType;
				$row_data{ADD_ROW}         = 0;
				
				$row_data{ETYPE}           = $propertyEType;
				$row_data{P1}              = $pp1;
				$row_data{P2}              = $pp2;
				$row_data{P3}              = $pp3;
				$row_data{P4}              = $pp4;
				$row_data{P5}              = $pp5;
				$row_data{P6}              = $pp6;
					
				$row_data{KEY}             = $propertyKey;			
				$row_data{KEY_DESCRIPTION} = $tempKeyDescription;			
				$row_data{VALUE}           = $currentEntityName;

				$row_data{LINK}            = Tools::getJWELink($projectId, $propertyEType, $currentEntityName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6, 0, 0);
				$row_data{EXPAND_LINK}     = Tools::getJWELink($projectId, $propertyEType, $currentEntityName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6, $row_data{INDEX}, $level + 1, 1);
				
				$row_data{LEVEL}           = $level + 1;
				$row_data{LEVEL_OFFSET}    = $level * 30 + 30;
							
#				$row_data{ENTITIES}        = \@entities;
					
				push(@entities2, \%row_data);

			    Tools::Log("Entity value : $currentEntityName");
			    Tools::Log("Entity type  : Entity");

				$tempIndex = $tempIndex + 1;
				$tempKeyDescription = "";
				
				if (length($valueArray) > 0)
				{
					$valueArray = $valueArray . ", ";
				}
				
				$valueArray = $valueArray . $currentEntityName;
				
			}

			if ($addRow eq "1")
			{
				my %row_data;
			
				$row_data{PROJECT_ID}          = $projectId;
				$row_data{PROJECT}             = $pp1;
	
				$row_data{PARENT_INDEX}        = $parentIndex . $index;
				$row_data{INDEX}               = $row_data{PARENT_INDEX} . "_999";
				$row_data{ELEMENT_ID}          = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
	
				$row_data{TYPE_ENTITIES}       = 1;
				$row_data{TYPE_FILE}           = 0;
				$row_data{TYPE_FILES}          = 0;
				$row_data{TYPE_STRING}         = 0;
				$row_data{ENTITY_TYPE}         = $entityType;
				$row_data{ADD_ROW}             = 1;
				$row_data{CURRENT_ENTITY_TYPE} = $propertyEType;
				
				$row_data{ETYPE}               = $propertyEType;
				$row_data{P1}                  = $pp1;
				$row_data{P2}                  = $pp2;
				$row_data{P3}                  = $pp3;
				$row_data{P4}                  = $pp4;
				$row_data{P5}                  = $pp5;
				$row_data{P6}                  = $pp6;
						
				$row_data{KEY}                 = $propertyKey;			
				$row_data{KEY_DESCRIPTION}     = $tempKeyDescription;			
				$row_data{VALUE}               = "";	
								
				push(@entities2, \%row_data);
			}

			my %row_data2;
		
			$row_data2{PROJECT_ID}          = $projectId;
			$row_data2{PROJECT}             = $pp1;

			$row_data2{PARENT_INDEX}        = $parentIndex;
			$row_data2{INDEX}               = $row_data2{PARENT_INDEX} . $index;
			$row_data2{ELEMENT_ID}          = $row_data2{INDEX}        . "_" . $entityType . "_" . $propertyKey;

			$row_data2{TYPE_ENTITIES}       = 1;
			$row_data2{TYPE_FILE}           = 0;
			$row_data2{TYPE_FILES}          = 0;
			$row_data2{TYPE_STRING}         = 0;
			$row_data2{ENTITY_TYPE}         = $entityType;
			$row_data2{CURRENT_ENTITY_TYPE} = $propertyEType;
			
			$row_data2{ETYPE}               = $propertyEType;
			$row_data2{P1}                  = $pp1;
			$row_data2{P2}                  = $pp2;
			$row_data2{P3}                  = $pp3;
			$row_data2{P4}                  = $pp4;
			$row_data2{P5}                  = $pp5;
			$row_data2{P6}                  = $pp6;
					
			$row_data2{KEY}                 = $propertyKey;			
			$row_data2{KEY_DESCRIPTION}     = $propertyDescription;			
			$row_data2{VALUES}              = \@entities2;
			$row_data2{VALUE}               = "[" . $valueArray . "]";

			push(@loop_data, \%row_data2);

			$index = $index + 1;
			$tempKeyDescription = "";
		}
	}
	
	Tools::LogExitFunction("ListEntitySettings");

	return ($index, @loop_data);
}

# ----------------------------------------------
# Function: ListSchemes
#
# Description:
# Function reads all schemes defined
# ----------------------------------------------

sub ListSchemes {

	my $projectId = $_[0];

	Tools::LogEnterFunction("ListSchemes");

	my $schemesRootPath = Configuration::GetEntitySchemeRootPath($projectId);

	my @loop_data = ();

	if ( !defined($schemesRootPath) ) {
	
	    Tools::Log("Scheme root path is undefined.");
	    
		Tools::LogExitFunction("ListSchemes");
	
		return @loop_data;
	}

	opendir my ($dh), $schemesRootPath
	  or die "Couldn't open dir '$schemesRootPath': $!";
	  
	my @files = grep { !/^\.\.?$/ && /(.*)\.atjs/ } readdir $dh;
	closedir $dh;

	foreach my $element (@files) {
		my %row_data;

		my $schemeName = $element;

		$schemeName =~ s/(.*)\.atjs/$1/g;

		$row_data{PROJECT_ID}  = $projectId;
		$row_data{ENTITY_TYPE} = $schemeName;

		push( @loop_data, \%row_data );

	    Tools::Log("Scheme : $schemeName");
	}

	Tools::LogExitFunction("ListSchemes");

	return @loop_data;
}

# ----------------------------------------------
# Function: ListSchemeProperties
#
# Description:
# Function reads all scheme settings from config file
# ----------------------------------------------

sub ListSchemeProperties {

	my $projectId  = $_[0];
	my $entityType = $_[1];
	my $entityName = $_[2];
	my $p1         = $_[3];
	my $p2         = $_[4];
	my $p3         = $_[5];
	my $p4         = $_[6];
	my $p5         = $_[7];
	my $p6         = $_[8];

	Tools::LogEnterFunction("ListSchemeProperties");

	my @loop_data = ();

	my $data = Configuration::GetEntitySchemeData( $projectId, $entityType );

	if ( !defined($data) ) {
	
	    Tools::Log("Null data returned.");

		Tools::LogExitFunction("ListSchemeProperties");
	
		return @loop_data;
	}

	foreach my $key ( sort( keys(%$data) ) ) {

		my $val = $data->{$key};

		if ( ref($val) eq "ARRAY" ) {
		    Tools::Log("Entity: $key (ARRAY).");
		}
		elsif ( ref($val) eq "HASH" ) {
	
			my @loop_data2 = ();

		    Tools::Log("Entity $key : HASH");

			foreach my $key2 ( sort( keys(%$val) ) ) {

				my $val2 = $val->{$key2};

				if ( ref($val2) eq "HASH" ) {

				    Tools::Log("Entity $key2 : HASH");
	
					my @loop_data3 = ();

					foreach my $key3 ( sort( keys(%$val2) ) ) {

						my $val3 = $val2->{$key3};

						my %row_data;

						$row_data{KEY}  = $key3;
						$row_data{HASH} = 0;

						if ( ref($val3) eq "ARRAY" ) {

						    Tools::Log("Entity $key3 : ARRAY");

							$row_data{HASH} = 1;

							my @loop_data4 = ();

							foreach my $parameter (@$val3) {

								my %row_data;

								$row_data{VALUE} = $parameter;

								push( @loop_data4, \%row_data );
				
							    Tools::Log("Entity value : $parameter");
							}

							$row_data{VALUE2} = \@loop_data4;
						}
						else {
						    Tools::Log("Entity $key3 : " . ref($val3));
			
							$row_data{VALUE} = $val3;
						}

						push( @loop_data3, \%row_data );
					}

					my %row_data;

					$row_data{ARRAY}    = 0;
					$row_data{HASH}     = 1;
					$row_data{KEY}      = $key2;
					$row_data{VALUE}    = $val2;
					$row_data{CHILDREN} = \@loop_data3;

					push( @loop_data2, \%row_data );
					
					Tools::Log("Entity $key2 : $val2");
				}
				else {
					my %row_data;

					$row_data{ARRAY} = 0;
					$row_data{HASH}  = 0;
					$row_data{KEY}   = $key;
					$row_data{VALUE} = $val;

					push( @loop_data2, \%row_data );
	
				    Tools::Log("Entity $key : $val");
				}
			}

			my %row_data;

			$row_data{ARRAY}    = 0;
			$row_data{HASH}     = 1;
			$row_data{KEY}      = $key;
			$row_data{VALUE}    = $val;
			$row_data{CHILDREN} = \@loop_data2;

			push( @loop_data, \%row_data );
			
			Tools::Log("Entity $key : $val");
		}
		else {
			my %row_data;

			$row_data{ARRAY} = 0;
			$row_data{HASH}  = 0;
			$row_data{KEY}   = $key;
			$row_data{VALUE} = $val;

			push( @loop_data, \%row_data );

			Tools::Log("Entity $key : $val");
		}
	}

	Tools::LogExitFunction("ListSchemeProperties");

	return @loop_data;
}


#################################################
#
#
# Functions for displaying pages
#
#
#################################################


# ----------------------------------------------
# Function: ShowProjectsPage
#
# Description:
# Function generates and displays list of all projects
# ----------------------------------------------

sub ShowProjectsPage
{
	Tools::LogEnterFunction("ShowProjectsPage");

	my $templateFilename = Configuration::GetConfigurationFolder() . 'projects.html';

	my $template = HTML::Template->new( filename => $templateFilename );

	$template->param( PAGE_TITLE => "Spletni urejevalnik JSON datotek" );

	my @loop_data = ListMainProjects();

	$template->param( PROJECTS => \@loop_data );

	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();

	Tools::LogExitFunction("ShowProjectsPage");
}

# ----------------------------------------------
# Function: showOverviewPage
#
# Description:
# Function generates and displays overview page
# ----------------------------------------------

sub ShowOverviewPage {
	
	my $projectId = $_[0];

	Tools::LogEnterFunction("ShowOverviewPage");

	my $templateFilename = Configuration::GetConfigurationFolder() . 'overview.html';

	my $template = HTML::Template->new( filename => $templateFilename );

	$template->param( PAGE_TITLE => "Spletni urejevalnik JSON datotek" );
	$template->param( PROJECT_ID => $projectId );
	
	my @loop_data = ListProjects($projectId);

	$template->param( PROJECTS => \@loop_data );

	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();

	Tools::LogExitFunction("ShowOverviewPage");
}

# ----------------------------------------------
# Function: editEntity
#
# Description:
# Function generates and displays page for
# editing project settings
# ----------------------------------------------

sub EditEntity {

	my $projectId    = $_[0];
	my $entityType   = $_[1];
	my $entityName   = $_[2];
	my $p1           = $_[3];
	my $p2           = $_[4];
	my $p3           = $_[5];
	my $p4           = $_[6];
	my $p5           = $_[7];
	my $p6           = $_[8];
	my $singleEntity = $_[9];
	my $index        = $_[10];
	my $level        = $_[11];
	my $ajax         = $_[12];
	
	$level = 0 if !defined $level;
	$ajax  = 1 if !defined $ajax;

	Tools::LogEnterFunction("EditEntity");


	my $templateFilename;
	
	if ( $ajax == 0 )
	{
 		$templateFilename = Configuration::GetConfigurationFolder() . 'Entity3 - Index.html';	
	}
	else
	{
		$templateFilename = Configuration::GetConfigurationFolder() . 'Entity3 - Ajax Entity Entry.html';
	}

	my $template = HTML::Template->new(
		filename          => $templateFilename,
		loop_context_vars => 1,
		die_on_bad_params => 0
	);

	$template->param( PAGE_TITLE  => "Spletni urejevalnik JSON datotek" );
	$template->param( PROJECT_ID  => $projectId );
	$template->param( ENTITY_TYPE => $entityType );
	$template->param( ENTITY_NAME => $entityName );
	$template->param( P1          => $p1 );
	$template->param( P2          => $p2 );
	$template->param( P3          => $p3 );
	$template->param( P4          => $p4 );
	$template->param( P5          => $p5 );
	$template->param( P6          => $p6 );

	$template->param( SINGLE_ENTITY => $singleEntity );

	my ( $maxIndex, @loop_data ) =
	  ListEntitySettings( $projectId, $entityType, $entityName,	$p1, $p2, $p3, $p4, $p5, $p6, $index, "1", $level );

	$template->param( ELEMENT_ID => "Root_Element");
	$template->param( LEVEL_OFFSET => $level );
	$template->param( SETTINGS => \@loop_data );

	# Send HTML to the browser.
	print "Content-type:text/html\n\n" if ($ajax != 1);
	print $template->output();


	Tools::LogExitFunction("EditEntity");
}

# ----------------------------------------------
# Function: editSchemes
#
# Description:
# Function generates list of existing schemes
# ----------------------------------------------

sub EditSchemes {

	my $projectId = $_[0];

	Tools::LogEnterFunction("EditSchemes");

	my $templateFilename = Configuration::GetConfigurationFolder() . 'EditSchemes.html';

	my $template = HTML::Template->new( filename => $templateFilename );

	$template->param( PAGE_TITLE => "Spletni urejevalnik JSON datotek" );

	my @loop_data = ListSchemes($projectId);

	$template->param( SCHEMES => \@loop_data );

	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();

	Tools::LogExitFunction("EditSchemes");
}

# ----------------------------------------------
# Function: editScheme
#
# Description:
# Function allows to edit scheme
# ----------------------------------------------

sub EditScheme {
	
	my $projectId  = $_[0];
	my $entityType = $_[1];

	Tools::LogEnterFunction("EditScheme");

	my $templateFilename = Configuration::GetConfigurationFolder() . 'EditScheme.html';

	my $template = HTML::Template->new( filename => $templateFilename );

	$template->param( PAGE_TITLE => "Spletni urejevalnik JSON datotek" );
	$template->param( ENTITY_TYPE => $entityType );

	my @loop_data = ListSchemeProperties( $projectId, $entityType );

	$template->param( SCHEME_PROPERTIES => \@loop_data );

	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();

	Tools::LogExitFunction("EditScheme");
}

# ----------------------------------------------
# Function: editScheme
#
# Description:
# Function allows to edit scheme
# ----------------------------------------------

sub StartFileManager {

	my $projectId = $_[0];

	Tools::LogEnterFunction("StartFileManager");

	my $uploadFolder = Configuration::GetProjectRootPath($projectId);
	
	my $templateFilename = Configuration::GetConfigurationFolder() . 'FileManager.html';

	my $template = HTML::Template->new( filename => $templateFilename );

	$template->param( PAGE_TITLE => "Spletni urejevalnik JSON datotek" );
	$template->param( UPLOAD_FOLDER => $uploadFolder );

	# Send HTML to the browser.
	print "Content-type:text/html\n\n";
	print $template->output();

	Tools::LogExitFunction("StartFileManager");
}

sub showEmptyPage {
	print "Content-type:text/html\n\n";
	print "Non-existing page."
}

1;