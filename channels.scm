(list (channel
        (name 'guix)
        ;; (url "https://git.savannah.gnu.org/git/guix.git")
        (url "https://codeberg.org/guix/guix.git")
        (branch "master")
        (commit
          "7031794abef44c4e2f8dbd43dbad5e929ea6d3c6")
        (introduction
          (make-channel-introduction
            "df14cacca9b95d69fdd3b6191e42df36af266bcd"
            (openpgp-fingerprint
              "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
        (name 'guix-gaming-games)
        (url "https://gitlab.com/guix-gaming-channels/games.git")
        (branch "master")
        (commit
          "9f0daa2b1bd0dbfe634bb07398a8daf8b026adf3")
        (introduction
          (make-channel-introduction
            "c23d64f1b8cc086659f8781b27ab6c7314c5cca5"
            (openpgp-fingerprint
              "50F3 3E2E 5B0C 3D90 0424  ABE8 9BDC F497 A4BB CC7F"))))
      (channel
        (name 'guix-past)
        ;; (url "https://gitlab.inria.fr/guix-hpc/guix-past")
        (url "https://codeberg.org/guix-science/guix-past")
        (branch "master")
        (commit
          "b14d7f997ae8eec788a7c16a7252460cba3aaef8")
        (introduction
          (make-channel-introduction
            "0c119db2ea86a389769f4d2b9c6f5c41c027e336"
            (openpgp-fingerprint
              "3CE4 6455 8A84 FDC6 9DB4  0CFB 090B 1199 3D9A EBB5"))))
      (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        (branch "master")
        (commit
          "60ffd0353e70d5e371c4bfe2201c9d08c1c05e18")
        (introduction
          (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
              "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
