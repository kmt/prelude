;; load the local settings
(setq kmt-local-dir "~/.emacs-local.d/")
(when (file-exists-p kmt-local-dir)
  (message "Loading personal configuration files in %s..." kmt-local-dir)
  (mapc 'load (directory-files kmt-local-dir 't "^[^#].*el$")))
