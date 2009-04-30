; This just checks that the basic parsing and call to builtin say works.
(say '1..5')
(say 'ok 1')
(say 'ok ' 2)
(say 'ok' ' ' 3)
(say 'ok ' (+ 2 2))
(say 'ok ' (/ (* 2 (+ 3 2)) 2))
