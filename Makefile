CYAN_TERMINAL_OUTPUT = \033[1;36m
GREEN_TERMINAL_OUTPUT = \033[1;32m
RED_TERMINAL_OUTPUT = \033[1;31m
CLEAR = \033[0m

install: --config-home --install-home

.ONESHELL:
--config-home:
	@{ \
		echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Building Home...${CLEAR}"
		mkdir -p build
		cat configs/*.org >build/tangle.org
		emacs --batch --eval "(require 'org)" \
			--eval "(add-hook 'org-babel-pre-tangle-hook (lambda () (setq coding-system-for-write 'utf-8-unix)))" \
			--eval '(org-babel-tangle-file "build/tangle.org")'
		bash -c "shopt -s dotglob; cp -pr home/* build/home/"
	}

.ONESHELL:
--install-home:
	@{ \
		if command -v guix; then
			echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying Guix Home...${CLEAR}"
			if guix time-machine -C channels.scm -- home reconfigure ./build/guix-home-config.scm; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Finished deploying Guix Home.${CLEAR}"
			fi
		elif command -v stow; then
			echo -e "${CYAN_TERMINAL_OUTPUT}--> Warning: guix not found, deploying with Stow...${CLEAR}"
			echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying Stow Home...${CLEAR}"
			if stow --no-folding --dir=./build --target ~/ home; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Finished deploying Stow home${CLEAR}"
			fi
		fi

		echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Copying emacs-eat terminfo files${CLEAR}"
		cp -pr "$$(emacs --batch --eval "(require 'eat)" --eval "(princ eat-term-terminfo-directory)")" "${HOME}"/.terminfo

		if test -d "${HOME}"/AppData/Roaming/.emacs.d; then
			echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Copying config files to Windows Emacs folder${CLEAR}"
			cp ./build/home/.config/emacs/* "${HOME}"/AppData/Roaming/.emacs.d/
		fi
	}

.ONESHELL:
--update-channels:
	@{
		echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Updating channels.scm...${CLEAR}"
		mkdir -p build
		sed -e '/commit/,+1d' channels.scm >build/channels-update.scm
	  guix time-machine -C build/channels-update.scm -- describe --format=channels >channels.scm
	}

clean:
	@echo "Removing build artifacts..."
	@rm -rf build
