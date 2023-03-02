;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu packages)
             (gnu services)
             (guix gexp))

(define (make-file path name)
    (local-file
         (string-append (getenv "HOME") "/software/guix-home/" path)
            name
               #:recursive? #t))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "glibc-locales"
                                            "shellcheck"
                                            "grep"
                                            "findutils"
                                            "direnv"
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
                                  ,(local-file "home/.sync-history.sh" "sync-history")))
                   ))))
