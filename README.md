dotfiles
========

Gabor Udvari's dotfiles

Installation
------------

### Guix Home

The preferred method is to use [guix home](https://guix.gnu.org/manual/en/guix.html#Home-Configuration) with the included `guix-home-config.scm` manifest file. This will not only install the config files, but the packages and services as well.

```
git clone https://github.com/gabor-udvari/dotfiles.git
guix home dotfiles/guix-home-config.scm
```

### Homeshick

For compatibility the folder structure follows the [homeshick](https://github.com/andsens/homeshick) castle standard, you can also use that for installing the config files.

```
homeshick clone gabor-udvari/dotfiles
```

Added features of bash
----------------------

- launching an ssh-agent session
- customizing the prompt
- adding terminal logging as seen on [launchpad](https://answers.launchpad.net/ubuntu/+source/gnome-terminal/+question/7131#comment-6)

Content of bin
--------------

- odfgrep: search in Open Document Format files (requires tidy)
- sync-ssh2local.sh: sync a remote and local folder with rsync
- todo.sh: [todo.txt-cli](https://github.com/ginatrapani/todo.txt-cli) version 2.10
