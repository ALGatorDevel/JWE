# JsonHelper.pm
package JsonHelper;

use JSON::PP;

use CGI;
use CGI::Carp qw ( fatalsToBrowser );

use File::Path qw(make_path);
use File::Basename;

sub readJSONFile
{
    my $filename = $_[0];
	my $data;
	
	if (open (my $json_stream, $filename))
	{
	      local $/ = undef;
	      my $json = JSON::PP->new;
	      $data = $json->decode(<$json_stream>);
	      close($json_stream);
	}
	
	return $data;
}

sub writeJSONFile
{
	my $returnValue = 1;
	
    my $filename = $_[0];
	my $data = $_[1];
	
	my $json = JSON::PP->new->pretty;

	my $dirname = dirname($filename);

	make_path("$dirname") unless -e $dirname;
	
	open my $fh, ">", "$filename";
	$returnValue = print $fh $json->encode($data);
	close $fh;
	
	return $returnValue;
}

sub expandJSONVariable {
	
	my $data = $_[0];
    my $variableClass = $_[1];
    my $variable = $_[2];

	my $retValue = $data->{$variableClass}->{$variable};
	
	my $guard = 30;
	
	# expand variable
	
	while (($guard > 0) && ($retValue =~ /\$/))
	{
		if ($retValue =~ /\$([\d\w]+)/)
		{
			my $tokenToBeReplaced = $1;
			my $newToken = $data->{$variableClass}->{$tokenToBeReplaced};
			
			$retValue =~ s/(\$[\d\w]+)/$newToken/;
		}
		
		$guard --;
	}
		
	return $retValue;
}

sub expandJSONVariableNoClass {
	
	my $data = $_[0];
    my $variable = $_[1];

	my $retValue = $data->{$variable};
	
	my $guard = 30;
	
	# expand variable
	
#	while (($guard > 0) && ($retValue =~ /\$/))
#	{
#		if ($retValue =~ /\$([\d\w]+)/)
#		{
#			my $tokenToBeReplaced = $1;
#			my $newToken = $data->{$tokenToBeReplaced};
#			
#			$retValue =~ s/(\$[\d\w]+)/$newToken/;
#		}
#		
#		$guard --;
#	}
		
	return $retValue;
}

sub getValueFromJSONFile {
	
    my $filename = $_[0];
    my $variableClass = $_[1];
    my $variable = $_[2];

	my $data = readJSONFile($filename);
	
	# expand variable
	my $retValue = expandJSONVariable($data, $variableClass, $variable);
	
	return $retValue;
}

sub getValueFromJSONFileNoClass {
	
    my $filename = $_[0];
    my $variable = $_[1];

	my $data = readJSONFile($filename);
	
	# expand variable
	my $retValue = expandJSONVariableNoClass($data, $variable);
	
	return $retValue;
}

1;