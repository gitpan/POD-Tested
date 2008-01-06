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
use Directory::Scratch ;


{
local $Plan = {'input through file' => 2} ;

throws_ok
	{
	my $parser = POD::Tested->new(FILE_HANDLE => undef);
	}
	qr/Expecting input data through argument 'STRING', 'FILE' or 'FILE_HANDLE'/, 'invalid file handle' ;

throws_ok
	{
	my $parser = POD::Tested->new();
	}
	qr/Expecting input data through argument 'STRING', 'FILE' or 'FILE_HANDLE'/, 'missing source' ;

}

{
local $Plan = {'print coverage' => 1} ;

use IO::File;

my $current_fh = select ;

my $fh = new IO::File; # not opened
select $fh ;

throws_ok
	{
	warning_is
		{
		POD::Tested::OutputStrings('test') ;
		}
		qr/print() on unopened filehandle/, 'unopen filehandle' ;
	}
	qr/Bad file descriptor/, 'print failed' ;
	
select $current_fh ;
}
