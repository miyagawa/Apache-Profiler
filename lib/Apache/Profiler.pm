package Apache::Profiler;

use strict;
use vars qw($VERSION);
$VERSION = 0.01;

use Apache::Log;
use Time::HiRes qw(gettimeofday);

sub handler {
    my $r = shift;
    $r->pnotes(ap_start_time => scalar gettimeofday());
    $r->register_cleanup(\&compute);
}

sub compute {
    my $r = shift;
    my $now = gettimeofday();
    my $diff = $now - $r->pnotes('ap_start_time');

    my $threshold = $r->dir_config('ProfileLongerThan') || 0;
    if ($diff >= $threshold) {
	my $uri = $r->uri;
	my $query = $r->query_string;
	if ($query) { $uri .= "?$query" }
	$r->log->notice("uri: $uri takes $diff seconds");
    }
}

1;
__END__

=head1 NAME

Apache::Profiler - profiles time needed for one request

=head1 SYNOPSIS

  <Location /cgi-bin>
  PerlInitHandler Apache::Profiler
  </Location>

=head1 DESCRIPTION

Apache::Profiler is a mod_perl init (and cleanup) handler to profile
time taken to process one request to the Apache Log file. It'd be
useful to profile some heavy application taking a long time to proceed.

It uses L<Time::HiRes> to take millisecond, and outputs profiled data
as Apache log C<notice> level.

=head1 CONFIGURATION

=over 4

=item ProfileLongerThan

  PerlSetVar ProfileLongerThan 0.5

specifies lower limit of request time taken to profile. This example
only logs requests which takes longer than 0.5 seconds. This value is
set to 0 by default, which means it logs every requests.

=head1 TODO

=over 4

=item *

customizable log format (exportable to some profiling tools)

=item *

profiles CPU time rather than C<gettimeofday>

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Apache::Log>

=cut
