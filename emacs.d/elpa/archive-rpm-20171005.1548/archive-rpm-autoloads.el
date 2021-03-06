;;; archive-rpm-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "archive-cpio" "archive-cpio.el" (23000 27809
;;;;;;  444642 855000))
;;; Generated autoloads from archive-cpio.el

(autoload 'archive-cpio-find-type "archive-cpio" "\
Return `cpio' if the current buffer contains a CPIO archive.
Otherwise, return nil.

This function is meant to be used as a :before-until advice for
`archive-find-type'.

\(fn)" nil nil)

(with-eval-after-load "arc-mode" (advice-add 'archive-find-type :before-until 'archive-cpio-find-type))

;;;***

;;;### (autoloads nil "archive-rpm" "archive-rpm.el" (23000 27809
;;;;;;  442824 263000))
;;; Generated autoloads from archive-rpm.el

(autoload 'archive-rpm-find-type "archive-rpm" "\
Return `rpm' if the current buffer contains an RPM archive.
Otherwise, return nil.

This function is meant to be used as a :before-until advice for
`archive-find-type'.

\(fn)" nil nil)

(with-eval-after-load "arc-mode" (advice-add 'archive-find-type :before-until 'archive-rpm-find-type))

(add-to-list 'magic-mode-alist '("\355\253\356\333 " . archive-mode))

;;;***

;;;### (autoloads nil nil ("archive-rpm-pkg.el") (23000 27809 439330
;;;;;;  392000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; archive-rpm-autoloads.el ends here
