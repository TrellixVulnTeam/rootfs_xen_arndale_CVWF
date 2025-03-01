package Net::DNS::Resolver::os2;

#
# $Id: os2.pm 1225 2014-07-01 19:38:51Z willem $
#
use vars qw($VERSION);
$VERSION = (qw$LastChangedRevision: 1225 $)[1];

=head1 NAME

Net::DNS::Resolver::os2 - OS2 Resolver Class

=cut


use strict;
use base qw(Net::DNS::Resolver::Base);


my $etc		= $ENV{ETC} || '/etc';
my $resolv_conf = "$etc/resolv";
my $dotfile	= '.resolv.conf';

my @config_path;
push( @config_path, $ENV{HOME} ) if exists $ENV{HOME};
push( @config_path, '.' );


sub init {
	my ($class) = @_;

	$class->read_config_file($resolv_conf) if -f $resolv_conf && -r _;

	foreach my $dir (@config_path) {
		my $file = "$dir/$dotfile";
		$class->read_config_file($file) if -f $file && -r _ && -o _;
	}

	$class->read_env;
}


1;
__END__


=head1 SYNOPSIS

    use Net::DNS::Resolver;

=head1 DESCRIPTION

This class implements the OS specific portions of C<Net::DNS::Resolver>.

No user serviceable parts inside, see L<Net::DNS::Resolver|Net::DNS::Resolver>
for all your resolving needs.

=head1 COPYRIGHT

Copyright (c) 1997-2002 Michael Fuhr.

All rights reserved.  This program is free software; you may redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<perl>, L<Net::DNS>, L<Net::DNS::Resolver>

=cut
