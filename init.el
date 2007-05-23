
(load "~/.site-init.el" t)

(require 'cl)

(setq inferior-lisp-program  "sbcl")
;(setq inferior-lisp-program  "/home/larry/allegro/acl62_trial/alisp")
;(setq inferior-lisp-program  "lisp")
;(setq inferior-lisp-program  "env SBCL_HOME=/home/larry/usrsbcl/lib/sbcl /home/larry/usrsbcl/bin/sbcl")
;(setq inferior-lisp-program  "/sw/bin/openmcl --load /Users/larry/.openmcl-init")
;(setq inferior-lisp-program  "/Users/larry/usr-sbcl-cvs/bin/sbcl --core /Users/larry/usr-sbcl-cvs/lib/sbcl/sbcl.core")

(setq load-path (cons "~/usr/share/emacs/site-lisp" load-path))
(autoload 'maxima "maxima")
(setq load-path (cons "/usr/share/maxima/5.9.1/emacs/" load-path))

;(setq load-path (cons "/usr/share/emacs/site-lisp/tnt/" load-path))
(setq load-path (cons "~/config" load-path))
(setq load-path (cons "~/emacslisp" load-path))
(setq load-path (cons "~/emacslisp/tnt-2.5/" load-path))
(setq load-path (cons "~/emacslisp/emacs-cl" load-path))
(setq load-path (cons "~/emacslisp/darcs-mode" load-path))
(autoload 'lisppaste-paste-region "lisppaste" "lisppaste" t)

(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "web browser" t)
(autoload 'tnt-open "tnt" "tnt" t)

(add-hook 'after-save-hook 
	  'executable-make-buffer-file-executable-if-script-p)


(defvar i-have-escreen nil)
(when (load "escreen" t)
  ;(setq escreen-prefix-char "\M-\d")
  (setq i-have-escreen t)
  (setq escreen-prefix-char "\M-`")
  (define-key escreen-map "w" 'escreen-w)
  (escreen-install))

(defun escreen-w ()
  (interactive)
  (let ((screen-list (sort (escreen-configuration-screen-numbers) '<)))
    (message "escreen: active screens: %s --- current screen is number %d"
	     (mapconcat 'number-to-string screen-list " ") 
	     escreen-current-screen-number) screen-list))

(when (load "fff" t)
  (fff-install-map))

(when (load "fff-elisp" t)
  (fff-elisp-install-map))

(defun perl-lib-path () 
  (when (get-buffer "*foo*")
    (kill-buffer "*foo*"))
  (call-process "perl" nil "*foo*" nil "-e" "print join ':', @INC")
  (save-excursion 
    (set-buffer "*foo*")
    (buffer-substring (point-min) (point-max))))

(defun fff-pm (name)
  (interactive (list (read-string "Module name: ")))
  (fff-find-file-in-path (concat name ".pm") (perl-lib-path)))

(setq i-have-slime (load "slime" t))
(when i-have-slime
  (slime-setup)

  (def-slime-selector-method ?h
    "*Help* buffer."
    (get-buffer "*Help*"))

  (def-slime-selector-method ?S
    "*scratch* buffer."
    (get-buffer "*scratch*"))

  (def-slime-selector-method ?I
    "*Slime Inspector* buffer."
    (slime-inspector-buffer))

  (def-slime-selector-method ?t
    "*terminal* buffer."
    (get-buffer "*terminal*"))

  (def-slime-selector-method ?T
    "SLIME threads buffer."
    (slime-list-threads)
    "*slime-threads*")

  (def-slime-selector-method ?b
    "*Backtrace* buffer"
    (get-buffer "*Backtrace*")))

(defun link-url-at-point ()
  (interactive)
  (let ((url (browse-url-url-at-point)))
    (call-process "chain" nil nil nil url "1")))

(defun links ()
  (interactive)
  (occur "http://[^ ]*"))

(global-set-key "\C-x4l" 'link-url-at-point)

(defun makehoriz ()
  (interactive)
  (other-window 1)
  (let ((buf (current-buffer)))
    (delete-window)
    (other-window -1)
    (split-window-horizontally)
    (other-window 1)
    (switch-to-buffer buf)
    (other-window -1)))

(defun makevert ()
  (interactive)
  (other-window 1)
  (let ((buf (current-buffer)))
    (delete-window)
    (other-window -1)
    (split-window-vertically)
    (other-window 1)
    (switch-to-buffer buf)
    (other-window -1)))

(global-set-key "\C-x4h" 'makehoriz)
(global-set-key "\C-x4v" 'makevert)

(defun my-unhighlight ()
  (interactive)
  (sldb-delete-overlays))

(defun is-sexp-start ()
  (condition-case err
      (let ((p (point)))
	(save-excursion 
	  (forward-sexp)
	  (backward-sexp)
	  (equal (point) p)))
    (error nil)))

(defun is-sexp-end ()
  (condition-case err
      (let ((p (point)))
	(save-excursion 
	  (backward-sexp)
	  (forward-sexp)
	  (equal (point) p)))
    (error nil)))

(defun semi-forward-sexp ()
  (interactive)
  (let ((a (point)))
    (forward-sexp)
    (let ((b (point)))
      (backward-sexp)
      (unless (< a (point))
	(setf (point) b)))))

(defun semi-backward-sexp ()
  (interactive)
  (let ((a (point)))
    (backward-sexp)
    (let ((b (point)))
      (forward-sexp)
      (unless (< (point) a)
	(setf (point) b)))))

;(defun semi-backward-sexp ()
;  (interactive)
;  (if (cheqstr (char-before (point)) ")")
;      (backward-sexp)
;    (progn
;      (backward-sexp)
;      (forward-sexp))))

(defun save-sexp ()
  (interactive)
  (save-excursion
    (unless (is-sexp-start)
      (semi-forward-sexp))
    (mark-sexp)
    (call-interactively 'kill-ring-save)))


(define-key emacs-lisp-mode-map "\M-k" 'save-sexp)
(define-key lisp-interaction-mode-map "\M-." 'find-function)
(define-key emacs-lisp-mode-map "\M-." 'find-function)

(when i-have-slime
  (slime-define-key "\M-c" 'my-unhighlight)
  (slime-define-key [tab] 'slime-indent-and-complete-symbol)
  (slime-define-key "\M-/" 'slime-fuzzy-complete-symbol))

(global-set-key "\C-\M-n" 'semi-forward-sexp)
(global-set-key "\C-\M-p" 'semi-backward-sexp)

(defun my-slime-edit-definition (name &optional where)
  (interactive (list (slime-read-symbol-name "Symbol: ")))
  (set-mark (point))
  (slime-edit-definition name where))

(when i-have-slime
  (define-key slime-mode-map "\M-." 'my-slime-edit-definition))

(tool-bar-mode)

(if (not (eq system-type 'darwin)) 
    (setq default-frame-alist 
	  '((vertical-scroll-bars) (menu-bar-lines . 0))))

(setq next-line-add-newlines nil)

(setq indent-tabs-mode ())

(defun myblink-h ()
  (cond
   ((equal (char-to-string (char-before (point))) ")") t)
   ((equal (char-to-string (char-before (point))) "]") t)
   ((equal (char-to-string (char-before (point))) "}") t)
   (t (progn (backward-char) (myblink-h))))
  (call-interactively blink-paren-function))

(defun myblink ()
  (interactive)
  (let ((p (point)))
    (unwind-protect (myblink-h) (goto-char p))))

(defun diff-current-buffer-with-file ()
  (interactive)
  (diff-buffer-with-file (current-buffer))
  (save-excursion 
    (set-buffer (get-buffer "*Diff*"))
    (toggle-read-only 1)))


(defun remove-keymap-prop (begin end)
  (interactive "r")
  (remove-text-properties begin end '(keymap)))


(defun insert-some-pair (&optional open) 
  (interactive "c")
  (if (null open)
      (setq open ?\())
  (let ((close (cond 
		((eql open ?\( ) ?\) )
		((eql open ?\{ ) ?\} )
		((eql open ?\[ ) ?\] )
		(t open))))
    (insert-pair 0 open close)))

(defun my-insert-parentheses (&optional arg)
  (interactive "P")
  (if (null arg)
      (insert-pair 0 ?\( ?\) )
    (call-interactively 'insert-some-pair)))

(defun self-insert-pair ()
  (interactive)
  (insert-some-pair (string-to-char (this-command-keys))))

(show-paren-mode)

;(global-set-key "\C-o"      'myblink)
(global-set-key [C-return] 'open-line)
(global-set-key [(f1)]     'delete-other-windows)
(global-set-key [(f2)]     'next-error)
(global-set-key "\C-xe"    'next-error)
(global-set-key "\C-xd"    'beginning-of-defun)
(global-set-key "\M-_"     'unwrap-next-sexp)
(global-set-key "\C-x\C-b" 'ibuffer)

(if (>= emacs-major-version 22)
    (global-set-key "\C-\M-y"  'my-insert-parentheses)
  (global-set-key "\C-\M-y"  'insert-parentheses))

(global-set-key "\C-\M-j"  'join-line)
(global-set-key "\C-xp"    'revert-buffer)
(global-set-key "\C-x\C-p" 'diff-current-buffer-with-file)
(global-set-key "\C-x`"    'delete-other-windows)
(global-set-key "\M-o"     'switch-to-buffer)
(global-set-key "\M-e"     'call-last-kbd-macro)
(global-set-key "\C-xm"    'comp)
(global-set-key "\C-x\C-m" 'compi)
(global-set-key "\C-p"     'previous-line)
(global-set-key "\C-x\M-f" 'view-file)
(global-set-key "\M-\""     'transient-mark-mode)
;(global-set-key "\C-h\M-a"  'apropos)
(global-set-key "\C-xf"     'set-visited-file-name)
;(global-set-key "\C-z"      'scroll-up-one)
(global-set-key "\C-z"      'SUO)
(global-set-key "\C-q"      'SDO)
;(global-set-key "\C-q"      'scroll-down-one)
(global-set-key [prior]      'scroll-down-half)
(global-set-key [next]     'scroll-up-half)
(global-set-key [C-M-right] 'forward-sexp)
(global-set-key [C-M-left]  'backward-sexp)
(global-set-key "\C-xq"     'quoted-insert)
(global-set-key "\C-j"      'backwards-kill-line)
(global-set-key "\M-s"      'ispell-region)
(global-set-key "\C-xc"     'font-lock-fontify-buffer)
(global-set-key "\C-h"      'delete-backward-char)
(global-set-key "\M-?"      'help-command)
(global-set-key "\M-p"      'fill-paragraph)
(global-set-key "\M-\C-q"   'shrink-window)
(global-set-key "\M-z"      'suspend-emacs)
;(global-set-key "\M-r"      're-lock)
(global-set-key "\M-r"      'replace-regexp-region)
(global-set-key "\M-l"      'goto-line)
(global-set-key [C-down] 'scroll-up-one)
(global-set-key [C-up]  'scroll-down-one)
(global-set-key "\M-z" 'scroll-up-one)
(global-set-key "\M-q" 'scroll-down-one)
;(global-set-key "\C-\M-z" 'scroll-up-half)
;(global-set-key "\C-\M-q" 'scroll-down-half)
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\C-v" 'view-mode)
(global-set-key   "\M-\C-z"   'scroll-up-half)
(global-set-key "\M-\C-a"   'scroll-down-half)
(global-set-key [home] 'SDO)
(global-set-key [end]  'SUO)

(setq perl-indent-level 2)

(setq compile-command "make | cat")

(setq cperl-font-lock t)

(defun filter (pred list)
  (mapcan #'(lambda (x)
	      (if (funcall pred x)
		  (list x)
		nil))
	  list))

(setq auto-mode-alist 
      (filter #'(lambda (x)
		  (not (or (equal (cdr x) 'xml-mode)
			   (equal (cdr x) 'sgml-mode))))
	      auto-mode-alist))

(setq auto-mode-alist
      (append '(("\\.\\([pP][Llm]\\|al\\)$" . cperl-mode)
		("\\.sawfishrc" . lisp-mode)
		("\\.php" . php-mode)
		("\\.ph" . cperl-mode)
		("\\.rb" . ruby-mode)
		("\\.asd" . lisp-mode)
		("\\.jl$" . lisp-mode)
		("\\.\\(xsl\\|xml\\|rss\\|rdf\\)$" . nxml-mode)
		("\\.css$" . css-mode))
	      auto-mode-alist )) 

(when (>= emacs-major-version 22)
  (add-to-list 'auto-mode-alist 
	       (cons "^/tmp/mutt-" 'message-mode)))

(add-to-list 'auto-mode-alist
	     (cons (concat "\\." (regexp-opt '("xml" "xsd" "sch" "rng" "xslt" "svg" "rss") t)
			   "\\'")
		   'nxml-mode))

(add-to-list 'magic-mode-alist
	     (cons "<\\?xml" 'nxml-mode))


(global-font-lock-mode 't)

(transient-mark-mode -1)

(setq font-lock-global-modes '(c-mode
  			       c++-mode
			       perl-mode
			       lisp-mode
			       xml-mode
			       cperl-mode	
			       emacs-lisp-mode
			       ruby-mode
			       shell-script-mode
			       asm-mode
			       pascal-mode
                               html-mode
			       sh-mode
			       java-mode
			       makefile-mode
			       diff-mode))

;;orig. by marco baringer
(defun unwrap-next-sexp (&optional kill-n-sexps)
  "Convert (x ...) to ..."
  (interactive "P")
  (forward-sexp)
  (backward-delete-char 1)
  (set-mark (point))
  (backward-up-list)
  (delete-char 1)
  (unless (equal kill-n-sexps 0)
    (let ((start-region-to-kill (point)))
      (kill-sexp kill-n-sexps)
      (forward-sexp)
      (backward-sexp)
      (delete-region start-region-to-kill (1- (point)))))
  (lisp-indent-line)
  (call-interactively 'indent-region))

(defun delete-empty-lines ()
  (interactive)
  (delete-horizontal-space)
  (when (equal (char-after (point)) 10)
      (delete-char 1)
      (delete-empty-lines)))

(defun is-space (c)
  (or (equal c 10)
      (equal c 32)
      (equal c 9)))


(defun forward-delete-space ()
  (interactive)
  (let ((newlines nil))
    (while (is-space (char-after (point)))
      (if (cheqstr (char-after (point)) "\n")
	  (setq newlines t))
      (delete-char 1))
    newlines))

(defun cheqstr (char str)
  (and char 
       (equal (char-to-string char) str)))

(defun is-closer (char)
  (cond 
   ((eql ?\) char) t)
   ((eql ?\} char) t)
   ((eql ?\] char) t)
   (t nil)))

(defun forward-delete-space-through-parens ()
  (interactive)
  (forward-delete-space)
  (when (is-closer (char-after (point)))
    (forward-char)
    (let ((close nil))
      (save-excursion
	(while (is-space (char-after (point)))
	  (forward-char))
	(when (is-closer  (char-after (point)))
	  (setq close t)))
      (when close 
	(forward-delete-space-through-parens))
      (backward-char))))

(defun beginning-of-line-p ()
  (or (equal (point) 1) (cheqstr (char-before (point)) "\n")))

(defun end-of-line-p ()
  (or (null (char-after (point))) (cheqstr (char-after (point)) "\n")))

(defun line-empty-before-point ()
  (save-excursion
    (while (and (not (beginning-of-line-p))
		(is-space (char-before (point))))
      (backward-char))
    (beginning-of-line-p)))

(defun line-empty-after-point ()
  (save-excursion
    (while (and (not (end-of-line-p))
		(is-space (char-after (point))))
      (forward-char))
    (end-of-line-p)))      

(defun is-tail ()
  (save-excursion
    (while (is-space (char-after (point)))
      (forward-char))
    (cheqstr (char-after (point)) ")")))

(defun grab-quotes-before-point ()
  (if (or (cheqstr (char-before (point)) "'")
	  (cheqstr (char-before (point)) "`"))
      (let ((quote (char-to-string (char-before (point)))))
	(backward-delete-char 1)
	(concat (grab-quotes-before-point) quote))
    ""))

(defun at-most-one-space ()
  (interactive)
  (if (or (and (not (beginning-of-line-p)) (is-space (char-before (point))))
	  (and (not (end-of-line-p))       (is-space (char-after  (point)))))
      (just-one-space)))

(when (< emacs-major-version 22)
  (defun indent-pp-sexp ()
    (indent-sexp)))

(defun consume-sexp-and-indent ()
  (interactive)
  (let ((quote (grab-quotes-before-point))
	(n 0))
    (at-most-one-space)
    (while (not (is-tail))
      (incf n)
      (forward-sexp))
    (consume-sexp (< 0 n))
    (backward-sexp)
    (insert quote)
    (backward-char (length quote))
    (lisp-indent-line)
    (indent-pp-sexp)
    (forward-sexp)
    (while (< 0 n)
      (decf n)
      (backward-sexp)
      (call-interactively 'transpose-sexps)
      (backward-sexp))))

(defun lisp-newline-and-indent ()
  (interactive)
  (newline)
  (lisp-indent-line))

(defun consume-sexp  (&optional supress-newlines)
  (interactive)
  (forward-delete-space-through-parens)
  (while (and (line-empty-before-point)
	      (or (save-excursion
		    (beginning-of-line)
		    (backward-char)
		    (line-empty-before-point))
		  (save-excursion
		    (forward-char)
		    (line-empty-after-point))))
    (join-line)
    (lisp-indent-line))
  (backward-up-list)
  (forward-sexp)
  (let ((c (char-before (point))))
    (backward-delete-char 1)
    (let ((newlines (and (forward-delete-space) (not supress-newlines))))
      (cond
       ((equal (char-to-string (char-after (point))) ")")
	(consume-sexp supress-newlines)
	(insert c)
	(backward-char))
       (t (when (and (not newlines)
		     (not (cheqstr (char-before (point)) "`"))
		     (not (cheqstr (char-before (point)) "'"))
		     (not (cheqstr (char-before (point)) "("))
		     (not (cheqstr (char-before (point)) " ")))
	    (insert " "))
	  (when newlines 
	    (lisp-newline-and-indent))
	  (forward-sexp)
	  (insert c)
	  (backward-char))))))

(defun lisp-ctrla ()
  (interactive)
  (if (>= emacs-major-version 22)
      (call-interactively 'move-beginning-of-line)
    (call-interactively 'beginning-of-line))
  (lisp-indent-line))

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

(global-set-key "\M-'" 'forward-delete-space-through-parens)
(when i-have-slime
  (define-key slime-mode-map "\C-cp" 'slime-insert-eval-last-expression))
(global-set-key "\M-i" 'consume-sexp-and-indent)

(defun my-mark-defun ()
  (interactive)
  (call-interactively 'beginning-of-defun)
  (forward-sexp)
  (call-interactively 'set-mark-command)
  (backward-sexp))

(defun backward-transpose-sexp ()
  (interactive)
  (call-interactively 'transpose-sexps)
  (backward-sexp)
  (backward-sexp))

(defun space-to-col (n)
  (interactive "p")
  (while (not (equal n (current-column)))
    (insert " ")))

(defun lisp-join-line ()
  (interactive)
  (join-line)
  (lisp-indent-line))

(defun lisp-yank (&optional arg)
  (interactive "*P")
  (yank arg)
  (cond 
   ((null arg) 
    (when (and (is-sexp-end)
	       (equal (save-excursion
			(backward-sexp)
			(point))
		      (mark)))
      (backward-sexp)
      (indent-pp-sexp)
      (forward-sexp)))))

(defun lisp-yank-pop (&optional arg)
  (interactive "*p")
  (let ((last-command (if (equal last-command 'lisp-yank)
			  'yank
			last-command)))
    (yank-pop arg)))

(when i-have-slime
  (slime-define-key   "\C-ce" 'slime-insert-expand-last-expression))

(defvar my-lisp-keys nil)

(defun my-lisp-define-key (k b)
  (setq my-lisp-keys (cons (cons k b) my-lisp-keys)))

(defun define-my-lisp-keys-on-map (map)
  (dolist (cns my-lisp-keys)
    (define-key map (car cns) (cdr cns))))

(my-lisp-define-key "\C-y"    'lisp-yank)
(my-lisp-define-key "\M-y"    'lisp-yank-pop)
(my-lisp-define-key "\M-k"    'save-sexp)
(my-lisp-define-key "\C-\M-j" 'lisp-join-line)
(my-lisp-define-key "\C-a"    'lisp-ctrla)
(my-lisp-define-key "\C-\M-h" 'my-mark-defun)
(my-lisp-define-key "\r"      'lisp-newline-and-indent)
(my-lisp-define-key "\C-\M-e" 'backward-transpose-sexp)

(when i-have-slime
  (define-my-lisp-keys-on-map slime-repl-mode-map))
(define-my-lisp-keys-on-map emacs-lisp-mode-map)
(define-my-lisp-keys-on-map lisp-interaction-mode-map)
(define-my-lisp-keys-on-map lisp-mode-map)

(when i-have-slime
  (define-key slime-repl-mode-map "\r" 'slime-repl-return))

(eval-after-load "interaction"
  '(progn
     (define-key emacs-cl-mode-map "\C-m" 'emacs-cl-newline)
     (define-my-lisp-keys-on-map emacs-cl-mode-map)))

(defun define-jk (map)
  (define-key map "u" 'scroll-down-half)
  (define-key map "d" 'scroll-up-half)
  (define-key map "J" 'next-line)
  (define-key map "K" 'previous-line)
  (define-key map "j" 'SUO)
  (define-key map "k" 'SDO)
  (define-key map "/" 'isearch-forward)
  (define-key map "?" 'isearch-backward))


(eval-after-load 'apropos
  '(progn 
     (define-jk apropos-mode-map)))

(eval-after-load 'comint
  '(progn
     (define-key comint-mode-map "\C-z" 'scroll-up-one)
     (define-key comint-mode-map "\C-q" 'scroll-down-one)))

;(define-key comint-mode-map "\M-p" 'previous-line)
;(define-key comint-mode-map "\M-n" 'next-line)
;(define-key comint-mode-map [up]   'comint-previous-input)
;(define-key comint-mode-map [down] 'comint-next-input)
;(define-key comint-mode-map "\C-p" 'comint-previous-input)
;(define-key comint-mode-map "\C-n" 'comint-next-input)

(add-hook 'Man-mode-hook 
	  (lambda () 
	    (define-jk Man-mode-map)))

(when (load "term")
  (define-key term-mode-map (kbd "TAB") 'term-dynamic-complete)
  (when (null term-raw-map)
    (term "echo"))
  (when i-have-escreen
    (define-key term-raw-map "\M-`" escreen-map))
  (define-key term-raw-map "\C-x" ctl-x-map)
  (define-key term-raw-map "\C-y" 'term-paste)
  (define-key term-raw-map "\M-x" 'execute-extended-command)
  (define-key term-raw-map "\C-cb" 'slime-selector))


(eval-after-load 'help
  '(add-hook 'help-mode-hook 
	     (lambda ()
	       (define-jk help-mode-map))))

(add-hook 'view-mode-hook
	  '(lambda ()
	     (progn 
	       (define-jk view-mode-map)
	       (define-key view-mode-map "q" '(lambda () (interactive) 1)))))

;(define-key view-mode-map "q" '(lambda () (interactive) (view-mode -1)))
;(define-key view-mode-map " " 'foo)
;(define-key view-mode-map [return] 'foo)
;(define-key view-mode-map [backspace] 'foo)

(when i-have-slime
  (define-jk slime-inspector-mode-map)
  (define-key slime-inspector-mode-map "D" 'slime-inspector-describe))


(eval-after-load 'info 
  '(progn
     (define-jk Info-mode-map)
     (define-key Info-mode-map "U" 'Info-up)
     (define-key Info-mode-map "D" 'Info-directory)))

(setq diff-default-read-only t)

(add-hook 'diff-mode-hook 
	  '(lambda () 
	     (define-key diff-mode-map "\M-q" 'scroll-down-one)
	     (define-key diff-mode-map "a" 'diff-apply-hunk)
	     (define-key diff-mode-map "t" 'diff-test-hunk)))


(add-hook 'before-make-frame-hook '(lambda () (menu-bar-mode -1)))
(add-hook 'window-setup-hook '(lambda () (scroll-bar-mode -1)))
;(add-hook 'emacs-startup-hook '(lambda () (menu-bar-mode -1)))

(define-key text-mode-map "\M-s" 'ispell-region)

(defun SUO (x) (interactive "p")  (scroll-up-one x) (next-line x))
(defun SDO (x) (interactive "p") (scroll-down-one x) (previous-line x))

(add-hook 'cperl-mode-hook 
	  (lambda () 
	    (define-key cperl-mode-map "(" 'self-insert-command)
	    (define-key cperl-mode-map "\"" 'self-insert-command)
	    (define-key cperl-mode-map "[" 'self-insert-command)
	    (define-key cperl-mode-map "{" 'self-insert-command)
	    (define-key cperl-mode-map "\C-j" 'backwards-kill-line)))

(add-hook 'LaTeX-mode-hook 
	  (lambda () 
	    (define-key cperl-mode-map "\C-j" 'backwards-kill-line)))

(add-hook 'ruby-mode-hook
	  (lambda () 
	    (define-key ruby-mode-map "\C-j" 'backwards-kill-line)))

(defun replace-regexp-region ()
  (interactive) 
  (let ((p (point)) (m (mark)))
    (if transient-mark-mode (call-interactively 'replace-regexp)
      (unwind-protect
	  (progn (call-interactively 'transient-mark-mode)
		 (call-interactively 'replace-regexp))
	(call-interactively 'transient-mark-mode)))))
    

(defun replace-regexp-region-foo (re to) 
  (let ((p (point)) (m (mark)))
  (if transient-mark-mode (replace-regexp re to)
    (unwind-protect
	(progn (call-interactively 'transient-mark-mode)
	       (replace-regexp re to))
      (call-interactively 'transient-mark-mode)))
  (goto-char p)
  (set-mark m)))


(defun diff-clear ()
  (interactive)
  (replace-regexp-region-foo "^." " "))

(defun caddr (l)
  (car (cddr l)))

(defun cadddr (l)
  (cadr (cddr l)))

(defun goodp (elem) 
  (and (consp elem)
       (symbolp (cdr elem))))

(defun no-electric (map)
  (let ((rest map) (elem) (str))
    (while rest
      (setq elem (car rest))
      (when (goodp elem)
	(setq str (symbol-name (cdr elem)))
	(when (and (string-match "electric" str)
		   (not (equal str "c-electric-backspace")))
;	  (define-key map (car elem) 'self-insert-command))
	  (setcdr elem 'self-insert-command)))
      (setq rest (cdr rest)))))


;(no-electric java-mode-map)   
;(goodp (caddr java-mode-map))
; (caddr java-mode-map)
;(setcrr (cdr (cadddr java-mode-map)) 'foooooo)
;(setq FOO '(foo bar))
;(setq foi java-mode-map)
;(setq java-mode
;(set (cadr FOO) 'baz)
;(define-key java-mode-map "/" 'self-insert-command)


; (global-set-key "\C-xd" 'diff-clear)


;(defun replace-regexp-region ()
;  (interactive) (let ((p (point)) (m (mark)))
;  (if transient-mark-mode (call-interactively 'replace-regexp)
;    (progn (call-interactively 'transient-mark-mode)
;	   (call-interactively 'replace-regexp)
;	   (call-interactively 'transient-mark-mode)))
;  (goto-char p)
;  (set-mark m)
;  ))	   
;
 
(defun scroll-up-one (n)
  (interactive "p")
  (scroll-up n))

(defun scroll-down-one (n)
  (interactive "p")
  (scroll-down n))

(defun scroll-up-half ()
  (interactive)
  (SUO (/ (window-height) 2)))

(defun scroll-down-half ()
  (interactive)
  (SDO (/ (window-height) 2)))

(defun re-lock ()
  (interactive)
  (font-lock-unfontify-buffer)
  (font-lock-fontify-buffer))

(defun backwards-kill-line ()
  (interactive)
  (let ((oldpoint (point))
	(start-line (progn (beginning-of-line) (point))))
    (cond
     ((or (string-match "^[ \t]+$" (buffer-substring start-line oldpoint))
	  (= oldpoint start-line))
      (kill-region (max 1 (1- start-line)) oldpoint))
     (t 
      (kill-region start-line oldpoint)))))

			
;(defun backwards-kill-line () 
;  (interactive)
;  (let ((oldpoint (point))) 
;    (if (= (point) (progn (beginning-of-line) (point))) 
;	(kill-region (progn (forward-char -1) (point))
;		     (progn (forward-char 1)  (point)))
;        (kill-region oldpoint
;		     (point)))))
             
   
(add-hook 'message-mode-hook 
	  '(lambda ()
	     (define-key message-mode-map "\C-cs" 'skip-to-body)))

(setq truncate-partial-width-windows nil)

(defun skip-to-body ()     
  (interactive)
  (if (= (progn (beginning-of-line) (point)) 
	 (progn (end-of-line)       (point)))
      (forward-line 1)
    (progn (forward-line 1) (skip-to-body))))

(defun muttland-wrapper ()
  (interactive)
  (if muttland-on (progn (skip-to-body) (setq muttland-on nil)) t))

(setq muttland-on nil)
    
(defun muttland () 
  (setq muttland-on t)
  (add-hook 'find-file-hooks 'muttland-wrapper))


(defun set-window-lines (w l) 
  (let ((SW (selected-window))
	(h  (window-height w)))
    (select-window w)
    (shrink-window (- h l))
    (select-window SW)))

(defun comp (&optional i)
  (interactive)
  (if i (call-interactively 'compile) (compile compile-command))
  (set-window-lines (get-buffer-window "*compilation*") 15))

(defun compi () (interactive) (comp 1))

(setenv "USER_JFLAGS" " +E ")


(defun no-exit ()
  (interactive)
  (global-set-key "\C-x\C-c" 'foo))


(defun yes-exit ()
  (interactive)
  (global-set-key "\C-x\C-c" 'save-buffers-kill-emacs))

(global-set-key "\C-cb" 'slime-selector)
(global-set-key [backtab] 'slime-fuzzy-complete-symbol)



(column-number-mode t)

;(setq scheme-program-name "guile")
;(autoload 'run-scheme "cmuscheme48" "Run an inferior Scheme process." t)
(autoload 'ruby-mode "ruby-mode" "editor mode for ruby" t)


;; (defun slime-handle-indentation-update (alist)
;;   "Update Lisp indent information.

;; ALIST is a list of (SYMBOL-NAME . INDENT-SPEC) of proposed indentation
;; settings for `common-lisp-indent-function'. The appropriate property
;; is setup, unless the user already set one explicitly."
;;   (dolist (info alist)
;;     (let ((symbol-name (car info)))
;;       (unless (and slime-conservative-indentation
;;                    (string-match "^\\(def\\|\\with-\\)" symbol-name))
;;         (let ((symbol (intern symbol-name))
;;               (indent (cdr info)))
;;           ;; Does the symbol have an indentation value that we set?
;;           (when (equal (get symbol 'lisp-indent-function)
;;                        (get symbol 'slime-indent))
;;             (put symbol 'slime-indent indent)
;;             (put symbol 'lisp-indent-function indent)))))))

(setq custom-file "~/.custom.el")
(load "~/.custom.el" t)



(put 'downcase-region 'disabled nil)

(setf (get 'bind 'common-lisp-indent-function) 2)
(setf (get 'defmethod/cc 'common-lisp-indent-function)
      'lisp-indent-defmethod)

(defun open-inspector-helper ()
  (slime-eval-async '(swank:init-inspector "utils::*future-inspectee*") 'slime-open-inspector))



(defun back-window ()
  (interactive)
  (other-window -1))

(global-set-key "\C-xi" 'back-window)


(defun freenode ()
  (interactive)
  (erc-select :server "irc.freenode.net" :port "ircd" :nick "smoofra" :password my-stupid-passwd))

(defun dalnet ()
  (interactive)
  (erc-select :server "punch.va.us.dal.net" :port "ircd" :nick "smoofra" :password my-stupid-passwd))

(defun wjoe ()
  (interactive)
  (erc-select :server "localhost" :port "ircd" :nick "smoofra")
  (erc-join-channel "#yourmom"))

(defun bitlbee ()
  (interactive)
  (erc-select :server "localhost" :port 6666 :nick "smoofra"))

(autoload 'erc-select "erc")

(eval-after-load 'erc 
  '(progn (add-hook 'erc-join-hook 'bitlbee-identify)
	  (setq erc-auto-query 'buffer)))

(defun bitlbee-identify ()
   "If we're on the bitlbee server, send the identify command to the #bitlbee channel."
   (when (and (string= "localhost" erc-session-server)
	      (= 6666 erc-session-port)
	      (string= "&bitlbee" (buffer-name)))
     (erc-message "PRIVMSG" (format "%s identify %s" (erc-default-target) my-stupid-passwd))))

(setq manual-program  "man")

(defun perldoc (&optional q)
  (interactive)
  (let* ((query (if q q (read-string  "perldoc: " nil nil)))
	 (manual-program "perldoc")
	 (bufname (concat "*Perldoc " query "*"))
	 (oldbuf (get-buffer bufname)))
    (man query)
    (let* ((buf (get-buffer (concat "*Man " query "*"))))
      (save-excursion
	(if oldbuf (kill-buffer oldbuf))
	(set-buffer buf)
	(rename-buffer bufname)))))


(eval-after-load 'css-mode
  '(setq cssm-indent-function #'cssm-c-style-indenter))

(eval-after-load 'nxml-mode
  '(progn
     (define-key nxml-mode-map "\C-c/" 'nxml-finish-element)
     (define-key nxml-mode-map "\C-\M-f" 'nxml-forward-element)
     (define-key nxml-mode-map "\C-\M-b" 'nxml-backward-element)))

(eval-after-load 'sgml-mode
  '(progn
     (define-key sgml-mode-map "\C-\M-f" 'sgml-skip-tag-forward)
     (define-key sgml-mode-map "\C-\M-b" 'sgml-skip-tag-backward)
     (define-key html-mode-map "\C-\M-f" 'sgml-skip-tag-forward)
     (define-key html-mode-map "\C-\M-b" 'sgml-skip-tag-backward)))

(window-configuration-to-register ?w)

;(setq sgml-auto-activate-dtd t)
;(setq sgml-indent-data t)
;(setq sgml-set-face t)  



(defun deprop-region (start end)
  (interactive "r")
  (set-text-properties start end nil ))

;(eval-after-load 'c-mode
;'(define-key c-mode-map "\M-q" 'scroll-down-one))

;(eval-after-load 'cc-mode
;'(define-key c-mode-map "\M-q" 'scroll-down-one))


;;; indentation-related crap
; c-basic-offset
; indent-tab-mode
; tab-width
; c-backspace-function
; backward-delete-char-untabify-method
; c-set-style

(when i-have-slime
  (defun slime-clean ()
	(interactive)
	(slime-remove-old-overlays)))


(defun setup-tramp ()
  (interactive)
  (require 'tramp)
  (setq tramp-default-method "scp"))
