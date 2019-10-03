(define (install-division-package)

	; Hierarchy Of Types
	
	(define types '(
		(organization) 
		(division) 
		(emp-record) 
		(attr)))
	
	; selectors for constructors
	
	(define associate cons)
	
	(define wrap list)
	
	; constructors
		
	(define (make-organization identifier . divisions) (associate identifier divisions)) ; organization is the highest data strucutre, no need to have organizations
	; (organization 'identifier' (list of divisions))
	
	(define (make-division identifier . records) (associate identifier records)) ; divisions are a personel file, (division 'identifier' (list of emp-records))

	(define (make-emp-record identifier . attrs) (associate identifier attrs)) ; (emp-record 'identifier' (list of attrs))

	(define (make-attr identifier attr-value) (wrap identifier attr-value)) ; (attr ('identifier' attr-value))
	
	; predicates
	
	(define (coercion? type container-type)
		(<= (index-of types container-type) (index-of types type)))
	
	(define (of-requested-type? type container-type)
		(equal? type container-type))
		
	(define (one-item? container)
		(equal? (length container) 3)) ; (data-object identifier data) we only have one data item of the data-object
	
	; selectors
	
	(define get-identifier cadr)
	
	(define type-tag car)
	
	(define sub-type-contents caddr)
	
	; TODO ADD TRANSFORM FUNC FOR OTHERS TO USE?
			   
			   
	(define (get-generic type-desired container identifier) ; container should be of a specfic data object type, so all divisions, emp-records, or attributes
		(cond  ((not (coercion? type-desired (type-tag container))) (error "Cannot perform coercion on container passed in -- " (type-tag container)))
			   ((not (of-requested-type? type-desired (type-tag container))) (apply append (map (lambda (datum) (get-generic type-desired datum identifier)) (sub-type-contents container))))
			   (else (find identifier container))))
			   
	
	; utility
	
	(define (index-of lst x)
		(define (index-of-helper lst count)
			(cond ((null? lst) -1)
				  ((equal? (car lst) (list x)) count) ; all types are in braces e.g. (organization)
				  (else (index-of-helper (cdr lst) (+ 1 count)))))
	  (index-of-helper lst 0))
	
	(define (find identifier container-row)
		(if (equal? identifier (get-identifier container-row))
			(list container-row)
			'()))
			  
	(trace coercion?)
	(trace index-of)
	
	;; interface to rest of the system
	(define (tag type e) (attach-tag type e))
	(put 'make '(organization)
		(lambda (identifier . divisions) (tag 'organization (make-organization identifier divisions))))
	(put 'get-data '(organization)
		(lambda (organization identifier) (get-generic 'organization organization identifier)))
	(put 'make '(division)
		(lambda (identifier . emp-records) (tag 'division (make-division identifier emp-records))))
	(put 'get-data '(division)
		(lambda (division identifier) (get-generic 'division division identifier)))
	(put 'make '(emp-record)
		(lambda (identifier . emp-attrs) (tag 'emp-record (make-emp-record identifier emp-attrs))))
	(put 'get-data '(emp-record)
		(lambda (emp-record identifier) (get-generic 'emp-record emp-record identifier)))
	(put 'make '(attr)
		(lambda (identifier attr-value) (tag 'attr (make-attr identifier attr-value))))
	(put 'get-data '(attr)
		(lambda (identifier value) (get-generic 'attr identifier value)))
'done)

; package install
(install-division-package)

; interface procedures

(define (make-organization-data type-desired data identifier)
	(let ((func (get 'make (append (list type-desired) '()))))
		(if func
			(func identifier data)
			(error "Unknown type-desired -- make-organization-data: " type-desired))))

;a
(define (get-record type-desired data identifier)
	(let ((func (get 'get-data (append (list type-desired) '()))))
		(if func
			(func data identifier)
			(error "Unknown type of record to get -- get-record: " type-desired))))
			
;b			
(define (get-salary emp div)
		(get-record 
			'attr 
			(car (get-record 'emp-record div emp))
			'salary))
;c			
(define (find-employee-record emp org)
		(get-record 'emp-record org emp))
	
	
;d
;The only change to be made, will be that the new company will need to be added as a new division to Insatiable

;;;;;;;;

(define attr1 ((get 'make '(attr)) 'Salary '50000))
(define attr2 ((get 'make '(attr)) 'Address '(298 Smith Road)))

(define emp-record ((get 'make '(emp-record)) 'Conner attr1 attr2))

(define attr3 ((get 'make '(attr)) 'Salary '70000))
(define attr4 ((get 'make '(attr)) 'Address '(123 Bob Road)))

(define emp2-record ((get 'make '(emp-record)) 'William attr3 attr4))

(define division ((get 'make '(division)) 'Alpha emp-record emp2-record))

(define org ((get 'make '(organization)) 'the-cool-guys division))
