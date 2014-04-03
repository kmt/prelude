;;;; Org-Mode
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-agenda-files '("~/org"))

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(setq org-agenda-custom-commands
      '(
        ("n" "Agenda and all TODO's"
         ((agenda "" (alltodo)))
         )
        ("R" "Report completed tasks from previous week"
         ((agenda "" ((org-agenda-entry-types '(:timestamp :sexp :scheduled))
                      (org-agenda-show-log t)))))
        ;; ("W" "Completed and/or deferred tasks from previous week"
        ;;  ((agenda "" ((org-agenda-span 5)
        ;;               (org-agenda-start-day "lastweek")
        ;;               (org-agenda-entry-types '(:timestamp :sexp :scheduled))
        ;;               (org-agenda-show-log t)))))
      ;; other commands
      )
)
