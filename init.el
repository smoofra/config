(require 'cl)

(setq inferior-lisp-program  "sbcl")
;;(setq inferior-lisp-program  "sbcl.cvs")
;;(setq inferior-lisp-program  "/home/larry/allegro/acl62_trial/alisp")
;;(setq inferior-lisp-program  "lisp")
;;(setq inferior-lisp-program  "env SBCL_HOME=/home/larry/usrsbcl/lib/sbcl /home/larry/usrsbcl/bin/sbcl")
;;(setq inferior-lisp-program  "/sw/bin/openmcl --load /Users/larry/.openmcl-init")
;;(setq inferior-lisp-program  "/Users/larry/usr-sbcl-cvs/bin/sbcl --core /Users/larry/usr-sbcl-cvs/lib/sbcl/sbcl.core")

(setq load-path (cons "~/usr/share/emacs/site-lisp" load-path))
(autoload 'maxima "maxima")

(autoload 'svn-status "psvn" "" t)
(eval-after-load 'psvn 
  '(setq svn-status-default-log-arguments '("--verbose"   "--limit=20")))
(autoload 'darcsum-whatsnew "darcsum" "" t)


(setq load-path (cons "/usr/share/maxima/5.9.1/emacs/" load-path))

;(setq load-path (cons "/usr/share/emacs/site-lisp/tnt/" load-path))
(setq load-path (cons "~/config" load-path))
(setq load-path (cons "~/emacslisp" load-path))
(setq load-path (cons "~/emacslisp/tnt-2.5/" load-path))
(setq load-path (cons "~/emacslisp/emacs-cl" load-path))
(setq load-path (cons "~/emacslisp/darcs-mode" load-path))
(autoload 'lisppaste-paste-region "lisppaste" "lisppaste" t)

;;(setq browse-url-browser-function 'browse-url-firefox)
(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "web browser" t)
(autoload 'tnt-open "tnt" "tnt" t)


(autoload 'bubble-buffer-next "bubble-buffer")
(autoload 'bubble-buffer-previous "bubble-buffer")
(global-set-key [f11] 'bubble-buffer-next)
(global-set-key [(shift f11)] 'bubble-buffer-previous)

(autoload 'javascript-mode "javascript" "javascript-mode" t)


(defvar pending-emacsmerge nil)
(defvar emacsmerge-wc nil)
(defvar emacsmerge-a nil)
(defvar emacsmerge-b nil)
(defvar emacsmerge-ancestor nil)
(defvar emacsmerge-out nil)
(defvar emacsmerge-pid nil)

(defun done-emacsmerge ()
  (interactive)
  (when pending-emacsmerge
    (call-process "/bin/kill" nil nil nil "-HUP" (prin1-to-string pending-emacsmerge))
    (setq pending-emacsmerge nil)
    (run-at-time ".1 sec" nil (lambda () (set-window-configuration emacsmerge-wc)))))

(defun emacsmerge-setup-quit-hook ()
  (setq emerge-quit-hook 
	(cons (lambda ()
		(done-emacsmerge))
	      emerge-quit-hook)))

(defun dmerge ()
  (interactive)
  (setq emacsmerge-wc (current-window-configuration))
  (emerge-files-with-ancestor nil emacsmerge-a emacsmerge-b emacsmerge-ancestor emacsmerge-out)
  (window-configuration-to-register ?j))

(defun emacsmerge (pid a b ancestor out)
  (setq pending-emacsmerge pid)
  (setq emacsmerge-a a)
  (setq emacsmerge-b b)
  (setq emacsmerge-ancestor ancestor)
  (setq emacsmerge-out out)
  (setq emacsmerge-pid pid)
  (run-at-time ".1 sec" nil (lambda () (call-interactively (quote dmerge))))
  nil)

(add-hook 'emerge-startup-hook 'emacsmerge-setup-quit-hook)

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
  
  (def-slime-selector-method ?C
	"*compilation* buffer"
	(get-buffer "*compilation*"))
  
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
  
  (def-slime-selector-method ?y
    "*shell* buffer."
    (get-buffer "*shell*"))

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

(defun link-url (url)
  (call-process "chain" nil nil nil url "1"))

(defun links ()
  (interactive)
  (occur "https?://[^ ]*"))

(global-set-key "\C-x4l" 'link-url-at-point)
(global-set-key "\C-x4k" 'browse-url-at-point)

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
  (slime-remove-old-overlays)
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
;;;; C-x C-SPC to go back if it sends you to a new buffer
;;;; C-U C-SPC to go back in the current buffer
;;;; damn  that's stupid
(define-key lisp-interaction-mode-map "\M-." 'find-function) 
(define-key emacs-lisp-mode-map "\M-." 'find-function)
(define-key emacs-lisp-mode-map "\M-/" 'lisp-complete-symbol)

(when i-have-slime
  (slime-define-key "\M-c" 'my-unhighlight)
  (slime-define-key [tab] 'slime-indent-and-complete-symbol)
  (slime-define-key [(control tab)]   'tab-to-tab-stop)
  (slime-define-key "\M-/" 'slime-fuzzy-complete-symbol)
  (define-key slime-repl-mode-map "\M-/" 'slime-fuzzy-complete-symbol))
 

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

;;;;from emacs source, modified
(eval-after-load "diff"
  '(defun diff-sentinel (code)
	 "Code run when the diff process exits.
     CODE is the exit code of the process.  It should be 0 iff no diffs were found."
	 (if diff-old-temp-file (delete-file diff-old-temp-file))
	 (if diff-new-temp-file (delete-file diff-new-temp-file))
	 (save-excursion
	   (goto-char (point-max))
	   (let ((inhibit-read-only t))
		 (insert (format "\nDiff finished%s.  %s\n"
						 (if (equal 0 code) " (no differences)" "")
						 (current-time-string)))))
	 (when (and (not (null buffer-to-revert-if-no-diff))
				(equal 0 code))
	   (set-buffer buffer-to-revert-if-no-diff)
	   (revert-buffer t t t))
	 (setq diff-return-code code)))
 

(defvar diff-return-code nil)
(defvar buffer-to-revert-if-no-diff nil)

(defun diff-current-buffer-with-file ()
  (interactive)
  (let ((wc (current-window-configuration))
		(buffer-to-revert-if-no-diff (current-buffer))
		(diff-return-code nil))
	(diff-buffer-with-file (current-buffer))
	(cond 
	 ((equal diff-return-code 0)
	  (message "no diff")
	  ;;(read-char nil nil .5)
	  (sit-for .5)
	  (set-window-configuration wc))
	 (t 
	  (save-excursion 
		(set-buffer (get-buffer "*Diff*"))
		(toggle-read-only 1))))))

(defun my-revert-buffer () 
  (interactive)
  (revert-buffer-with-coding-system buffer-file-coding-system))

;;; keymap properties aren't overlays!
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
(global-set-key [(f12)]    'delete-window)
(global-set-key [(f2)]     'next-error)
(global-set-key "\C-xe"    'next-error)
(global-set-key "\C-xd"    'beginning-of-defun)
(global-set-key "\M-_"     'unwrap-next-sexp)
(global-set-key "\C-x\C-b" 'ibuffer)

(if (>= emacs-major-version 22)
    (global-set-key "\C-\M-y"  'my-insert-parentheses)
  (global-set-key "\C-\M-y"  'insert-parentheses))

(global-set-key "\C-\M-j"  'join-line)
(global-set-key "\C-xp"    'my-revert-buffer)
(global-set-key "\C-x\C-p" 'diff-current-buffer-with-file)
(global-set-key "\C-x`"    'delete-other-windows)
(global-set-key "\M-o"     'switch-to-buffer)
(global-set-key "\M-e"     'call-last-kbd-macro)
(global-set-key "\C-xm"    'comp)
(global-set-key "\C-x\C-m" 'compi)
(define-key ctl-x-map [(control 59)] mule-keymap) ;;; 59 is semicolon
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
;(global-set-key   "\M-\C-z"   'scroll-up-half)
;(global-set-key "\M-\C-a"   'scroll-down-half)
(global-set-key [home] 'SDO)
(global-set-key [end]  'SUO)
(global-set-key "\M-," 'pop-tag-mark)
(global-set-key "\M-*" 'tags-loop-continue)
(global-set-key "\C-xj" 'other-frame)

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

(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\)$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.sawfishrc" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.mak" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.php" . php-mode))
(add-to-list 'auto-mode-alist '("\\.pl" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.ph" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.rb" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.asd" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.jl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.css$" . css-mode))
;;(add-to-list 'auto-mode-alist '("\\.js" . javascript-mode))
;;(add-to-list 'magic-mode-alist (cons "#!.*perl" 'cperl-mode))

(when (>= emacs-major-version 22)
  (add-to-list 'auto-mode-alist 
	       (cons "^/tmp/mutt-" 'message-mode)))

(defun setup-nxml-crap ()
  (add-to-list 'auto-mode-alist
	       (cons (concat "\\." (regexp-opt '("xsl" "rss" "rdf" "xml" "xsd" "sch" "rng" "xslt" "svg" "rss") t)
			     "\\'")
		     'nxml-mode))
  (add-to-list 'magic-mode-alist
	       (cons "<\\?xml" 'nxml-mode)))

(eval-after-load "nxml-mode"
  '(setup-nxml-crap))


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


(defun c-unwrap-next-sexp (&optional kill-n-sexps)
  "Convert (x ...) to ..."
  (interactive "P")
  (forward-sexp)
  (backward-delete-char 1)
  (set-mark (point))
  (backward-up-list)
  (delete-char 1)
  (c-indent-command)
  (call-interactively 'indent-region))

;;orig. by marco baringer
(defun unwrap-next-sexp (&optional arg)
  "Convert (x ...) to ..."
  (interactive "P")
  (forward-sexp)
  (backward-delete-char 1)
  (set-mark (point))
  (backward-up-list)
  (delete-char 1)
  (unless arg
    (let ((start-region-to-kill (point)))
      (kill-sexp 1)
      (forward-sexp)
      (backward-sexp)
      (delete-region start-region-to-kill (1- (point)))))
  (lisp-indent-line)
  (lisp-indent-region (point) (mark)))

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

(defun unwrap-sexp-at-mark ()
  (interactive)
  (if (> (mark) (point))
      (exchange-point-and-mark))
  (let ((x (copy-marker (point))))
    (kill-sexp)
    (exchange-point-and-mark)
    (lisp-yank)
    (lisp-newline-and-indent)
    (lisp-newline-and-indent)
    (indent-pp-sexp)
    (setf (mark) x)))

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
    ;;(lisp-indent-line)
    (indent-according-to-mode))
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
            ;;(lisp-newline-and-indent)
            (newline)
            (indent-according-to-mode))
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
(global-set-key "\M-i" 'consume-sexp)

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

(defun c-join-line ()
  (interactive)
  (join-line)
  (c-indent-command))

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
(my-lisp-define-key "\M-i"    'consume-sexp-and-indent)
(my-lisp-define-key "\M-I"    'unwrap-sexp-at-mark)
(my-lisp-define-key "\M-y"    'lisp-yank-pop)
(my-lisp-define-key "\M-k"    'save-sexp)
(my-lisp-define-key "\C-\M-j" 'lisp-join-line)
(my-lisp-define-key "\C-a"    'lisp-ctrla)
(my-lisp-define-key "\C-\M-h" 'my-mark-defun)
(my-lisp-define-key "\r"      'lisp-newline-and-indent)
(my-lisp-define-key "\C-\M-e" 'backward-transpose-sexp)
(my-lisp-define-key "\C-j"    'backwards-kill-line)

(when i-have-slime
  (define-my-lisp-keys-on-map slime-mode-map)
  (define-my-lisp-keys-on-map slime-repl-mode-map)
  (define-my-lisp-keys-on-map slime-scratch-mode-map))
(define-my-lisp-keys-on-map emacs-lisp-mode-map)
(define-my-lisp-keys-on-map lisp-interaction-mode-map)
(define-my-lisp-keys-on-map lisp-mode-map)


(when i-have-slime
  (defun slime-repl-backwards-kill-line ()
    (interactive)
    (let ((p (point)))
      (slime-repl-bol)
      (kill-region (point) p)))
  
  (define-key slime-repl-mode-map "\C-j" 'slime-repl-backwards-kill-line)
  (define-key slime-repl-mode-map "\r"   'slime-repl-return)
  (define-key slime-repl-mode-map "\C-a" 'slime-repl-bol))

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

(defun comint-previous-matching-input-feh () 
  (interactive)
  (comint-previous-matching-input (car minibuffer-history-search-history) 1))

(defun comint-next-matching-input-feh () 
  (interactive)
  (comint-next-matching-input (car minibuffer-history-search-history) 1))

(eval-after-load 'comint
  '(progn
     (define-key comint-mode-map "\M-\C-r" 'comint-previous-matching-input-feh)
     (define-key comint-mode-map "\M-\C-s" 'comint-next-matching-input-feh)
     (define-key comint-mode-map "\M-/" 'comint-dynamic-list-filename-completions)
     (define-key comint-mode-map "\M-?" 'help)
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
  (define-key term-raw-map "\C-c\C-y" 'term-paste)
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

;; (define-key view-mode-map "q" '(lambda () (interactive) (view-mode -1)))
;; (define-key view-mode-map " " 'foo)
;; (define-key view-mode-map [return] 'foo)
;; (define-key view-mode-map [backspace] 'foo)

(when i-have-slime
  (define-jk slime-inspector-mode-map)
  (define-key slime-inspector-mode-map "D" 'slime-inspector-describe))


;;; (setq Info-additional-directory-list '("/usr/share/info/emacs-snapshot"))

(eval-after-load 'info 
  '(progn
     (define-key Info-mode-map "u" 'scroll-down-half)
     (define-key Info-mode-map "d" 'scroll-up-half)
     (define-key Info-mode-map "k" 'scroll-down-one)
     (define-key Info-mode-map "j" 'scroll-up-one)
     (define-key Info-mode-map "h" 'backward-char)
     (define-key Info-mode-map "l" 'forward-char)
     (define-key Info-mode-map "n" 'next-line)
     (define-key Info-mode-map "d" 'next-line)
     (define-key Info-mode-map "u" 'scroll-down-half)
     (define-key Info-mode-map "d" 'scroll-up-half)
     (define-key Info-mode-map "N" 'Info-next)
     (define-key Info-mode-map "L" 'Info-history-back)
     (define-key Info-mode-map "H" 'Info-history)
     (define-key Info-mode-map "P" 'Info-prev)
     (define-key Info-mode-map "U" 'Info-up)
     (define-key Info-mode-map "D" 'Info-directory)))

(setq diff-default-read-only t)

(add-hook 'diff-mode-hook 
	  '(lambda () 
	     (define-key diff-mode-map "\M-q" 'scroll-down-one)
	     (define-jk diff-mode-shared-map)
             (define-jk diff-mode-map)
             (define-key diff-mode-map "a" 'diff-apply-hunk)
	     (define-key diff-mode-map "t" 'diff-test-hunk)))


(add-hook 'before-make-frame-hook '(lambda () (menu-bar-mode -1)))
(add-hook 'window-setup-hook '(lambda () (scroll-bar-mode -1)))
;(add-hook 'emacs-startup-hook '(lambda () (menu-bar-mode -1)))

(define-key text-mode-map "\M-s" 'ispell-region)

(defun SUO (x) (interactive "p")  (scroll-up-one x) (next-line x))
(defun SDO (x) (interactive "p") (scroll-down-one x) (previous-line x))

(eval-after-load 'cperl 
  (setq cperl-invalid-face 'default))

(add-hook 'cperl-mode-hook 
	  (lambda () 
            (define-key cperl-mode-map "\M-_"   'c-unwrap-next-sexp)
            (define-key cperl-mode-map "\r" 'newline-and-indent)
	    (define-key cperl-mode-map "(" 'self-insert-command)
	    (define-key cperl-mode-map "\"" 'self-insert-command)
	    (define-key cperl-mode-map "[" 'self-insert-command)
	    (define-key cperl-mode-map "{" 'self-insert-command)
	    (define-key cperl-mode-map "\C-j" 'backwards-kill-line)))

(add-hook 'latex-mode-hook 
	  (lambda () 
            (setq skeleton-pair t)
            (define-key latex-mode-map ""  'newline-and-indent)
            (define-key latex-mode-map [(control tab)] 'tab-to-tab-stop)
	    (define-key latex-mode-map "\C-j" 'backwards-kill-line)))

(add-hook 'ruby-mode-hook
	  (lambda () 
	    (define-key ruby-mode-map "\C-j" 'backwards-kill-line)))

(defun replace-regexp-region () 
  (interactive)
  (let ((end (copy-marker (max (point) (mark)))))
    (if transient-mark-mode (call-interactively 'replace-regexp)
      (unwind-protect
          (progn (call-interactively 'transient-mark-mode)
                 (call-interactively 'replace-regexp))
        (call-interactively 'transient-mark-mode)))
    (setf (point) end)))

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
  (if (= (point) (+ 1 (buffer-size)))
      (backward-char))
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

(defvar comp-default-directory nil)

(defun end-of-compilation-buffer (buf str)
  (set-window-point (get-buffer-window buf) 
					(save-excursion 
					  (set-buffer buf)
					  (point-max))))

(setq compilation-finish-functions (list 'end-of-compilation-buffer))

(defun comp (&optional i)
  (interactive)
  (if i (call-interactively 'compile) (compile compile-command))
  (set-window-lines (get-buffer-window "*compilation*") 20)
  (when comp-default-directory 
	  (save-excursion
		(set-buffer "*compilation*")
		(setq default-directory comp-default-directory))))

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

;; (defun silly-scroll-down-one-hack ()
;;   (interactive)
;;   (previous-line)
;;   (scroll-down-one 1)
;;   (next-line))

(eval-after-load 'erc
  '(progn (add-hook 'erc-join-hook 'bitlbee-identify)
          ;;;(define-key erc-mode-map "\M-q" 'silly-scroll-down-one-hack )
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


;;;; indentation-related crap
; c-default-style
; c-basic-offset
; indent-tabs-mode
; tab-width
; c-backspace-function
; backward-delete-char-untabify-method
; c-set-style

(defun setup-tramp ()
  (interactive)
  (require 'tramp)
  (setq tramp-default-method "scp"))


(defun c-kill-line ()
  (interactive)
  (call-interactively 'kill-line)
  ;;(c-indent-command)
  )

(defun c-open-line ()
  (interactive)
  (call-interactively 'open-line)
  (save-excursion 
	(next-line)
	(c-indent-command)))


(eval-after-load 'cc-mode
  '(progn 
	 (defun c-newline-and-indent ()
	   (interactive)
	   (newline)
	   (c-indent-command))
	 (define-key c-mode-map "\C-o"   'c-open-line)
	 (define-key c-mode-map "\C-k"   'c-kill-line)
	 (define-key c-mode-map "\M-_"   'c-unwrap-next-sexp)
	 (define-key c-mode-map [return] 'c-newline-and-indent)
	 (define-key c-mode-map "\C-\M-j" 'c-join-line)))


;; hl-line-mode will highlight the current line, 
;; but i woln't be able to remember it's name
(defun highlight-current-line-mode ()
  (interactive)
  (hl-line-mode))


(defun advance-column ()
  (interactive)
  (let ((c (current-column))
		(lp nil))
	(while (and (not (is-space (char-after (point))))
				(is-space (char-before (point))))
	  (setq lp (point))
	  (forward-line -1)
	  (setf (current-column) c))
	(setf (point) lp)
	(advance-column-down)))

(defun advance-column-down ()
  (interactive)
  (when (and (not (is-space (char-after (point))))
			 (is-space (char-before (point))))
	(let ((c (current-column)))
	  (call-interactively 'tab-to-tab-stop)
      (forward-line)
	  (setf (current-column) c)
      (advance-column))))

(add-hook 'c-mode-common-hook '(lambda ()
                                 (setq indent-tabs-mode t)
                                 (setq tab-width 4) 
                                 (setq c-basic-offset 4)))

;; to keep long lines from wrapping around use toggle-truncate-lines

;; amazing fucking awesome buffer switcher
(require 'iswitchb)
(iswitchb-mode 1)
;;(global-set-key "\C-xb" 'iswitchb-buffer)

;; amazing fucking awesome quicksilver-like thing
(defvar i-have-anything (load "anything" t))
(when i-have-anything 
  (define-key anything-map  "\C-n" 'anything-next-line)
  (define-key anything-map  "\C-p" 'anything-previous-line)
  (anything-iswitchb-setup))

(defun open-scratches ()
  (let ((enable-local-eval t))
    (find-file "~/slime-scratch.lisp")
    (ignore-errors
      (kill-buffer "*scratch*"))
    (find-file "~/scratch.el")))

(setq x-select-enable-clipboard t)

(defvar nice-font "Bitstream Vera Sans Mono-13")

;;dont' forget to remove any default font from .custom.el
(defun set-nice-font (&optional x)
  (let ((f (selected-frame)))
    (when x 
      (select-frame x))
    (set-default-font nice-font)
    (select-frame f)))

(defun set-nice-font-setter ()
  (setq after-make-frame-functions 
        (cons 'set-nice-font after-make-frame-functions)))



;;;;; C-g fucked up, fix it.
(setq 
 query-replace-map
 (cons 'keymap (cons (cons 33554439 'exit) (cdr query-replace-map))))


;;;freaking, yay.  this should be the default though.
(setq comint-prompt-read-only 1)
(eval-after-load 'shell
  '(progn
     (add-hook 'shell-mode-hook 'my-shell-hook)
     (load-library "ansi-color")
     (ansi-color-for-comint-mode-on)
     (setq shell-font-lock-keywords nil)
     (define-key shell-mode-map "\M-?" 'help)))

(defun my-shell-hook ()
  (setq comint-last-output-start (copy-marker 0))
  (end-of-buffer)
  ;;(insert "echo foo")
  ;;(call-interactively 'comint-send-input)
  (shell-send-columns)
    )

(defun shell-send-line (s)
  (shell)
  (end-of-buffer)
  (set-mark (point))
  (move-beginning-of-line nil)
  (call-interactively 'kill-region)
  (insert s)
  ;;(comint-send-input nil t)
  (call-interactively 'comint-send-input)
  (yank))

(defun here-shell ()
  (interactive)
  (let ((dd default-directory))
    (shell-send-line (concat "cd " dd))))

(defun shell-send-columns ()
  (interactive)
  (shell-send-line (concat "export COLUMNS=" (prin1-to-string (window-width)))))

(setq grep-command "grep -nHir ")

(setq make-backup-files nil)



;;; to get the x clipboard selection use x-clipboard-yank
;;; to get the primary selection just yank 



(setq custom-file "~/config/init.el")
;;(load "~/.custom.el" t)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(Info-additional-directory-list (quote ("/usr/share/info/emacs-snapshot")))
 '(Man-notify-method (quote pushy))
 '(blink-cursor-alist (quote ((box . box) (t . box))))
 '(c-basic-offset 4)
 '(c-default-style (quote ((c-mode . "k&r") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(cperl-invalid-face (quote default))
 '(delete-selection-mode nil)
 '(diff-switches "-u")
 '(erc-track-exclude-types (quote ("JOIN" "NICK" "PART" "QUIT")))
 '(indent-tabs-mode nil)
 '(safe-local-variable-values (quote ((syntax . common-lisp) (package . common-lisp) (Package . CLIM-DEMO) (Package . MCCLIM-FREETYPE) (Syntax . Common-Lisp) (Package . CLIMI) (Package . CLIM-INTERNALS) (unibyte . t) (Package . COMMON-LISP-USER))))
 '(slime-backend "swank-loader.lisp")
 '(slime-enable-evaluate-in-emacs t)
 '(slime-multiprocessing t)
 '(svn-status-default-log-arguments (quote ("--verbose   --limit=20")))
 '(tab-width 8)
 '(woman-use-own-frame nil))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "#ffffff"))))
 '(diff-changed ((nil (:foreground "yellow"))))
 '(diff-file-header ((((class color) (min-colors 88) (background dark)) (:foreground "cyan" :weight bold))))
 '(diff-header ((((class color) (min-colors 88) (background dark)) (:foreground "green" :weight bold))))
 '(diff-removed ((t (:inherit diff-changed :foreground "red"))))
 '(mmm-default-submode-face ((t (:background "gray85" :foreground "black")))))



;;; this seems to be a problem so we'll just set it outside of custom for everything
;;;'(default ((t (:stipple nil :background "#000000" :foreground "#ffffff" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 133 :width normal :family "bitstream-bitstream vera sans mono"))))

(cond 
 ((display-graphic-p)
  (set-face-background 'default "#110022")
  (set-face-foreground 'default "#ffffff"))
 (t
  (set-face-background 'default "#000000")))

(defun find-diff-file (file)
  (interactive)
  (find-file file)
  (diff-mode))

;;;;;; how to find out how to bind a particular key interactively 
;;; M-x global-set-key
;;; M-x repeat-complex-command (or C-x ESC ESC)

;;test change for git, again.  now testing pushing. again

(site-init-late)

;;bar

(define-skeleton latex-begin 
   "\begin something"
   ""
   "\\begin{" (setq foo (skeleton-read "begin what? ")) "}" ?\n > _ > ?\n > "\\end{" foo "}" >)

(define-abbrev latex-mode-abbrev-table "beg" "" 'latex-begin)



