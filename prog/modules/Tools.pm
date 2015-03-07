# Tools.pm
package Tools;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use DateTime;

use MIME::Base64;

my $LOG_TO_FILE = 0;

my $currentLevel = 0;

# ----------------------------------------------
# Function: Log
#
# Description:
# Function writes message to log file
# ----------------------------------------------

sub Log
{
	if ($LOG_TO_FILE == 0)
	{
		return;
	}
	
	my $dt1 = DateTime->now();
	
	my $message = $_[0];

	my $filename = 'report.txt';
			
	open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";

	my $indentMessage = "    ";
	
	my $i = 0;
	
	while ($i < $currentLevel)
	{
		$indentMessage = $indentMessage . "    ";
		$i = $i + 1;
	}
				
	print $fh $dt1->datetime() . "$indentMessage$message\n";

	close $fh;
} 
 
# ----------------------------------------------
# Function: LogEnterFunction
#
# Description:
# Function increases call log level
# ----------------------------------------------

sub LogEnterFunction
{
	my $message = $_[0];

	Log(" ");
	Log("====> $message");

	$currentLevel = $currentLevel + 1;
} 
 
# ----------------------------------------------
# Function: LogExitFunction
#
# Description:
# Function increases call log level
# ----------------------------------------------

sub LogExitFunction
{
	my $message = $_[0];

	if ($currentLevel > 0)
	{
		$currentLevel = $currentLevel - 1;
	}

	Log("<==== $message");
} 
 
# ----------------------------------------------
# Function:
#
# Description:
# 
# ----------------------------------------------

sub readFile {
	
	my $filename = $_[0];

	my $retValue = "";

	# Read in the HTML template file.
	open (HTMLFILE, "<$filename");
	my @inputLines = <HTMLFILE>;
	close HTMLFILE;

	foreach (@inputLines)
	{
	    $retValue .= $_;
	}
	
	return $retValue;
}

# ----------------------------------------------
# Function:
#
# Description:
# 
# ----------------------------------------------

sub readFileArray {
	
	my $filename = $_[0];

	my $retValue = "";

	# Read in the HTML template file.
	open (HTMLFILE, "<$filename");
	my @inputLines = <HTMLFILE>;
	close HTMLFILE;

	return @inputLines;
}

# ----------------------------------------------
# Function:
#
# Description:
# 
# ----------------------------------------------

sub writeFile {
	
	my $filename = $_[0];
	my $txt = $_[1];

	my $retValue = "";

	open (HTMLFILE, ">$filename");

	printf HTMLFILE $txt;

	close HTMLFILE;

	return $retValue;
}

# ----------------------------------------------
# Function:
#
# Description:
# 
# ----------------------------------------------

sub checkCredentials {
	
	my ($user, $pass) = (@_);

	my $sessionId = -1;
	
	if (!defined($user))
	{
		return $sessionId;
	}
	
	if (!defined($pass))
	{
		return $sessionId;
	}
	
	if ($user eq "marko") {

		$sessionId = 1;
	}

    return $sessionId;
}

# ----------------------------------------------
# Function:
#
# Description:
# 
# ----------------------------------------------

sub checkSessionId {
	
    my $sessionId = $_[0];

	my $status = 0;

	if (!defined($sessionId))
	{
		return $status;
	}

	if ($sessionId eq "1") 
	{
		$status = 1;
	}
	
    return $status;
}


# ----------------------------------------------
# Function: encodeURL
# Parameters: projectID, entityType, propertyName, and optional $1, $2, $3, ... $6 
#
# Description: Creates and encodes URL string with required parameters  
# 
# ----------------------------------------------

sub getJWELink {
  my $projectId         = $_[0];
  my $propertyEType     = $_[1];
  my $currentEntityName = $_[2];

  my ($pp1, $pp2, $pp3, $pp4, $pp5, $pp6);

  $pp1 = $_[3];
  $pp2 = $_[4];
  $pp3 = $_[5];
  $pp4 = $_[6];
  $pp5 = $_[7];
  $pp6 = $_[8];
  
  my $index = $_[9];
  my $level = $_[10];
  my $ajax  = $_[11];
  

  my $tempLink = "pId=$projectId&eType=$propertyEType&eName=$currentEntityName";

  $tempLink = $tempLink . "&\$1=$pp1" if defined($pp1);
  $tempLink = $tempLink . "&\$2=$pp2" if defined($pp2);
  $tempLink = $tempLink . "&\$3=$pp3" if defined($pp3);
  $tempLink = $tempLink . "&\$4=$pp4" if defined($pp4);
  $tempLink = $tempLink . "&\$5=$pp5" if defined($pp5);
  $tempLink = $tempLink . "&\$6=$pp6" if defined($pp6);
  
  $tempLink = $tempLink . "&index=$index" if defined($index);
  $tempLink = $tempLink . "&level=$level" if defined($level);
  $tempLink = $tempLink . "&ajax=$ajax" if defined($ajax);

  $tempLink = encode_base64($tempLink);
  $tempLink =~ s/\n/NEWLINE/g;

  $tempLink =~ s/\+/WERTYYTREW/g;
  $tempLink =~ s/\//ERTYUUYTRE/g;
  $tempLink =~ s/\=/QWERTTREWQ/g;

  return $tempLink;
}

sub getParametersFromJWELink {
	my $tempString = $_[0];
	my ($pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6, $index, $level, $ajax);

    $tempString =~ s/NEWLINE/\n/g;
    $tempString =~ s/WERTYYTREW/\+/g;
	$tempString =~ s/ERTYUUYTRE/\//g;
	$tempString =~ s/QWERTTREWQ/\=/g;

	my $decoded = decode_base64($tempString);

	my @tokens = split( /\&/, $decoded );

	foreach my $token (@tokens) {
		my @tokens2 = split( /=/, $token );

		my $param = $tokens2[0];
		my $value = $tokens2[1];

		if ( lc $param eq "pid" ) {
			$pId = $value;
		}

		if ( lc $param eq "etype" ) {
			$eType = $value;
		}

		if ( lc $param eq "ename" ) {
			$eName = $value;
		}

		if ( lc $param eq "\$1" ) {
			$p1 = $value;
		}

		if ( lc $param eq "\$2" ) {
			$p2 = $value;
		}

		if ( lc $param eq "\$3" ) {
			$p3 = $value;
		}

		if ( lc $param eq "\$4" ) {
			$p4 = $value;
		}

		if ( lc $param eq "\$5" ) {
			$p5 = $value;
		}

		if ( lc $param eq "\$6" ) {
			$p6 = $value;
		}

		if ( lc $param eq "index" ) {
			$index = $value;
		}

		if ( lc $param eq "level" ) {
			$level = $value;
		}

		if ( lc $param eq "ajax" ) {
			$ajax = $value;
		}
	}
	return ($pId, $eType, $eName, $p1, $p2, $p3, $p4, $p5, $p6, $index, $level, $ajax); 	
}


1;