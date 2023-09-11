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
		cat guix/home-header.org apps/emacs.org apps/hledger.org guix/home.org >build/tangle.org
		emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "build/tangle.org")'
		cp -pr home build/home
	}

.ONESHELL:
--install-home:
	@{ \
		echo -e "${GREEN_TERMINAL_OUTPUT}--> Deploying Guix Home...${CLEAR}"
		if guix home reconfigure ./build/guix-home-config.scm; then
			 echo -e "${GREEN_TERMINAL_OUTPUT}--> [Makefile] Finished deploying Guix Home.${CLEAR}"
		fi
	}

clean: 
	@echo "Removing build artifacts..."
	@rm -rf build
