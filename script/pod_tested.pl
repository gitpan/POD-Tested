#!/usr/bin/perl

use strict ;
use warnings ;

use Carp ;
use Data::TreeDumper ;

use POD::Tested ; 
use File::Slurp ;
use Getopt::Long ;

use vars qw ($VERSION);
$VERSION     = 0.01;

my ($output, $input, $verbose, $help) ;

if
	(
	GetOptions 
		(
		'i|input=s' => \$input,
		'o|output=s' => \$output,
		'v|verbose'  => \$verbose,
		'help'  => \$help,
		)
	)
	{
	croak GetHelp() if(defined $help || (!defined $input));
	
	$output = $input . '.tested.pod' unless defined $output ;

	my @options_to_pod_tested ;
	push @options_to_pod_tested, (VERBOSE  => $verbose) if defined $verbose ;
	
	my $parser = POD::Tested->new(@options_to_pod_tested);
	$parser->parse_from_file($input) ;	

	warn "Generating '$output'.\n" ;
	write_file($output, $parser->GetPOD()) ;
	}

#------------------------------------------------------------------------------

sub GetHelp
{
return <<'EOW' ;

Name
	pod_tested.pl
	
Synopsis
	perl pod_tested.pl -i pod_file
	
Description
	Extract POD and code and test it.
	
Options
	-i|input
	-o|output
	-v|verbose
	
Input file format

=head1 Config::Hierarchical cookbook

=begin common

  my $value = 'hi' ;
  print "value = '$value'\n" ;

=end common

Result:

=begin test

  is($value, 'hi') ;
  generate_pod("  value = '$value'\n") ;

=end test

=for POD::Tested reset

other text, including code (indented text) that is not checked

  indented pod code that is not checked

=cut

EOW
}

#------------------------------------------------------------------------------

