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

;; Guix home already installed the packages for us,
;; no need to use package.el or use-package

;; Configure evil
;; For certain modes start in Emacs mode by default
(defun myhooks/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  term-mode))
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
