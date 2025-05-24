{
  description = "A wrapper tool for nix OpenGL applications";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      # Boilerplate to make the rest of the flake more readable
      # Do not inject system into these attributes
      flatAttrs = [
        "overlays"
        "nixosModules"
      ];
      # Inject a system attribute if the attribute is not one of the above
      injectSystem =
        system:
        lib.mapAttrs (name: value: if builtins.elem name flatAttrs then value else { ${system} = value; });
      # Combine the above for a list of 'systems'
      forSystems =
        systems: f:
        lib.attrsets.foldlAttrs (
          acc: system: value:
          lib.attrsets.recursiveUpdate acc (injectSystem system value)
        ) { } (lib.genAttrs systems f);
    in
      forSystems
        [
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
          "x86_64-linux"
        ](
          system:
      let
        isIntelX86Platform = system == "x86_64-linux";
        pkgs = import ./default.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          enable32bits = isIntelX86Platform;
          enableIntelX86Extensions = isIntelX86Platform;
        };
      in rec {

        packages = {
          # makes it easy to use "nix run nixGL --impure -- program"
          default = pkgs.auto.nixGLDefault;

          nixGLDefault = pkgs.auto.nixGLDefault;
          nixGLNvidia = pkgs.auto.nixGLNvidia;
          nixGLNvidiaBumblebee = pkgs.auto.nixGLNvidiaBumblebee;
          nixGLIntel = pkgs.nixGLIntel;
          nixVulkanNvidia = pkgs.auto.nixVulkanNvidia;
          nixVulkanIntel = pkgs.nixVulkanIntel;
        };

        overlays.default = final: _:
          let isIntelX86Platform = final.system == "x86_64-linux";
          in {
            nixgl = import ./default.nix {
              pkgs = final;
              enable32bits = isIntelX86Platform;
              enableIntelX86Extensions = isIntelX86Platform;
            };
          };
      });
}
