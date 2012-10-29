package MooseX::RelatedClasses::Aliased;

use 5.010;
use strict;
use warnings;

BEGIN {
	$MooseX::RelatedClasses::Aliased::AUTHORITY = 'cpan:TOBYINK';
	$MooseX::RelatedClasses::Aliased::VERSION   = '0.001';
}

use MooseX::RelatedClasses  0.001 qw( );

use Carp                    0     qw( croak );
use Devel::Caller           2.00  qw( caller_args );
use Hook::AfterRuntime      0     qw( after_runtime );
use List::MoreUtils         0     qw( uniq );
use Moose::Util             2.00  qw( apply_all_roles );
use Scalar::Util            0     qw( blessed );
use Sub::Install            0     qw( install_sub );

sub import
{
	my $caller = caller;
	my ($class, $parameters) = @_;
	
	my @names = uniq(
		grep defined,
			@{ $parameters->{names} || [] },
			$parameters->{name}
	);
	
	foreach my $name (@names)
	{
		my $method = sprintf('%s_class', lc $name);
		install_sub {
			into => $caller,
			as   => $name,
			code => sub () {
				1 if $];
				my ($self) = caller_args(1);
				blessed $self
					or croak "'$name' cannot be called outside a method";
				$self->$method;
			},
		}
	}
	
	after_runtime {
		apply_all_roles($caller, 'MooseX::RelatedClasses', $parameters);
	};
}

1;

__END__

=head1 NAME

MooseX::RelatedClasses::Aliased - sugar for MooseX::RelatedClasses

=head1 SYNOPSIS

Example from L<MooseX::RelatedClasses>...

   package My::Framework;
   use Moose;
   use namespace::autoclean;
   with 'MooseX::RelatedClasses' => {
      name => 'Thinger',
   };

Later on you'd do this:

   sub my_method {
      my $self    = shift;
      my $thinger = $self->thinger_class->new(...);
      ...;
   }

Using this module...

   package My::Framework;
   use Moose;
   use namespace::autoclean;
   use MooseX::RelatedClasses::Aliased => {
      name => 'Thinger',
   };

And:

   sub my_method {
      my $self    = shift;
      my $thinger = Thinger->new(...);
      ...;
   }

=head1 DESCRIPTION

This is the spawn on L<MooseX::RelatedClasses> and L<aliased>.
It's cute, but it relies on some pretty dodgy stuff under the hood.

This idea doesn't work very well with inheritance right now.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=MooseX-RelatedClasses-Aliased>.

=head1 SEE ALSO

L<MooseX::RelatedClasses>,
L<aliased>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

