# Configuration.pm
package Configuration;

use lib "../";

use modules::JsonHelper;
use modules::Tools;

use Cwd;

use MIME::Base64;

use Env qw(JWE_PROJECTS_ROOT);

use strict;
use warnings;
 
my $pwd = cwd();

# ----------------------------------------------
# Function: GetConfigurationFolder
#
# Description:
# Function returns path to the configuration folder
# ----------------------------------------------

sub GetConfigurationFolder
{
	# path to the common configuration file
	my $folder = $pwd . '/conf/';
	
	return $folder;
}

# ----------------------------------------------
# Function: GetConfigurationFilePath
#
# Description:
# Function returns path to the common config file
# ----------------------------------------------

sub GetConfigurationFilePath
{
	# path to the common configuration file
	my $filename = GetConfigurationFolder() . 'config.json';
	
	return $filename;
}

# ----------------------------------------------
# Function: GetConfigurationSettings
#
# Description:
# Function returns all common settings
# ----------------------------------------------

sub GetConfigurationSettings
{
	# path to the common configuration file
	my $filename = GetConfigurationFilePath();
	
	# read data from config file 
	my $data = JsonHelper::readJSONFile($filename);
	
	return $data;
}

# ----------------------------------------------
# Function: GetProjectSettings
#
# Description:
# Function returns all common settings
# ----------------------------------------------

sub GetProjectSettings
{
	my $projectId = $_[0];
	
	my $val;
	
	# get configuration settings from common configuration file
	my $data = GetConfigurationSettings();

	# if settings cannot be read or project id is not defined return empty value
	if (!defined($data) || !defined($projectId))
	{
		return $val;
	}
	
	# get project settings for current main project 
	$val = $data->{$projectId};
	
	return $val;
}

# ----------------------------------------------
# Function: GetProjectRootPath
#
# Description:
# Function returns list of projects defined in 
# current main project
# ----------------------------------------------

sub GetProjectRootPath
{
	my $projectId = $_[0];
	
	my $val;
	
	# get project settings for current main project 
	my $projectSettings = GetProjectSettings($projectId);

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

# ----------------------------------------------
# Function: GetProjectPath
#
# Description:
# Function returns project path
# ----------------------------------------------

sub GetProjectPath
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
	
	my $projectsRootPath = GetProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		return $val;
	}

	my $entitySchemeData = GetEntitySchemeData($projectId, $entityType);

	if (!defined($entitySchemeData))
	{
		return $val;
	}

	my $projectFolder = $entitySchemeData->{Folder};

	if (!defined($projectFolder))
	{
		return $val;
	}

	$projectFolder =~ s/\{\}/$entityName/g;

	$projectFolder =~ s/\$1/$p1/g if defined($p1);
	$projectFolder =~ s/\$2/$p2/g if defined($p2);
	$projectFolder =~ s/\$3/$p3/g if defined($p3);
	$projectFolder =~ s/\$4/$p4/g if defined($p4);
	$projectFolder =~ s/\$5/$p5/g if defined($p5);
	$projectFolder =~ s/\$6/$p6/g if defined($p6);
	
	$projectFolder = $projectsRootPath . "/projects/" . $projectFolder;
	
	$val = $projectFolder;
	
	return $val;
}

# ----------------------------------------------
# Function: getEntitySchemeRootPath
#
# Description:
# Function returns path to the root of scheme files
# ----------------------------------------------

sub GetEntitySchemeRootPath
{
	my $projectId = $_[0];
	
	my $schemaFilePath;
	
	my $projectRootPath = GetProjectRootPath($projectId);

	if (!defined($projectRootPath))
	{
		return $schemaFilePath;
	}

	$schemaFilePath = $projectRootPath . "/schema";

	return $schemaFilePath;
}

# ----------------------------------------------
# Function: GetEntitySchemaFilePath
#
# Description:
# Function returns path to the common config file
# ----------------------------------------------

sub GetEntitySchemaFilePath
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	
	my $schemaFilePath; 

	my $entitySchemeRootPath = GetEntitySchemeRootPath($projectId);

	if (!defined($entitySchemeRootPath))
	{
		return $schemaFilePath;
	}

	$schemaFilePath = $entitySchemeRootPath . "/$entityType.atjs";

	return $schemaFilePath;
}

# ----------------------------------------------
# Function: getEntitySchemeData
#
# Description:
# Function returns properties of current entity scheme
# ----------------------------------------------

sub GetEntitySchemeData
{
	my $projectId  = $_[0];
	my $entityType = $_[1];
	
	my $val;
	
	# if settings cannot be read or project id is not defined return empty value
	if (!defined($projectId) || !defined($entityType))
	{
		return $val;
	}
	
	my $entitySchemeFilename = GetEntitySchemaFilePath($projectId, $entityType);
	
	if (!defined($entitySchemeFilename))
	{
		return $val;
	}

	$val = JsonHelper::readJSONFile($entitySchemeFilename);
	
	return $val;
}

# ----------------------------------------------
# Function: GetEntityFilename
#
# Description:
# Function returns rntity filename
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
	
	if (!defined($projectId) || !defined($entityType) || !defined($entityName))
	{
		return $val;
	}
	
	my $projectsRootPath = GetProjectRootPath($projectId);
	
	if (!defined($projectsRootPath))
	{
		return $val;
	}

	my $entitySchemeData = GetEntitySchemeData($projectId, $entityType);

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

1;