
=head1 TITLE

steme.pir - A steme compiler.

=head2 Description

This is the entry point for the steme compiler.

=head2 Functions

=over 4

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the steme compiler.

=cut

.sub 'main' :main
    .param pmc args

    load_language 'steme'

    $P0 = compreg 'steme'
    $P1 = $P0.'command_line'(args)
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

