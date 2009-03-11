=head1 TITLE

steme.pir - A Steme compiler.

=head2 Description

This is the base file for the Steme compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PGE libraries,
and registers the compiler under the name 'Steme'.

=head2 Functions

=over 4

=item onload()

Creates the Steme compiler using a C<PCT::HLLCompiler>
object.

=cut

.namespace [ 'Steme::Compiler' ]

#.loadlib 'steme_group'

.sub 'onload' :anon :load :init
    load_bytecode 'PCT.pbc'

    $P0 = get_hll_global ['PCT'], 'HLLCompiler'
    $P1 = $P0.'new'()
    $P1.'language'('Steme')
    $P1.'parsegrammar'('Steme::Grammar')
    $P1.'parseactions'('Steme::Grammar::Actions')
.end

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the Steme compiler.

=cut

.sub 'main' :main
    .param pmc args

    $P0 = compreg 'Steme'
    $P1 = $P0.'command_line'(args)
.end

.include 'src/gen_builtins.pir'
.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

