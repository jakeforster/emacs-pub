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

(defun jf/guix-gpg-agent-restart-maybe ()
  "Restart herd service gpg-agent if it has respawned.

gpg-agent occasionally stops working after being respawned, and restarting it fixes it."
  (let ((result (shell-command-to-string "herd status gpg-agent")))
    (when (string-match-p "Last respawned on" result)
      (start-process
       "restart-gpg-agent" ;; process name
       nil ;; no buffer
       "herd"
       "restart"
       "gpg-agent")
      (message "gpg-agent has been restarted."))))

(provide 'jf-guix)
