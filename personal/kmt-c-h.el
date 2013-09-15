;;; first off, we do some fancy stuff to make C-h work "properly," but still
;;; have good access to the help functions!
;;;
;;; Using C-h for "help" might seem OK to some folks, but since it's also the
;;; ASCII standard value for the "backspace" character, one typically used ever
;;; since the days of the typewriter to move the cursor backwards one position
;;; and in computing normally to erase any character backed over, a vast amount
;;; of stupidity is needed in emacs to continue to (ab)use as the "help"
;;; character.  Instead it is still quite intuitive, and often much easier in
;;; zillions of environments, to use M-? for help.
;;;
;;; So, we can set C-h and C-? and friends to sensible bindings...
;;
;; Remember to call override-local-key-settings in the appropriate hooks to fix
;; up modes which violate global user preferences....
;;
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-?" 'delete-char)
(global-set-key "\e\C-h" 'backward-kill-word)
(global-set-key "\e\C-?" 'kill-word)

;;; and then we diddle with help to make it work again....
;;
;; Oddly, the help interface in emacs is extremely scatter-brained, with
;; several slightly different ways of doing the same thing.  This is probably
;; due to the fact that several different programmers have implemented various
;; bits and pieces of the help systems.  See help.el and help-macro.el, but try
;; not to tear your hair out when you find out help-event-list in 19.34 is
;; essentially bogus, since it is simply an extension to a "standard" list.
;;
;; Remember to call override-local-key-settings in the appropriate hooks to fix
;; up modes which violate global user preferences....
;;
(global-set-key [f1] 'help-command)     ; first do this for 19.28.
(global-set-key "\e?" 'help-command)    ; this is the first step to set up help
(global-set-key "\e?F" 'view-emacs-FAQ) ; in 19.34 it needs more help...
;; should help-char be just ? instead?
(setq help-char ?\M-?)                  ; this should "fix" the rest.

;; one more handy help-related binding...
;;
(define-key help-map "?" 'describe-key-briefly) ; also C-x? for Jove compat

;;; Now for function key mappings...
;;;
;;; I USUALLY EXPECT THE BACKSPACE KEY TO WORK LIKE AN ASCII BACKSPACE!
;;
;; For some entirely un-fathomable reason the default function bindings make
;; the 'backspace' and 'delete' keys synonymous!
;;
;; NOTE: this *should* work by simply reading termio for current erase char.
;;
;; As of emacs-21.2 a note was added to the NEWS file which says "** On
;; terminals whose erase-char is ^H (Backspace), Emacs now uses
;; normal-erase-is-backspace-mode."  Unfortunately this does EXACTLY the WRONG
;; thing, and in a totally bizzare, disruptive, subversive, and stupid
;; backwards way.  With every major release it's gotten worse and worse and
;; worse; more convoluted, and ugly.
;;
;; So, we must do something to kill that horrible stupid broken poor
;; useless excuse for a feature, normal-erase-is-backspace-mode....
;;
;; seems 23.1 changes function-key-map radically....
;;
;; Unfortunately 23.1 also still has function-key-map so we can't make that
;; (function-key-map) an alias for the new local-function-key-map that we need
;; to use in 23.1 to modify key translations.  Sigh.
;;
;; Instead make a new alias that can be used transparently as the desired map.
;;
(eval-and-compile
  (if (functionp 'defvaralias)          ; since 22.1
      (if (boundp 'local-function-key-map)
          (defvaralias 'my-function-key-map 'local-function-key-map
            "Special variable alias to allow transparent override of
`local-function-key-map' for 23.1 vs 22.3(?).")
        (defvaralias 'my-function-key-map 'function-key-map
          "Special variable alias to allow transparent override
of `function-key-map' for 22.3(?) vs. older,"))
    ;; XXX is this right?  it works (maybe?)
    (defvar my-function-key-map function-key-map)))
;;
;; First undo (local-)funtion-key-map weirdness.
;;
;; luckily on Mac OS-X X11, at least with the mini-wireless keyboard and on the
;; large USB keyboard, the big "delete" key on the main block is actually
;; sending <backspace> by default, else one would have to first change the X11
;; keyboard map!
;;
(define-key my-function-key-map [delete] [?\C-?])
(define-key my-function-key-map [S-delete] [?\C-h])
(define-key my-function-key-map [M-delete] [?\C-\M-?])
(define-key my-function-key-map [kp-delete] [?\C-?])
(define-key my-function-key-map [backspace] [?\C-h])
(define-key my-function-key-map [S-backspace] [?\C-?])
;;(define-key my-function-key-map [C-backspace] [?\C-h]) ; sometimes *is* DEL....
(define-key my-function-key-map [M-backspace] [?\e?\C-h])
(define-key my-function-key-map [M-S-backspace] [?\e?\C-?])
(define-key my-function-key-map [kp-backspace] [?\C-h])
;;
;; Next, zap the keyboard translate table, set up by
;; normal-erase-is-backspace-mode (in simple.el), which can do nothing
;; but confuse!
;;
(setq keyboard-translate-table nil)
;;
;; Finally, kill, Kill, KILL! the input-decode-map added in 23.x, and set
;; up by normal-erase-is-backspace-mode (in simple.el) which can do
;; nothing but confuse!
;;
;; This is TRULY _E_V_I_L_!!!!  HORRID!!!  MASSIVELY STUPID!!!!
;;
;; input-decode-map is poorly documented, and causes things above and
;; below to fail with the most confusing errors!
;;
;; (This probably only needs to be blown away on window systems, and
;; perhaps only for X, but doing it here now is apparently early enough
;; to allow for terminal mode specific settings to be re-applied to it
;; and so it seems safe to just blow away the asinine stupid attempt to
;; transpose backspace and delete.  RMS is a pedantic idiot on this!)
;;
(if (boundp 'input-decode-map)
    (setq input-decode-map (make-sparse-keymap)))

;; finally here's a little function to help fix up modes which don't honour default
;; bindings in sensible ways.  Use this in any init hooks for modes which cause problems
;;
(defun override-local-key-settings ()
  "User defined function.  Intended to be called within various hooks to
override the value of buffer-local key map settings which may have been
overridden without consideration by the major mode."
  (local-set-key "\C-?" 'delete-char)   ; many modes
  (local-set-key "\C-h" 'delete-backward-char)  ; sh-mode
  ;; the rest are *not* overridden by cc-mode, but are by c-mode
  (local-set-key "\e\C-h" 'backward-kill-word) ; text-mode
  (local-set-key "\e?" 'help-command)   ; nroff-mode
  (local-set-key "\eh" 'mark-c-function)
  (local-set-key "\e\C-?" 'kill-word)
  (local-set-key "\e\C-e" 'compile)
  ;; try this on for size...
  (local-set-key "\C-x\e\C-e" 'recompile)
  )

(add-hook 'isearch-mode-hook
          (function
           (lambda ()
            "Private isearch-mode fix for C-h."
            (define-key isearch-mode-map "\C-h" 'isearch-delete-char))))


;;; OK, that's the end of the stuff to fix GNU Emacs' C-h brain damage.  Phew!
(provide 'kmt-c-h)
