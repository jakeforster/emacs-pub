(defun jf/compilation-cleanup (buffer msg)
  "Close the *compilation* buffer if compilation finished successfully."
  (when (and (buffer-live-p buffer)
             (eq buffer (get-buffer "*compilation*"))
             (string-match "finished" msg))
    (kill-buffer buffer)))

(defun jf/toggle-compilation-cleanup ()
  (interactive)
  (if (memq 'jf/compilation-cleanup compilation-finish-functions)
      (remove-hook 'compilation-finish-functions #'jf/compilation-cleanup)
    (add-to-list 'compilation-finish-functions #'jf/compilation-cleanup)))

(defun jf/kill-compilation-buffer ()
  "Kill the *compilation* buffer and its process without confirmation."
  (interactive)
  (let ((compilation-buffer (get-buffer "*compilation*")))
    (when compilation-buffer
      (when (get-buffer-process compilation-buffer)
        (set-process-query-on-exit-flag (get-buffer-process compilation-buffer) nil)
        (kill-process (get-buffer-process compilation-buffer)))
      (kill-buffer compilation-buffer))))

(defun jf/compile (command)
  "Like `compile`, but different behaviour when called with prefix arg.

If called with prefix arg, `jf/toggle-compilation-cleanup` is called before compiling, and compilation buffer will NOT be in Comint mode."
  (interactive
   (list (compilation-read-command compile-command)))
  (when current-prefix-arg
    (jf/toggle-compilation-cleanup))
  (compile command nil))

(provide 'jf-compile)
