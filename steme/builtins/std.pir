.sub list
    .param pmc l :slurpy
    .return (l)
.end

.sub dump
    .param pmc a
    .local pmc d
    load_bytecode 'dumper.pbc'
    d = get_root_global ['parrot'], '_dumper'
    d(a)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
