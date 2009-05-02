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

.HLL 'steme'

.namespace [ 'Steme';'Compiler' ]

.loadlib 'steme_group'

.sub '' :anon :load :init
    load_bytecode 'PCT.pbc'
    .local pmc parrotns, hllns, exports
    parrotns = get_root_namespace ['parrot']
    hllns = get_hll_namespace
    exports = split ' ', 'PAST PCT PGE'
    parrotns.'export_to'(hllns, exports)
.end

.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'

.sub 'onload' :anon :load :init
    $P0 = get_hll_global ['PCT'], 'HLLCompiler'
    $P1 = $P0.'new'()
    $P1.'language'('steme')
    $P0 = get_hll_namespace ['Steme';'Grammar']
    $P1.'parsegrammar'($P0)
    $P0 = get_hll_namespace ['Steme';'Grammar';'Actions']
    $P1.'parseactions'($P0)

    ## Create a list for holding the stack of nested blocks
    $P0 = new 'ResizablePMCArray'
    set_hll_global ['Steme';'Grammar';'Actions'], '@?BLOCK', $P0
.end

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the Steme compiler.

=cut

.sub 'main' :main
    .param pmc args

    $P0 = compreg 'steme'
    $P1 = $P0.'command_line'(args)
.end

.include 'src/gen_builtins.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

