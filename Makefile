SHELL = /usr/bin/env
.SHELLFLAGS = bash -c
CYAN_TERMINAL_OUTPUT = \033[1;36m
GREEN_TERMINAL_OUTPUT = \033[1;32m
RED_TERMINAL_OUTPUT = \033[1;31m
CLEAR = \033[0m

install: --config-home --install-home

.ONESHELL:
--config-home:
	@{ \
		echo -e "${GREEN_TERMINAL_OUTPUT}--> Building Home...${CLEAR}"
		mkdir -p build
		cat configs/*.org >build/tangle.org
		emacs -Q --batch --eval "(require 'org)" \
			--eval "(add-hook 'org-babel-pre-tangle-hook (lambda () (setq coding-system-for-write 'utf-8-unix)))" \
			--eval '(org-babel-tangle-file "build/tangle.org")'
		shopt -s dotglob
		test -d home && cp -pr home/* build/home/ || true
	}

.ONESHELL:
--install-home:
	@{ \
		if command -v guix; then
			echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying Guix Home...${CLEAR}"
			guix pull -C channels.scm
			if guix time-machine -C channels.scm -- home reconfigure ./build/guix-home-config.scm; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> Finished deploying home with Guix.${CLEAR}"
			fi
		elif command -v stow; then
			echo -e "${CYAN_TERMINAL_OUTPUT}--> Warning: Guix not found, deploying with Stow...${CLEAR}"
			echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying home with Stow...${CLEAR}"
			if stow --no-folding --adopt --dir=./build --target ~/ home; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> Finished deploying home with Stow.${CLEAR}"
			fi
		elif command -v rsync; then
			echo -e "${CYAN_TERMINAL_OUTPUT}--> Warning: Guix not found, deploying with Rsync...${CLEAR}"
			echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying home with Rsync...${CLEAR}"
			if rsync -avr build/home/ ~/; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> Finished deploying home with Rsync.${CLEAR}"
			fi
		fi
	}

.ONESHELL:
--install-terminfo:
	@{ \
		echo -e "${GREEN_TERMINAL_OUTPUT}--> Copying emacs-eat terminfo files${CLEAR}"
		cp -pr "$$(emacs --batch --eval "(require 'eat)" --eval "(princ eat-term-terminfo-directory)")" "${HOME}"/.terminfo
	}

update-channels:
	@{
		echo -e "${GREEN_TERMINAL_OUTPUT}--> Updating channels.scm...${CLEAR}"
		mkdir -p build
		sed -e '/commit/,+1d' channels.scm >build/channels-update.scm
		guix time-machine -C build/channels-update.scm -- describe --format=channels >channels.scm
	}

clean:
	@echo "Removing build artifacts..."
	@rm -rf build
