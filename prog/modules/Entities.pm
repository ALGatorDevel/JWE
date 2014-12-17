# Entities.pm
package Entities;

use lib "../";

use modules::JsonHelper;
use modules::Tools;
use modules::Configuration;

use Cwd;

use MIME::Base64;

use File::Path qw(make_path rmtree);
use File::Basename;
use File::Spec;

use strict;
use warnings;

# ----------------------------------------------
# Function: AddProject
#
# Description:
# Function adds new project
#
# Parameters:
# key and value to be written
# ----------------------------------------------

sub AddProject
{
	my $projectId  = $_[0];
	my $entityName = $_[1];

	Tools::LogEnterFunction("AddProject (Project Id: $projectId, Entity Name: $entityName)");

	my $data = Configuration::GetConfigurationSettings();
	
	my $val = $data->{$projectId}->{'projects'};
	
	my @values;
	
	foreach my $v1 (@$val)
	{
		push(@values, $v1);

		Tools::Log("Project: $v1");
	}
	
	push(@values, $entityName);
		
	$data->{$projectId}->{'projects'} = \@values;

	my $filename = Configuration::GetConfigurationFilePath();	

	JsonHelper::writeJSONFile($filename, $data);	

	Tools::LogExitFunction("AddProject");
}

# ----------------------------------------------
# Function: GetEntitySchemeData
#
# Description:
# Function returns properties of current entity scheme
# ----------------------------------------------

sub GetEntitySchemeData
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	
	Tools::LogEnterFunction("GetEntitySchemeData (Project Id: $projectId, Entity Type: $entityType)");

	my $val;
	
	# if settings cannot be read or project id is not defined return empty value
	if (!defined($projectId) || !defined($entityType))
	{
		Tools::Log("Project id or entity type undefined.");

		Tools::LogExitFunction("GetEntitySchemeData");

		return $val;
	}
	
	my $entitySchemeFilename = Configuration::GetEntitySchemaFilePath($projectId, $entityType);
	
	if (!defined($entitySchemeFilename))
	{
		Tools::Log("Entity scheme filename undefined.");

		Tools::LogExitFunction("GetEntitySchemeData");

		return $val;
	}

	Tools::Log("Read scheme: $entitySchemeFilename.");
	
	$val = JsonHelper::readJSONFile($entitySchemeFilename);
	
	Tools::LogExitFunction("GetEntitySchemeData");

	return $val;
}

# ----------------------------------------------
# Function: GetEntityFilename
#
# Description:
# Function returns properties of entity
# ----------------------------------------------

sub GetEntityFilename
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
	
	Tools::LogEnterFunction("GetEntityFilename (Project Id: $projectId, Entity Type: $entityType, Entity Name: $entityName)");

	if (!defined($projectId) || !defined($entityType) || !defined($entityName))
	{
		Tools::Log("Project id, entity type or entity name undefined.");

		Tools::LogExitFunction("GetEntityFilename");

		return $val;
	}
	
	my $projectsRootPath = Configuration::GetProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		Tools::Log("Project root undefined.");

		Tools::LogExitFunction("GetEntityFilename");

		return $val;
	}

	my $entitySchemeData = GetEntitySchemeData($projectId, $entityType);

	if (!defined($entitySchemeData))
	{
		Tools::Log("Could not retrieve scheme data.");

		Tools::LogExitFunction("GetEntityFilename");

		return $val;
	}

	my $entityFilename = $entitySchemeData->{Filename};

	if (!defined($entityFilename))
	{
		Tools::Log("Entity filename undefined.");

		Tools::LogExitFunction("GetEntityFilename");

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
	
	Tools::LogExitFunction("GetEntityFilename (return $val).");

	return $val;
}

# ----------------------------------------------
# Function: GetEntityFolder
#
# Description:
# Function returns entity folder
# ----------------------------------------------

sub GetEntityFolder
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
	
	Tools::LogEnterFunction("GetEntityFolder");

	if (!defined($projectId) || !defined($entityType) || !defined($entityName))
	{
		Tools::Log("Project id, entity type or entity name undefined.");

		Tools::LogExitFunction("GetEntityFolder");

		return $val;
	}
	
	my $projectsRootPath = Configuration::GetProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		Tools::Log("Could not retrieve project root path.");
		
		Tools::LogExitFunction("GetEntityFolder");

		return $val;
	}

	my $entitySchemeData = GetEntitySchemeData($projectId, $entityType);

	if (!defined($entitySchemeData))
	{
		Tools::Log("Could not retrieve entity scheme data.");
		
		Tools::LogExitFunction("GetEntityFolder");

		return $val;
	}

	my $entityFolder = $entitySchemeData->{Folder};

	if (!defined($entityFolder))
	{
		Tools::Log("Could not retrieve entity folder.");
		
		Tools::LogExitFunction("GetEntityFolder");

		return $val;
	}

	$entityFolder =~ s/\{\}/$entityName/g;

	$entityFolder =~ s/\$1/$p1/g if defined($p1);
	$entityFolder =~ s/\$2/$p2/g if defined($p2);
	$entityFolder =~ s/\$3/$p3/g if defined($p3);
	$entityFolder =~ s/\$4/$p4/g if defined($p4);
	$entityFolder =~ s/\$5/$p5/g if defined($p5);
	$entityFolder =~ s/\$6/$p6/g if defined($p6);
	
	$entityFolder = $projectsRootPath . "/projects/" . $entityFolder;
	
	$val = $entityFolder;
	
	Tools::LogExitFunction("GetEntityFolder (return $val).");

	return $val;
}

# ----------------------------------------------
# Function: CreateEntitySettings
#
# Description:
# Function reads all entity settings from config file
# ----------------------------------------------

sub CreateEntitySettings
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

	Tools::LogEnterFunction("CreateEntitySettings (Project id: $projectId, Entity type: $entityType, Entity name: $entityName)");

	my $entitySchemeData = GetEntitySchemeData ($projectId, $entityType);
	my $entityFilename   = GetEntityFilename   ($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
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
	
	Tools::LogExitFunction("CreateEntitySettings");

	return $data;
}

# ----------------------------------------------
# Function: GetEntityData
#
# Description:
# Function returns properties of entity
# ----------------------------------------------

sub GetEntityData
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
	
	Tools::LogEnterFunction("GetEntityData (Project id: $projectId, Entity type: $entityType, Entity name: $entityName)");

	my $val;
	
	my $entityFilename = GetEntityFilename($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	if (!defined($entityFilename))
	{
		Tools::Log("Could not retrieve entity filename.");

		Tools::LogExitFunction("GetEntityData");

		return $val;
	}
	
	$val = JsonHelper::readJSONFile($entityFilename);
	
	Tools::LogExitFunction("GetEntityData");

	return $val;
}

# ----------------------------------------------
# Function: ReadEntityFile
#
# Description:
# Function reads file for editing
# ----------------------------------------------

sub ReadEntityFile
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
	
	Tools::LogEnterFunction("ReadEntityFile(project id $projectId, entity type $entityType, entity name $entityName).");

	my $txt = "";
	my $pwd = cwd();
	
	if (!defined($projectId) || !defined($p1) || !defined($entityName))
	{
		Tools::Log("Project id, p1 or entity name undefined.");

		Tools::LogExitFunction("ReadEntityFile");

		return $txt;
	}
	
	my $projectsRootPath = Configuration::GetProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		Tools::Log("Could not retrieve project root path.");

		Tools::LogExitFunction("ReadEntityFile");

		return $txt;
	}

	my $filename = $projectsRootPath . "/projects/" . $p1 . "/" . $entityName;
	
	Tools::Log("Read file $filename.");
	
	my @fileContent = Tools::readFileArray($filename);

	my $lines = 0;
	
	foreach (@fileContent)
	{
		$lines = $lines + 1;
		
		my $line = $_;
	 	$txt = $txt . $line;
	}
	
	if ($lines == 0)
	{
		Tools::Log("Could not retrieve content of file.");
	}

	Tools::LogExitFunction("ReadEntityFile");

	return $txt;
}

# ----------------------------------------------
# Function: WriteEntityFile
#
# Description:
# Function writes edited file
# ----------------------------------------------

sub WriteEntityFile
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
	
	Tools::LogEnterFunction("WriteEntityFile(Project id $projectId, entity type $entityType, entity name $entityName.");

	my $txt = $p2;

	if (!defined($projectId) || !defined($p1) || !defined($entityName))
	{
		Tools::Log("Project id, p1 or entity name undefined.");

		Tools::LogExitFunction("WriteEntityFile");

		return "";
	}
	
	my $projectsRootPath = Configuration::GetProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		Tools::Log("Could not retrieve project root path.");

		Tools::LogExitFunction("WriteEntityFile");

		return "";
	}

	my $filename = $projectsRootPath . "/projects/" . $p1 . "/" . $entityName;

	Tools::Log("Write file $filename.");
	
	my @fileContent = Tools::writeFile($filename, $txt);

	Tools::LogExitFunction("WriteEntityFile");
}

# ----------------------------------------------
# Function: SaveEntity
#
# Description:
# Function saves entity
# ----------------------------------------------

sub SaveEntity
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

	Tools::LogEnterFunction("SaveEntity(project id $projectId, entity type $entityType, entity name $entityName).");

	my $returnValue = 1;

	my $entityFilename   = Configuration::GetEntityFilename	($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	my $entitySchemeData = Configuration::GetEntitySchemeData($projectId, $entityType);

	my $data             = CreateEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	my $properties = $data->{$entityType};
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
			
			if ($type =~ /(.*)\[\]/)
			{
				if (defined($currentPropertyList))
				{
					foreach my $currentPropertyKey ( sort(keys(%$currentPropertyList)))
					{
						my $currentProperty = $currentPropertyList->{$currentPropertyKey};
						my $newEType = $entityProperty->{eType};
						my $newEName = $currentProperty->{VALUE};
						
						my @parameters = @{$entityProperty->{parameters}};
						
						my $pp1 = $parameters[0] if scalar(@parameters) > 0;
						my $pp2 = $parameters[1] if scalar(@parameters) > 1;
						my $pp3 = $parameters[2] if scalar(@parameters) > 2;
						my $pp4 = $parameters[3] if scalar(@parameters) > 3;
						my $pp5 = $parameters[4] if scalar(@parameters) > 4;
						my $pp6 = $parameters[5] if scalar(@parameters) > 5;
						
						if (defined($pp1))
						{
							$pp1 =~ s/\{\}/$entityName/g;
							
							$pp1 =~ s/\$1/$p1/g;
							$pp1 =~ s/\$2/$p2/g;
							$pp1 =~ s/\$3/$p3/g;
							$pp1 =~ s/\$4/$p4/g;
							$pp1 =~ s/\$5/$p5/g;
							$pp1 =~ s/\$6/$p6/g;
						}
	
						if (defined($pp2))
						{
							$pp2 =~ s/\{\}/$entityName/g;
							
							$pp2 =~ s/\$1/$p1/g;
							$pp2 =~ s/\$2/$p2/g;
							$pp2 =~ s/\$3/$p3/g;
							$pp2 =~ s/\$4/$p4/g;
							$pp2 =~ s/\$5/$p5/g;
							$pp2 =~ s/\$6/$p6/g;
						}
	
						if (defined($pp3))
						{
							$pp3 =~ s/\{\}/$entityName/g;
							
							$pp3 =~ s/\$1/$p1/g;
							$pp3 =~ s/\$2/$p2/g;
							$pp3 =~ s/\$3/$p3/g;
							$pp3 =~ s/\$4/$p4/g;
							$pp3 =~ s/\$5/$p5/g;
							$pp3 =~ s/\$6/$p6/g;
						}
	
						if (defined($pp4))
						{
							$pp4 =~ s/\{\}/$entityName/g;
							
							$pp4 =~ s/\$1/$p1/g;
							$pp4 =~ s/\$2/$p2/g;
							$pp4 =~ s/\$3/$p3/g;
							$pp4 =~ s/\$4/$p4/g;
							$pp4 =~ s/\$5/$p5/g;
							$pp4 =~ s/\$6/$p6/g;
						}
	
						if (defined($pp5))
						{
							$pp5 =~ s/\{\}/$entityName/g;
							
							$pp5 =~ s/\$1/$p1/g;
							$pp5 =~ s/\$2/$p2/g;
							$pp5 =~ s/\$3/$p3/g;
							$pp5 =~ s/\$4/$p4/g;
							$pp5 =~ s/\$5/$p5/g;
							$pp5 =~ s/\$6/$p6/g;
						}
	
						if (defined($pp6))
						{
							$pp1 =~ s/\{\}/$entityName/g;
							
							$pp6 =~ s/\$1/$p1/g;
							$pp6 =~ s/\$2/$p2/g;
							$pp6 =~ s/\$3/$p3/g;
							$pp6 =~ s/\$4/$p4/g;
							$pp6 =~ s/\$5/$p5/g;
							$pp6 =~ s/\$6/$p6/g;
						}
	
						my $result = SaveEntity($currentProperty, $projectId, $newEType, $newEName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6);
						
						$returnValue = $returnValue && $result;
					}

					my @values;
	
					foreach my $currentPropertyKey ( sort(keys(%$currentPropertyList)))
					{
						my $currentProperty = $currentPropertyList->{$currentPropertyKey};
						my $newEName = $currentProperty->{VALUE};
	
						push(@values, $newEName);
					}
					
					$properties->{$name} = \@values;
				}
			}
			elsif ($type eq "Files")
			{
				if (defined($currentPropertyList))
				{
					my @values;
	
					foreach my $currentPropertyKey ( sort(keys(%$currentPropertyList)))
					{
						my $currentProperty = $currentPropertyList->{$currentPropertyKey};
						my $value = $currentProperty->{VALUE};

						my @filenames = split(",", $value);
						
						foreach my $filename (@filenames)
						{
							my $trimmedFilename = $filename;
							$trimmedFilename =~ s/^\s+|\s+$//g;
							
							push(@values, $trimmedFilename);
						}
					}
										
					$properties->{$name} = \@values;
				}
					
#
#
#				my $val = $properties->{$name};
#				
#				my @values;
#				
#				foreach my $v1 (@$val)
#				{
#					push(@values, $v1);
#				}
#				
#				my @filenames = split(",", $value);
#				
#				foreach my $filename (@filenames)
#				{
#					push(@values, $filename);
#				}
#					
#				$properties->{$name} = \@values;
			}
			else
			{
				$properties->{$name} = $value;
			}
		}
	}
		
	$data->{$entityType} = $properties;

	my $result = JsonHelper::writeJSONFile($entityFilename, $data);
	
	$returnValue = $returnValue && $result;

	Tools::LogExitFunction("SaveEntity");

	return $returnValue;	
}

# ----------------------------------------------
# Function: DeleteEntity
#
# Description:
# Function deletes all entity files
# ----------------------------------------------

sub DeleteEntity
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

	Tools::LogEnterFunction("DeleteEntity");
	
    Tools::Log("Project Id : $projectId");
    Tools::Log("Entity Type: $entityType");
    Tools::Log("Entity Name: $entityName");
    
    my $projectRootPath = Configuration::GetProjectRootPath($projectId);
    
	my $entityFileData   = GetEntityData($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	my $entitySchemeData = GetEntitySchemeData($projectId, $entityType);
			
	my @loop_data = ();
	
	my $schemeProperties = $entitySchemeData->{properties};
	my $propertyOrder;

	foreach my $propertyKey (sort(keys(%$schemeProperties)))
	{
		push(@$propertyOrder, $propertyKey);
	}
	
	my $entityFilename = GetEntityFilename($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);

	my $entityFolder = GetEntityFolder($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	foreach my $propertyKey (@$propertyOrder)
	{
		my $propertyValue       = $schemeProperties->{$propertyKey};
		
		my $propertyType        = $propertyValue->{type};
		my $propertyDescription = $propertyValue->{description};

		if (uc($propertyType) eq "ENTITY_NAME")
		{
			next;
		}
		
		if (uc($propertyType) eq "STRING")
		{
			next;
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
				
			my $filename = $projectRootPath . "/projects/" . $root . "/" . $value;
			
			if (-e "$filename")
			{
			    Tools::Log("File $filename is deleted.");
				unlink("$filename"); 
			}
			else
			{
			    Tools::Log("File $filename does not exist.");
			}
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
				my $filename = $root . "/" . $currentEntityName;
				
				if (-e $filename)
				{
					Tools::Log("File $filename from list would be deleted.");
				}
				else
				{
					Tools::Log("File $filename from list does not exist.");
				}
			}
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
				DeleteEntity($projectId, $propertyEType, $currentEntityName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6);
			}
		}
	}
	Tools::Log(" ");
	Tools::Log("Delete entity $entityFilename");
	
	if (defined($entityFolder))
	{
		Tools::Log("Delete entity folder: $entityFolder");
	}

	if (-e "$entityFilename")
	{
		unlink("$entityFilename"); 
	}

	if (defined($entityFolder))
	{
		if (-d "$entityFolder")
		{
			rmtree("$entityFolder");
		}
	}
	
	Tools::LogExitFunction("DeleteEntity");
}

# ----------------------------------------------
# Function: deleteProject
#
# Description:
# Function deletes project
# ----------------------------------------------

sub DeleteProject
{
	my $projectId  = $_[0];
	my $entityName = $_[1];

	Tools::LogEnterFunction("DeleteProject");

	my $data = Configuration::GetConfigurationSettings();
	
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

	my $filename = Configuration::GetConfigurationFilePath();	

	JsonHelper::writeJSONFile($filename, $data);

	Tools::LogExitFunction("DeleteProject");
}

1;