(defconst jf/is-guix-system (and (eq system-type 'gnu/linux)
                                 (require 'f)
                                 (string-equal (f-read "/etc/issue")
                                               "\nThis is the GNU system.  Welcome.\n")))

(defun jf/shell-command-output-matches-p (command pattern)
  "Return t if PATTERN is found in the output of COMMAND."
  (let ((output (shell-command-to-string command)))
    (string-match-p pattern output)))

(defun jf/guix-gpg-agent-providing-ssh-agent-p ()
  "Return t if gpg-agent is providing ssh-agent on Guix System."
  (jf/shell-command-output-matches-p "herd status gpg-agent" "ssh-agent"))

(provide 'jf-guix)
