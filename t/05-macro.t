(say "1..2")
(define num 1)
(let ((ok (lambda (cond msg) (say (if cond 'ok ' 'nok ') num ' # ' msg)(define num (+ num 1)))))
(macro is
    (_ a b)
    "make PAST::Op.new(:pasttype('call'), :name('ok'),
        PAST::Op.new(:pasttype('call'), :name('='),
        $<a>.ast, $<b>.ast),
        PAST::Val.new( :returns('String'), :value('Got ' ~ $<b> ~ ' from ' ~ $<a> ))
    );"
    )
    (is 1 1)
    (is (+ 1 1) 2)
)

;Expected Output
;
; 1..2
; ok 1 # Got 1 from 1
; ok 2 # Got 2 from (+ 1 1)
