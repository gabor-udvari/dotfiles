;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu packages)
             (gnu packages base)
             (gnu packages emacs)
             (gnu packages containers)
             (gnu services)
             (guix gexp))

(define my-glibc-locales
  (make-glibc-utf8-locales
   glibc
   #:locales (list "hu_HU" "en_US")
   #:name "glibc-hungarian-utf8-locales"))

;; Put logs into XDG_LOG_HOME/#$name.log
;; Or $HOME/.local/var/log/$#name.log
(define (home-log name)
        #~(string-append (format #f "~a"
                                 (or (getenv "XDG_LOG_HOME")
                                     (format #f "~a/.local/var/log"
                                             (getenv "HOME"))))
                         "/" #$name ".log"))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (append
              (specifications->packages (list ;; "glibc-locales"
                                            "emacs"
                                            "emacs-doom-modeline"
                                            "emacs-disable-mouse"
                                            "emacs-dashboard"
                                            "emacs-denote"
                                            "emacs-emms"
                                            "emacs-evil"
                                            "emacs-evil-collection"
                                            "emacs-evil-commentary"
                                            "emacs-ivy"
                                            "emacs-no-littering"
                                            "emacs-magit"
                                            "emacs-markdown-mode"
                                            "emacs-org"
                                            "emacs-org-modern"
                                            "emacs-yaml-mode"
                                            "emacs-visual-fill-column"
                                            "emacs-eat"
                                            "emacs-vterm"
                                            "fontconfig"
                                            "font-abattis-cantarell"
                                            "shellcheck"
                                            "jq"
                                            "python-yamllint"
                                            "grep"
                                            "findutils"
                                            "direnv"
                                            "tmux"
                                            "vim"
                                            "pdfgrep"
                                            "qpdf"
                                            "mpv"
                                            "hunspell"
                                            "hunspell-dict-hu"
                                            "hunspell-dict-en"
                                            "podman"
                                            "docker-compose"
                                            ))
              (list my-glibc-locales)
              )
            )

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
    (list (service home-bash-service-type
                   (home-bash-configuration
                     (guix-defaults? #f)
                     (bashrc (list (local-file
                                    "home/.bashrc"
                                    "bashrc")))
                     (bash-logout (list (local-file
                                         "home/.bash_logout"
                                         "bash_logout")))))

          ;; Extend .profile with my own
          (simple-service 'my-profile
                          home-shell-profile-service-type
                              `(,(local-file "home/.profile" "profile")))

          (simple-service 'env-vars-service
                          home-environment-variables-service-type
                          `(("DOCKER_HOST" .  ,(string-append "unix://"
                                                              (or (getenv "XDG_RUNTIME_DIR")
                                                                     (format #f "/run/user/~a"
                                                                       (getuid)))
                                                              "/podman/podman.sock"))
                                ))

          (simple-service 'dotfiles-symlinking-service
                          home-files-service-type
                              `((".shell_prompt.sh"
                                  ,(local-file "home/.shell_prompt.sh" "shell_prompt"))
                                (".sync-history.sh"
                                  ,(local-file "home/.sync-history.sh" "sync-history"))
                                (".config/emacs/init.el"
                                  ,(local-file "home/.config/emacs/init.el" "emacs-init"))))

          (simple-service 'emacsdaemon
                    home-shepherd-service-type
                    (list (shepherd-service
                           (provision '(emacs))
                           (documentation "Run `emacs --daemon'")
                           (start #~(make-forkexec-constructor
                                     (list #$(file-append emacs "/bin/emacs")
                                           "--fg-daemon")
                                     #:log-file #$(home-log "emacs")))
                           (stop #~(make-system-destructor "emacsclient -e '(client-save-kill-emacs)'"))
                           (respawn? #f))))

          ;; Socket activated podman, you can compare with the systemd unit files here:
          ;; https://github.com/containers/podman/issues/9633
          (simple-service 'podman-socket
                    home-shepherd-service-type
                    (list (shepherd-service
                            (provision '(podman))
                            (documentation "Start a systemd like podman.socket")
                            (start #~(make-systemd-constructor
                                      (list #$(file-append podman "/bin/podman")
                                            "system" "service" "-t" "0")
                                      (list (endpoint
                                              (make-socket-address
                                                AF_UNIX
                                                (string-append (or (getenv "XDG_RUNTIME_DIR")
                                                                   (format #f "/run/user/~a"
                                                                     (getuid)))
                                                 "/podman/podman.sock"))))
                                      #:environment-variables (append (default-environment-variables)
                                                                        (list (string-append "CONTAINERS_REGISTRIES_CONF="
                                                                                             (getenv "HOME")
                                                                                             "/.config/containers/registries.conf")))
                                      #:log-file #$(home-log "podman")))
                            (stop #~(make-systemd-destructor)))))
          )))
