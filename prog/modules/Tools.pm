# Tools.pm
package Tools;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use DateTime;

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

1;