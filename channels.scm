(list (channel
        (name 'guix)
        ;; (url "https://git.savannah.gnu.org/git/guix.git")
        (url "https://codeberg.org/guix/guix.git")
        (branch "master")
        (commit
          "6c980300f485953bb4935abc2ea0047118e07466")
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
          "a6fc9859837de4a3d8cc824845f8bd28f68c530f")
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
          "473e5a62cd512cc0d5b4ac2c33be0bc0d0379435")
        (introduction
          (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
              "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
        ;; TODO: once https://issues.guix.gnu.org/76081 is merged, we can remove this
        (name 'gocix)
        (url "https://github.com/fishinthecalculator/gocix")
        (branch "main")
        (commit
          "46429d2fc4a428ee52853228107abbc5e3ee6d81")
        (introduction
          (make-channel-introduction
            "cdb78996334c4f63304ecce224e95bb96bfd4c7d"
            (openpgp-fingerprint
              "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))
      (channel
        ;; This is a dependency for the gocix channel
        (name 'sops-guix)
        (url "https://github.com/fishinthecalculator/sops-guix")
        (branch "main")
        (commit
          "8005f05fb1790cad007df3835798f4563e5ca550")
        (introduction
          (make-channel-introduction
            "0bbaf1fdd25266c7df790f65640aaa01e6d2dbc9"
            (openpgp-fingerprint
              "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2")))))
