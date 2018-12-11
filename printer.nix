{ pkgs, ... }: with pkgs;
{
  services.printing = {
    enable = true;
    # add a printer: `nix run nixpkgs.hplip` then `hp-setup`
    drivers = [ pkgs.hplip ];
  };
}