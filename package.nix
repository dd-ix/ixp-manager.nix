{ lib
, fetchFromGitHub
, fetchpatch
, php82
, dataDir ? "/var/lib/ixp-manager"
}:

let
  phpPackage = php82;
in
phpPackage.buildComposerProject2 rec {
  pname = "ixp-manager";
  version = "6.4.2";

  src = fetchFromGitHub {
    owner = "inex";
    repo = "IXP-Manager";
    rev = "v${version}";
    sha256 = "sha256-/bd7AYPBQ4hZS45kbtCmpILroiYIrcqnivoDRTwYxYI=";
  };

  # fails because deprecated license identifier was used 🙄
  composerStrictValidation = false;

  vendorHash = "sha256-P7gSGyBgrSiDN7/EeBl1TV2lFvEMTEcRG9BD9UT7Ri0=";

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
