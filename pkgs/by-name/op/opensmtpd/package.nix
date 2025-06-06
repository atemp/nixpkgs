{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  autoconf-archive,
  pkgconf,
  libtool,
  bison,
  libevent,
  zlib,
  libressl,
  db,
  pam,
  libxcrypt,
  nixosTests,
}:

stdenv.mkDerivation rec {
  pname = "opensmtpd";
  version = "7.7.0p0";

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkgconf
    libtool
    bison
  ];
  buildInputs = [
    libevent
    zlib
    libressl
    db
    pam
    libxcrypt
  ];

  src = fetchurl {
    url = "https://www.opensmtpd.org/archives/${pname}-${version}.tar.gz";
    hash = "sha256-sJU9oc4sv+S+E5zbGaqTX7+rQs8KmT1CWzejl9xIOWg=";
  };

  patches = [
    ./proc_path.diff # TODO: upstream to OpenSMTPD, see https://github.com/NixOS/nixpkgs/issues/54045
  ];

  postPatch = ''
    substituteInPlace mk/smtpctl/Makefile.am --replace "chgrp" "true"
    substituteInPlace mk/smtpctl/Makefile.am --replace "chmod 2555" "chmod 0555"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-mantype=doc"
    "--with-auth-pam"
    "--without-auth-bsdauth"
    "--with-path-socket=/run"
    "--with-path-pidfile=/run"
    "--with-user-smtpd=smtpd"
    "--with-user-queue=smtpq"
    "--with-group-queue=smtpq"
    "--with-path-CAfile=/etc/ssl/certs/ca-certificates.crt"
    "--with-libevent=${libevent.dev}"
    "--with-table-db"
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  meta = with lib; {
    homepage = "https://www.opensmtpd.org/";
    description = ''
      A free implementation of the server-side SMTP protocol as defined by
      RFC 5321, with some additional standard extensions
    '';
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      obadz
      ekleog
      vifino
    ];
  };
  passthru.tests = {
    basic-functionality-and-dovecot-interaction = nixosTests.opensmtpd;
    rspamd-integration = nixosTests.opensmtpd-rspamd;
  };
}
