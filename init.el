
;; coding-system stuff is at C-x C-;
;; to figure out where a command is, or to find the key it's bound to, use where-is

;;; when slime highlights the stuff that isn't compiled, it's slime-highlight-edits-mode

;; to switch to a buffer that's visible in another window, use C-x 4 b iswitchb-buffer-other-window

;;; (debiafy) in .site init for debian crap


(require 'cl)

(setq load-path (cons "~/usr/share/emacs/site-lisp" load-path))
(autoload 'maxima "maxima")

(autoload 'svn-status "psvn" "" t)
(eval-after-load 'psvn 
  '(setq svn-status-default-log-arguments '("--verbose"   "--limit=20")))
(autoload 'darcsum-whatsnew "darcsum" "" t)
(autoload 'paredit-mode "paredit" "" t)
(add-hook 'lisp-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode +1)))


(setq load-path (cons "/usr/share/emacs/site-lisp/maxima/" load-path))

(setq load-path (cons "~/config" load-path))
(setq load-path (cons "~/config/emacslisp" load-path))

(autoload 'lisppaste-paste-region "lisppaste" "lisppaste" t)

;;(setq browse-url-browser-function 'browse-url-firefox)
(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "web browser" t)


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

(defun tt ()
  (interactive)
  (toggle-truncate-lines))

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


(defun chat () 
  (interactive)
  (if  (get-register ?C)
      (progn (jump-to-register ?C)
             (let ((win (selected-window))
                   (done nil))
               (while (not done)
                 (end-of-buffer)
                 (other-window 1)
                 (when (eq win (selected-window))
                   (setq done t))))
             (current-buffer))
    (progn
      (delete-other-windows)
      (split-window-vertically)
      (switch-to-buffer "mgwyer")
      (other-window 1)
      (switch-to-buffer "#yourmom"))))

(defun chat-yourmom ()
  (interactive)
  (switch-to-buffer "#yourmom"))

(defun chat-mgwyer ()
  (interactive)
  (switch-to-buffer "mgwyer"))



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

(defun can-forward-sexp ()
  (condition-case err
      (save-excursion
        (forward-sexp)
        t)
    (error nil)))

(defun my-forward-sexp ()
  (interactive)  
  (if (can-forward-sexp)
      (call-interactively 'forward-sexp)
    (progn
      (up-list)
      (backward-char))))

(defun semi-forward-sexp ()
  (interactive)
  (if (looking-at "[ \n]*)")
      (progn (up-list)
             (backward-char))
    (let ((a (point)))
      (forward-sexp)
      (let ((b (point)))
        (backward-sexp)
        (unless (< a (point))
          (setf (point) b))))))

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
;  (if (= (char-before (point)) ?\) )
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

(defvar my-function-places nil)


(autoload 'find-function-read "find-func")
(defun my-find-function (function)
  (interactive (find-function-read))
  (push  (copy-marker (point)) my-function-places)
  (find-function-do-it function nil 'switch-to-buffer))

(defun my-pop-function ()
  (interactive)
  (let ((p (pop my-function-places)))
    (when p 
      (switch-to-buffer (or (marker-buffer p)
                            (error "The marked buffer has been deleted")))
      (goto-char p))))

(define-key lisp-interaction-mode-map "\M-." 'my-find-function) 
(define-key emacs-lisp-mode-map "\M-." 'my-find-function)
(define-key lisp-interaction-mode-map "\M-," 'my-pop-function) 
(define-key emacs-lisp-mode-map "\M-," 'my-pop-function)
(define-key emacs-lisp-mode-map "\M-/" 'lisp-complete-symbol)






(tool-bar-mode -1)

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


;; this is the old version that doesn't seem to work with new emacs
(if nil
    (eval-after-load "diff"
      ;; from emacs source, modified
      (quote (defun diff-sentinel (code)
               "Code run when the diff process exits.
            CODE is the exit code of the process.  It should be 0
            iff no diffs were found."
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
                 (my-revert-buffer t t))
               (setq diff-return-code code)))))


(eval-after-load "diff"
  ;; from emacs source (diff.el), modified
  '(defun diff-sentinel (code &optional old-temp-file new-temp-file)
     (if old-temp-file (delete-file old-temp-file))
     (if new-temp-file (delete-file new-temp-file))
     (diff-setup-whitespace)
     (goto-char (point-min))
     (save-excursion
       (goto-char (point-max))
       (let ((inhibit-read-only t))
         (insert (format "\nDiff finished%s.  %s\n"
                         (cond ((equal 0 code) " (no differences)")
                               ((equal 2 code) " (diff error)")
                               (t ""))
                         (current-time-string)))))
     (when (and (not (null buffer-to-revert-if-no-diff))
                (equal 0 code))
       (set-buffer buffer-to-revert-if-no-diff)
       (my-revert-buffer t t))
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
      (sit-for .5)
      (set-window-configuration wc))
     (t 
      (save-excursion 
        (set-buffer (get-buffer "*Diff*"))
        (toggle-read-only 1))))))


(defun my-revert-buffer (&optional noconfirm preserve-modes) 
  (interactive)
  (check-coding-system buffer-file-coding-system)
  (let ((coding-system-for-read buffer-file-coding-system))
    (revert-buffer t noconfirm preserve-modes)
    (ignore-errors 
      (delete-file buffer-auto-save-file-name))))

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

(show-paren-mode t)

(defun my-server-done ()
  (interactive)
  (dolist (x server-clients)
    (when (eql (current-buffer) (cadr x))
      (call-interactively 'server-edit))))

(defun bury ()
  (interactive)
  (if (= 1 (length (window-list)))
      (bury-buffer)
    (progn
      (bury-buffer)
      (delete-window))))

(defun bury-all ()
  (interactive)
  (let ((bufs 
         (loop for x in (window-list)
               collect (window-buffer x))))
    (delete-other-windows)
    (loop for x in bufs
          do (progn
               (set-buffer x)
               (bury-buffer)))))

(global-set-key "\C-c\C-c" 'my-server-done)
(global-set-key "\\" 'indent-region)
(global-set-key [C-return] 'open-line)
(global-set-key [(f1)] 'delete-other-windows)
(global-set-key [(f12)] 'bury)
(global-set-key [(f7)] 'chat-yourmom)
(global-set-key [(f8)] 'chat-mgwyer)
(global-set-key [(f9)] 'chat)
(global-set-key [(f10)] 'erc-next-channel)
(global-set-key [(control x) (f12)] 'bury-all)

(global-set-key [(f2)]     'next-error)
(global-set-key "\C-xe"    'next-error)
(global-set-key "\C-xd"    'beginning-of-defun)
(global-set-key "\M-_"     'unwrap-next-sexp)
(global-set-key "\C-x\C-b" 'ibuffer)

(if (>= emacs-major-version 22)
    (global-set-key "\C-\M-y"  'my-insert-parentheses)
  (global-set-key "\C-\M-y"  'insert-parentheses))

(global-set-key "\C-c;"     'comment-region)
(global-set-key "\C-\M-j"  'join-line)
(global-set-key "\C-xp"    'my-revert-buffer)
(global-set-key "\C-x\C-p" 'diff-current-buffer-with-file)
(global-set-key "\C-x`"    'delete-other-windows)
(global-set-key "\M-o"     'switch-to-buffer)
;;(global-set-key "\M-e"     'call-last-kbd-macro)
(global-set-key "\M-e"     'kmacro-call-macro)
(global-set-key "\C-xm"    'comp)
(global-set-key "\C-x\C-m" 'compi)
(define-key ctl-x-map [(control 59)] mule-keymap) ;;; 59 is semicolon
(global-set-key "\C-p"     'previous-line)
(global-set-key "\C-x\M-f" 'view-file)
(global-set-key "\M-\""     'transient-mark-mode)
;(global-set-key "\C-h\M-a"  'apropos)
(global-set-key "\C-xf"     'set-visited-file-name)
;(global-set-key "\C-z"      'scroll-up-one)
;(global-set-key "\C-z"      'SUO)
;(global-set-key "\C-q"      'SDO)
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
;(global-set-key "\M-z"      'suspend-emacs)
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
(global-set-key "\C-v" 'jk-mode)
(global-set-key "\M-j" 'jk-mode)
;;; \C--
(global-set-key (quote [67108909]) 'toggle-truncate-lines)


;(global-set-key   "\M-\C-z"   'scroll-up-half)
;(global-set-key "\M-\C-a"   'scroll-down-half)
(global-set-key [home] 'SDO)
(global-set-key [end]  'SUO)
(global-set-key "\M-," 'pop-tag-mark)
(global-set-key "\M-*" 'tags-loop-continue)
(global-set-key "\C-xj" 'other-frame)
(global-set-key "\C-xi" 'back-window)
(global-set-key "\C-xI" 'insert-file) 
(global-set-key "\C-xg" 'grep)
(global-set-key [insertchar] 'repeat)
       
(setq perl-indent-level 2)

(setq compile-command "make | cat")

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

(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\)$" . perl-mode))
(add-to-list 'auto-mode-alist '("\\.sawfishrc$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.mak$" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
;(add-to-list 'auto-mode-alist '("\\.m$". octave-mode))
(add-to-list 'auto-mode-alist '("\\.m$". objc-mode))
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.asd$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.jl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.css$" . css-mode))
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.c$" . c-mode))
(add-to-list 'auto-mode-alist '("\\.h$" . c-mode))

;;(add-to-list 'auto-mode-alist '("\\.js" . javascript-mode))
;;(add-to-list 'magic-mode-alist (cons "#!.*perl" 'cperl-mode))

;; (add-to-list 'interpreter-mode-alist '("perl" . perl-mode))

;; (when (>= emacs-major-version 22)
;;   (add-to-list 'auto-mode-alist 
;; 	       (cons "^/tmp/mutt-" 'message-mode)))
;; (add-hook 'message-mode-hook 
;; 	  '(lambda ()
;; 	     (define-key message-mode-map "\C-cs" 'skip-to-body)))

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

(setq font-lock-global-modes t)

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
  (unless (or t arg) ;;;; im not sure i like it deleteing the head anymore
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
      (if (= (char-after (point)) ?\n)
	  (setq newlines t))
      (delete-char 1))
    newlines))

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
  (or (equal (point) 1) (= (char-before (point)) ?\n)))

(defun end-of-line-p ()
  (or (null (char-after (point))) (= (char-after (point)) ?\n)))

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
    (= (char-after (point)) ?\))))

(defun grab-quotes-before-point ()
  (if (or (= (char-before (point)) ?')
	  (= (char-before (point)) ?`))
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

(defun sexp-inside-out (&optional arg)
  (interactive "P")
  (setf (mark)
        (if arg (mark) 
          (save-excursion 
            (backward-up-list) (point))))
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


(defun buffer-is-cc-mode ()
  nil)

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
                     (not (buffer-is-cc-mode))
                     (not (= (char-before (point)) ?\[ ))
                     (not (= (char-before (point)) ?\{ ))
                     (not (= (char-before (point)) ?\` ))
                     (not (= (char-before (point)) ?\' ))
                     (not (= (char-before (point)) ?\( ))
                     (not (= (char-before (point)) ?\  )))
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






(global-set-key "\M-'" 'forward-delete-space-through-parens)
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



(defun define-my-lisp-keys-on-map (map)
  (dolist (cns my-lisp-keys)
    (define-key map (car cns) (cdr cns))))

(defun indent-defun ()
  (interactive)
  (let ((x (copy-marker (point))))
    (beginning-of-defun)
    (indent-sexp)
    (goto-char x)))


(defun define-jk (map)
  (define-key map "h" 'backward-char)
  (define-key map "l" 'forward-char)
  (define-key map "H" 'scroll-right)
  (define-key map "L" 'scroll-left)
  (define-key map "u" 'scroll-down-half)
  (define-key map "d" 'scroll-up-half)
  (define-key map "J" 'next-line)
  (define-key map "K" 'previous-line)
  (define-key map "j" 'SUO)
  (define-key map "k" 'SDO)
  (define-key map "/" 'isearch-forward)
  (define-key map "?" 'isearch-backward))

(defun jk-warn ()
  (interactive)
  (message "you're in jk mode dumbass"))

(defvar jk-keymap nil)
(defvar jk-implies-readonly t)
(progn
  (make-variable-buffer-local 'jk-implies-readonly)
  (setq jk-keymap (make-keymap))
  (loop for i from 32 to 126 
        do (define-key jk-keymap (char-to-string i) 'jk-warn))
  (define-key jk-keymap "" 'jk-warn)
  (define-jk jk-keymap)
  (define-minor-mode jk-mode
    "a lightweight version view mode with vilike movement key "
    :init-value nil
    :lighter " jk"
    :keymap jk-keymap
    (if jk-implies-readonly
        (if jk-mode
            (progn 
              (setq jk-buffer-read-only buffer-read-only)
              (toggle-read-only 1))
          (toggle-read-only (if jk-buffer-read-only 1 -1))))))

 
(defun my-lisp-define-key (k b)
  (setq my-lisp-keys (cons (cons k b) my-lisp-keys)))

;;lisp keybinds
(progn
  (defvar my-lisp-keys nil)
  (setq my-lisp-keys nil)
  (my-lisp-define-key "\C-\M-n" 'semi-forward-sexp)
  (my-lisp-define-key "\C-\M-p" 'semi-backward-sexp)
  (my-lisp-define-key "\\"    'indent-defun)
  (my-lisp-define-key "("       'my-insert-parentheses) 
  (my-lisp-define-key ")"       'up-list)
  (my-lisp-define-key "\C-c;"   'comment-region)
  (my-lisp-define-key "\C-c-"   'kill-backward-up-list)
  (my-lisp-define-key "\C-y"    'lisp-yank)
  (my-lisp-define-key "\M-i"    'consume-sexp-and-indent)
  (my-lisp-define-key "\M-I"    'sexp-inside-out)
  (my-lisp-define-key "\M-y"    'lisp-yank-pop)
  (my-lisp-define-key "\M-k"    'save-sexp)
  (my-lisp-define-key "\C-\M-f" 'my-forward-sexp)
  (my-lisp-define-key "\C-\M-j" 'lisp-join-line)
  (my-lisp-define-key "\C-a"    'beginning-of-line)
  (my-lisp-define-key "\C-\M-h" 'my-mark-defun)
  (my-lisp-define-key "\r"      'lisp-newline-and-indent)
  (my-lisp-define-key "\C-\M-e" 'backward-transpose-sexp)
  (my-lisp-define-key "\""      'skeleton-pair-insert-maybe)
  (my-lisp-define-key "\C-j"    'backwards-kill-line)
  (my-lisp-define-key "\C-cd"   'mark-defun)

  (define-my-lisp-keys-on-map emacs-lisp-mode-map)
  (define-my-lisp-keys-on-map lisp-interaction-mode-map)
  (define-my-lisp-keys-on-map lisp-mode-map))

(eval-after-load "paredit" 
  (quote
   (progn
     (define-key paredit-mode-map "\M-q"  'scroll-down-one)
     (define-key paredit-mode-map "\M-r"  'replace-regexp-region)
     (define-key paredit-mode-map "\C-\M-n" 'semi-forward-sexp)
     (define-key paredit-mode-map "\C-\M-p" 'semi-backward-sexp)
     (define-key paredit-mode-map "\C-j" 'backwards-kill-line)
     (define-key paredit-mode-map (kbd ")")
       'paredit-close-parenthesis)
     (define-key paredit-mode-map (kbd "M-)")
       'paredit-close-parenthesis-and-newline))))



(eval-after-load "interaction"
  (quote
   (progn
     (define-key emacs-cl-mode-map "\C-m" 'emacs-cl-newline)
     (define-my-lisp-keys-on-map emacs-cl-mode-map))))

(eval-after-load 'apropos
  (quote
   (progn 
     (define-jk apropos-mode-map))))

(defun comint-recenter ()
  (interactive)
  (when comint-dynamic-list-completions-config
    (set-window-configuration comint-dynamic-list-completions-config)
    (setq comint-dynamic-list-completions-config nil))
  (comint-postoutput-scroll-to-bottom ""))

(defun comint-previous-matching-input-feh () 
  (interactive)
  (comint-previous-matching-input (car minibuffer-history-search-history) 1))

(defun comint-next-matching-input-feh () 
  (interactive)
  (comint-next-matching-input (car minibuffer-history-search-history) 1))

(eval-after-load 'comint
  (quote
   (progn
     (define-key comint-mode-map "\M-\C-r" 'comint-previous-matching-input-feh)
     (define-key comint-mode-map "\M-\C-s" 'comint-next-matching-input-feh)
     (define-key comint-mode-map "\M-\C-p" 'comint-previous-matching-input-feh)
     (define-key comint-mode-map "\M-\C-n" 'comint-next-matching-input-feh)
     (define-key comint-mode-map "\M-/" 'comint-dynamic-list-filename-completions)
     (define-key comint-mode-map "\C-l" 'comint-recenter)
     (define-key comint-mode-map "\M-?" 'help)
     (define-key comint-mode-map "\C-z" 'scroll-up-one)
     (define-key comint-mode-map "\C-q" 'scroll-down-one))))

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
  (define-key term-raw-map "\C-p" 'term-send-up)
  (define-key term-raw-map "\C-n" 'term-send-down)
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

;;; (setq Info-additional-directory-list '("/usr/share/info/emacs-snapshot"))

(eval-after-load 'info 
  (quote
   (progn
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
     (define-key Info-mode-map "D" 'Info-directory))))

(setq diff-default-read-only t)

;;; minor mode, keymap, shadow, override
(add-hook 'diff-mode-hook 'my-diff-hook)
(defun my-diff-hook () 
  (define-key diff-mode-map "\M-q" 'scroll-down-one)
  ;;(define-jk diff-mode-shared-map)
  ;;(define-jk diff-mode-map)
  ;; diff mode sets this so it can add binds to read-only buffers 
  ;; in an extremely broken way, and removes it in a special hook
  ;; for view mode in an even more broken way.  ugh disgusting.
  (setq minor-mode-overriding-map-alist nil) 
  ;;(jk-mode)
  (define-jk  diff-mode-map)
  (define-key diff-mode-map "n"  'diff-hunk-next)
  (define-key diff-mode-map "p"  'diff-hunk-prev)
  (define-key diff-mode-map "a" 'diff-apply-hunk)
  (define-key diff-mode-map "t" 'diff-test-hunk))


(add-hook 'before-make-frame-hook '(lambda () (menu-bar-mode -1)))
(add-hook 'window-setup-hook '(lambda () (menu-bar-mode -1)
                                         (scroll-bar-mode -1)))
;(add-hook 'emacs-startup-hook '(lambda () (menu-bar-mode -1)))

(define-key text-mode-map "\M-s" 'ispell-region)

(defun SUO (x) (interactive "p")  (scroll-up-one x) (next-line x))
(defun SDO (x) (interactive "p") (scroll-down-one x) (previous-line x))

(eval-after-load 'cperl-mode 
  (quote
   (progn
     (defun cperl-mark-active ()
       (and transient-mark-mode (mark)))
     (setq cperl-electric-parens nil)
     (setq cperl-electric-parens-mark t)
     (setq cperl-invalid-face 'default)
     (setq cperl-electric-keywords nil)
     (setq cperl-electric-keyword nil)
     (define-key cperl-mode-map "\M-'" 'forward-delete-space)
     (define-key cperl-mode-map "\C-c(" 'my-insert-parentheses)
     (define-key cperl-mode-map "\M-_"   'c-unwrap-next-sexp)
     (define-key cperl-mode-map "\C-c{" 'curly-braces)
     (define-key cperl-mode-map "\r" 'newline-and-indent)
     (define-key cperl-mode-map "\C-j" 'backwards-kill-line))))

(add-hook 'cperl-mode-hook
          (lambda ()
            (setq local-abbrev-table nil)))

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

;;(setq compilation-finish-functions (list 'end-of-compilation-buffer))

(defun comp (&optional i)
  (interactive)
  (ignore-errors (kill-buffer "*compilation*"))
  (if i (call-interactively 'compile) (compile compile-command))
  (end-of-compilation-buffer (get-buffer "*compilation*") nil)
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






(column-number-mode t)

;(setq scheme-program-name "guile")
;(autoload 'run-scheme "cmuscheme48" "Run an inferior Scheme process." t)
(autoload 'ruby-mode "ruby-mode" "editor mode for ruby" t)


(put 'downcase-region 'disabled nil)

(defun open-inspector-helper ()
  (slime-eval-async '(swank:init-inspector "utils::*future-inspectee*") 'slime-open-inspector))


(defun back-window ()
  (interactive)
  (other-window -1))


(defun freenode ()
  (interactive)
  (erc-select :server "irc.freenode.net" :port "ircd" :nick "smoofra" :password my-stupid-passwd))

(defun dalnet ()
  (interactive)
  (erc-select :server "punch.va.us.dal.net" :port "ircd" :nick "smoofra" :password my-stupid-passwd))

(defun wjoe ()
  (interactive)
  (erc-tls :server "localhost" :port 7778 :nick "ldanna" :password (concat "larry:" my-dumb-passwd ":wjoe"))
  (erc-join-channel "#yourmom"))

(defun baconet ()
  (interactive)
  ;;(erc-select :server "irc.baconautics.com" :port "ircd" :nick "smoofra")
  (erc-tls :server "localhost" :port 7778 :nick "ldanna" :password (concat "larry:" my-dumb-passwd ":bacon"))
  (erc-join-channel "#baconautics"))


(defun bitlbee ()
  (interactive)
  (erc-tls :server "localhost" :port 7778 :nick "smoofra" :password (concat "larry:" my-dumb-passwd ":bitlbee")))

;;(autoload 'erc-select "erc")

;; (defun silly-scroll-down-one-hack ()
;;   (interactive)
;;   (previous-line)
;;   (scroll-down-one 1)
;;   (next-line))

(require 'erc)
(require 'erc-track)
(progn
  (load "erc-track-patch")
  (add-hook 'erc-mode-hook '(lambda () (setq jk-implies-readonly nil)))
  (erc-scrolltobottom-enable)
  (add-hook 'erc-join-hook 'bitlbee-identify)
  (add-hook 'erc-after-connect 'wjoe-identify)
  ;;(define-key erc-mode-map "\M-q" 'silly-scroll-down-one-hack )
  (setq erc-auto-query 'buffer)
  (define-key erc-mode-map [home]  'SDO))

(defun strjoin (d l)
  (cond 
   ((null l) "")
   ((null (cdr l)) (car l))
   (t (concat (car l) d (strjoin d (cdr l))))))

(defun erc-track-string ()
  (strjoin "," (mapcar (lambda (x) (buffer-name (car x))) erc-modified-channels-alist)))

(defun erc-next-channel ()
  (interactive)
  (erc-user-is-active)
  (when erc-modified-channels-alist
    (switch-to-buffer (caar erc-modified-channels-alist))))

(defun nc ()
  (interactive)
  (erc-next-channel))

(defun bs ()
  (interactive)
  (push 92 unread-command-events))

(defun erc-record-track ()
  (interactive)
  (call-process "notify" nil nil nil "-p" "--file" "/home/larry/.http-notification/erctrack" (erc-track-string)))

(add-hook 'erc-track-list-changed-hook 'erc-record-track)

(defun bitlbee-identify ()
  "If we're on the bitlbee server, send the identify command to the #bitlbee channel."
  (when (ignore-errors 
          (and (string= "localhost" erc-session-server)
               (= 7777 erc-session-port)
               (string= "&bitlbee" (buffer-name))))
    (erc-message "PRIVMSG" (format "%s identify %s" (erc-default-target) my-stupid-passwd))))

(defun wjoe-identify (&rest x)
  "If we're on wjoe, send the identify command to NickServ channel."
  (when (ignore-errors
          (and (string= "localhost" erc-session-server)
               (string= erc-session-port "ircd")
               (string= "localhost:ircd" (buffer-name))))
    (erc-message "PRIVMSG" (format "NickServ identify %s" my-stupid-passwd))))

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
  (quote (setq cssm-indent-function #'cssm-c-style-indenter)))

(eval-after-load 'nxml-mode
  (quote
   (progn
     (define-key nxml-mode-map "\C-c/" 'nxml-finish-element)
     (define-key nxml-mode-map "\C-x\C-\M-f" 'nxml-forward-element)
     (define-key nxml-mode-map "\C-x\C-\M-b" 'nxml-backward-element)
     (define-key nxml-mode-map "\C-\M-f" 'nxml-forward-balanced-item)
     (define-key nxml-mode-map "\C-\M-b" '(lambda () 
                                            (interactive)
                                            (nxml-forward-balanced-item -1)))
     (define-key nxml-mode-map "\M-f" 'forward-word)
     (define-key nxml-mode-map "\M-b" 'backward-word))))

(eval-after-load 'sgml-mode
  (quote
   (progn
     (define-key sgml-mode-map "\C-\M-f" 'sgml-skip-tag-forward)
     (define-key sgml-mode-map "\C-\M-b" 'sgml-skip-tag-backward)
     (define-key html-mode-map "\C-\M-f" 'sgml-skip-tag-forward)
     (define-key html-mode-map "\C-\M-b" 'sgml-skip-tag-backward))))

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

(defun curly-braces ()
  (interactive)
  (if transient-mark-mode
      (let ((b (copy-marker (region-beginning)))
            (e (copy-marker (region-end))))
        (goto-char b)
        (forward-delete-space)
        (insert "{\n")
        (goto-char e)
        (if (not (looking-back "\n[ \t]*"))
            (insert "\n"))
        (insert "}")
        (indent-region b (point)))
    (skeleton-proxy-new
     '("" > "{" > ?\n > _ > ?\n "}" >))))

;; (defun lambdamark ()
;;   (interactive)
;;   (setq transient-mark-mode 'lambda))
;; (global-set-key "\C-x " 'lambdamark)
;;;; don't need this, use C-u C-x C-x

(eval-after-load 'cc-mode
  (quote
   (progn 
     (defun c-newline-and-indent ()
       (interactive)
       (newline)
       (insert " ")
       (c-indent-command))
     (defun buffer-is-cc-mode ()
       c-buffer-is-cc-mode)
     (define-key c-mode-map "\C-c;"  'comment-region)
     ;; (define-key c-mode-map "\""     'skeleton-pair-insert-maybe)
     ;; (define-key c-mode-map "("      'skeleton-pair-insert-maybe)
     ;; (define-key c-mode-map "{"      'curly-braces)
     ;; (define-key c-mode-map "["      'skeleton-pair-insert-maybe)
     (define-key c-mode-map "\C-o"   'c-open-line)
     (define-key c-mode-map "\C-k"   'c-kill-line)
     (define-key c-mode-map "\M-_"   'c-unwrap-next-sexp)
     (define-key c-mode-map [return] 'c-newline-and-indent)
     (define-key c-mode-map "\C-\M-j" 'c-join-line))))


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


(defun my-c-mode-hook ()
  ;; (setq indent-tabs-mode t)
  ;; (setq tab-width 4)
  ;; (setq c-basic-offset 4)
  )

(add-hook 'c-mode-common-hook 'my-c-mode-hook)

;; to keep long lines from wrapping around use toggle-truncate-lines

;; amazing fucking awesome buffer switcher
(require 'iswitchb)
(iswitchb-mode 1)
;;(global-set-key "\C-xb" 'iswitchb-buffer)

;; amazing fucking awesome quicksilver-like thing
(defvar i-have-anything (load "anything" t))
(defvar anything-extra-files nil)
(when i-have-anything 
  (setq anything-sources 
        (concatenate 'list  anything-sources
                     (list '((name . "Extra Files")
                             (candidates . anything-extra-files)
                             (type . file)))))
  (setq anything-iswitchb-idle-delay 100000)
  (define-key anything-map  "\C-n" 'anything-next-line)
  (define-key anything-map  "\C-p" 'anything-previous-line)
  (global-set-key "\C-x\M-b" 'anything)
  (anything-iswitchb-setup))

(defun open-scratches ()
  (let ((enable-local-eval t))
    (find-file "~/slime-scratch.lisp")
    (ignore-errors
      (kill-buffer "*scratch*"))
    (find-file "~/scratch.el")))

;; (defvar nice-font "Bitstream Vera Sans Mono-13")
(defvar nice-font "-unknown-DejaVu Sans Mono-normal-normal-normal-*-20-*-*-*-m-0-iso10646-1")

;; to find your current font, (frame-parameter nil 'font)
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

;;;; put this in your .site-init.el to set the font
;; (defun site-init-late ()
;; 	(set-default-font "Bitstream Vera Sans Mono-22")
;; 	(set-nice-font-setter))




;;;;; C-g fucked up, fix it.
(setq 
 query-replace-map
 (cons 'keymap (cons (cons 33554439 'exit) (cdr query-replace-map))))


;;;freaking, yay.  this should be the default though.
(setq comint-prompt-read-only 1)
(eval-after-load 'shell
  (quote
   (progn
     (define-key comint-mode-map "\C-c\\" 'comint-kill-subjob)
     (add-hook 'shell-mode-hook 'my-shell-hook)
     (load-library "ansi-color")
     (ansi-color-for-comint-mode-on)
     (setq shell-font-lock-keywords nil)
     (define-key shell-mode-map "\M-?" 'help))))

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

(setq grep-command "grep --exclude '*~' --exclude '#*#'  --exclude '*.svn*' -nHir ")

(setq make-backup-files nil)


;;; to get the x clipboard selection use x-clipboard-yank
;;; to get the primary selection just yank 
(setq x-select-enable-clipboard nil)







(defun find-diff-file (file &optional dir )
  (interactive)
  (find-file file)
  (when dir
    (setq default-directory dir))
  (diff-mode))

(defun find-grep-file (file &optional dir)
  (interactive)
  (find-file file)
  (when dir
    (setq default-directory dir))
  (grep-mode))

;;;;;; how to find out how to bind a particular key interactively 
;;; M-x global-set-key
;;; M-x repeat-complex-command (or C-x ESC ESC)



(define-skeleton html-tag 
  "add a html tag"
  ""
  "<" (setq foo (read-from-minibuffer "tag? ")) ">"  _ "</" foo ">" )

(setq skeleton-end-newline nil)

(eval-after-load 'php-mode
  (quote
   (progn 
     ;; C-, 
     (define-key php-mode-map (quote [67108908]) (quote html-tag))
     ;;(define-key php-mode-map ")" 'up-list)
     )))


(define-skeleton latex-begin 
  "\begin something"
  ""
  "\\begin{" (setq foo (skeleton-read "begin what? ")) "}"  _ > ?\n > "\\end{" foo "}" >)

(define-skeleton latex-textrm 
  "put something in roman font"
  ""
  "\\textrm{" _ "}")

(define-skeleton latex-textsf
  "put something in sans-serif font"
  ""
  "\\textsf{" _ "}")

(define-skeleton latex-texttt
  "put something in typewriter font"
  ""
  "\\texttt{" _ "}")

(define-skeleton latex-textit
  "put something in italic"
  ""
  "\\textit{" _ "}")


(define-skeleton latex-textbf
  "put something in bold font"
  ""
  "\\textbf{" _ "}")


(setq skeleton-pair t)

(defun define-my-latex-keys (map)
  (define-key map "\C-c>" 'latex-close-block)
  (define-key map ""  'newline-and-indent)
  (define-key map [(control tab)] 'tab-to-tab-stop)
  (define-key map "\C-j" 'backwards-kill-line))


(defun my-latex-mode-hook ()
  (define-my-latex-keys latex-mode-map))

(defun my-LaTeX-mode-hook ()
  (define-key LaTeX-mode-map "{" 'TeX-insert-braces)
  (define-key LaTeX-mode-map "}" 'up-list)
  (define-key LaTeX-mode-map "\C-c>" 'LaTeX-close-environment)
  (define-my-latex-keys LaTeX-mode-map))
   

(add-hook 'LaTeX-mode-hook 'my-LaTeX-mode-hook)
(add-hook 'latex-mode-hook 'my-latex-mode-hook)


(defun my-makefile-mode-hook ()
  (define-key makefile-mode-map "(" 'skeleton-pair-insert-maybe))
(add-hook 'makefile-mode-hook 'my-makefile-mode-hook)

(setq-default abbrev-mode t)
(setq scroll-step 1)
(setq scroll-conservatively 10000)

(defmacro alist-set (place key thing)
  (let ((cons (gensym)))
    `(let ((,cons (assoc ,key ,place)))
       (if ,cons
           (setf (cdr ,cons) ,thing)
         (setf ,place (cons (cons ,key ,thing) ,place))))))


(alist-set 
 save-some-buffers-action-alist
 ?e
 (list
  (lambda (buf)
    (switch-to-buffer buf)
    (recursive-edit)
    nil)
  "edit this buffer"))

(alist-set 
 save-some-buffers-action-alist 
 ?r 
 (list 
  (lambda (buf)
    (switch-to-buffer buf)
    (my-revert-buffer)
    nil)
  "revert this buffer"))


;;;;;; I don't really remember what this variant of ?d was supposed to do.  I
;;;;;; think it had to do with letting you scroll around in the diff buffer.  In
;;;;;; any case it's gone stale in the more recent emacs, so I'm just going to
;;;;;; comment it out.  Setting enable-recursive-minibuffers to t seems to
;;;;;; accomplish the same end.

;; (alist-set
;;  save-some-buffers-action-alist
;;  ?d
;;  (list
;;   (lambda (buf) ;; from files.el
;;     (if (null buffer-file-name)
;;         (message "Not applicable: no file")
;;       (save-window-excursion (diff-buffer-with-file buf))
;;       (if (not enable-recursive-minibuffers)
;;           (progn (display-buffer (get-buffer-create "*Diff*"))
;;                  (setq other-window-scroll-buffer "*Diff*"))
;;         (view-buffer (get-buffer-create "*Diff*")
;;                      (lambda (_) (exit-recursive-edit)))
;;         (recursive-edit)))
;;     ;; Return nil to ask about BUF again.
;;     nil)
;;   "view changes in this buffer"))

(setq enable-recursive-minibuffers t)

(defun arithmatic-on-number-at-point (form)
  (interactive "x")
  (if (looking-at "\\([0-9]+\\)")
      (let* ((x  (car (read-from-string (match-string 1))))
             (nx (eval form)))
        (replace-match (prin1-to-string nx)))
    (error "not an integer")))

(defun increment-number-at-point ()
  (interactive)
  (if (looking-at "\\([0-9]+\\)")
      (replace-match (prin1-to-string (+ 1 (car (read-from-string (match-string 1))))))
    (error "not an integer")))


(defun big-undo-dummy-function ())

(defun big-undo-boundary ()
  (interactive)
  (undo-boundary)
  (push '(apply big-undo-dummy-function) buffer-undo-list))

(defun remove-little-boundaries (orig &optional things)
  (interactive (list buffer-undo-list))
  (if (null buffer-undo-list)
      (progn
        (setq buffer-undo-list orig)
        (error "no big undo boundary"))
    (let ((x (pop buffer-undo-list)))
      (if (null x)
          (remove-little-boundaries orig things)
        (if (equal x '(apply big-undo-dummy-function))
            (dolist (thing things)
              (push thing buffer-undo-list))
          (remove-little-boundaries orig (cons x things)))))))

(defmacro with-single-undo (&rest body)
  `(progn
     (big-undo-boundary)
     (unwind-protect
         (progn ,@body)
       (call-interactively 'remove-little-boundaries))))

(defmacro grab-orig-def (from to)
  `(condition-case err
       (symbol-function ,to)
     (error nil (setf 
                 (symbol-function ,to)
                 (symbol-function ,from)))))

(defmacro redefine (name ll &rest body)
  (let ((orig (intern (concat "orig-" (symbol-name name)))))
    (grab-orig-def name orig)
    `(progn
       (grab-orig-def ',name ',orig)
       (defun ,name ,ll 
       ,(documentation orig)
       ,@body))))



;; (redefine kmacro-call-macro (arg &optional no-repeat end-macro)
;;     (interactive "p")
;;     (with-single-undo
;;      (orig-kmacro-call-macro arg no-repeat end-macro)))

;; (redefine kmacro-exec-ring-item (item arg)
;;   (with-single-undo
;;    (orig-kmacro-exec-ring-item item arg)))


(defun restore-named-kmacro (name)
  (interactive "aKeyboard macro to restore: ")
  (kmacro-push-ring)
  (let ((kmacro (kmacro-extract-lambda (symbol-function name))))
    (setq last-kbd-macro (car kmacro))
    (setq kmacro-counter (nth 1 kmacro))
    (setq kmacro-counter-format (nth 2 kmacro))))

(global-set-key "\C-x\C-k\C-r" 'restore-named-kmacro)

    
(eval-after-load  'w3m
  (quote
   (progn
     (define-jk w3m-mode-map)
     (define-key w3m-mode-map "C-cd" 'w3m-download-this-url))))


;;from antifuchs, file variables safe
(put 'package 'safe-local-variable 'symbolp)
(put 'Package 'safe-local-variable 'symbolp)
(put 'syntax 'safe-local-variable 'symbolp)
(put 'Syntax 'safe-local-variable 'symbolp)
(put 'Base 'safe-local-variable 'integerp)
(put 'base 'safe-local-variable 'integerp)


;; handle multiple qualifires correctly
(defun lisp-indent-defmethod (path state indent-point sexp-column
				   normal-indent)
  "Indentation function defmethod."
  (let ((n 0))
    (save-excursion (goto-char (elt state 1))
                    (forward-char 1)
                    (forward-sexp 2)
                    (while (looking-at "[[:space:]]*[^([:space:]]")
                      (incf n)
                      (forward-sexp 1)))
    (lisp-indent-259 (append (times 4 (+ n 1)) '((&whole 4 &rest 4) &body))
                     path state indent-point sexp-column normal-indent)))

(setf (get 'redefine 'lisp-indent-function) 2)
(setf (get 'bind 'common-lisp-indent-function) 2)
(setf (get 'defmethod/cc 'common-lisp-indent-function)
      'lisp-indent-defmethod)


;;; keybinds for weird putty function keys
(global-set-key "Os" (quote scroll-up-half))
(global-set-key "Op" (quote repeat))
(global-set-key "Oy" (quote scroll-down-half))
(global-set-key "[11" (quote putty-f1))
(defun putty-f1 ()
  (interactive)
  (read-event)
  (call-interactively 'delete-other-windows))



(defun my-hask-hook ()
  (turn-on-haskell-indent)
  (define-key haskell-mode-map "\C-c;" 'comment-region)
  (define-key haskell-mode-map "\r" 'newline-and-indent))
(add-hook 'haskell-mode-hook 'my-hask-hook)

(defun prompt-insert-char (char)
  (interactive "n")
  (insert (make-string 1 char)))

(defun open-char ()
  (interactive)
  (insert " ")
  (backward-char))

(global-set-key "\C-x " 'open-char)

;;; to insert a unicode chacter M-x ucs-insert 
(set-input-method "TeX")
(quail-define-rules 
 ((append . t))
 ("->" ?→)
 ("<-" ?←)
 ("=>" ?⇒)
 ("<=" ?⇐) 
 ("\\sqrt" ?√)
 ("::" ?∷)
 ("\\partial" ?∂)
 ("\\del" ?∇)
 ("\\forces" ?⊩)
 ("\\proves" ?⊦))
(set-input-method nil)

(eval-after-load 'octave-mod
  (quote
   (progn
     (setq octave-comment-char ?%)
     (setq octave-end-keywords
           '("endfor" "endfunction" "endif" "endswitch" "end_try_catch"
             "end_unwind_protect" "endwhile" "until" "end"))
     (setq octave-block-end-regexp
           (concat "\\<\\("
                   (mapconcat 'identity octave-end-keywords "\\|")
                   "\\)\\>"))
     (define-key octave-mode-map "\C-j" 'backwards-kill-line)
     (define-key octave-mode-map "\C-\M-j" 'join-line)
     (define-key octave-mode-map "\M-_" 'c-unwrap-next-sexp))))



(defun ffap ()
  (interactive)
  (if transient-mark-mode 
      (progn
        (transient-mark-mode)
        (find-file (buffer-substring (region-beginning) (region-end))))
    (call-interactively 'find-file-at-point)))


(defvar pre nil)
(defun pre ()
  (interactive)
  (if pre
      (set-face-attribute 'modeline nil :inverse-video t)
    (set-face-attribute 'modeline nil :inverse-video nil))
  (setq pre (not pre)))

(site-init-late)

(defalias 'perl-mode 'cperl-mode)

(load "~/config/init-slime.el")

(if
    (string-equal system-type "darwin")
    (progn
      (setq nice-font "-*-Menlo-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")
      (set-frame-font nice-font)
      (set-nice-font-setter)

      (setq ispell-program-name  "/usr/local/bin/ispell")

      (global-set-key "\M-v" 'clipboard-yank)

      (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
      (setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
      (setq scroll-step 1) ;; keyboard scroll one line at a time
      ))



(setq split-height-threshold 60)
(setq split-width-threshold  200)


(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))


(require 'package)
(package-initialize)
(package-install 'dtrt-indent)
(package-install 'rtags)

(require 'dtrt-indent)

(setq custom-file "~/config/init.el")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Info-additional-directory-list (quote ("/usr/share/info/emacs-snapshot")))
 '(Man-notify-method (quote pushy))
 '(blink-cursor-alist (quote ((box . box) (t . box))))
 '(c-basic-offset 4)
 '(c-default-style
   (quote
    ((c-mode . "k&r")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu"))))
 '(cperl-invalid-face (quote default))
 '(delete-selection-mode nil)
 '(diff-switches "-u")
 '(dns-mode-soa-auto-increment-serial nil)
 '(erc-fill-column 69)
 '(erc-track-exclude (quote ("&bitlbee")))
 '(erc-track-exclude-server-buffer t)
 '(erc-track-exclude-types (quote ("JOIN" "NICK" "PART" "QUIT")))
 '(erc-track-when-inactive nil)
 '(fill-column 80)
 '(dtrt-indent-mode t nil (dtrt-indent))
 '(indent-tabs-mode nil)
 '(iswitchb-default-method (quote samewindow))
 '(matlab-comment-region-s "%")
 '(matlab-fill-code nil)
 '(matlab-indent-level 4)
 '(matlab-verify-on-save-flag nil)
 '(ns-command-modifier (quote meta))
 '(octave-block-offset 4)
 '(rtags-path "/usr/local")
 '(safe-local-variable-values
   (quote
    ((Package SERIES :use "COMMON-LISP" :colon-mode :external)
     (Package . HUNCHENTOOT)
     (Syntax . COMMON-LISP)
     (Package . FLEXI-STREAMS)
     (Package . Memoization)
     (Package . COMMON-LISP-CONTROLLER)
     (Package . XREF)
     (Syntax . Common-lisp)
     (Package . UFFI)
     (Package . CL-USER)
     (syntax . COMMON-LISP)
     (Package ITERATE :use "COMMON-LISP" :colon-mode :external)
     (Package . lift)
     (Base . 10)
     (Syntax . ANSI-Common-Lisp)
     (syntax . common-lisp)
     (package . common-lisp)
     (Package . CLIM-DEMO)
     (Package . MCCLIM-FREETYPE)
     (Syntax . Common-Lisp)
     (Package . CLIMI)
     (Package . CLIM-INTERNALS)
     (unibyte . t)
     (Package . COMMON-LISP-USER))))
 '(slime-backend "swank-loader.lisp")
 '(slime-enable-evaluate-in-emacs t)
 '(slime-multiprocessing t)
 '(svn-status-default-log-arguments (quote ("--verbose   --limit=20")))
 '(tab-width 8)
 '(warning-suppress-types (quote ((undo discard-info))))
 '(woman-use-own-frame nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(anything-header ((t (:background "grey" :foreground "black" :weight bold))) t)
 '(cursor ((t (:background "#ffffff"))))
 '(diff-added ((t (:inherit diff-changed))))
 '(diff-changed ((t (:foreground "yellow"))))
 '(diff-file-header ((((class color) (min-colors 88) (background dark)) (:foreground "cyan" :weight bold))))
 '(diff-header ((((class color) (min-colors 88) (background dark)) (:foreground "green" :weight bold))))
 '(diff-removed ((t (:inherit diff-changed :foreground "red"))))
 '(mmm-default-submode-face ((t (:background "gray85" :foreground "black")))))

(cond
 ((display-graphic-p)
  (set-face-background 'default "#110022")
  (set-face-foreground 'default "#ffffff"))
 (t
  (set-face-background 'default "#000000")))
