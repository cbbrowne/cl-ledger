(declaim (optimize (safety 3) (debug 3) (speed 1) (space 0)))

(in-package :ledger.textual)

(defclass automated-entry (entry)
  ((predicate-expr :accessor entry-predicate-expr :initarg :predicate-expr :type string)
   (predicate :accessor entry-predicate :initarg :predicate :type function)))

(defun read-automated-entry (in journal)
  (declare (type journal journal))
  (declare (type stream in))
  (let* ((predicate-expr (read-line in))
	 (function (or (parse-value-expr predicate-expr)
		       (error "Failed to parse predicate value expression: ~S"
			      predicate-expr)))
	 (entry
	  (make-instance 'automated-entry
			 :journal journal
			 :predicate-expr predicate-expr
			 :predicate (compose-predicate function))))
    (loop
       for transaction = (read-transaction in entry)
       while transaction do
       (add-transaction entry transaction))
    entry))

(pushnew `(#\= . ,#'(lambda (in journal)
		      (read-char in)
		      (add-entry journal (read-automated-entry in journal))))
	 *directive-handlers*)

(provide 'autoentry)

;; autoentry.lisp ends here