(defun jf/latex-generate-command ()
  "Generate the LaTeX compile command for the current buffer.

This command compiles either the current file or a specified master file.
Set the `master-filename` local variable in your LaTeX file to specify a master file.

For example, add the following at the end of your LaTeX file to set a master file:
    %%% Local Variables:
    %%% master-filename: \"/path/to/master/file.tex\"
    %%% End:"
  (let* ((master-filename (and (boundp 'master-filename) master-filename))
         (filename (or master-filename (buffer-file-name))))
    (when filename
      (if (eq system-type 'windows-nt)
          (format "latexmk -pdf %s && latexmk -c" (shell-quote-argument filename))
        (format "latexmk -pdf %s && ! grep -i 'undefined references' %s.log && latexmk -c"
                (shell-quote-argument filename)
                (shell-quote-argument (file-name-sans-extension filename)))))))

(provide 'jf-latex)
