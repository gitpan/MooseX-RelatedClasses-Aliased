use Test::More;

BEGIN {
	package Local::ABC;
	use Moose;
};

BEGIN {
	package My::Framework;
	use Moose;
	use MooseX::RelatedClasses::Aliased {
		name => 'Thinger',
	};
	sub xyz {
		Thinger->new;
	}
};

my $obj = My::Framework->new( thinger_class => 'Local::ABC' );

is($obj->thinger_class, 'Local::ABC');
isa_ok($obj->xyz, 'Local::ABC');

done_testing;
