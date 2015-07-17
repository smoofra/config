

(setq load-path (cons "~/config/emacslisp/slime-2.10.1" load-path))
(require 'slime-autoloads)
(setq inferior-lisp-program  "sbcl")
(setq slime-contribs '(slime-asdf slime-fancy))
(slime-setup)

(defun fix-slime-selector ()
  (setq slime-net-coding-system 'utf-8-unix)

  (def-slime-selector-method ?j
    "next erc channel"
    (erc-next-channel))

  (def-slime-selector-method ?o
    "*Shell Command Output*"
    (get-buffer "*Shell Command Output*"))

  (def-slime-selector-method ?.
    "exit"
    (current-buffer))

  ;; this is control-g.  don't ask me why, but
  ;; you can call (read-char) or (read-event) to find out the code
  ;; for sometihng
  ;;(def-slime-selector-method 33554439
  ;;"exit"
  ;;(current-buffer))

  (def-slime-selector-method ?V
    "*svn-status*"
    (get-buffer "*svn-status*"))

  (def-slime-selector-method ?g
    "*grep*"
    (get-buffer "*grep*"))

  (def-slime-selector-method ?K
    "chat"
    (chat))

  (def-slime-selector-method ?k
    "#yourmom"
    (get-buffer "#yourmom"))

  (def-slime-selector-method ?m
    "mgwyer"
    (get-buffer "mgwyer"))

  (def-slime-selector-method ?b
    "bobbyisosceles"
    (get-buffer "bobbyisosceles"))

  (def-slime-selector-method ?L
    "#lisp"
    (get-buffer "#lisp"))

  (def-slime-selector-method ?C
    "*compilation* buffer"
    (get-buffer "*compilation*"))

  (def-slime-selector-method ?h
    "*Help* buffer."
    (get-buffer "*Help*"))

  (def-slime-selector-method ?S
    "*scratch* buffer."
    (get-buffer "*scratch*"))

  (def-slime-selector-method ?s
    "*slime-scratch* buffer."
    (get-buffer "*slime-scratch*"))

  (def-slime-selector-method ?I
    "*Slime Inspector* buffer."
    (slime-inspector-buffer))

  (def-slime-selector-method ?t
    "*terminal* buffer."
    (get-buffer "*terminal*"))

  (def-slime-selector-method ?y
    "*shell* buffer."
    (when (null (get-buffer "*shell*"))
      (call-interactively 'shell))
    (get-buffer "*shell*"))

  (def-slime-selector-method ?T
    "SLIME threads buffer."
    (slime-list-threads)
    "*slime-threads*")

  (def-slime-selector-method ?B
    "*Backtrace* buffer"
    (get-buffer "*Backtrace*")))

(fix-slime-selector)

(defun my-unhighlight ()
  (interactive)
  (slime-remove-old-overlays)
  (sldb-delete-overlays))

(defun my-slime-edit-definition (name &optional where)
  (interactive (list (slime-read-symbol-name "Symbol: ")))
  (set-mark (point))
  (slime-edit-definition name where))

(defun slime-insert-eval-last-expression ()
  (interactive)
  (insert (slime-eval `(swank:pprint-eval ,(slime-last-expression)))))

(defun slime-insert-expand-last-expression ()
  (interactive)
  (insert (slime-eval
	   `(swank::with-buffer-syntax
	     ()
	     (swank::swank-pprint
	      (cl::list
	       (cl::macroexpand-1
		(cl::read-from-string ,(slime-last-expression)))))))))

(defun slime-repl-backwards-kill-line ()
  (interactive)
  (let ((p (point)))
    (slime-repl-bol)
    (kill-region (point) p)))


(global-set-key "\C-cb" 'slime-selector)
(global-set-key [backtab] 'slime-fuzzy-complete-symbol)

(define-key slime-mode-map "\C-\M-a" 'slime-beginning-of-defun)
(define-jk slime-inspector-mode-map)
(define-key slime-inspector-mode-map "l" 'slime-inspector-pop)
(define-key slime-inspector-mode-map "D" 'slime-inspector-describe)
(define-key slime-mode-map "\M-." 'my-slime-edit-definition)
(define-key slime-mode-map "\M-c" 'my-unhighlight)
(define-key slime-mode-map "\t" 'slime-indent-and-complete-symbol)
(define-key slime-mode-map [(control tab)]   'tab-to-tab-stop)
(define-key slime-mode-map "\C-cp" 'slime-insert-eval-last-expression)
(define-key slime-mode-map "\C-ce" 'slime-insert-expand-last-expression)
(define-key slime-mode-map "\M-/" 'slime-fuzzy-complete-symbol)
(define-key slime-repl-mode-map "\M-/" 'slime-fuzzy-complete-symbol)
(define-my-lisp-keys-on-map slime-mode-map)
(define-my-lisp-keys-on-map slime-repl-mode-map)
(define-my-lisp-keys-on-map slime-scratch-mode-map)
(define-key slime-repl-mode-map "\C-j" 'slime-repl-backwards-kill-line)
(define-key slime-repl-mode-map "\r"   'slime-repl-return)
(define-key slime-repl-mode-map [home] 'SDO)
(define-key slime-repl-mode-map "\C-a" 'slime-repl-bol)
