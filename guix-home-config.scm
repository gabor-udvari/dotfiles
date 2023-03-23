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
             (gnu packages emacs)
             (gnu services)
             (guix gexp))

(define (make-file path name)
    (local-file
         (string-append (getenv "HOME") "/software/guix-home/" path)
            name
               #:recursive? #t))

(define (home-log name)
        #~(string-append (or (getenv "XDG_LOG_HOME")
                             (string-append (getenv "HOME") "/.log"))
                         "/" #$name ".log"))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "glibc-locales"
                                            "emacs"
                                            "shellcheck"
                                            "grep"
                                            "findutils"
                                            "direnv"
                                            "tmux"
                                            "vim"
                                            )))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
    (list (service home-bash-service-type
                   (home-bash-configuration
                     (bash-profile (list (local-file
                                    "home/.profile"
                                    "bash_profile")))
                     (bashrc (list (local-file
                                    "home/.bashrc"
                                    "bashrc")))
                     (bash-logout (list (local-file
                                         "home/.bash_logout"
                                         "bash_logout")))))
          (simple-service 'dotfiles-symlinking-service
                          home-files-service-type
                              `((".shell_prompt.sh"
                                  ,(local-file "home/.shell_prompt.sh" "shell_prompt"))
                                (".sync-history.sh"
                                  ,(local-file "home/.sync-history.sh" "sync-history"))
                                (".emacs.d/init.el"
                                  ,(local-file "home/.emacs.d/init.el" "emacs-init"))))
          (simple-service 'my-home-services
                    home-shepherd-service-type
                    (list (shepherd-service
                           (provision '(emacs))
                           (documentation "Run `emacs --daemon'")
                           (start #~(make-forkexec-constructor
                                     (list #$(file-append emacs "/bin/emacs")
                                           "--fg-daemon")
                                     #:log-file #$(home-log "emacs")))
                           (stop #~(make-system-destructor "emacsclient -e '(kill-emacs)'"))
                           (respawn? #f))))
          )))
