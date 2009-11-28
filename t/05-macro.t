(say "1..2")
(define num 1)
(let ((ok (lambda (cond msg) (say (if cond 'ok ' 'nok ') num ' # ' msg)(define num (+ num 1)))))
(macro is
    "<sym> <a=.item> <b=.item>"
    "make PAST::Op.new(:pasttype('call'), :name('ok'),
        PAST::Op.new(:pasttype('call'), :name('='),
        $<a>.ast, $<b>.ast),
        PAST::Val.new( :returns('String'), :value('Got ' ~ $<b> ~ ' from ' ~ $<a> ))
    );"
    )
    (is 1 1)
    (is (+ 1 1) 2)
)
