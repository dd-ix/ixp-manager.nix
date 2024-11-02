{ lib
, fetchFromGitHub
, fetchpatch
, php82
, dataDir ? "/var/lib/ixp-manager"
}:

let
  phpPackage = php82;
in
phpPackage.buildComposerProject rec {
  pname = "ixp-manager";
  version = "6.4.1";

  src = fetchFromGitHub {
    owner = "inex";
    repo = "IXP-Manager";
    rev = "v${version}";
    sha256 = "sha256-Hgjem/3z3FXWklZTbN0Y+gJEeL6QGGePEd70qC28Ktg=";
  };

  vendorHash = "sha256-l5DHdjMZT5QfcVDyk02MR0y/yEfZamRwmE9D/ObIEuk=";
  composerStrictValidation = false;

  patches = [
    ./cipher-config.patch
    (fetchpatch {
      name = "fix-landingpage-logo.path";
      url = "https://github.com/MarcelCoding/IXP-Manager/commit/015f4ff8e6c5f7c45e1b2544620148909b29802f.patch";
      hash = "sha256-N0o6ohtSBMgcdp3F+cbQSF4rzJJhJDuE1d4JsopLbqY=";
    })
  ];

  installPhase = ''
    runHook preInstall

    mv $out/share/php/ixp-manager/* $out
    rm -r $out/share

    rm -rf $out/bootstrap/cache $out/storage $out/.env
    ln -s ${dataDir}/.env $out/.env
    ln -s ${dataDir}/storage $out/storage
    ln -s ${dataDir}/cache $out/bootstrap/cache
    ln -s ${dataDir}/skin $out/resources/skins/custom
    ln -s ${dataDir}/custom.php $out/config/custom.php

    runHook postInstall
  '';

  passthru = { inherit phpPackage; };

  meta = with lib; {
    description = "A full stack management platform for Internet eXchange Points (IXPs)";
    homepage = "https://www.ixpmanager.org/";
    license = licenses.gpl2Only;
    # maintainers = teams.wdz.members;
    platforms = platforms.linux;
  };
}
