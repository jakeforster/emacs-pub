(defun jf/compilation-cleanup (buffer msg)
  "Display a success message and close the *compilation* buffer when LaTeX compilation completes."
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

(provide 'jf-compile)
