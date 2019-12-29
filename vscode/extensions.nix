{pkgs, ...}:
with pkgs;
# for extensions that exist in nixpkgs (some even do not work from marketplace)
with vscode-extensions; [
  bbenoist.Nix
  ms-vscode.cpptools
  ms-python.python
]

# for the rest of extensions
++ vscode-utils.extensionsFromVscodeMarketplace [
  {
    name = "local-history";
    publisher = "xyz";
    version = "1.7.0";
    sha256 = "1fqf2jnk7aix27m6l7ry19bl23bhj9szm3wibglmfa8pnjhp78gm";
  }
  {
    name = "highlight-trailing-white-spaces";
    publisher = "ybaumes";
    version = "0.0.2";
    sha256 = "01hqvszdxg1mn2wyax8alkz92scqv20741rkpvy62hm0wy4piqf2";
  }
  {
    name = "turbo-console-log";
    publisher = "chakrounanas";
    version = "1.3.1";
    sha256 = "06hff8nhm2cnvbd0rg297haw29n8zwkdh5y20qak41jxhilgn4ip";
  }
  {
    name = "prettify-symbols-mode";
    publisher = "siegebell";
    version = "0.4.2";
    sha256 = "0jpv9jy9hll3ypx4638j0sabjdlnhrw3lsd876x2p4cyjbvd8xn8";
  }
  # {
  #   name = "csharp";
  #   publisher = "ms-vscode";
  #   version = "1.21.8";
  #   sha256 = "0jafv4i2acvfja5pj5nka1i05xza6xyjsvzizma3aj233nx1ag0q";
  # }
  {
    name = "bracket-pair-colorizer";
    publisher = "CoenraadS";
    version = "1.0.61";
    sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
  }
  {
    name = "Theme-x3-alpha";
    publisher = "gerane";
    version = "0.0.2";
    sha256 = "1xplyppwhnqb2j5al4lklwapm0ka87y43g2bvdiakhqmmqsn8qrh";
  }
  {
    name = "blender-development";
    publisher = "JacquesLucke";
    version = "0.0.12";
    sha256 = "1np437ahichidlr90irf4anc1v8vg3w10lhv3q5nrgwlq5rydxyz";
  }
  {
    name = "partial-diff";
    publisher = "ryu1kn";
    version = "1.4.0";
    sha256 = "1q8ccbaqv6kq6mw5gizslnjg4rdzpwmapaac17z9pwah8qsnqimw";
  }
  {
    name = "vsc-space-block-jumper";
    publisher = "jmfirth";
    version = "1.2.2";
    sha256 = "0lahqjg1kzxa4vbjsyxp36i265s82b9xsj47siggi2iqi4slfwdx";
  }
  {
    name = "bracket-select";
    publisher = "chunsen";
    version = "2.0.1";
    sha256 = "0sw8azz87ikadggp91ypfvazkbjs769z0p1bsl6cc18lfpmdfl2d";
  }
  {
    name = "nodejs-repl";
    publisher = "lostfields";
    version = "0.5.11";
    sha256 = "1rik6qwdag4h19253psnrx5hjj5hskx529qnnr1g65kzdx51dx3h";
  }
  {
    name = "find-jump";
    publisher = "mksafi";
    version = "1.2.4";
    sha256 = "1qk2sl3dazna3zg6nq2m7313jdl67kxm5d3rq0lfmi6k1q2h9sd7";
  }
  {
    name = "prettify-json";
    publisher = "mohsen1";
    version = "0.0.3";
    sha256 = "1spj01dpfggfchwly3iyfm2ak618q2wqd90qx5ndvkj3a7x6rxwn";
  }
  {
    name = "debugger-for-chrome";
    publisher = "msjsdiag";
    version = "4.11.3";
    sha256 = "1i5skl12pdd1f5diday0prihdd99kdvcv3www3zrkpvxkpyp8v9a";
  }
  {
    name = "color-highlight";
    publisher = "naumovs";
    version = "2.3.0";
    sha256 = "1syzf43ws343z911fnhrlbzbx70gdn930q67yqkf6g0mj8lf2za2";
  }
  {
    name = "printcode";
    publisher = "nobuhito";
    version = "3.0.0";
    sha256 = "0nms3fd401mimg9ansnqadnmg77f3n3xh98bpcqxhln4562rmv9b";
  }
  {
    name = "indent-rainbow";
    publisher = "oderwat";
    version = "7.3.0";
    sha256 = "18m08k8ghck4dcd83v9r4a7djw4yc40qb1ajga57qc2gag6m9sg7";
  }
  {
    name = "vscode-scheme";
    publisher = "sjhuangx";
    version = "0.3.2";
    sha256 = "0v6a6dzjw6zkpjc92jaiah5nbk9c85f4jfbzhwwcm0q1lbj0wyjq";
  }
  {
    name = "move-ts";
    publisher = "stringham";
    version = "1.11.3";
    sha256 = "0bf1jk0crp19crwad30kh0j9h4cl966f3wn0pjy2p67frfbp68yw";
  }
  {
    name = "cmake";
    publisher = "twxs";
    version = "0.0.17";
    sha256 = "11hzjd0gxkq37689rrr2aszxng5l9fwpgs9nnglq3zhfa1msyn08";
  }
  {
    name = "gitblame";
    publisher = "waderyan";
    version = "2.6.3";
    sha256 = "08rlmb5ic22hglh6fmi2pl2p1yphjk5vpbi2hs12pxqjc57cqww9";
  }
  {
    name = "markdown-pdf";
    publisher = "yzane";
    version = "1.2.0";
    sha256 = "1qwkyi2gcmwmw74n6q2wixwm4da4xvbln0d70af6hwg4b9ysmxgs";
  }
  {
    name = "whiteviz";
    publisher = "spywhere";
    version = "0.6.1";
    sha256 = "1nv8h1yfjvm7c7wl19kg4dhfhbisx4r7983p47njhhp17laf2wrc";
  }
]
