(defun jf/latex-mode-setup ()
  (add-hook 'before-save-hook 'jf/latex-before-save-hook nil t)
  (flyspell-buffer)
  (flyspell-mode))

(defun jf/latex-before-save-hook ()
  (indent-region (point-min) (point-max)))

(defun jf/latex-compile ()
  "Compile the LaTeX file using Latexmk.

This function compiles either the current file or a specified master file.
Set the `master-filename` local variable in your LaTeX file to specify a master file.

For example, add the following at the end of your LaTeX file to set a master file:
    %%% Local Variables:
    %%% master-filename: \"/path/to/master/file.tex\"
    %%% End:"
  (interactive)
  (let* ((master-filename (and (boundp 'master-filename) master-filename))
         (filename (or master-filename (buffer-file-name))))
    (when filename
      (compile (format "latexmk -pdf %s && latexmk -c" (shell-quote-argument filename))))))

(provide 'jf-latex)
