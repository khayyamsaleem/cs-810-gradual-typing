;;;; pmatch : A pattern matcher written by Oleg Kiselyov.
;;;; https://www.cs.indiana.edu/l/www/classes/b521/pmatch.pdf

(define-syntax pmatch
  (syntax-rules (else guard)
    ((_ (rator rand ...) cs ...)
     ;; ensures expression to be pmatched is evaluated only once
     (let ((v (rator rand ...)))
       (pmatch v cs ...)))	     
    ((_ v) (error 'pmatch "failed: ~s" v))
    ((_ v (else e0 e ...)) (begin e0 e ...))
    ((_ v (pat (guard g ...) e0 e ...) cs ...)
     (let ((fk (lambda () (pmatch v cs ...))))
       (ppat v pat
	     (if (and g ...) (begin e0 e ...) (fk))
	     (fk))))
    ((_ v (pat e0 e ...) cs ...)
     (let ((fk (lambda () (pmatch v cs ...))))
       (ppat v pat (begin e0 e ...) (fk))))))

(define-syntax ppat
  (syntax-rules (? quote unquote)
    ((_ v ? kt kf) kt)
    ((_ v () kt kf) (if (null? v) kt kf))
    ((_ v (quote lit) kt kf) (if (equal? v (quote lit)) kt kf))
    ((_ v (unquote var) kt kf) (let ((var v)) kt))
    ((_ v (x . y) kt kf)
     (if (pair? v)
	 (let ((vx (car v)) (vy (cdr v)))
	   (ppat vx x (ppat vy y kt kf) kf))
	 kf))
    ((_ v lit kt kf) (if (equal? v (quote lit)) kt kf))))
