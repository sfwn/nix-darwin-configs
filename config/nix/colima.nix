{ lib, fetchFromGitHub, pkgs }:

# see: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/virtualization/colima/default.nix
pkgs.colima.overrideAttrs (old: {
  version = "latest";
  src = fetchFromGitHub {
    owner = "abiosoft";
    repo = old.pname;
    rev = "6d1ff8bcf8b26ce48ef1e24989a11e65297be0b5";
    sha256 = "sha256-K6klNjbICjn0WK+aWTOibyp/t9SfO0PMdNzJroVzwU0=";
    # We need the git revision
    leaveDotGit = true;
    postFetch = ''
      git -C $out rev-parse --short HEAD > $out/.git-revision
      rm -rf $out/.git
    '';
  };
  preConfigure = ''
    ldflags="-s -w -X github.com/abiosoft/colima/config.appVersion=latest \
    -X github.com/abiosoft/colima/config.revision=$(cat .git-revision)"
  '';
})
