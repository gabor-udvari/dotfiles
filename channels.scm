(list (channel
        (name 'guix)
        ;; (url "https://git.savannah.gnu.org/git/guix.git")
        (url "https://codeberg.org/guix/guix-mirror.git")
        (branch "master")
        (commit
          "9bc97424d347901e6b70b5477a1066359f3d6f2c")
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
          "f17f73f97b673383fbca2ace691b5ab52f374e6b")
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
          "7152e92a13edf3e9a356e7b9b759b163aed3044c")
        (introduction
          (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
              "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))
