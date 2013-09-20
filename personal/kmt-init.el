;;;; UTF-8 support
(set-keyboard-coding-system 'mule-utf-8)
(set-terminal-coding-system 'mule-utf-8)
(prefer-coding-system 'utf-8)


;;;; Shell-mode
(add-hook 'shell-mode-hook 'compilation-shell-minor-mode)
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)


;;;; Compilation
(setq compilation-scroll-output t)


;;;;; Projectile
(defun kmt/projectile-shell ()
  "Open a shell in the current project's root."
  (interactive)
  (projectile-dired)
  (shell (concat (concat "*"(projectile-project-name) "-shell*"))))
(defun kmt/projectile-switch-project-shell ()
  "Switch to a project and open a shell in it's root."
  (interactive)
  (let* ((project-to-switch
          (projectile-completing-read "Shell in project: "
                                      projectile-known-projects))
         (default-directory project-to-switch))
    (kmt/projectile-shell)
    (let ((project-switched project-to-switch))
      (run-hooks 'projectile-switch-project-hook))))
(add-hook 'projectile-mode-hook
          (lambda ()
            (define-key projectile-mode-map (kbd "C-c p M-m") 'kmt/projectile-shell)
            (define-key projectile-mode-map (kbd "C-c p M-s") 'kmt/projectile-switch-project-shell)))


(provide 'kmt-init)
;;; kmt-init.el ends here
