(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(custom-safe-themes (quote ("1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" default)))
 '(erc-stamp-mode t)
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

(provide 'custom)
;;;END CUSTOM
