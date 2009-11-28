# $Id$

=head1

cmp.pir -- simple implementation of comparison functions

=cut

.namespace []

.sub '='
    .param pmc a
    .param pmc b
    eq a, b, true
    .return (0)
  true:
    .return (1)
.end

.sub '<'
    .param pmc a
    .param pmc b
    lt a, b, true
    .return (0)
  true:
    .return (1)
.end

.sub '>'
    .param pmc a
    .param pmc b
    gt a, b, true
    .return (0)
  true:
    .return (1)
.end

.sub '<='
    .param pmc a
    .param pmc b
    le a, b, true
    .return (0)
  true:
    .return (1)
.end

.sub '>='
    .param pmc a
    .param pmc b
    ge a, b, true
    .return (0)
  true:
    .return (1)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

