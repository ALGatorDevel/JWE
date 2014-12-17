# EntityTools.pm
package EntityTools;

use lib "../";

use modules::JsonHelper;
use modules::Tools;

use Cwd;

use MIME::Base64;

use strict;
use warnings;
 
#################################################
#
# Function: getConfigFilePath
#
# Description:
# 	Function returns path to the common config file
#
#################################################

sub getConfigFilePath
{
	my $pwd = cwd();

	# path to the common configuration file
	my $filename = $pwd . '/conf/config.json';
	
	return $filename;
}

#################################################
#
# Function: getConfigSettings
#
# Description:
# 	Function returns all common settings
#
#################################################

sub getConfigSettings
{
	# path to the common configuration file
	my $filename = getConfigFilePath();
	
	# read data from config file 
	my $data = JsonHelper::readJSONFile($filename);
	
	return $data;
}

#################################################
#
# Function: getProjectSettings
#
# Description:
# 	Function returns all common settings
#
#################################################

sub getProjectSettings
{
	my $projectId = $_[0];
	
	my $val;
	
	# get configuration settings from common configuration file
	my $data = getConfigSettings();

	# if settings cannot be read or project id is not defined return empty value
	if (!defined($data) || !defined($projectId))
	{
		return $val;
	}
	
	# get project settings for current main project 
	$val = $data->{$projectId};
	
	return $val;
}

#################################################
#
# Function: getProjectList
#
# Description:
# 	Function returns list of projects defined in 
#	current main project
#
#################################################

sub getProjectList
{
	my $projectId = $_[0];
	
	my $val;
	
	# get project settings for current main project 
	my $projectSettings = getProjectSettings($projectId);

	# if settings for current project are not found return empty value
	if (!defined($projectSettings))
	{
		return $val;
	}
	
	# get array of defined projects
	$val = $projectSettings->{projects};
	
	return $val;
}

#################################################
#
# Function: getProjectRootPath
#
# Description:
# 	Function returns list of projects defined in 
#	current main project
#
#################################################

sub getProjectRootPath
{
	my $projectId = $_[0];
	
	my $val;
	
	# get project settings for current main project 
	my $projectSettings = getProjectSettings($projectId);

	# if settings for current project are not found return empty value
	if (!defined($projectSettings))
	{
		return $val;
	}
	
	# get project root path
	$val = $projectSettings->{ProjectsRoot};
	
	my $JWE_PROJECTS_ROOT= $ENV{'JWE_PROJECTS_ROOT'};
	$val =~ s/JWE_PROJECTS_ROOT/$JWE_PROJECTS_ROOT/;
	
	return $val;
}

#################################################
#
# Function: getEntitySchemeRootPath
#
# Description:
# 	Function returns path to the root of scheme files
#
#################################################

sub getEntitySchemeRootPath
{
	my $projectId = $_[0];
	
	my $schemaFilePath;
	
	my $projectRootPath = getProjectRootPath($projectId);

	if (!defined($projectRootPath))
	{
		return $schemaFilePath;
	}

	$schemaFilePath = $projectRootPath . "/schema";

	return $schemaFilePath;
}

#################################################
#
# Function: getEntitySchemaFilePath
#
# Description:
# 	Function returns path to the common config file
#
#################################################

sub getEntitySchemaFilePath
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	
	my $schemaFilePath; 

	my $entitySchemeRootPath = getEntitySchemeRootPath($projectId);

	if (!defined($entitySchemeRootPath))
	{
		return $schemaFilePath;
	}

	$schemaFilePath = $entitySchemeRootPath . "/$entityType.atjs";

	return $schemaFilePath;
}

#################################################
#
# Function: getEntitySchemeData
#
# Description:
# 	Function returns properties of current entity scheme
#
#################################################

sub getEntitySchemeData
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	
	my $val;
	
	# if settings cannot be read or project id is not defined return empty value
	if (!defined($projectId) || !defined($entityType))
	{
		return $val;
	}
	
	my $entitySchemeFilename = getEntitySchemaFilePath($projectId, $entityType);
	
	if (!defined($entitySchemeFilename))
	{
		return $val;
	}

	$val = JsonHelper::readJSONFile($entitySchemeFilename);
	
	return $val;
}

#################################################
#
# Function: getEntityFilename
#
# Description:
# 	Function returns properties of entity
#
#################################################

sub getEntityFilename
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
	
	my $val;
	
	if (!defined($projectId) || !defined($entityType) || !defined($entityName))
	{
		return $val;
	}
	
	my $projectsRootPath = getProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		return $val;
	}

	my $entitySchemeData = getEntitySchemeData($projectId, $entityType);

	if (!defined($entitySchemeData))
	{
		return $val;
	}

	my $entityFilename = $entitySchemeData->{Filename};

	if (!defined($entityFilename))
	{
		return $val;
	}

	$entityFilename =~ s/\{\}/$entityName/g;

	$entityFilename =~ s/\$1/$p1/g if defined($p1);
	$entityFilename =~ s/\$2/$p2/g if defined($p2);
	$entityFilename =~ s/\$3/$p3/g if defined($p3);
	$entityFilename =~ s/\$4/$p4/g if defined($p4);
	$entityFilename =~ s/\$5/$p5/g if defined($p5);
	$entityFilename =~ s/\$6/$p6/g if defined($p6);
	
	$entityFilename = $projectsRootPath . "/projects/" . $entityFilename;
	
	$val = $entityFilename;
	
	return $val;
}

#################################################
#
# Function: getEntityData
#
# Description:
# 	Function returns properties of entity
#
#################################################

sub getEntityData
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
	
	my $val;
	
	my $entityFilename = getEntityFilename($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	if (!defined($entityFilename))
	{
		return $val;
	}
	
	$val = JsonHelper::readJSONFile($entityFilename);
	
	return $val;
}

#################################################
#
# Function: saveEntity
#
# Description:
# 	Function saves entity
#
# Parameters:
#	key and value to be written
#
#################################################

sub saveEntity
{
	my %entityProperties = %{$_[0]};

	my $projectId  = $_[1];
	my $entityType = $_[2];
	my $entityName = $_[3];
	my $p1         = $_[4];
	my $p2         = $_[5];
	my $p3         = $_[6];
	my $p4         = $_[7];
	my $p5         = $_[8];
	my $p6         = $_[9];
	
	my $entityFilename   = getEntityFilename   ($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	my $entitySchemeData = getEntitySchemeData ($projectId, $entityType);

	my $data             = createEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	my $properties;
	my $propertyKey;
	
	my $schemeProperties = $entitySchemeData->{properties};
	
	my $propertyList = $entityProperties{PROPERTIES};
	
	foreach $propertyKey ( sort(keys(%$propertyList)))
	{
		my $property = $entityProperties{PROPERTIES}->{$propertyKey};
		
		if (defined($property))
		{
			my $name  = $property->{PROPERTY};
			my $value = $property->{VALUE};
	
			my $entityProperty = $schemeProperties->{$name};
			my $type           = $schemeProperties->{$name}->{type};

			my $currentPropertyList = $property->{PROPERTIES};
			
			if (defined($currentPropertyList))
			{
				my $newEType = $entityProperty->{eType};
				my $newEName = $value;
				
				my @parameters = @{$entityProperty->{parameters}};
				
				my $pp1 = $parameters[0] if scalar(@parameters) > 0;
				my $pp2 = $parameters[0] if scalar(@parameters) > 1;
				my $pp3 = $parameters[0] if scalar(@parameters) > 2;
				my $pp4 = $parameters[0] if scalar(@parameters) > 3;
				my $pp5 = $parameters[0] if scalar(@parameters) > 4;
				my $pp6 = $parameters[0] if scalar(@parameters) > 5;
				
				$pp1 =~ s/\{\}/$entityName/g if defined($pp1);
				$pp2 =~ s/\{\}/$entityName/g if defined($pp2);
				$pp3 =~ s/\{\}/$entityName/g if defined($pp3);
				$pp4 =~ s/\{\}/$entityName/g if defined($pp4);
				$pp5 =~ s/\{\}/$entityName/g if defined($pp5);
				$pp6 =~ s/\{\}/$entityName/g if defined($pp6);
				
				saveEntity($property, $projectId, $newEType, $newEName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6);
			}
						
			if ($type =~ /(.*)\[\]/ || $type eq "Files")
			{
				my $val = $properties->{$name};
				
				my @values;
				
				foreach my $v1 (@$val)
				{
					push(@values, $v1);
				}
				
				push(@values, $value);
					
				$properties->{$name} = \@values;
			}
			else
			{
				$properties->{$name} = $value;
			}
		}
	}
		
	$data->{$entityType} = $properties;

	JsonHelper::writeJSONFile($entityFilename, $data);	
}

sub readEntityFile
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
	
	my $txt = "";
	my $pwd = cwd();
	
	if (!defined($projectId) || !defined($p1) || !defined($entityName))
	{
		return $txt;
	}
	
	my $projectsRootPath = getProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		return $txt;
	}

	my $filename = $projectsRootPath . "/projects/" . $p1 . "/" . $entityName;
	
	my @fileContent = Tools::readFileArray($filename);

	foreach (@fileContent)
	{
		my $line = $_;
	 	$txt = $txt . $line;
	}
	
	return $txt;
}

sub writeEntityFile
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
	
	my $txt = $_[9];

	my $pwd = cwd();
	
	if (!defined($projectId) || !defined($p1) || !defined($entityName))
	{
		return "";
	}
	
	my $projectsRootPath = getProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		return "";
	}

	my $filename = $projectsRootPath . "/projects/" . $p1 . "/" . $entityName;
	
	my @fileContent = Tools::writeFile($filename, $txt);

	return "";
}

#################################################
#
# Function: createEntitySettings
#
# Description:
# 	Function reads all entity settings from config file
#
#################################################

sub createEntitySettings
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

	my $entitySchemeData = getEntitySchemeData ($projectId, $entityType);
	my $entityFilename   = getEntityFilename   ($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	my $data;
	my $properties;
	
	my $schemeProperties = $entitySchemeData->{properties};
	
	foreach my $key (sort(keys(%$schemeProperties)))
	{
		my $type = $entitySchemeData->{properties}->{$key}->{type};
		
		my $property;
		
		if ($type =~ /(.*)\[\]/ || $type eq "Files")
		{
			my @value;
			$properties->{$key} = \@value;
		}
		else
		{
			my $value = "";
			$properties->{$key} = $value;
		}
	}
		
	$data->{$entityType} = $properties;
	
	return $data;
}

#################################################
#
# Function: listEntitySettings
#
# Description:
# 	Function reads all entity settings from config file
#
#################################################

sub listEntitySettings
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
    
    my $projectRootPath = getProjectRootPath($projectId);
    
    my $index = 0;

	my $entityFileData   = EntityTools::getEntityData      ($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6, $addRow);
	my $entitySchemeData = EntityTools::getEntitySchemeData($projectId, $entityType);
			
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
			
			
			push(@loop_data, \%row_data);
			
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
			
			$row_data{TYPE_ENTITIES} = 0;
			$row_data{TYPE_FILE}     = 0;
			$row_data{TYPE_FILES}    = 0;
			$row_data{TYPE_STRING}   = 1;
			
			$row_data{KEY}             = $propertyKey;			
			$row_data{KEY_DESCRIPTION} = $propertyDescription;			
			$row_data{VALIDATION}      = 0;
			$row_data{ENTITY_TYPE}     = $entityType;
			
			$row_data{VALUE}           = $value;
						
			if (defined($pattern)) 
			{
				$row_data{VALIDATION} = 1;
				$row_data{PATTERN}    = $pattern;
			}
			
			push(@loop_data, \%row_data);
			
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

			if (defined($root))
			{
				$row_data{USE_ROOT} = 1;

				$row_data{ROOT}     =  $root;
				
				$row_data{FM_ROOT}  = $projectRootPath . "/projects/". $root;
			}

			push(@loop_data, \%row_data);

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

				if (defined($root))
				{
					$row_data{USE_ROOT} = 1;
		
					$row_data{ROOT}     = $root;
				}

				push(@entities2, \%row_data);

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

				$row_data{TYPE_ENTITIES}   = 0;
				$row_data{TYPE_FILE}       = 0;
				$row_data{TYPE_FILES}      = 1;
				$row_data{TYPE_STRING}     = 0;
				$row_data{ENTITY_TYPE}     = $entityType;
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
				my ($new_index, @entities) = listEntitySettings($projectId, $propertyEType, $currentEntityName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6, $parentIndex . $index . "_" . $tempIndex, $addRow);
	
				my %row_data;

				$row_data{PARENT_INDEX}    = $parentIndex . $index;
				$row_data{INDEX}           = $row_data{PARENT_INDEX} . "_" . $tempIndex;
				$row_data{ELEMENT_ID}      = $row_data{INDEX}        . "_" . $entityType . "_" . $propertyKey;
					
				$row_data{TYPE_ENTITIES}   = 1;
				$row_data{TYPE_FILE}       = 0;
				$row_data{TYPE_FILES}      = 0;
				$row_data{TYPE_STRING}     = 0;
				$row_data{ENTITY_TYPE}     = $entityType;
				$row_data{ADD_ROW}         = 0;
					
				$row_data{KEY}             = $propertyKey;			
				$row_data{KEY_DESCRIPTION} = $tempKeyDescription;			
				$row_data{VALUE}           = $currentEntityName;
				
				my $tempLink               = "pId=$projectId&eType=$propertyEType&eName=$currentEntityName";
				
				$tempLink = $tempLink . "&\$1=$pp1" if defined($pp1);
				$tempLink = $tempLink . "&\$2=$pp2" if defined($pp2);
				$tempLink = $tempLink . "&\$3=$pp3" if defined($pp3);
				$tempLink = $tempLink . "&\$4=$pp4" if defined($pp4);
				$tempLink = $tempLink . "&\$5=$pp5" if defined($pp5);
				$tempLink = $tempLink . "&\$6=$pp6" if defined($pp6);
				
				$tempLink = encode_base64($tempLink);
				
				$tempLink =~ s/\+/WERTYYTREW/g;
				$tempLink =~ s/\//ERTYUUYTRE/g;
				$tempLink =~ s/\=/QWERTTREWQ/g;
				
				$row_data{LINK}            = $tempLink;
							
				$row_data{ENTITIES}        = \@entities;
					
				push(@entities2, \%row_data);

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
					
			$row_data2{KEY}                 = $propertyKey;			
			$row_data2{KEY_DESCRIPTION}     = $propertyDescription;			
			$row_data2{VALUES}              = \@entities2;
			$row_data2{VALUE}               = "[" . $valueArray . "]";

			push(@loop_data, \%row_data2);

			$index = $index + 1;
			$tempKeyDescription = "";
		}
	}
	
	return ($index, @loop_data);
}

#################################################
#
# Function: addProject
#
# Description:
# 	Function adds new project
#
# Parameters:
#	key and value to be written
#
#################################################

sub addProject
{
	my $projectId  = $_[0];
	my $entityName = $_[1];

	my $data = getConfigSettings();
	
	my $val = $data->{$projectId}->{'projects'};
	
	my @values;
	
	foreach my $v1 (@$val)
	{
		push(@values, $v1);
	}
	
	push(@values, $entityName);
		
	$data->{$projectId}->{'projects'} = \@values;

	my $filename = getConfigFilePath();	
	JsonHelper::writeJSONFile($filename, $data);	
}

#################################################
#
# Function: deleteProject
#
# Description:
# 	Function adds new project
#
# Parameters:
#	key and value to be written
#
#################################################

sub deleteProject
{
	my $projectId  = $_[0];
	my $entityName = $_[1];

	my $data = getConfigSettings();
	
	my $val = $data->{$projectId}->{'projects'};
	
	my @values;
	
	foreach my $v1 (@$val)
	{
		if ($v1 ne $entityName)
		{
			push(@values, $v1);
		}
	}
	
	$data->{$projectId}->{'projects'} = \@values;

	my $filename = getConfigFilePath();	
	JsonHelper::writeJSONFile($filename, $data);	
}

#################################################
#
# Function: deleteEntity
#
# Description:
# 	Function deletes entity from project
#
# Parameters:
#	project id and entity to be deleted.
#
#################################################

sub deleteEntity
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	my $entityName = $_[2];
}
1;