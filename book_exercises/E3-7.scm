(define (make-account password balance)
	(define times-accessed 0)
	(define call-the-cops (lambda () "bee-doo bee-doo!"))
	(define (withdraw amount)
		(if (>= balance amount)
			(begin 
			(set! times-accessed 0)
			(set! balance (- balance amount))
				balance)
			"Insufficient funds"))
	(define (deposit amount)
		(set! times-accessed 0)
		(set! balance (+ balance amount))
			balance)
	(define (dispatch dispatch-password m)
		(cond ((equal? dispatch-password password)
				(cond ((eq? m 'withdraw) withdraw)
					  ((eq? m 'deposit) deposit)
					  (else (error "Unknown request: MAKE-ACCOUNT" m))))
			  ((>= times-accessed 7) (call-the-cops))
			  (else 
				(begin 
					(set! times-accessed (+ times-accessed 1))
					(error "Incorrect Password -- " dispatch-password)))))
	dispatch)

(define (make-join acc password new-password)
	(define (dispatch dispatch-password m)
		(if (or (equal? dispatch-password new-password)
				(equal? dispatch-password password))
			(acc password m)
			(error "Incorrect Password -- " dispatch-password)))
	dispatch)