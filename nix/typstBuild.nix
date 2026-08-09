{
  typst,
  fontconfig,
  stdenv,
}:
let
  typstDeps = [
    typst
    fontconfig
  ];
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

  nativeBuildInputs = typstDeps ++ extraBuildInputs;

  buildPhase = ''
    mkdir -p $out
    typst compile ${src}/${mainFile} $out/${name}.pdf
  '';
  # Фаза install не нужна — PDF уже в $out после buildPhase
  dontInstall = true;
}
