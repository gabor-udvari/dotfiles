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
                vterm-mode-hook
                markdown-mode-hook
                ))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Prevent GUI dialogs
(setq use-dialog-box nil)

;; Automatically revert buffers
(global-auto-revert-mode 1)

;; Guix home already installed the packages for us,
;; no need to use package.el or use-package

;; Configure no-littering
(require 'no-littering)
;; Move auto-save files to var
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
;; Store custom-file in etc
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(load custom-file 'noerror 'nomessage)

;; Load all the icons before the dashboard
(require 'all-the-icons)

;; Configure dashboard
(defun myhooks/dashboard-font-setup ()
  (dolist (face '((dashboard-banner-logo-title . 1.4)
                  (dashboard-text-banner . 1.2)
                  (dashboard-heading . 1.1)
                  (dashboard-items-face . 1.0)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face))))

(require 'dashboard)
(add-hook 'dashboard-setup-startup-hook #'myhooks/dashboard-font-setup)
(dashboard-setup-startup-hook)
;; Allow emacsclient -c to show dashboard as well
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
;; Set the banner
(setq dashboard-startup-banner 'logo)
;; Content is not centered by default. To center, set
(setq dashboard-center-content t)
;; Configure widgets
(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(setq dashboard-set-footer nil)

;; Configure ivy
(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

;; Configure Projectile
(projectile-mode +1)
;; Recommended keymap prefix on Windows/Linux
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; Configure evil
;; For certain modes start in Emacs mode by default
(defun myhooks/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  term-mode
                  vterm-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

(require 'doom-modeline)
(doom-modeline-mode 1)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(setq evil-want-keybinding nil)
(require 'evil)
(setq evil-want-integration t)
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

;; Org Mode Configuration ------------------------------------------------------

(defun myhooks/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun myhooks/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(require 'org)
(add-hook 'org-mode-hook #'myhooks/org-mode-setup)
(setq org-ellipsis " ▾")
;; Hide leading stars
(setq org-hide-leading-stars nil)
(myhooks/org-font-setup)

(require 'org-superstar)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
;; Hide leading bullets
(setq org-superstar-leading-bullet ?\s)

(defun myhooks/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(require 'visual-fill-column)
(add-hook 'org-mode-hook #'myhooks/org-mode-visual-fill)

;; In case of dashboard mode do a dashboard-refresh-buffer
;; As seen in https://github.com/emacs-dashboard/emacs-dashboard/issues/433#issuecomment-1468060398
(add-hook 'server-after-make-frame-hook
            (lambda ()
              (when (eq (buffer-local-value 'major-mode (current-buffer)) 'dashboard-mode)
                (dashboard-refresh-buffer))))

;; Configure markdown-mode
(defun myhooks/markdown-font-setup ()
  ;; Set faces for heading levels
  (dolist (face '((markdown-header-face-1 . 1.2)
                  (markdown-header-face-2 . 1.1)
                  (markdown-header-face-3 . 1.05)
                  (markdown-header-face-4 . 1.0)
                  (markdown-header-face-5 . 1.1)
                  (markdown-header-face-6 . 1.1)
                  (markdown-markup-face . 1.0)
                  ))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))
  )

(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist
             '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
   "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(add-hook 'markdown-mode-hook #'myhooks/markdown-font-setup)
