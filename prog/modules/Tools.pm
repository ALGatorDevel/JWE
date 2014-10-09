# Tools.pm
package Tools;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

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

sub readFileArray {
	
	my $filename = $_[0];

	my $retValue = "";

	# Read in the HTML template file.
	open (HTMLFILE, "<$filename");
	my @inputLines = <HTMLFILE>;
	close HTMLFILE;

	return @inputLines;
}

sub writeFile {
	
	my $filename = $_[0];
	my $txt = $_[1];

	my $retValue = "";

	open (HTMLFILE, ">$filename");

	printf HTMLFILE $txt;

	close HTMLFILE;

	return $retValue;
}

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