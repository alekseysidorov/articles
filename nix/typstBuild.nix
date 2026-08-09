# Вспомогательная функция для сборки слайдов из .typ файла.
# Принимает attrset с полями name и src, возвращает derivation,
# которая кладёт PDF в $out/slides.pdf.
# Использование:
#   typstBuild { name = "my-slides"; src = "slides/my-talk/slides.typ"; }
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
  name,
  extraBuildInputs ? [ ],
}:
stdenv.mkDerivation {
  inherit name;
  # Берём весь репозиторий как источник —
  # слайды могут ссылаться на общие ресурсы (шрифты, картинки)
  src = ./.;
  nativeBuildInputs = typstDeps + extraBuildInputs;

  buildPhase = ''
    mkdir -p $out
    typst compile ${src} $out/${name}.pdf
  '';
  # Фаза install не нужна — PDF уже в $out после buildPhase
  dontInstall = true;
}
