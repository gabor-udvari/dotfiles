CYAN_TERMINAL_OUTPUT = \033[1;36m
GREEN_TERMINAL_OUTPUT = \033[1;32m
RED_TERMINAL_OUTPUT = \033[1;31m
CLEAR = \033[0m

install: --config-home --install-home

.ONESHELL:
--config-home:
	@{ \
		echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Building Home...${CLEAR}"
		-mkdir build
		cat guix/home-header.org apps/*.org guix/home.org >build/tangle.org
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
			if guix home reconfigure ./build/guix-home-config.scm; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Finished deploying Guix Home.${CLEAR}"
			fi
		elif command -v stow; then
			echo -e "${CYAN_TERMINAL_OUTPUT}--> Warning: guix not found, deploying with Stow...${CLEAR}"
			echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying Stow Home...${CLEAR}"
			if stow --no-folding --dir=./build --target ~/ home; then
				echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Finished deploying Stow home${CLEAR}"
			fi
		fi
		if test -d "${HOME}"/AppData/Roaming/.emacs.d; then
			echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Copying init.el to Windows Emacs folder${CLEAR}"
			cp ./build/home/.config/emacs/init.el "${HOME}"/AppData/Roaming/.emacs.d/
		fi
	}

clean: 
	@echo "Removing build artifacts..."
	@rm -rf build
