
;;;;;;; this is mostly refactored copypasta out of erc-track.el
;;;;;;; it does what erc-track-when-inactive is supposed to do


(defun erc-buffer-really-visible (buffer)
  "Return non-nil when the buffer is visible."
  (erc-track-get-buffer-window buffer erc-track-visibility))

(defun erc-buffer-visible (buffer)
  "Return non-nil when the buffer is visible and not inactive."
  (when erc-buffer-activity             ; could be nil
    (and (erc-track-get-buffer-window buffer erc-track-visibility)
         (<= (erc-time-diff erc-buffer-activity (erc-current-time))
             erc-buffer-activity-timeout))))

(defun erc-track-add-channel-to-alist (buffer this-channel faces)
  (unless (and
           (or (eq erc-track-priority-faces-only 'all)
               (member this-channel erc-track-priority-faces-only))
           (not (catch 'found
                  (dolist (f faces)
                    (when (member f erc-track-faces-priority-list)
                      (throw 'found t))))))
    (if (not (assq buffer erc-modified-channels-alist))
        ;; Add buffer, faces and counts
        (setq erc-modified-channels-alist
              (cons (cons buffer
                          (cons 1 (erc-track-find-face faces)))
                    erc-modified-channels-alist))
      ;; Else modify the face for the buffer, if necessary.
      (when faces
        (let* ((cell (assq buffer
                           erc-modified-channels-alist))
               (old-face (cddr cell))
               (new-face (erc-track-find-face
                          (if old-face
                              (cons old-face faces)
                            faces))))
          (setcdr cell (cons (1+ (cadr cell)) new-face)))))
    (erc-modified-channels-display)))

(defun erc-track-rm-channel-from-alist (buffer)
  (when (assq buffer erc-modified-channels-alist)
    (erc-modified-channels-remove-buffer buffer)
    (erc-modified-channels-display)))

(defun erc-user-is-active (&rest ignore)
  "Set `erc-buffer-activity'."
  (setq erc-buffer-activity (erc-current-time))
  (dolist (buf (buffer-list))
    (save-excursion
      (set-buffer buf)
      (when (and (equal major-mode 'erc-mode)
                 (erc-buffer-really-visible buf))
        (erc-track-rm-channel-from-alist buf)))))

(defun erc-track-modified-channels ()
  "Hook function for `erc-insert-post-hook' to check if the current
buffer should be added to the modeline as a hidden, modified
channel.  Assumes it will only be called when current-buffer
is in `erc-mode'."
  (lexical-let* ((this-channel (or (erc-default-target)
                                   (buffer-name (current-buffer))))
                 (excluded (or (member this-channel erc-track-exclude)
                               (and erc-track-exclude-server-buffer
                                    (erc-server-buffer-p))
                               (erc-message-type-member
                                (or (erc-find-parsed-property)
                                    (point-min))
                                erc-track-exclude-types))))
    (cond
     ((and (not excluded)
           (not (erc-buffer-visible (current-buffer))))
      (erc-track-add-channel-to-alist (current-buffer) this-channel (erc-faces-in (buffer-string))))
     ((and (not excluded)
           (erc-buffer-visible (current-buffer)))
      (lexical-let ((delay (+ 1 
                              (max 0
                                   (- erc-buffer-activity-timeout (- (erc-current-time) erc-buffer-activity)))))
                    (faces (erc-faces-in (buffer-string)))
                    (buffer (current-buffer))
                    (last-acty erc-buffer-activity))
        (run-at-time delay nil 
                     (lambda ()
                       (when (and (equal erc-buffer-activity last-acty)
                                  (not (erc-buffer-visible buffer)))
                         (erc-track-add-channel-to-alist buffer this-channel faces)))))
      (erc-track-rm-channel-from-alist (current-buffer)))
     ((and (or (erc-buffer-visible (current-buffer))
               excluded))
      (erc-track-rm-channel-from-alist (current-buffer))))))

(setq erc-buffer-activity-timeout 300)
(add-hook 'window-configuration-change-hook 'erc-user-is-active)
(add-hook 'erc-send-completed-hook 'erc-user-is-active)
(add-hook 'erc-server-001-functions 'erc-user-is-active)

