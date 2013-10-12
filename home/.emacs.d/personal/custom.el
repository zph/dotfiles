;;; Custom Emacs Config
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(custom-safe-themes (quote ("1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" default)))
 '(erc-stamp-mode t)
  '(org-datetree-add-timestamp (quote inactive))
 '(org-default-notes-file "~/Dropbox/org_mode/incoming.org")
 '(org-directory "~/Dropbox/org_mode/")
 '(org-startup-truncated nil)

 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Startup server
(add-hook 'server-visit-hook 'make-frame)
(add-hook 'server-switch-hook
          '(lambda ()
             (server-switch-buffer (other-buffer))))
(server-start)
(setq frame-title-format "%b")		; use buffer name for title
(setq display-buffer-reuse-frames t)    ; no new frame if already open
;; use this shell alias for emacs to run emacsclient unless emacs not running, then run server
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)
(load-theme 'sanityinc-tomorrow-bright t)
(when (require 'multi-term nil t)
  (global-set-key (kbd "<f5>") 'multi-term)
  (global-set-key (kbd "<C-next>") 'multi-term-next)
  (global-set-key (kbd "<C-prior>") 'multi-term-prev)
  (setq multi-term-buffer-name "term"
        multi-term-program "/bin/zsh"))
;; Display ido results vertically, rather than horizontally
(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
(defun ido-disable-line-truncation () (set (make-local-variable 'truncate-lines) nil))
(add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)
(defun ido-define-keys () ;; C-n/p is more intuitive in vertical layout
  (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
  (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
(add-hook 'ido-setup-hook 'ido-define-keys)
(global-set-key (kbd "C-x f") 'find-file-in-repository)
(require 'icicles)
(icy-mode 1)
;; Setting rbenv path
(require 'rbenv)
(global-rbenv-mode)
(require 'exec-path-from-shell)
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))
(global-set-key (kbd "M-p") 'shell-command)
(require 'ob-sml nil 'noerror)
(global-set-key (kbd "<f12>") 'whitespace-mode)
;(add-hook 'org-mode-hook (lambda () (
;  ('whitespace-mode)
;)))
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode 1))
(define-key global-map (kbd "C-c c") 'org-capture)

(setq org-capture-templates
      ; '(("Incoming" ?i "** %t: %?\n  %i\n  %a"  "Uncategorized")))
  '(
    ("n" "Notes" entry (file+datetree "~/Dropbox/org_mode/incoming.org")
    "* %^{Description} %^g %?
    Added: %U")
    ("t" "Todo" entry (file+headline (concat org-directory "/incoming.org") "Tasks")
       "* TODO %?\n %i\n")
      ("l" "Link" plain (file (concat org-directory "/incoming.org"))
       "- %?\n %x\n")
  )
)
(require 'org-install)
(require 'ob-tangle)
(global-set-key (kbd "<f8>") 're-builder) ; helps with building regexes
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
;; This will transform ansi color to faces in Emacs shell!
(ansi-color-for-comint-mode-on)
(defun eshell-handle-ansi-color ()
  (ansi-color-apply-on-region eshell-last-output-start
                              eshell-last-output-end))
(add-hook 'eshell-mode-hook
          '(lambda ()
             (add-to-list
              'eshell-output-filter-functions
              'eshell-handle-ansi-color)))
(org-babel-do-load-languages
 'org-babel-load-languages
 '( (perl . t)
    (ruby . t)
    (sh . t)
    (python . t)
    (emacs-lisp . t)
    ))
(setq org-confirm-babel-evaluate nil)
(defun pivotal-open-story-on-web ()
  "Opens a Pivotal Story on the web when executed on a Story #"
  (interactive)
  ;(sample "45870133")
  (let (link-name)
    (setq link-name (thing-at-point 'word))
    (shell-command (concat "open https://www.pivotaltracker.com/story/show/" link-name))))
     ;(shell-command (concat "open x-devonthink-item:" record-location))

(global-set-key "\C-c\C-p" 'pivotal-open-story-on-web)
;; Authenticate Pivotal API
(load "~/.emacs_auth")
(provide 'custom)
;;;END CUSTOM
