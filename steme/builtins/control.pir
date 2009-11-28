# $Id$

=head1

control.pir -- basic flow control

=cut

.namespace []

.sub 'sleep'
    .param num t
    .local num before, after
    before = time
    sleep t
    after = time
    $N0 = after - before
    .return ($N0)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

