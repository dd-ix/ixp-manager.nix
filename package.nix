{ lib
, fetchFromGitHub
, php84
, dataDir ? "/var/lib/ixp-manager"
}:

let
  phpPackage = php84;
in
phpPackage.buildComposerProject2 (finalAttrs: {
  pname = "ixp-manager";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "inex";
    repo = "IXP-Manager";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-wrLWAd9GdNqzkmZnjzZ0CNaAXNaeXVvmpaRiF7uleSM=";
  };

  # fails because deprecated license identifier was used 🙄
  composerStrictValidation = false;

  vendorHash = "sha256-Kcv52Fow/XTZKxmA9XX6ICdFJhm74QDn3tyt+ho8JT4=";

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
})
