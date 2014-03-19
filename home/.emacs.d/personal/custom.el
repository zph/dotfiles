;;; Custom Emacs Config
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(custom-safe-themes (quote ("a3d519ee30c0aa4b45a277ae41c4fa1ae80e52f04098a2654979b1ab859ab0bf" "41b6698b5f9ab241ad6c30aea8c9f53d539e23ad4e3963abff4b57c0f8bf6730" "de2c46ed1752b0d0423cde9b6401062b67a6a1300c068d5d7f67725adc6c3afb" "e53cc4144192bb4e4ed10a3fa3e7442cae4c3d231df8822f6c02f1220a0d259a" "9bac44c2b4dfbb723906b8c491ec06801feb57aa60448d047dbfdbd1a8650897" "978ff9496928cc94639cb1084004bf64235c5c7fb0cfbcc38a3871eb95fa88f6" "51bea7765ddaee2aac2983fac8099ec7d62dff47b708aa3595ad29899e9e9e44" "f41fd682a3cd1e16796068a2ca96e82cfd274e58b978156da0acce4d56f2b0d5" "1affe85e8ae2667fb571fc8331e1e12840746dae5c46112d5abb0c3a973f5f5a" "2b5aa66b7d5be41b18cc67f3286ae664134b95ccc4a86c9339c886dfd736132d" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" default)))
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
;; Authenticate Pivotal API
(load "~/.emacs_auth")
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
;;(load-theme 'base16-railscasts t)
(load-theme 'sanityinc-tomorrow-bright t)
(global-hl-line-mode -1)
(setq tab-width 2)
;; Clojure
(setq nrepl-hide-special-buffers t)
(defun open-file-at-cursor ()
  "Open the file path under cursor.
If there is text selection, uses the text selection for path.
If the path is starts with “http://”, open the URL in browser.
Input path can be {relative, full path, URL}.
This command is similar to `find-file-at-point' but without prompting for confirmation.
"
  (interactive)
  (let ( (path (thing-at-point 'filename)))
    (if (string-match-p "\\`https*://" path)
        (progn (browse-url path))
      (progn ; not starting “http://”
        (if (file-exists-p path)
            (progn (find-file path))
          (if (file-exists-p (concat path ".el"))
              (progn (find-file (concat path ".el")))
            (progn
              (when (y-or-n-p (format "file doesn't exist: 「%s」. Create?" path) )
                (progn (find-file path ))) ) ) ) ) ) ))
(when (require 'multi-term nil t)
  (global-set-key (kbd "<f5>") 'multi-term)
  (global-set-key (kbd "<C-next>") 'multi-term-next)
  (global-set-key (kbd "<C-prior>") 'multi-term-prev)
  (global-set-key (kbd "C-c t") 'multi-term-next)
  (global-set-key (kbd "C-c T") 'multi-term) ;; create a new one
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
(global-set-key (kbd "C-x f") 'ido-find-file)
(global-set-key (kbd "C-x r") 'prelude-recentf-ido-find-file) ;; not really working
(global-set-key (kbd "C-x C-f") 'ido-find-file)
(global-set-key (kbd "C-x C-r") 'prelude-recentf-ido-find-file) ;; not really working
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1) 
(setq ido-use-filename-at-point 'guess) 
(defun terminal-init-screen ()
  "Terminal initialization function for screen."
  ;; Use the xterm color initialization code.
  (xterm-register-default-colors)
  (tty-set-up-initial-frame-faces))
(require 'icicles)
(icy-mode 1)
(setq prelude-whitespace nil)
;; Setting rbenv path
(require 'exec-path-from-shell)
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))
(global-set-key (kbd "M-p") 'shell-command)
(require 'ob-sml nil 'noerror)
(global-set-key (kbd "<f12>") 'whitespace-mode)
(whitespace-mode -1)
(add-hook 'org-mode-hook (lambda () (
  (setq org-indent-mode 1)
)))
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode 1))
(define-key global-map (kbd "C-c c") 'org-capture)
;; add to your ~/.emacs
;; (or your ~/.emacs.d/init.el)

(require 'clojure-mode)

;; more aesthetic spacing for compojure macros
(define-clojure-indent
  (defroutes 'defun)
  (context 'defun)
  (GET 2)
  (POST 2)
  (PUT 2)
  (DELETE 2)
  (HEAD 2)
  (ANY 2)
  (context 2))

(add-to-list 'auto-mode-alist '("\\.cljs\\'" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljx\\'" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.edn\\'"  . clojure-mode))

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
(set-face-attribute 'default nil :font "Source Code Pro-13")
(load "~/src/pivotal-tracker/pivotal-tracker")

;;(match-string "(dev)" "rr,stuff_dev_t,more")
(require 'pivotal-tracker)
(require 'yasnippet)
(yas-global-mode 1)
;; fix some org-mode + yasnippet conflicts:
;;(defun connect-to-freenode
;;  (lambda () (interactive)
;;    (erc :server "irc.freenode.net" :nick "zph" :full-name "Zander" :password irc-password)
;;))

;; erc
(defun erc-start ()
    (interactive) 
    (setq erc-echo-notices-in-minibuffer-flag t)
    (require 'erc)

    ;; require erc-match
    (require 'erc-match)
    (setq erc-keywords '("resolve" "mbuf"))
    (setq erc-current-nick-highlight-type 'nick)
    (setq erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE"))
    (setq erc-track-use-faces t)
    (setq erc-track-faces-priority-list
         '(erc-current-nick-face erc-keyword-face)) (setq erc-track-priority-faces-only 'all)

    ;; erc scroll to bottom
    (setq erc-input-line-position -2)
    (setq erc-echo-notices-in-minibuffer-flag t)

    ;; Connect 
    (setq erc-autojoin-channels-alist 
         '(("freenode.net" "##lonelyhackersclub #rubydcamp")))
    (erc :server "irc.freenode.net" :nick "zph" :full-name "Zander" :password irc-password)
)

(defun yas/org-very-safe-expand ()
  (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))

(add-hook 'org-mode-hook
          (lambda ()
            (org-babel-do-load-languages
             'org-babel-load-languages
             '( (perl . t)
                (ruby . t)
                (sh . t)
                (python . t)
                (emacs-lisp . t)
                ))
            (setq org-confirm-babel-evaluate nil)
            (make-variable-buffer-local 'yas/trigger-key)
            (setq yas/trigger-key [tab])
            (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
            (define-key yas/keymap [tab] 'yas/next-field)))

(key-chord-mode -1)
;;(require 'org-latex)
(require 'evil)
  (evil-mode 1)
(provide 'custom)
;;;END CUSTOM
;; Notes
;; use <sTAB to add src blocks
;; C-c ' will open the src block in the proper highlighting and mode
;; For Pivotal mode, M-s h l is useful to highlight lines that match regex (ie a specific label) (Credit: http://irreal.org/blog/?p=635)
;; Pivotal Mode notes
;* <kbd>t</kbd> toggles expanded view for a story. <kbd>Enter</kbd> also toggles this view
;* <kbd>R</kbd> refreshes the view
;* <kbd>L</kbd> list projects. displays the Projects View
;* <kbd>N</kbd> will load and display the next iteration
;* <kbd>P</kbd> will load and display the previous iteration
;* <kbd>E</kbd> will prompt for a new integer estimate for that story
;* **numeric prefix** + <kbd>E</kbd> will use that number for the estimate
;**  example: pressing <kbd>2</kbd> followed by pressing <kbd>E</kbd> will assign a **2 pt** estimate for current story
;* <kbd>C</kbd> will prompt for a new comment
;* <kbd>S</kbd> will prompt for new status
;* <kbd>T</kbd> will prompt for a new task
;* <kbd>F</kbd> will mark the task (not the story) under the cursor as finished
;* <kbd>+</kbd> adds a new story
;; Babel execution of src code in Emacs orgmode
; C-c C-c or C-c C-v e with the point on a code block2.
; Freenode channels: ##lonelyhackersclub, #rubydcamp 
