{ lib
, fetchFromGitHub
, php84
, dataDir ? "/var/lib/ixp-manager"
}:

let
  phpPackage = php84;
in
phpPackage.buildComposerProject2 rec {
  pname = "ixp-manager";
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "inex";
    repo = "IXP-Manager";
    rev = "v${version}";
    sha256 = "sha256-XT0QFv39482VkmvFXzvm1I2D+oIfgO8C+ko5dBwur7Q=";
  };

  # fails because deprecated license identifier was used 🙄
  composerStrictValidation = false;

  vendorHash = "sha256-Lh8doq48W0raHrKggOaiqTuDLzvtu+SzK6ReA6V90yk=";

  patches = [
    ./cipher-config.patch
  ];

  installPhase = ''
    runHook preInstall

    ixp_manager_out="$out/share/php/ixp-manager"

    rm -r $ixp_manager_out/bootstrap/cache $ixp_manager_out/storage
    ln -s ${dataDir}/.env $ixp_manager_out/.env
    ln -s ${dataDir}/storage $ixp_manager_out/storage
    ln -s ${dataDir}/cache $ixp_manager_out/bootstrap/cache
    ln -s ${dataDir}/skin $ixp_manager_out/resources/skins/custom
    ln -s ${dataDir}/custom.php $ixp_manager_out/config/custom.php

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
