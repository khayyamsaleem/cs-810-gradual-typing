#|
	Gradual Type System
	Khayyam Saleem, Ramana Nagasamudram
|#

(load "pmatch.scm")
(load "types.scm")
(load "caster.scm")

(define initial-type-environment
  (alist->te predefined-types))

(define (system-type-environment)
  (alist->te predefined-types))

(define (should-check? expr te)
  (if (te/lookup te expr)
      #t
      (pmatch
       expr
       ((let ,body . ,rest) #f)
       ((lambda (,v . ,vs) ,body) #f)
       ((if ,p ,t ,s) #f)
       ((fn (: ,v ,t) . ,body) #t)
       ((,rator ,rand) (or (should-check? rator te)
			   (should-check? rand te)))
       ((,rator . ,rands) (or (should-check? rator te)
			      (should-check? rands te)))
       ((listof (: ,t) . ,items) #t)
       (else #f))))

(define (sc? expr te)
  (should-check? expr (alist->te te)))

(define (type-checker expr te)
  (if (should-check? expr te)
      (check expr te)
      'no-check))

;; (define (check-file filename)
;;   (let ((in (open-input-file filename)))
;;     (let loop ((n 0) (e (read in)) (te (system-type-environment)))
;;       (begin (display "Checking ") (display e) (display " in ") (display (te->alist te)) (newline))
;;       (if (eof-object? e)
;; 	  'done
;; 	  (loop (+ n 1) (read in) (te/merge (tj/te (type-checker e te)) te))))))

(define (check-file filename)
  (let ((in (open-input-file filename)))
    (let loop ((n 0) (e (read in)) (te (system-type-environment)))
      (begin (display "Checking ") (display e) (display " in ") (display (te->alist te)) (newline))
      (if (eof-object? e)
	  (list 'done n)
	  (let ((tc (type-checker e te)))
	    (if (equal? tc 'no-check)
		(loop n (read in) te)
		(loop (+ n 1) (read in) (te/merge (tj/te tc) te))))))))






