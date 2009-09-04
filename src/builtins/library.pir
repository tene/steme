# $Id$

=head1

library.pir -- library functions

=cut

.namespace []

.sub 'export'
    .param pmc sym
    .local pmc ns, ex
    $P0 = getinterp
    ns = $P0['namespace';1]
    ex = ns['@EXPORTS']
    unless null ex goto have_ex
    ex = root_new ['parrot';'ResizablePMCArray']
  have_ex:
    ex.'push'(sym)
    ns['@EXPORTS'] = ex
    .return ()
.end

.sub 'import'
    .param pmc ns :slurpy
    .param pmc hll :named('hll') :optional
    .param pmc has_hll :opt_flag
    .local pmc compiler, targetns, symbols, nsiter, library
    .local string lang
    lang = 'steme'
    if null hll goto no_hll
    lang = hll
    compiler = compreg lang
    unless null compiler goto have_compiler
    'load_language'(lang)
  no_hll:
    compiler = compreg lang
  have_compiler:
    library = compiler.'load_library'(ns)

    $P0 = getinterp
    targetns = $P0['namespace';1]
    $P0 = library['symbols']
    symbols = $P0['DEFAULT']
    nsiter = iter symbols
  import_loop:
    unless nsiter goto import_loop_end
    $S0 = shift nsiter
    $P0 = symbols[$S0]
    targetns[$S0] = $P0
    goto import_loop
  import_loop_end:
    .return ()
.end


.HLL 'parrot'   # work around a parrot bug
.sub 'load_language'
    .param string lang
    load_language lang
.end

.HLL 'steme'
# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

