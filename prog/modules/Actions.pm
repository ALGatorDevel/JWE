# Actions.pm
package Actions;

use lib "../";

use modules::Tools;
use modules::Pages;
use modules::Entities;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use Cwd;
use URI::Escape;
use feature qw(switch);

use File::Path qw(make_path rmtree);
use File::Basename;
use File::Spec;

use strict;
use warnings;
 
my $query1;
my $pwd = cwd();

# ----------------------------------------------
# Function: EntityCreateEntity
#
# Description:
# Function generates and displays page for
# editing entity settings
# ----------------------------------------------

sub EntityCreateEntity {

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

	Tools::LogEnterFunction("EntityCreateEntity (project id $projectId, entity type $entityType, entity name $entityName).");

	Entities::CreateEntitySettings( $projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6 );
	Entities::AddProject( $projectId, $entityName );

	Pages::EditEntity( $projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6, $singleEntity );

	print $query1->header();
	
	Tools::LogExitFunction("EntityCreateEntity");
}

# ----------------------------------------------
# Function: EntityReadFile
#
# Description:
# User wants to read content of file
# ----------------------------------------------

sub EntityReadFile {

	my $projectId    = $_[0];
	my $entityType   = $_[1];
	my $entityName   = $_[2];
	my $p1           = $_[3];
	my $p2           = $_[4];
	my $p3           = $_[5];
	my $p4           = $_[6];
	my $p5           = $_[7];
	my $p6           = $_[8];

	Tools::LogEnterFunction("EntityReadFile (project id $projectId, entity type $entityType, entity name $entityName).");

	my $txt = Entities::ReadEntityFile($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
		
	print $query1->header();
	print $txt;

	Tools::LogExitFunction("EntityReadFile");
}

# ----------------------------------------------
# Function: EntityWriteFile
#
# Description:
# User wants to write content of file
# ----------------------------------------------

sub EntityWriteFile {
	
	my $projectId    = $_[0];
	my $entityType   = $_[1];
	my $entityName   = $_[2];
	my $p1           = $_[3];
	my $p2           = $_[4];
	my $p3           = $_[5];
	my $p4           = $_[6];
	my $p5           = $_[7];
	my $p6           = $_[8];

	Tools::LogEnterFunction("EntityWriteFile (project id $projectId, entity type $entityType, entity name $entityName).");

	my $txt        = uri_unescape($p2);

	Entities::WriteEntityFile($projectId, $entityType, $entityName, $p1, $txt, $p3, $p4, $p5, $p6);
		
	print $query1->header();

	Tools::LogExitFunction("EntityWriteFile");
}

# ----------------------------------------------
# Function: EntitySaveEntity
#
# Description:
# User wants to save entity
# ----------------------------------------------

sub EntitySaveEntity {

	print $query1->header();

	my( $name, $value );

	my $projectId    = $_[0];
	my $entityType   = $_[1];
	my $entityName   = $_[2];
	my $p1           = $_[3];
	my $p2           = $_[4];
	my $p3           = $_[5];
	my $p4           = $_[6];
	my $p5           = $_[7];
	my $p6           = $_[8];

	Tools::LogEnterFunction("EntitySaveEntity (project id $projectId, entity type $entityType, entity name $entityName).");

	my %entityValues;
	
	foreach $name ( $query1->param )
	{
		my $value = $query1->param($name);

		Tools::Log("");	
		Tools::Log("Param: $name\t\tValue: $value") if (defined($value));

		my $parentId;
		my $new_id;
		my $id;
		my $entityType;
		my $property;
		
		my @tokens = split("_", $name);
		
		if ($#tokens < 2)
		{
			next;
		}

		Tools::Log("\t\tNum tokens: $#tokens");
		
		my @parentIds;
		my $index;
		
		my $currentId1 = "";
		
		for $index (0..($#tokens - 3))
		{
			if (length($currentId1) > 0)
			{
				$currentId1 = $currentId1 . "_" . $tokens[$index];
			}
			else
			{
				$currentId1 = $tokens[$index];
			}
			
			push(@parentIds, $currentId1);
			
			Tools::Log("\t\t\tPush ParentId: $currentId1");
			
		}
		
		$parentId = "";
		$parentId   = $parentIds[$#parentIds];

		Tools::Log("\t\tParentId: $parentId") if defined $parentId;
		
		$id         = $tokens[$#tokens - 2];
		$entityType = $tokens[$#tokens - 1];
		$property   = $tokens[$#tokens];
		
		if (!defined($parentId) || (length($parentId) == 0))
		{
			$new_id = $id;
		}
		else
		{
			$new_id = $parentId . "_" . $id;
		}
		
		if ($id eq "999" || $value eq '')
		{
			next;
		}

		Tools::Log("\t\tNew Id: $new_id");

		my %row_data;

		$row_data{VALUE}       = $value;
		$row_data{PROPERTY}    = $property;

		my %parentItem = %entityValues;
		
		my $currentId = "";
		
		my %parents;

		$parents{''} = \%entityValues;
		
		Tools::Log("\t\tNum Parent Ids: $#parentIds");
		
		for my $index (0..$#parentIds)
		{
			Tools::Log("\t\t\tIndex: $index");

			$currentId = $parentIds[$index];
			
			my $properties = $parentItem{PROPERTIES};
	
			if (defined ($properties))
			{
				my %properties = %{$properties};
			
				%parentItem = %{$properties{$currentId}};
	
				my %hren = %parentItem;
				
				$parents{$currentId} = \%hren;
			}
		}

		if ($#parentIds >= 0)
		{
			my %tempValue = %row_data;
			my $tempId = $new_id;

			for (my $index1 = $#parentIds; $index1 >= 0; $index1--)
			{
				my %koki = %tempValue;
				$parents{$parentIds[$index1]}{PROPERTIES}{$tempId} = \%koki;

				if (!defined($parents{$parentIds[$index1]}{ENTITY_TYPE}))
				{
					$parents{$parentIds[$index1]}{ENTITY_TYPE} = $entityType;
				}
				
				$tempId    = $parentIds[$index1];
				%tempValue = %{$parents{$tempId}};
			}

			$parents{''}{PROPERTIES}{$tempId} = \%tempValue;
		}
		else
		{
			$parents{''}{PROPERTIES}{$new_id} = \%row_data;
		}
		
		%entityValues = %{$parents{''}};

		if (!defined($entityValues{PROJECT_ID}))
		{
			$entityValues{PROJECT_ID} = $projectId;
		}

		if (!defined($entityValues{VALUE}))
		{
			$entityValues{VALUE} = $entityName;
		}
		
		if (!defined($entityValues{ENTITY_TYPE}))
		{
			$entityValues{ENTITY_TYPE} = $entityType;
		}
	}

	my $result = Entities::SaveEntity(\%entityValues, $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	my $txt = $result ? "1" : "0";

#	print $query1->header();
	print $txt;

	Tools::LogExitFunction("EntityWriteFile");
}

# ----------------------------------------------
# Function: EntityAddEntity
#
# Description:
# User wants to add entity
# ----------------------------------------------

sub EntityAddEntity {

	my $projectId    = $_[0];
	my $entityType   = $_[1];
	my $entityName   = $_[2];
	my $p1           = $_[3];
	my $p2           = $_[4];
	my $p3           = $_[5];
	my $p4           = $_[6];
	my $p5           = $_[7];
	my $p6           = $_[8];
	my $level        = $_[9];
	
	my $newId      = $query1->param("elId");
	my $entity     = $query1->param("entity");
	my $property           = $query1->param("property");
	my $entityArrayValueId = $query1->param("entityArrayValueId");
	my $parentItemIndex    = $query1->param("parentItemIndex");

	Tools::LogEnterFunction("EntityAddEntity (project id $projectId, entity type $entityType, entity name $entityName).");
	
	my $entityFilename = Entities::GetEntityFilename($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	my $data           = Entities::CreateEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
		
	JsonHelper::writeJSONFile($entityFilename, $data);	

	my $filename = Configuration::GetConfigurationFolder() . "Entity3 - Add Row.html";
	 
	my $template = HTML::Template->new(filename => $filename, loop_context_vars => 1, die_on_bad_params => 0);

	my $entityData = Entities::GetEntityData($projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6);

	my ($maxIndex, @loop_data) = Pages::ListEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6, $newId, "1", $level);

	$template->param(ENTTITY_ARRAY_VALUE_ID => $entityArrayValueId);
	$template->param(KEY_DESCRIPTION => "Novi element");
	$template->param(PARENT_INDEX => $parentItemIndex);
	$template->param(ELEMENT_ID => $newId . "_" . $entity . "_" . $property);
	$template->param(KEY => $property);
	$template->param(VALUE => $entityName);
	$template->param(SETTINGS => \@loop_data);
	$template->param(PROJECT_ID => $projectId);
	$template->param(LEVEL => $level);
	$template->param(LEVEL_OFFSET => ($level * 30));
	
	# Send HTML to the browser.
	my $txt = $template->output();

	print $query1->header();
	print $txt;

	Tools::LogExiFunction("EntityAddEntity");
}

# ----------------------------------------------
# User wants to delete entity
# ----------------------------------------------

sub EntityDeleteEntity {

	my $projectId    = $_[0];
	my $entityType   = $_[1];
	my $entityName   = $_[2];
	my $p1           = $_[3];
	my $p2           = $_[4];
	my $p3           = $_[5];
	my $p4           = $_[6];
	my $p5           = $_[7];
	my $p6           = $_[8];
	
	Tools::LogEnterFunction("EntityDeleteEntity (project id $projectId, entity type $entityType, entity name $entityName).");

	Entities::DeleteEntity($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);

	print $query1->header();

	Tools::LogExitFunction("EntityDeleteEntity");
}

# ----------------------------------------------
# User wants to delete project
# ----------------------------------------------

sub EntityDeleteProject {

	my $projectId    = $_[0];
	my $entityName   = $_[1];

	Tools::LogEnterFunction("EntityDeleteProject (project id $projectId, entity name $entityName).");

	Entities::DeleteProject($projectId, $entityName);

	my $projectFolder = Configuration::GetProjectPath($projectId, "Project", $entityName);
	
	if (-d $projectFolder)
	{
		rmtree($projectFolder);
	}	
	
	print $query1->header();

	Tools::LogExitFunction("EntityDeleteProject");
}

# ----------------------------------------------
# Function: FileManagerListFiles
#
# Description:
# Function returns list of files
#
# Parameters:
# Source folder which should be read
# ----------------------------------------------

sub FileManagerListFiles
{
    my $path = $_[0];

	opendir my($dh), $path or die "Couldn't open dir '$path': $!";
	my @files = grep { !/^\.?$/ && !/^\.(.*)$/ || /^\.\.$/} readdir $dh;
	closedir $dh;
	
    return @files;
}

# ----------------------------------------------
# Function: FileManagerGetFileInfo
#
# Description:
# Function gets folder info for file manager
# ----------------------------------------------

sub FileManagerGetFileInfo
{
	my $folder      = $_[0];
	my $currentPath = $_[1];
	my $absPath     = $_[2];
	my $rootFolder  = $_[3];
	
	Tools::LogEnterFunction("FileManagerGetFileInfo (folder $folder, current path $currentPath, abs path $absPath, root folder $rootFolder).");

	if ($currentPath eq "")
	{
		$currentPath = $pwd;
	}
	
	$folder = uri_unescape ($folder);

	make_path("$folder") unless -e $folder;
	
	
#	if (!-d $folder) {
#		system "mkdir -p $folder";
#	}
#	
	
	$currentPath = uri_unescape ($currentPath);
	
	my $path = $currentPath;
	
	my @tokens = split(/\//, $folder);
	
	foreach my $token (@tokens)
	{
		if ($token eq "..")
		{
			my $pos = rindex($path, '/');
			
			if ($pos > 0)
			{
				$path = substr $path, 0, $pos;
			} 
		}
		else
		{
			$path = "$path/$token";
		}
	}
	
	if ($absPath eq "1")
	{
		$path = $folder;
	}
	
	if ($path eq "")
	{
		$path = $rootFolder;
	}
	
	my @files = FileManagerListFiles($path . "/");
	
	my $fileList = $path;
	
	foreach my $filename (@files)
	{
		if (($filename eq "..") && ($path eq $rootFolder))
		{
			next;
		}
		
		my $filepath = $path . "/" . $filename;
		my $filesize = -s $filepath;
		my $fileType = "file";
		
		if (-d $filepath)
		{
			$fileType = "folder";
		}
		
		my $divider = "|";
		
		if ($fileList eq $path)
		{
			$divider = "@";
		}
		
		my $fileEntry = "$fileType" . "/" . "$filename" . "/" . "$filesize"; 
		
		$fileList = "$fileList" . "$divider" . "$fileEntry";
		
		Tools::Log("File: $fileEntry");
	}
	
	print $query1->header();
	print $fileList;

	Tools::LogExitFunction("FileManagerGetFileInfo");
}

# ----------------------------------------------
# Function: FileManagerCreateFolder
#
# Description:
# Function creates folder in file manager
# ----------------------------------------------

sub FileManagerCreateFolder
{
	my $currentFolder = $_[0];
	my $folderName    = $_[1];
	
	Tools::LogEnterFunction("FileManagerCreateFolder (current folder $currentFolder, folder $folderName).");

	my $folderPath = uri_unescape($currentFolder) . "/" . uri_unescape($folderName);
		
	make_path("$folderPath") unless -e $folderPath;

	print $query1->header();

	Tools::LogExitFunction("FileManagerCreateFolder");
}

# ----------------------------------------------
# Function: FileManagerDeleteFile
#
# Description:
# Function deletes file/folder in file manager
# ----------------------------------------------

sub FileManagerDeleteFile
{
	my $filename = $_[0];
	
	Tools::LogEnterFunction("FileManagerDeleteFile (file $filename).");

	$filename = uri_unescape($filename);
	
	if (-d $filename)
	{
		rmtree($filename);
	}	
	else
	{
		unlink($filename);
	}

	print $query1->header();

	Tools::LogExitFunction("FileManagerDeleteFile");
}

# ----------------------------------------------
# Function: FileManagerUploadFile
#
# Description:
# Function uploads file in file manager
# ----------------------------------------------

sub FileManagerUploadFile
{
	my $uploadFolder = $_[0];

	my @fileHandleList = $query1->upload('files');
	
	Tools::LogEnterFunction("FileManagerUploadFile (upload folder $uploadFolder).");

	foreach my $fh (@fileHandleList)
	{
		# undef may be returned if it's not a valid file handle
		if (defined $fh )
		{
			# Upgrade the handle to one compatible with IO::Handle:
			my $io_handle = $fh->handle;
	
			open( OUTFILE, '>', $uploadFolder . $fh );
			
			binmode OUTFILE;
			
			while ( my $bytesread = $io_handle->read( my $buffer, 1024 ) )
			{
				print OUTFILE $buffer;
			}
			
			Tools::Log("Upload file: $uploadFolder . $fh");
		}
	}

	print $query1->header();

	Tools::LogExitFunction("FileManagerUploadFile");
}

# ----------------------------------------------
# Function: UploadFileFileManager
#
# Description:
# Function uploads file in file manager
# ----------------------------------------------

sub EntityUploadFile
{
	my $projectId  = $_[0];
	my $p1         = $_[1];

	my $filesId = $query1->param("filesId");
	my @fileHandleList = $query1->upload($filesId);

	Tools::LogEnterFunction("EntityUploadFile (project id $projectId, p1 $p1).");

	my $projectsRootPath = Configuration::GetProjectRootPath($projectId); 

	my $uploadFolder   = $projectsRootPath . "/projects/" . $p1 . "/";
	
	make_path("$uploadFolder") unless -e $uploadFolder;
	
	foreach my $fh (@fileHandleList)
	{
		# undef may be returned if it's not a valid file handle
		if (defined $fh )
		{
			# Upgrade the handle to one compatible with IO::Handle:
			my $io_handle = $fh->handle;
	
			open( OUTFILE, '>', $uploadFolder . $fh );
	
			while ( my $bytesread = $io_handle->read( my $buffer, 1024 ) )
			{
				print OUTFILE $buffer;
			}

			Tools::Log("Upload file: $uploadFolder . $fh");
		}
	}

	print $query1->header();

	Tools::LogExitFunction("EntityUploadFile");
}

# ----------------------------------------------
# Function: CheckPattern
#
# Description:
# Function checks value against pattern
#
# Parameters:
# value, allowedPattern
# ----------------------------------------------

sub CheckPattern
{
	my $p1 = $_[0];
	my $p2 = $_[1];
	
	my $ret = "0";

#	"[A-Za-z][A-Za-z0-9]{0-15}"
#	[A-Za-z]+?[A-Za-z]+?(0\d+|1[1-7])*?
	
	my $firstChar = "";
	my $basic = "";
	my $num1 = "";
	my $num2 = "";
	
	if ($p2 =~ /\[(.*)\]\[(.*)\]\{(.*)\-(.*)\}/)
	{
		$firstChar = $1;
		$basic = $2;
		$num1 = $3;
		$num2 = $4;
	}
	
	my $pattern = "[$firstChar]+[$basic]*";
	
#	$basic =~ s/\]/\]\+\?/g;

	if ($p1 =~ /^$pattern(\d*)$/)
	{
		my $num = $1;

		if (defined($num))
		{
			if ($num >= $num1 && $num <= $num2)
			{
				$ret = "1";
			}
		}
		else
		{
			$ret = "1";
		}
	}
	
    return $ret;
}

# ----------------------------------------------
# Function: ValidateField
#
# Description:
# Function validates field
# ----------------------------------------------

sub ValidateField
{
	my $p1 = $_[0];
	my $p2 = $_[1];
	
	my $txt = CheckPattern($p1, $p2);
	
	print $query1->header();
	print $txt;
}

# ----------------------------------------------
# Function: performAction
#
# Description:
# 	Function starts required action
# ----------------------------------------------

sub PerformAction {

	my $action       = $_[0];
	my $projectId    = $_[1];
	my $entityType   = $_[2];
	my $entityName   = $_[3];
	my $p1           = $_[4];
	my $p2           = $_[5];
	my $p3           = $_[6];
	my $p4           = $_[7];
	my $p5           = $_[8];
	my $p6           = $_[9];
	my $singleEntity = $_[10];
	
	$query1          = $_[11];

	my $level        = $_[12];

	Tools::LogEnterFunction("PerformAction");

	given ($action) {
		when ('EditScheme') {
			Pages::EditScheme( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6 );
		}
		when ('EditSchemes') {
			Pages::EditSchemes($projectId);
		}
		when ('FileManager') {
			Pages::StartFileManager($projectId);
		}
		when ('GetFileInfo') {
			FileManagerGetFileInfo( $p1, $p2, $p3, $p4 );
		}
		when ('CreateFolder') {
			FileManagerCreateFolder( $p1, $p2 );
		}
		when ('DeleteFile') {
			FileManagerDeleteFile( $p1 );
		}
		when ('UploadFileFileManager') {
			FileManagerUploadFile( $p1 );
		}
		when ('AddEntity') {
			EntityAddEntity( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6, $level );
		}
		when ('DeleteEntity') {
			EntityDeleteEntity( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6 );
		}
		when ('CreateEntity') {
			EntityCreateEntity( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6, $singleEntity );
		}
		when ('DeleteProject') {
			EntityDeleteProject( $projectId, $entityName);
		}
		when ('SaveEntity') {
			EntitySaveEntity( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6 );
		}
		when ('EntityUploadFile') {
			EntityUploadFile( $projectId, $p1 );
		}
		when ('ReadFile') {
			EntityReadFile( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6 );
		}
		when ('WriteFile') {
			EntityWriteFile( $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6 );
		}
		when ('ValidateField') {
			ValidateField( $p1, $p2 );
		}
		default {
			my $txt = "Unknown action: $action\n";
			
			print $query1->header();
			
			Tools::Log("Unknown action: $txt");
		}
	}

	Tools::LogExitFunction("PerformAction");
}

1;