{
  typst,
  fontconfig,
  stdenv,
  lib,
  xdg-utils
}:
let
  typstDeps = [
    typst
    fontconfig
  ];

  openCommand = if stdenv.isDarwin
    then "open"
    else "${xdg-utils}/bin/xdg-open";
in
{
  src,
  mainFile ? "slides.typ",
  name,
  extraBuildInputs ? [ ],
}:
stdenv.mkDerivation {
  inherit name;
  # Берём весь репозиторий как источник —
  # слайды могут ссылаться на общие ресурсы (шрифты, картинки)
  inherit src;

  nativeBuildInputs = typstDeps ++ extraBuildInputs;  # Фаза install не нужна — PDF уже в $out после buildPhase

  buildPhase = ''
    mkdir -p $out
    typst compile ${src}/${mainFile} $out/${name}.pdf
  '';

  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/${name} <<EOF
    #!/usr/bin/env bash
    exec ${openCommand} "$out/${name}.pdf"
    EOF
    chmod +x $out/bin/${name}
  '';

  meta = {
    description = "Typst output: ${name}";
    platforms   = lib.platforms.all;
  };

}
