{pkgs, ...}:
with pkgs;
let
user = "radivarig"; # TODO: use module options tom take this from configuration.nix
extensions = import ./vscode-extensions.nix {inherit pkgs;};
in {
  home-manager.users."${user}" = {
    home.packages = [vscode];
    services.compton.opacityRule = ["90:class_g *= 'Code'"];
  };

  system.activationScripts.fix-vscode-extensions =
  let
    homeDir = "/home/${user}";
    nixConfDir = "/etc/nixos";
    vscodeConfDir = "${homeDir}/.config/Code/User";
    extDir = "${homeDir}/.vscode/extensions";
  in rec {
    text = ''
      ln -sfv ${nixConfDir}/vscode-keybindings.json ${vscodeConfDir}/keybindings.json
      ln -sfv ${nixConfDir}/vscode-settings.json ${vscodeConfDir}/settings.json

      mkdir -p ${extDir}
      chown ${user}:users ${extDir}
      for x in ${lib.concatMapStringsSep " " toString extensions}; do
        ln -sfv $x/share/vscode/extensions/* ${extDir}/
      done
      chown -R ${user}:users ${extDir}
    '';
    deps = [];
  };
}
