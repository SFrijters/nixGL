let
  rev = "a88db0c7c603d31b9ecdd6d4c809104d78dec096";
in
import (fetchTarball {
  url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
})
