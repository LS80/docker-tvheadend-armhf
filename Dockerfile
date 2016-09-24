FROM lsiobase/alpine.armhf
MAINTAINER saarg

# package version
ARG ARGTABLE_VER="2.13"
ARG UNICODE_VER="2.09"
ARG XMLTV_VER="0.5.68"
ARG TZ="Europe/Oslo"

# Environment settings
ENV HOME="/config"

# copy patches
COPY patches/ /tmp/patches/

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	cmake \
	coreutils \
	ffmpeg-dev \
	file \
	findutils \
	g++ \
	gcc \
	gettext-dev \
	git \
	libhdhomerun-dev \
	libgcrypt-dev \
	libtool \
	libxml2-dev \
	libxslt-dev \
	make \
	mercurial \
	openssl-dev \
	patch \
	perl-dev \
	pkgconf \
	sdl-dev \
	uriparser-dev \
	wget \
	zlib-dev && \

# add runtime dependencies required in build stage
 apk add --no-cache \
	bsd-compat-headers \
	bzip2 \
	curl \
	gzip \
	libcrypto1.0 \
	libcurl	\
	libssl1.0 \
	linux-headers \
	openssl \
	perl \
	perl-archive-zip \
	perl-boolean \
	perl-capture-tiny \
	perl-cgi \
	perl-compress-raw-zlib \
	perl-datetime \
	perl-digest-sha1 \
	perl-file-slurp \
	perl-file-temp \
	perl-getopt-long \
	perl-html-parser \
	perl-html-tree \
	perl-http-cookies \
	perl-io \
	perl-io-compress \
	perl-io-html \
	perl-io-stringy \
	perl-json \
	perl-libwww \
	perl-module-build \
	perl-module-pluggable \
	perl-net-ssleay \
	perl-parse-recdescent \
	perl-path-class \
	perl-term-readkey \
	perl-test-exception \
	perl-test-requires \
	perl-try-tiny \
	perl-xml-parser \
	perl-xml-sax \
	python \
	tar \
	uriparser \
	wget \
	zlib && \

# build libiconv
 mkdir -p \
 /tmp/iconv-src && \
 curl -o \
 /tmp/iconv.tar.gz -L \
	ftp://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz && \
 tar xf /tmp/iconv.tar.gz -C \
	/tmp/iconv-src --strip-components=1 && \
 cd /tmp/iconv-src && \
 ./configure \
	--prefix=/usr/local && \
 patch -p1 -i \
	/tmp/patches/libiconv-1-fixes.patch && \
 make && \
 make install && \
 libtool --finish /usr/local/lib && \

# install perl modules
 curl -L http://cpanmin.us | perl - App::cpanminus && \
 cpanm Date::Language && \
 cpanm Date::Manip && \
 cpanm DateTime::Format::ISO8601 && \
 cpanm DateTime::Format::Strptime && \
 cpanm HTML::Entities && \
 cpanm HTML::TableExtract && \
 cpanm HTML::TreeBuilder && \
 cpanm HTTP::Cache::Transparent && \
 cpanm inc && \
 cpanm IO::Scalar && \
 cpanm IO::Socket::SSL && \
 cpanm JSON::PP && \
 cpanm Lingua::EN::Numbers::Ordinate && \
 cpanm Lingua::Preferred && \
 cpanm List::MoreUtils && \
 cpanm LWP::Simple && \
 cpanm LWP::UserAgent && \
 cpanm PerlIO::gzip && \
 cpanm SOAP::Lite && \
 cpanm Storable && \
 cpanm Term::ProgressBar && \
 cpanm Unicode::UTF8simple && \
 cpanm version && \
 cpanm WWW::Mechanize && \
 cpanm XML::DOM && \
 cpanm XML::LibXML && \
 cpanm XML::LibXSLT && \
 cpanm XML::TreePP && \
 cpanm XML::Twig && \
 cpanm XML::Writer && \

# patch and build perl-unicode-string
 mkdir -p \
	/tmp/unicode && \
 curl -o \
 /tmp/unicode-src.tar.gz -L \
	"http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Unicode-String-${UNICODE_VER}.tar.gz" && \
 tar xzf /tmp/unicode-src.tar.gz -C \
	/tmp/unicode --strip-components=1 && \
 cd /tmp/unicode/lib/Unicode && \
 patch -i /tmp/patches/perl-unicode.patch && \
 cd /tmp/unicode && \
 perl Makefile.PL && \
 make && \
 make test && \
 make install && \

# build dvb-apps
 hg clone http://linuxtv.org/hg/dvb-apps /tmp/dvb-apps && \
 cd /tmp/dvb-apps && \
 make && \
 make install && \

# build tvheadend
 git clone https://github.com/tvheadend/tvheadend.git /tmp/tvheadend && \
 cd /tmp/tvheadend && \
 ./configure \
	--disable-ffmpeg_static \
	--disable-hdhomerun_static \
	--disable-libfdkaac_static \
	--disable-libmfx_static \
	--disable-libtheora_static \
	--disable-libvorbis_static \
	--disable-libvpx_static \
	--disable-libx264_static \
	--disable-libx265_static \
	--enable-hdhomerun_client \
	--enable-libav \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/config && \
 make && \
 make install && \

# build XMLTV
 curl -o /tmp/xmtltv-src.tar.bz2 -L \
	"http://kent.dl.sourceforge.net/project/xmltv/xmltv/${XMLTV_VER}/xmltv-${XMLTV_VER}.tar.bz2" && \
 tar xf /tmp/xmtltv-src.tar.bz2 -C \
	/tmp --strip-components=1 && \
 cd "/tmp/xmltv-${XMLTV_VER}" && \
 /bin/echo -e "yes" | perl Makefile.PL PREFIX=/usr/ INSTALLDIRS=vendor && \
 make && \
 make test && \
 make install && \

# build argtable2
 ARGTABLE_VER1="${ARGTABLE_VER//./-}" && \
 mkdir -p \
	/tmp/argtable && \
 curl -o \
 /tmp/argtable-src.tar.gz -L \
	"https://sourceforge.net/projects/argtable/files/argtable/argtable-${ARGTABLE_VER}/argtable${ARGTABLE_VER1}.tar.gz" && \
 tar xf /tmp/argtable-src.tar.gz -C \
	/tmp/argtable --strip-components=1 && \
 cd /tmp/argtable && \
 ./configure \
	--prefix=/usr && \
 make && \
 make check && \
 make install && \

# build comskip
 git clone git://github.com/erikkaashoek/Comskip /tmp/comskip && \
 cd /tmp/comskip && \
 ./autogen.sh && \
	./configure \
		--bindir=/usr/bin \
		--sysconfdir=/config/comskip && \
 make DEFAULT_CFLAGS="-g -O2" && \
 make install && \

# install runtime packages
 apk add --no-cache \
	ffmpeg \
	ffmpeg-libs \
	libhdhomerun-libs \
	libxml2 \
	libxslt && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/config/.cpanm \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9981 9982
VOLUME /config /recordings
