
; switched to darcs!

(load "~/.site-init.el")

(setq inferior-lisp-program  "sbcl")
;(setq inferior-lisp-program  "/home/larry/allegro/acl62_trial/alisp")
;(setq inferior-lisp-program  "lisp")
;(setq inferior-lisp-program  "env SBCL_HOME=/home/larry/usrsbcl/lib/sbcl /home/larry/usrsbcl/bin/sbcl")
;(setq inferior-lisp-program  "/sw/bin/openmcl --load /Users/larry/.openmcl-init")
;(setq inferior-lisp-program  "/Users/larry/usr-sbcl-cvs/bin/sbcl --core /Users/larry/usr-sbcl-cvs/lib/sbcl/sbcl.core")

(setq load-path (cons "~/usr/share/emacs/site-lisp" load-path))
(autoload 'maxima "maxima")
(setq load-path (cons "/usr/share/maxima/5.9.1/emacs/" load-path))

(setq load-path (cons "~/config" load-path))
(setq load-path (cons "~/emacslisp" load-path))
(setq load-path (cons "~/emacslisp/darcs-mode" load-path))
(autoload 'lisppaste-paste-region "lisppaste" "lisppaste" t)

(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "web browser" t)

(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(when (load "escreen" t)
  (setq escreen-prefix-char "\M-\d")
  (escreen-install))

(when (load "fff" t)
  (fff-install-map))

(when (load "fff-elisp" t)
  (fff-elisp-install-map))

(require 'slime)
(slime-setup)

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
  (let ((p (point)))
    (save-excursion 
      (forward-sexp)
      (backward-sexp)
      (equal (point) p))))

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
(slime-define-key "\M-k" 'save-sexp)
(slime-define-key "\M-c" 'my-unhighlight)
(slime-define-key "\M-/" 'slime-fuzzy-complete-symbol)
(global-set-key "\C-\M-n" 'semi-forward-sexp)
(global-set-key "\C-\M-p" 'semi-backward-sexp)

(defun my-slime-edit-definition (name &optional where)
  (interactive (list (slime-read-symbol-name "Symbol: ")))
  (set-mark (point))
  (slime-edit-definition name where))
(define-key slime-mode-map "\M-." 'my-slime-edit-definition)

(tool-bar-mode)

(if (not (eq system-type 'darwin)) 
    (setq default-frame-alist '((vertical-scroll-bars) (menu-bar-lines . 0))))

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
      
(show-paren-mode)

;(global-set-key "\C-o"      'myblink)
(global-set-key [C-return] 'open-line)
(global-set-key [(f1)]     'delete-other-windows)
(global-set-key [(f2)]     'next-error)
(global-set-key "\C-xe"    'next-error)
(global-set-key "\C-xd"    'beginning-of-defun)
(global-set-key "\M-_"     'unwrap-next-sexp)
(global-set-key "\C-\M-y"  'insert-parentheses)
(global-set-key "\C-\M-j"  'join-line)
(global-set-key "\C-xp"    'revert-buffer)
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

(setq auto-mode-alist
      (append '(("\\.\\([pP][Llm]\\|al\\)$" . cperl-mode)
		("^/tmp/mutt-" . message-mode)
		("\\.sawfishrc" . lisp-mode)
		("\\.ph" . cperl-mode)
		("\\.rb" . ruby-mode)
		("\\.asd" . lisp-mode)
		("\\.jl$" . lisp-mode))
	      auto-mode-alist )) 

(global-font-lock-mode 't)

(transient-mark-mode -1)

(setq font-lock-global-modes '(c-mode
  			       c++-mode
			       perl-mode
			       lisp-mode
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

(defun forward-delete-space-through-parens ()
  (interactive)
  (forward-delete-space)
  (when (cheqstr (char-after (point)) ")")
    (forward-char)
    (let ((close nil))
      (save-excursion
	(while (is-space (char-after (point)))
	  (forward-char))
	(when (cheqstr (char-after (point)) ")")
	  (setq close t)))
      (when close 
	(forward-delete-space-through-parens))
      (backward-char))))

(defun beginning-of-line-p ()
  (or (equal (point) 1) (cheqstr (char-before (point)) "\n")))

(defun line-empty-before-point ()
  (save-excursion
    (while (and (not (beginning-of-line-p))
		(is-space (char-before (point))))
      (backward-char))
    (beginning-of-line-p)))

(defun is-tail ()
  (save-excursion
    (while (is-space (char-after (point)))
      (forward-char))
    (cheqstr (char-after (point)) ")")))

(defun consume-sexp-and-indent ()
  (interactive)
  (let ((n 0))
    (while (not (is-tail))
      (incf n)
      (forward-sexp))
    (consume-sexp (< 0 n))
    (backward-sexp)
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
  (while (line-empty-before-point)
    (join-line))
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
  (call-interactively 'move-beginning-of-line)
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
(define-key slime-mode-map "\C-cp" 'slime-insert-eval-last-expression)
(global-set-key "\M-i" 'consume-sexp-and-indent)

(defun my-mark-defun ()
  (interactive)
  (call-interactively 'beginning-of-defun)
  (forward-sexp)
  (call-interactively 'set-mark-command)
  (backward-sexp))

(defun my-lisp-define-key (k b)
  (define-key emacs-lisp-mode-map k b)
  (define-key lisp-interaction-mode-map k b)
  (define-key lisp-mode-map k b))

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

(slime-define-key   "\C-ce" 'slime-insert-expand-last-expression)

(my-lisp-define-key "\C-\M-j" 'lisp-join-line)
(my-lisp-define-key "\C-a"    'lisp-ctrla)
(my-lisp-define-key "\C-\M-h" 'my-mark-defun)
(my-lisp-define-key "\r"      'lisp-newline-and-indent)
(my-lisp-define-key "\C-\M-e" 'backward-transpose-sexp)

(defun define-jk (map)
  (define-key map "u" 'scroll-down-half)
  (define-key map "d" 'scroll-up-half)
  (define-key map "J" 'next-line)
  (define-key map "K" 'previous-line)
  (define-key map "j" 'SUO)
  (define-key map "k" 'SDO)
  (define-key map "/" 'isearch-forward)
  (define-key map "?" 'isearch-backward))


(require 'info)
(require 'view)
(require 'apropos)
(require 'comint)
(require 'man)
(require 'term)


(define-jk Info-mode-map)
(define-jk help-mode-map)
(define-jk view-mode-map)
(define-jk apropos-mode-map)
(define-jk slime-inspector-mode-map)
(define-jk Man-mode-map)
(define-key slime-inspector-mode-map "D" 'slime-inspector-describe)

(define-key term-mode-map (kbd "TAB") 'term-dynamic-complete)
(define-key Info-mode-map "U" 'Info-up)
(define-key Info-mode-map "D" 'Info-directory)

(add-hook 'diff-mode-hook 
	  '(lambda () 
	     (define-key diff-mode-map "\M-q" 'scroll-down-one)
	     (define-key diff-mode-map "a" 'diff-apply-hunk)
	     (define-key diff-mode-map "t" 'diff-test-hunk)))


(add-hook 'before-make-frame-hook '(lambda () (menu-bar-mode -1)))
(add-hook 'window-setup-hook '(lambda () (scroll-bar-mode -1)))
;(add-hook 'emacs-startup-hook '(lambda () (menu-bar-mode -1)))

;(define-key comint-mode-map "\M-p" 'previous-line)
;(define-key comint-mode-map "\M-n" 'next-line)
;(define-key comint-mode-map [up]   'comint-previous-input)
;(define-key comint-mode-map [down] 'comint-next-input)
;(define-key comint-mode-map "\C-p" 'comint-previous-input)
;(define-key comint-mode-map "\C-n" 'comint-next-input)
(define-key comint-mode-map "\C-z" 'scroll-up-one)
(define-key comint-mode-map "\C-q" 'scroll-down-one)


;(define-key view-mode-map "q" '(lambda () (interactive) (view-mode -1)))
(define-key view-mode-map "q" '(lambda () (interactive) 1))
;(define-key view-mode-map " " 'foo)
;(define-key view-mode-map [return] 'foo)
;(define-key view-mode-map [backspace] 'foo)

(define-key text-mode-map "\M-s" 'ispell-region)


(defun SUO (x) (interactive "p")  (scroll-up-one x) (next-line x))
(defun SDO (x) (interactive "p") (scroll-down-one x) (previous-line x))


(add-hook 'cperl-mode-hook 
	  (lambda () 
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
	(call-interactively 'transient-mark-mode)))
 ;   (goto-char p)
 ;    (set-mark m)
    ))

(defun replace-regexp-region-foo (re to) 
  (let ((p (point)) (m (mark)))
  (if transient-mark-mode (replace-regexp re to)
    (unwind-protect
	(progn (call-interactively 'transient-mark-mode)
	       (replace-regexp re to))
      (call-interactively 'transient-mark-mode)))
  (goto-char p)
  (set-mark m)
  ))


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

(setq scheme-program-name "guile")
(autoload 'run-scheme "cmuscheme48" "Run an inferior Scheme process." t)
(autoload 'ruby-mode "ruby-mode" "editor mode for ruby" t)


(defun slime-handle-indentation-update (alist)
  "Update Lisp indent information.

ALIST is a list of (SYMBOL-NAME . INDENT-SPEC) of proposed indentation
settings for `common-lisp-indent-function'. The appropriate property
is setup, unless the user already set one explicitly."
  (dolist (info alist)
    (let ((symbol-name (car info)))
      (unless (and slime-conservative-indentation
                   (string-match "^\\(def\\|\\with-\\)" symbol-name))
        (let ((symbol (intern symbol-name))
              (indent (cdr info)))
          ;; Does the symbol have an indentation value that we set?
          (when (equal (get symbol 'lisp-indent-function)
                       (get symbol 'slime-indent))
            (put symbol 'slime-indent indent)
            (put symbol 'lisp-indent-function indent)))))))

(setq custom-file "~/.custom.el")
(load "~/.custom.el")



(put 'downcase-region 'disabled nil)

(setf (get 'bind 'common-lisp-indent-function) 2)
(setf (get 'defmethod/cc 'common-lisp-indent-function)
      'lisp-indent-defmethod)

