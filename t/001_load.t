
# test module loading

use strict ;
use warnings ;

use Test::NoWarnings ;

use Test::More qw(no_plan);

use Test::Exception ;

BEGIN { use_ok( 'POD::Tested' ) or BAIL_OUT("Can't load module"); } ;

my $object = new POD::Tested ;

is(defined $object, 1, 'default constructor') ;
isa_ok($object, 'POD::Tested');

my $new_config = $object->new() ;
is(defined $new_config, 1, 'constructed from object') ;
isa_ok($new_config , 'POD::Tested');


dies_ok
	{
	POD::Tested::new () ;
	} "invalid constructor" ;
