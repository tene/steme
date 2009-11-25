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

Creates the Steme compiler using a C<HLL::Compiler>
object.

=cut

.HLL 'steme'

.namespace []

.loadlib 'steme_group'

.sub '' :anon :load :init
    load_bytecode 'PCT.pbc'
    load_bytecode 'P6Regex.pbc'
    .local pmc parrotns, hllns, exports
    parrotns = get_root_namespace ['parrot']
    hllns = get_hll_namespace
    exports = split ' ', 'PAST PCT HLL'
    parrotns.'export_to'(hllns, exports)
    .local pmc regexns
    regexns = hllns.'make_namespace'('Regex')
    $P0 = get_root_namespace ['parrot';'Regex';'Cursor']
    regexns.'add_namespace'('Cursor', $P0)
    $P0 = get_root_global ['parrot';'Regex'], 'Cursor'
    regexns['Cursor'] = $P0
    $P0 = get_root_namespace ['parrot';'Regex';'Match']
    regexns.'add_namespace'('Match', $P0)
    $P0 = get_root_global ['parrot';'Regex'], 'Match'
    regexns['Match'] = $P0
    $P0 = get_root_namespace ['parrot';'Regex';'P6Regex']
    regexns.'add_namespace'('P6Regex', $P0)
    $P0 = get_root_global ['parrot';'Regex'], 'P6Regex'
    regexns['P6Regex'] = $P0
.end

.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'

.namespace [ 'Steme';'Compiler' ]
.sub 'onload' :anon :load :init
    .local pmc steme
    $P0 = get_root_global ['parrot'], 'P6metaclass'
    steme = $P0.'new_class'('Steme::Compiler', 'parent'=>'HLL::Compiler')
    steme.'language'('steme')
    $P0 = get_hll_global ['Steme'], 'Grammar'
    steme.'parsegrammar'($P0)
    $P0 = get_hll_global ['Steme';'Grammar'], 'Actions'
    steme.'parseactions'($P0)
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

.sub 'load_library' :method
    .param pmc ns
    .param pmc extra :named :slurpy
    .local pmc sourcens, ex, library
    .local string file, lang
    file = join '/', ns
    file = concat file, '.scm'
    # TODO We need a registry to prevent re-loading
    # TODO We need a search path
    self.'evalfiles'(file, 'encoding'=>'utf8', 'transcode'=>'ascii iso-8859-1')

    library = root_new ['parrot';'Hash']
    sourcens = get_hll_namespace ns
    library['name'] = ns
    library['namespace'] = sourcens
    $P0 = root_new ['parrot';'Hash']
    $P0['ALL'] = sourcens
    ex = sourcens['@EXPORTS']
    if null ex goto no_ex
    $P1 = root_new ['parrot';'NameSpace']
    sourcens.'export_to'($P1, ex)
    $P0['DEFAULT'] = $P1
    goto have_ex
  no_ex:
    $P0['DEFAULT'] = sourcens
  have_ex:
    library['symbols'] = $P0
    .return (library)
.end

.namespace []
.include 'src/gen_builtins.pir'

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

