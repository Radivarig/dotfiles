{pkgs, ...}:
with pkgs;
let
user = "radivarig"; # TODO: use module options tom take this from configuration.nix
extensions = import ./extensions.nix {inherit pkgs;};
in {
  home-manager.users."${user}" = {
    home.packages = [vscode];
    services.compton.opacityRule = ["90:class_g *= 'Code'"];
  };

  system.activationScripts.fix-vscode-extensions =
  let
    homeDir = "/home/${user}";
    vscodeNixConfDir = "/etc/nixos/vscode";
    vscodeConfDir = "${homeDir}/.config/Code/User";
    extDir = "${homeDir}/.vscode/extensions";
    configs = ["settings.json" "keybindings.json"];
  in rec {
    text = ''
      for x in ${lib.concatMapStringsSep " " toString configs}; do
        ln -f ${vscodeNixConfDir}/$x ${vscodeConfDir}/
      done

      mkdir -p ${extDir}
      chown ${user}:users ${extDir}
      for x in ${lib.concatMapStringsSep " " toString extensions}; do
        ln -sf $x/share/vscode/extensions/* ${extDir}/
      done
      chown -R ${user}:users ${extDir}
    '';
    deps = [];
  };
}
