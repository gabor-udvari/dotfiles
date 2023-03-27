;; Simpler UI
;; as seen on https://www.youtube.com/watch?v=74zOY-vgkyw&
(setq inhibit-startup-message t)

(menu-bar-mode -1) ;; Disable menubar
(scroll-bar-mode -1) ;; Disable visible scrollbar
(tool-bar-mode -1) ;; Disable the toolbar
(tooltip-mode -1) ;; Disable tooltips
(set-fringe-mode 10) ;; Give some breathing room

;; Enable visible bell
(setq visible-bell t)

(load-theme 'wombat)

;; Enable line numbers globally
(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                vterm-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Move customization variables to separate file and load it
(setq custom-file (locate-user-emacs-file "customer-vars.el"))
(load custom-file 'noerror 'nomessage)

;; Prevent GUI dialogs
(setq use-dialog-box nil)

;; Automatically revert buffers
(global-auto-revert-mode 1)

;; Guix home already installed the packages for us,
;; no need to use package.el or use-package

;; Configure evil
;; For certain modes start in Emacs mode by default
(defun myhooks/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  term-mode
                  vterm-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

(require 'evil)
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(add-hook 'evil-mode #'myhooks/evil-hook)
(evil-mode 1)
(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
(evil-global-set-key 'motion "j" 'evil-next-visual-line)
(evil-global-set-key 'motion "k" 'evil-previous-visual-line)
(evil-set-initial-state 'messages-buffer-mode 'normal)
(evil-set-initial-state 'dashboard-mode 'normal)

;; Configure evil-collection
(evil-collection-init)

;; Configure hunspell
(setq ispell-program-name "hunspell")
(setq ispell-hunspell-dict-paths-alist
  '(("hu_HU" "~/.guix-home/profile/share/hunspell/hu_HU.aff")
    ("en_US" "~/.guix-home/profile/share/hunspell/en_US.aff")
   ))
(setq ispell-local-dictionary-alist
  '(("Hungarian" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "hu_HU") nil utf-8)
    ("English"   "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)
   ))
