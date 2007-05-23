# test

use strict ;
use warnings ;

use Data::TreeDumper ;

use Test::Exception ;
use Test::Warn;
use Test::NoWarnings qw(had_no_warnings);

use Test::More 'no_plan';
use Test::Block qw($Plan);

use POD::Tested ; 
use IO::String;

{
local $Plan = {'real empty POD' => 1} ;

my $parser = POD::Tested->new();

my $io = IO::String->new('') ;	

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<"EOE" ;


=cut
EOE

is($parsed_text,$expected_text, 'real empty POD') ;
}

{
local $Plan = {'empty POD' => 1} ;

my $parser = POD::Tested->new();

my $io = IO::String->new(<<"EOT") ;	

EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<"EOE" ;


=cut
EOE

is($parsed_text,$expected_text, 'empty POD') ;
}

{
local $Plan = {'heads POD' => 1} ;

my $parser = POD::Tested->new();

my $io = IO::String->new(<<"EOT") ;
=head1 HEAD1

=head2 HEAD2

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<"EOE" ;
=head1 HEAD1

=head2 HEAD2

=cut
EOE

is($parsed_text,$expected_text, 'heads POD') ;
}

{
local $Plan = {'text POD' => 1} ;

my $parser = POD::Tested->new();

my $io = IO::String->new(<<"EOT") ;
=head1 HEAD1

some text

=head2 HEAD2

more text

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<"EOE" ;
=head1 HEAD1

some text

=head2 HEAD2

more text

=cut
EOE

is($parsed_text,$expected_text, 'text POD') ;
}

{
local $Plan = {'test POD' => 2} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;
=head1 HEAD1

some text

=begin common

  my $cc = 'gcc' ;

# some text
# more

  my $ar = 'ar' ;

=end common

=begin test

  is($cc,'gcc') ;

=end test

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<'EOE' ;
=head1 HEAD1

some text

  my $cc = 'gcc' ;

# some text
# more

  my $ar = 'ar' ;

=cut
EOE

is($parsed_text,$expected_text, 'test POD') ;
}

{
local $Plan = {'common POD' => 2} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;
=head1 HEAD1

some text

=begin common

  my $cc = 'gcc' ;
  is($cc,'gcc') ;

=end common

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<'EOE' ;
=head1 HEAD1

some text

  my $cc = 'gcc' ;
  is($cc,'gcc') ;

=cut
EOE

is($parsed_text,$expected_text, 'common POD') ;
}

{
local $Plan = {'generate POD' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;
=head1 HEAD1

some text

=begin common

  my $cc = 'gcc' ;

=end common

=begin test

  generate_pod("generates: '$cc'\n") ;

=end test

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<'EOE' ;
=head1 HEAD1

some text

  my $cc = 'gcc' ;

generates: 'gcc'

=cut
EOE

is($parsed_text,$expected_text, 'generate POD') ;
}

{
local $Plan = {'share variables' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;
=head1 HEAD1

some text

=begin test

  my $cc = 'gcc' ;

=end test

=begin test

  generate_pod("generates: '$cc'\n\n") ;

=end test

=begin something

something

  something

=end something

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<'EOE' ;
=head1 HEAD1

some text

generates: 'gcc'

=begin something

something

  something

=end something

=cut
EOE

is($parsed_text,$expected_text, 'share variables') ;
}

{
local $Plan = {'verbose' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new(VERBOSE => 1);

my $io = IO::String->new(<<'EOT') ;
=head1 HEAD1

some text

=begin test

  my $cc = 'gcc' ;

=end test

=begin test

  generate_pod("generates: '$cc'\n\n") ;

=end test

=begin something

=end something

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<'EOE' ;
=head1 HEAD1

some text

generates: 'gcc'

=begin something

=end something

=cut
EOE

is($parsed_text,$expected_text, 'verbose does not affect generated POD') ;
}

{
local $Plan = {'for' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;
=head1 HEAD1

some text

=for something ignored

=for POD::Tested reset

=cut
EOT

$parser->parse_from_filehandle($io) ;	
my $parsed_text = $parser->GetPOD() ;

my $expected_text = <<'EOE' ;
=head1 HEAD1

some text

=for something ignored

=cut
EOE

is($parsed_text,$expected_text, 'for') ;
}

{
local $Plan = {'compile error' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;

=begin test

$a = ;

=end test

EOT

throws_ok
	{
	$parser->parse_from_filehandle($io) ;
	}
	qr/syntax error at/, 'compile error' ;
}

{
local $Plan = {'run time error' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;

=begin test

sub div_by_zero { my $a = 1; $a/0} ;

=end test

=begin test

div_by_zero() ;

=end test

EOT

throws_ok
	{
	$parser->parse_from_filehandle($io) ;
	}
	qr/Illegal division by zero/, 'run time error' ;
}

{
local $Plan = {'no error' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;

=begin test

  $a = 1 ;


  $b = '2' ;

=end test

EOT

lives_ok
	{
	$parser->parse_from_filehandle($io) ;
	} 'no syntax error' ;
}

{
local $Plan = {'no error' => 1} ; # the one in this test plust the one in the POD

my $parser = POD::Tested->new();

my $io = IO::String->new(<<'EOT') ;

=begin common

#something

  $a = 1 ;

=end common 

=begin test

#something

  $b = '2' ;

=end test

EOT

lives_ok
	{
	$parser->parse_from_filehandle($io) ;
	} 'no syntax error' ;
}
