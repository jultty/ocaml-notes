{pkgs, ...}: {
  kernel.nix.minimal.enable = true;
  kernel.rust.minimal.enable = true;
  # kernel.scala.minimal.enable = true;
  kernel.ocaml.minimal.enable = true;
  kernel.r.minimal.enable = true;
  kernel.zsh.minimal.enable = true;
  kernel.bash.minimal.enable = true;
  kernel.postgres.minimal.enable = true;
  kernel.javascript.minimal.enable = true;
  kernel.typescript.minimal.enable = true;
  kernel.haskell.minimal.enable = true;
  kernel.go.minimal.enable = true;
  kernel.python.minimal.enable = true;
}
