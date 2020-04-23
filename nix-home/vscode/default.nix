{config, pkgs, ...}:
with pkgs;
let
extensions = import ./extensions.nix {inherit pkgs;};
in {
  home.packages = [vscode];
  services.picom.opacityRule = ["90:class_g *= 'Code'"];

  home.activation.vscode-extensions =
  let
    homeDir = "$HOME";
    vscodeNixConfDir = "/etc/nixos/nix-home/vscode";
    vscodeConfDir = "${homeDir}/.config/Code/User";
    extDir = "${homeDir}/.vscode/extensions";
    configs = ["settings.json" "keybindings.json"];
  in config.lib.dag.entryAfter ["writeBoundary"] ''
    for x in ${lib.concatMapStringsSep " " toString configs}; do
      ln -f ${vscodeNixConfDir}/$x ${vscodeConfDir}/
    done

    mkdir -p ${extDir}
    chown $(whoami):users ${extDir}
    for x in ${lib.concatMapStringsSep " " toString extensions}; do
      ln -sf $x/share/vscode/extensions/* ${extDir}/
    done
    chown -R $(whoami):users ${extDir}
  '';
}
