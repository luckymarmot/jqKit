DIR = $(CURDIR)

all: autoreconf oniguruma libjq

autoreconf:
	cd ./Dependencies/jq/ && autoreconf -fi

oniguruma:
	cd ./Dependencies/jq/modules/oniguruma/ && \
		./configure CFLAGS="-fPIC -arch x86_64 -arch arm64" --target arm64-apple-macos11 --host x86_64-apple-darwin20.1.0 --disable-maintainer-mode --enable-all-static --disable-shared --prefix "$(DIR)/Dependencies/onig_install" && \
		MACOSX_DEPLOYMENT_TARGET=10.10 make && \
		make install

libjq:
	cd ./Dependencies/jq/ && \
		./configure CFLAGS="-fPIC -arch x86_64 -arch arm64 -D_REENTRANT=1" --target arm64-apple-macos11 --host x86_64-apple-darwin20.1.0 --disable-maintainer-mode --enable-all-static --disable-shared --with-oniguruma="$(DIR)/Dependencies/onig_install" --disable-docs --prefix="$(DIR)/Dependencies/jq_install" && \
		MACOSX_DEPLOYMENT_TARGET=10.10 make && \
		make install-libLTLIBRARIES install-includeHEADERS

clean:
	make -C ./Dependencies/jq/ clean
	make -C ./Dependencies/jq/modules/oniguruma/ clean
