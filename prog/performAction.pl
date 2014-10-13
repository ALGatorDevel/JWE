#!/usr/bin/perl -w

use lib ".";

use lib "/opt/local/lib/perl5/site_perl/5.16.3";
use HTML::Template;

use modules::JsonHelper;
use modules::EntityTools;
use modules::Tools;

use Data::Dumper; 

use Cwd;

use strict;
use warnings;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use File::Path qw(make_path rmtree);
use File::Basename;
use File::Spec;

use URI::Escape;


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

	my $returnValue = 1;
		
	my $entityFilename   = EntityTools::getEntityFilename   ($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	my $entitySchemeData = EntityTools::getEntitySchemeData ($projectId, $entityType);

	my $data             = EntityTools::createEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
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
						
						my $pp1 = $parameters[0] if length(@parameters) > 0;
						my $pp2 = $parameters[1] if length(@parameters) > 1;
						my $pp3 = $parameters[2] if length(@parameters) > 2;
						my $pp4 = $parameters[3] if length(@parameters) > 3;
						my $pp5 = $parameters[4] if length(@parameters) > 4;
						my $pp6 = $parameters[5] if length(@parameters) > 5;
						
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
	
						my $result = saveEntity($currentProperty, $projectId, $newEType, $newEName, $pp1, $pp2, $pp3, $pp4, $pp5, $pp6);
						
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

	return $returnValue;	
}

#################################################
#
# Function: listFiles
#
# Description:
# 	Function returns list of files
#
# Parameters:
#	Source folder which should be read
#
#################################################

sub listFiles
{
    my $path = $_[0];

	opendir my($dh), $path or die "Couldn't open dir '$path': $!";
	my @files = grep { !/^\.?$/ && !/^\.(.*)$/ || /^\.\.$/} readdir $dh;
	closedir $dh;
	
    return @files;
}

#################################################
#
# Function: checkPattern
#
# Description:
# 	Function checks value against pattern
#
# Parameters:
#	value, allowedPattern
#
#################################################

sub checkPattern
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


#################################################
#
# Main program
#
#################################################

my $pwd = cwd();

my $query = new CGI;

my $action = $query->param("performAction");

#################################################
# User wants to read content of file
#################################################
if ($action eq "readFile")
{
	my $projectId  = $query->param("pId");
	my $entityType = $query->param("eType");
	my $entityName = $query->param("eName");
	my $p1         = $query->param("\$1");
	my $p2         = $query->param("\$2");
	my $p3         = $query->param("\$3");
	my $p4         = $query->param("\$4");
	my $p5         = $query->param("\$5");
	my $p6         = $query->param("\$6");

	my $txt = EntityTools::readEntityFile($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
		
	print $query->header();
	print $txt;
}

#################################################
# User wants to write content to a file
#################################################
if ($action eq "writeFile")
{
	my $projectId  = $query->param("pId");
	my $entityType = $query->param("eType");
	my $entityName = $query->param("eName");
	my $p1         = $query->param("\$1");
	my $p2         = $query->param("\$2");
	my $p3         = $query->param("\$3");
	my $p4         = $query->param("\$4");
	my $p5         = $query->param("\$5");
	my $p6         = $query->param("\$6");

	my $txt        = uri_unescape($query->param("text"));

	EntityTools::writeEntityFile($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6, $txt);
		
	print $query->header();
}

#################################################
# User wants to get files information 
#################################################
if ($action eq "getFileInfo")
{
	my $folder      = $query->param("folder");
	my $currentPath = $query->param("currentpath");
	my $absPath     = $query->param("absPath");
	my $rootFolder  = $query->param("rootFolder");
	
	if ($currentPath eq "")
	{
		$currentPath = $pwd;
	}
	
	$folder = uri_unescape ($folder);
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
	
	my @files = listFiles($path . "/");
	
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
	}
	
	print $query->header();
	print $fileList;
}

#################################################
# User wants to create folder
#################################################
if ($action eq "createFolder")
{
	my $currentFolder = $query->param("currentFolder");
	my $folderName    = $query->param("folderName");
	
	my $folderPath = uri_unescape($currentFolder) . "/" . uri_unescape($folderName);
		
	make_path("$folderPath") unless -e $folderPath;

	print $query->header();
}

#################################################
# User wants to delete file
#################################################
if ($action eq "deleteFile")
{
	my $filename    = $query->param("filename");
	
	$filename = uri_unescape($filename);
	
	if (-d $filename)
	{
		rmtree($filename);
	}	
	else
	{
		unlink($filename);
	}

	print $query->header();
}

#################################################
# User wants to paste copied file
#################################################
if ($action eq "pasteFile")
{
	my $filename    = $query->param("filename");
	my $destination = $query->param("destination");
	my $cutFlag     = $query->param("cutFlag");
	
	$filename     = uri_unescape($filename);
	$destination  = uri_unescape($destination);

	if ($cutFlag eq "1")	
	{
		move($filename, $destination);
	}
	else
	{
		copy($filename, $destination);		
	}

	print $query->header();
}

#################################################
# User wants to upload file with File Manager
#################################################
if ($action eq "uploadFile")
{
	my @fileHandleList = $query->upload('files');
	my $uploadFolder   = $query->param('uploadFolder');
	
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
		}
	}

	print $query->header();
}

#################################################
# User wants to upload file
#################################################
if ($action eq "uploadFile2")
{
	my $filesId = $query->param("filesId");
	my @fileHandleList = $query->upload($filesId);

	my $projectId  = $query->param("pId");
	my $entityType = $query->param("eType");
	my $entityName = $query->param("eName");
	my $p1         = $query->param("\$1");
	my $p2         = $query->param("\$2");
	my $p3         = $query->param("\$3");
	my $p4         = $query->param("\$4");
	my $p5         = $query->param("\$5");
	my $p6         = $query->param("\$6");

	my $projectsRootPath = EntityTools::getProjectRootPath($projectId);

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
		}
	}

	print $query->header();
}

#################################################
# User wants to get files information 
#################################################
if ($action eq "validateField")
{
	my $p1 = $query->param("value");
	my $p2 = $query->param("pattern");
	
	my $txt = checkPattern($p1, $p2);
	
	print $query->header();
	print $txt;
}


#################################################
# User wants to save edited entity 
#################################################
if ($action eq "saveEntity")
{
	print $query->header();

	my( $name, $value );

#	foreach $name ( $query->param )
#	{
#		print "$name=\"";
#    	foreach $value ( $query->param( $name ) )
#    	{
#        	print "$value";
#    	}
#		print "\" ";
#	}
	
	my $projectId  = $query->param("pId");
	my $entityType = $query->param("eType");
	my $entityName = $query->param("eName");
	my $p1         = $query->param("p1");
	my $p2         = $query->param("p2");
	my $p3         = $query->param("p3");
	my $p4         = $query->param("p4");
	my $p5         = $query->param("p5");
	my $p6         = $query->param("p6");

	my %entityValues;
	
	foreach $name ( $query->param )
	{
		my $value = $query->param($name);

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
		}
		
		$parentId = "";
		$parentId   = $parentIds[$#parentIds];
		
		$id         = $tokens[$#tokens - 2];
		$entityType = $tokens[$#tokens - 1];
		$property   = $tokens[$#tokens];
		
		if (length($parentId) == 0)
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

		my %row_data;

		$row_data{VALUE}       = $value;
		$row_data{PROPERTY}    = $property;

		my %parentItem = %entityValues;
		
		my $currentId = "";
		
		my %parents;

		$parents{''} = \%entityValues;
		
		for my $index (0..$#parentIds)
		{
			$currentId = $parentIds[$index];
				
			my %properties = %{$parentItem{PROPERTIES}};
			%parentItem = %{$properties{$currentId}};

			my %hren = %parentItem;
			
			$parents{$currentId} = \%hren;
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

	my $result = saveEntity(\%entityValues, $projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	
	my $txt = $result ? "1" : "0";

#	print $query->header();
	print $txt;
}

#################################################
# User wants to add entity
#################################################
if ($action eq "addEntity")
{
	my $projectId  = $query->param("pId");
	my $entityType = $query->param("eType");
	my $entityName = $query->param("eName");
	my $p1         = $query->param("p1");
	my $p2         = $query->param("p2");
	my $p3         = $query->param("p3");
	my $p4         = $query->param("p4");
	my $p5         = $query->param("p5");
	my $p6         = $query->param("p6");
	
	my $newId      = $query->param("elId");
	my $entity     = $query->param("entity");
	my $property           = $query->param("property");
	my $entityArrayValueId = $query->param("entityArrayValueId");
	my $parentItemIndex    = $query->param("parentItemIndex");

	my $entityFilename = EntityTools::getEntityFilename   ($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
	my $data           = EntityTools::createEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p3, $p4, $p5, $p6);
		
	JsonHelper::writeJSONFile($entityFilename, $data);	

	my $filename = EntityTools::getProjectRootPath($projectId) . "/conf/Entity2Row.html"; 
	my $template = HTML::Template->new(filename => $filename, loop_context_vars => 1, die_on_bad_params => 0);

	my $entityData = EntityTools::getEntityData($projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6);

	my ($maxIndex, @loop_data) = EntityTools::listEntitySettings($projectId, $entityType, $entityName, $p1, $p2, $p4, $p4, $p5, $p6, $newId, "1");

	$template->param(ENTTITY_ARRAY_VALUE_ID => $entityArrayValueId);
	$template->param(KEY_DESCRIPTION => "Novi element");
	$template->param(PARENT_INDEX => $parentItemIndex);
	$template->param(ELEMENT_ID => $newId . "_" . $entity . "_" . $property);
	$template->param(KEY => $property);
	$template->param(VALUE => $entityName);
	$template->param(ENTITIES => \@loop_data);
	
	# Send HTML to the browser.
	my $txt = $template->output();

	print $query->header();
	print $txt;
}

#################################################
# User wants to delete project
#################################################
if ($action eq "deleteProject")
{
	my $projectId  = $query->param("pId");
	my $entityName = $query->param("eName");

	EntityTools::deleteProject($projectId, $entityName);

	print $query->header();
}

1;