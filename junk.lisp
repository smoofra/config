
(require 'asdf-install)
(defun asdf-install::where ()
  (list (pathname "/home/larry/lisp/asdf-install/")
		(pathname "/home/larry/lisp/asdf-installd-systems/")
		"custom"))
(defun asdf-install::temp-file-name (p)
  (let* ((pos-slash (position #\/ p :from-end t))
		 (pos-dot (position #\. p :start (or pos-slash 0))))
	(merge-pathnames
	 #P"/home/larry/lisp/tmp/"
	 (make-pathname
	  :name (subseq p (if pos-slash (1+ pos-slash) 0) pos-dot)
	  :type "asdf-install-tmp"))))
(pushnew "/home/larry/lisp/asdf-installd-systems/" asdf:*central-registry* :test #'equal)

;;;;;

(setf (logical-pathname-translations "sys")
      '(("SYS:**;*.*.*" #P"/home/larry/sbcl/**/*.*")))


;;;;;;;


(when (equal (lisp-implementation-version) "1.0.5")
  (load "/usr/share/common-lisp/source/common-lisp-controller/common-lisp-controller.lisp")
  (load "/usr/share/common-lisp/source/common-lisp-controller/post-sysdef-install.lisp"))

(when (equal (lisp-implementation-version) "1.0.5")
  (clc:init-common-lisp-controller-v5 "sbcl105"))





