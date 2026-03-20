{
  inputs = {
    # Стабильный канал nixpkgs — источник всех пакетов
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # flake-utils — хелпер, чтобы не писать руками атрибуты для каждой системы
    # (x86_64-linux, aarch64-linux, aarch64-darwin, x86_64-darwin)
    flake-utils.url = "github:numtide/flake-utils";
    # treefmt-nix — декларативная настройка formatter wrapper для всего репозитория
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    # Оборачиваем всё в eachDefaultSystem — flake автоматически
    # становится рабочим на всех поддерживаемых платформах
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Пакеты nixpkgs для текущей системы
        pkgs = nixpkgs.legacyPackages.${system};

        # Конфигурация treefmt для репозитория.
        # projectRootFile нужен, чтобы formatter корректно находил корень проекта.
        treefmt = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            # Форматирование .nix файлов
            nixfmt.enable = true;
            # Форматирование .typ файлов
            typstyle.enable = true;
          };
        };

        # Вспомогательная функция для сборки слайдов из .typ файла.
        # Принимает attrset с полями name и src, возвращает derivation,
        # которая кладёт PDF в $out/slides.pdf.
        # Использование:
        #   typstBuild { name = "my-slides"; src = "slides/my-talk/slides.typ"; }
        typstBuild =
          { name, src }:
          pkgs.stdenv.mkDerivation {
            inherit name;
            # Берём весь репозиторий как источник —
            # слайды могут ссылаться на общие ресурсы (шрифты, картинки)
            src = ./.;
            buildInputs = with pkgs; [
              typst
              # Route 159 — официальный шрифт NixOS, используется в slides.typ
              route159
            ];
            buildPhase = ''
              mkdir -p $out
              typst compile ${src} $out/${name}.pdf
            '';
            # Фаза install не нужна — PDF уже в $out после buildPhase
            dontInstall = true;
          };
      in
      {
        # formatter — стандартная точка входа для nix fmt
        formatter = treefmt.config.build.wrapper;

        # devShells.default — среда, которая активируется через:
        #   nix develop
        #   direnv (автоматически, при наличии .envrc с "use flake")
        #
        # После входа в среду в PATH появляются все перечисленные инструменты
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Компилятор Typst — typst compile / typst watch
            typst
            # LSP-сервер для Typst: автодополнение, ошибки, превью в редакторе
            # Подхватывается VSCode (Tinymist extension), Neovim, Helix и др.
            tinymist
            # Форматтер для .typ файлов — аналог rustfmt для Typst
            typstyle
            # Fontconfig нужен, чтобы Typst корректно находил
            # системные шрифты на Linux и в nix-окружении
            fontconfig
            # Route 159 — официальный шрифт NixOS из branding guide
            route159
          ];
        };

        # checks — то, что удобно прогонять в CI.
        # formatter.check self проверяет, что дерево уже отформатировано.
        checks = {
          formatting = treefmt.config.build.check self;
        };

        # packages — всё, что можно собрать через nix build .#<имя>
        # Результат появляется в ./result (симлинк, игнорируется .gitignore)
        #
        # Добавление новой статьи:
        #   slides-my-new-talk = typstBuild {
        #     name = "slides-my-new-talk";
        #     src = "slides/my-new-talk/slides.typ";
        #   };
        packages = {
          slides-nix-for-rust-developers = typstBuild {
            name = "slides-nix-for-rust-developers";
            src = "slides/nix-for-rust-developers/slides.typ";
          };
        };
      }
    );
}
