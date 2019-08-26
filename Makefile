DIR = $(CURDIR)

all: autoreconf oniguruma libjq

autoreconf:
	cd ./Dependencies/jq/ && autoreconf -fi

oniguruma:
	cd ./Dependencies/jq/modules/oniguruma/ && \
		./configure CFLAGS=-fPIC --disable-shared --prefix "$(DIR)/Dependencies/onig_install" && \
		make && \
		make install

libjq:
	cd ./Dependencies/jq/ && \
		./configure CFLAGS=-fPIC --disable-maintainer-mode --enable-all-static --disable-shared --with-oniguruma="$(DIR)/Dependencies/onig_install" --disable-docs --prefix="$(DIR)/Dependencies/jq_install" && \
		make && \
		make install-libLTLIBRARIES install-includeHEADERS
