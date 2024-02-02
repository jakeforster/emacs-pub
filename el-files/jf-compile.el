(defun jf/compilation-cleanup (buffer msg)
  "Close the *compilation* buffer when compilation does not return an error code."
  (when (eq buffer (get-buffer "*compilation*"))
    (kill-buffer "*compilation*")))

(defun jf/kill-compilation-buffer ()
  "Kill the *compilation* buffer and its process without confirmation."
  (interactive)
  (let ((compilation-buffer (get-buffer "*compilation*")))
    (when compilation-buffer
      (when (get-buffer-process compilation-buffer)
        (set-process-query-on-exit-flag (get-buffer-process compilation-buffer) nil)
        (kill-process (get-buffer-process compilation-buffer)))
      (kill-buffer compilation-buffer))))

(defun jf/toggle-compilation-cleanup ()
  (interactive)
  (if (memq 'jf/compilation-cleanup compilation-finish-functions)
      (remove-hook 'compilation-finish-functions 'jf/compilation-cleanup)
    (add-to-list 'compilation-finish-functions 'jf/compilation-cleanup)))

(provide 'jf-compile)
