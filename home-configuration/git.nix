{pkgs, ...}:
{
  programs.git = {
    enable = true;
    userName = "Radivarig";
    userEmail = "reslav.hollos@gmail.com";
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      core = {
        whitespace = "cr-at-eol";
        excludesfile = "~/.gitignore_global";
      };
    };
    lfs = {
      enable = true;
    };
  };

  home.file.".gitignore_global".text = with pkgs;  ''
  '';

  programs.bash.shellAliases = {
    gl = "git log";
    gla = "git log --all --decorate --oneline --graph";
    gd = "git diff";
    gds = "git diff --staged";
    gs = "git status";
    ga = "git add";
    gap = "git add --patch";
    gc = "git commit --message";
    gca = "git commit --amend";
    gch = "git checkout";
    gb = "git branch --all";
    gcp = "git cherry-pick";
    gp = "git pull";
    gm = "git merge";
    ggwp = "git push origin HEAD";
  };
}