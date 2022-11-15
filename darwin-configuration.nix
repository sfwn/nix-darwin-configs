{ config, pkgs, ... }:
let
  head_colima = pkgs.callPackage ./config/nix/colima.nix { };
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = with pkgs; [
      direnv
      hello
      neofetch
      inetutils
      gnumake
      hub
      jq
      yj
      wget
      curl
      ripgrep
      silver-searcher
      findutils
      universal-ctags
      fd
      kitty # Repeated statement with home-manager.users.sfwn.packages.kitty for Spotlight search, see issue: https://github.com/LnL7/nix-darwin/issues/139
      silicon
      alacritty
      kubectl
      jump
      starship
    ];
    shells = [
      pkgs.zsh
      pkgs.bashInteractive
    ];
  };

  programs.zsh = {
    enable = true;
    variables = {
      EDITOR = "vim";
      LANG = "en_US.UTF-8";
      PATH = "/run/current-system/sw/bin:$GOPATH/bin:/usr/local/bin:/opt/homebrew/bin:$PATH";
    };
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # see: https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module
  imports = [ <home-manager/nix-darwin> ];

  users.users.sfwn = {
    name = "sfwn";
    home = "/Users/sfwn";
  };

  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    brews = [
      {
        name = "mysql@5.7";
        restart_service = "changed";
        link = true;
        conflicts_with = [ "mysql" ];
      }
      {
        name = "etcd";
        restart_service = "changed";
        link = true;
        conflicts_with = [ "etcd" ];
      }
      {
        name = "showkey";
      }
    ];
    casks = [
    ];
  };

  home-manager.users.sfwn = { config, pkgs, ... }:
    {

      nixpkgs.overlays = [
        (import (builtins.fetchTarball {
          url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
        }))
      ];

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      programs.bash.enable = true;

      home.stateVersion = "22.11";

      home.packages = with pkgs; [
        # httpie
        go_1_19
        gopls
        rnix-lsp
        htop
        fortune
        git
        starship
        docker-client
        bat
        tailscale
        pkg-config
        libgit2_1_3_0
        head_colima
        docker-compose
        kind
        kubernetes-helm
        pstree
        rust-analyzer
        cargo
        nodejs-16_x
        lazygit
        code-minimap
        tree-sitter
        iosevka
      ];

      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      programs.btop = {
        enable = true;
      };

      # programs.kitty = {
      #   enable = true;
      #   # settings = builtins.readFile ./config/kitty/kitty.conf;
      # };
      home.file.".config/kitty/kitty.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink ./config/kitty/kitty.conf;
      };
      home.file.".config/kitty/current-theme.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink ./config/kitty/current-theme.conf;
      };

      programs.alacritty = {
        enable = true;
        # settings = let importYAML = file: pkgs.lib.importJSON (pkgs.runCommand "alacritty.yml" {} ''
        #   ${pkgs.yj}/bin/yj -yj < ${file} > $out
        # ''); in importYAML ./config/alacritty/alacritty.yml;
        settings = builtins.fromJSON (builtins.readFile ./config/alacritty/alacritty.json);
      };

      programs.wezterm = {
        enable = true;
      };

      programs.emacs = {
        enable = false;
        extraPackages = epkgs: [
          epkgs.nix-mode
          epkgs.magit
        ];
      };

      programs.git = {
        enable = true;
        userEmail = "sfwnlin@gmail.com";
        userName = "sfwn";
        aliases = {
          st = "status";
          co = "checkout";
          df = "diff";
          dfs = "diff --staged";
        };
        extraConfig = {
          commit.gpgsign = true;
          gpg.format.program = "gpg";
        };
      };

      programs = {
        zsh = rec {
          enable = true;
          enableCompletion = true;
          enableAutosuggestions = true;
          enableSyntaxHighlighting = false;
          dotDir = ".config/zsh";
          initExtra = "
              echo hello world
              echo hello nix
              eval \"$(jump shell)\"
              eval \"$(starship init zsh)\"
              eval \"$(brew shellenv)\"
              eval \"$(direnv hook zsh)\"
            ";

          history = {
            path = "$HOME/${dotDir}/history";
            size = 50000;
            save = 500000;
            ignoreDups = true;
            share = true;
            extended = true;
          };

          sessionVariables = rec {
            LANG = "en_US.UTF-8";
            EDITOR = "vim";
            VISUAL = EDITOR;
            GIT_EDITOR = EDITOR;
            GOPATH = "$HOME/go";
            NIX_PATH = "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels:darwin-config=$HOME/.nixpkgs/darwin-configuration.nix";
            PKG_CONFIG_PATH = "${pkgs.libgit2_1_3_0}/lib/pkgconfig";
            #GOLANG_PROTOBUF_REGISTRATION_CONFLICT = "ignore";
          };

          oh-my-zsh = {
            enable = true;
            theme = "robbyrussell";
            plugins = [ "git" ];
          };

          shellAliases = {
            ls = "${pkgs.coreutils}/bin/ls --color=auto";
            la = "${pkgs.coreutils}/bin/ls -a --color=auto";
            ll = "${pkgs.coreutils}/bin/ls -l -a --color=auto";
            ds = "darwin-rebuild switch";
          };
        };
      };

      programs.neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
        extraConfig = builtins.readFile (./config/nvim/init.vim);
        plugins = with pkgs.vimPlugins;
          let
            smart-term-esc-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "smart-term-esc";
              src = pkgs.fetchFromGitHub {
                owner = "sychen52";
                repo = "smart-term-esc.nvim";
                rev = "168cd1a9e4649038e356b293005e5714e6e9f190";
                sha256 = "sha256-/jce1Yyp1xfmy66Kv9dD+yJ+KPk+rs8YnO/TaluKv3k=";
              };
              buildPhase = "echo build smart-term-esc.nvim"; # cannot be empty string
            };
            telescope-live-grep-args-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "telescope-live-grep-args-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "nvim-telescope";
                repo = "telescope-live-grep-args.nvim";
                rev = "5a30d23a5b2a6c6a24da41cc7e21e4d68d0d1c6e";
                sha256 = "sha256-DMHauDTEFLY1rh0GpWMCUGwI0TwgsmqKELUClauKc44=";
              };
              buildPhase = "echo build smart-term-esc.nvim"; # cannot be empty string
            };
            silicon-lua = pkgs.vimUtils.buildVimPlugin {
              name = "silicon-lua";
              src = pkgs.fetchFromGitHub {
                owner = "narutoxy";
                repo = "silicon.lua";
                rev = "b17444e25f395fd7c7c712b46aa7977cc8433c84";
                sha256 = "sha256-nFcCeXWHO6+YXfuUUXuxgjBHyYaPO0myj0fkeqyxPFA=";
              };
              buildPhase = "echo build smart-term-esc.nvim";
            };
            beacon-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "beacon-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "DanilaMihailov";
                repo = "beacon.nvim";
                rev = "a786c9a89b2c739c69f9500a2f70f2586c06ec27";
                sha256 = "sha256-qD0dwccNjhJ7xyM+yG8bSFUyPn7hHZyC0RBy3MW1hz0=";
              };
              buildPhase = "echo build beacon.nvim";
            };
            mason-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "mason-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "williamboman";
                repo = "mason.nvim";
                rev = "311a14ffd7aa62561b73405c63478756c265585c";
                sha256 = "sha256-lieBUJ7LF9vSV75K9L6Gsa/BZmdxXwqpCZI7zJz/XTY=";
              };
              buildPhase = "echo build mason-nvim";
            };
            nvim-dap-go = pkgs.vimUtils.buildVimPlugin {
              name = "nvim-dap-go";
              src = pkgs.fetchFromGitHub {
                owner = "leoluz";
                repo = "nvim-dap-go";
                rev = "ce73cf9bce542e0731bb731690a8a72f03fe116b";
                sha256 = "sha256-q4zVjY0QucyMObR1MDyioAtTwytNi7IkIGq96ukzw0g=";
              };
              buildPhase = "echo build nvim-dap-go";
            };
            femaco-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "femaco-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "AckslD";
                repo = "nvim-FeMaco.lua";
                rev = "469465fc1adf8bddc2c9bbe549d38304de95e9f7";
                sha256 = "sha256-fayT1gtbxO0B3qK3pISsgarFVL9Kt/NWOyI26+S9Y+c=";
              };
              buildPhase = "echo build femaco-nvim";
            };
            lspsaga-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "lspsaga-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "glepnir";
                repo = "lspsaga.nvim";
                rev = "361e1ad5554ceaa6b1f462125a6a2442cc115f2d";
                sha256 = "sha256-QXMwIwdtpyh/1YqcGZkXw1JGv0LEUrzd3XUiHA4xqvw=";
              };
              buildPhase = "echo build lspsaga.nvim";
            };
            refactoring-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "refactoring-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "theprimeagen";
                repo = "refactoring.nvim";
                rev = "c9ca8e3bbf7218101f16e6a03b15bf72b99b2cae";
                sha256 = "sha256-eh3rs004NFggOugjvhhFS+5NHhE85rZDU3QKFcsQZ4E=";
              };
              buildPhase = "echo build refactoring.nvim";
            };
            styler-nvim = pkgs.vimUtils.buildVimPlugin {
              name = "styler-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "folke";
                repo = "styler.nvim";
                rev = "1454784d20f183e1791f14be5f3bfcce38285170";
                sha256 = "sha256-WrVXz6UqmBWv78v4ADsDLhs9RIOKig/Hg3ZHluVEN3s=";
              };
              buildPhase = "echo build styler.nvim";
            };
          in
          [
            {
              plugin = direnv-vim;
              type = "viml";
              config = ''
                  '';
            }
            {
              plugin = femaco-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/femaco-nvim.lua);
            }
            nvim-surround
            {
              plugin = nvim-surround;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-surround.lua);
            }
            {
              plugin = which-key-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/which-key-nvim.lua);
            }
            which-key-nvim
            {
              plugin = editorconfig-vim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/editorconfig-vim.lua);
            }
            #gruvbox-community
            #vim-elixi
            vim-nix
            beacon-nvim
            {
              plugin = silicon-lua;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/silicon.lua);
            }

            {
              plugin = nui-nvim;
              type = "lua";
              config = ''
              '';
            }

            # vim-startify
            {
              plugin = alpha-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/alpha-nvim.lua);
            }
            {
              plugin = nvim-web-devicons;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-web-devicons.lua);
            }
            {
              plugin = gitsigns-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/gitsigns-nvim.lua);
            }
            {
              plugin = git-messenger-vim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/git-messenger-vim.lua);
            }
            #nerdtree
            nvim-tree-lua
            {
              plugin = nvim-tree-lua;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-tree-lua.lua);
            }
            fzf-vim
            {
              plugin = FTerm-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/fterm-nvim.lua);
            }

            {
              plugin = indent-blankline-nvim;
              type = "lua";
              config = ''
                require("indent_blankline").setup {
                  -- for example, context is off by default, use this to turn it on
                  show_current_context = true,
                  show_current_context_start = true,
                  show_current_context_end = true,
                }
              '';
            }
            {
              plugin = smart-term-esc-nvim;
              type = "lua";
              config = ''
                require('smart-term-esc').setup{ key='<Esc>', except={'nvim', 'fzf', 'lazygit', 'btop'} }
              '';
            }

            {
              plugin = plenary-nvim;
            }

            {
              plugin = telescope-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/telescope.lua);
            }
            telescope-file-browser-nvim
            telescope-project-nvim
            telescope-fzf-native-nvim
            telescope-coc-nvim
            telescope-live-grep-args-nvim
            telescope-dap-nvim

            {
              plugin = lualine-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/lualine-nvim.lua);
            }

            {
              plugin = (nvim-treesitter.withPlugins (p: with p; [ dockerfile make bash go lua rust nix yaml json vim ]));
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-treesitter.lua);
            }
            # tree-sitter plugins
            {
              plugin = nvim-treesitter-context;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-treesitter-context.lua);
            }
            nvim-ts-rainbow

            # cmp
            {
              plugin = nvim-cmp;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-cmp.lua);
            }
            # cmp sources
            cmp-nvim-lsp
            cmp-buffer
            cmp-path
            cmp-cmdline
            # cmp-vsnip
            # vim-vsnip # depends by cmp-vsnip
            cmp-emoji
            # snippets
            cmp_luasnip
            luasnip # depends by cmp_luasnip
            friendly-snippets
            lspkind-nvim
            cmp-nvim-lsp-signature-help
            cmp-treesitter

            # dap
            {
              plugin = nvim-dap;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-dap.lua);
            }
            nvim-dap-ui
            nvim-dap-go

            {
              plugin = vim-fugitive;
              type = "viml";
              config = builtins.readFile (./config/nvim/plugins/vim-fugitive.vim);
            }
            vim-rhubarb # :GBrowse
            {
              plugin = git-blame-nvim;
              type = "viml";
              config = ''
                let g:gitblame_highlight_group = "Comment"
                autocmd VimEnter * GitBlameDisable
                noremap <silent> <space>gt :GitBlameToggle<CR>
                let g:gitblame_message_template = '      <author>, <date> • <summary>'
                let g:gitblame_date_format = "%c"
              '';
            }

            {
              plugin = symbols-outline-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/symbols-outline-nvim.lua);
            }

            {
              plugin = lsp_signature-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/lsp_signature-nvim.lua);
            }

            # lsp
            {
              plugin = nvim-lspconfig;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-lspconfig.lua);
            }
            {
              plugin = mason-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/mason-nvim.lua);
            }
            fidget-nvim
            {
              plugin = trouble-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/trouble-nvim.lua);
            }
            {
              plugin = lspsaga-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/lspsaga-nvim.lua);
            }
            {
              plugin = refactoring-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/refactoring-nvim.lua);
            }
            {
              plugin = null-ls-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/null-ls-nvim.lua);
            }


            # copilot
            copilot-vim
            {
              plugin = copilot-vim;
              type = "viml";
              config = ''
                imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
                let g:copilot_no_tab_map = v:true
              '';
            }

            {
              plugin = nvim-autopairs;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-autopairs.lua);
            }
            {
              plugin = comment-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/comment-nvim.lua);
            }
            {
              plugin = auto-save-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/auto-save-nvim.lua);
            }
            {
              plugin = leap-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/leap-nvim.lua);
            }
            {
              plugin = vim-repeat;
              type = "viml";
              config = builtins.readFile (./config/nvim/plugins/vim-repeat.vim);
            }

            {
              plugin = barbar-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/barbar-nvim.lua);
            }

            # theme
            papercolor-theme
            dracula-vim
            palenight-vim
            {
              plugin = nvim-colorizer-lua;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/nvim-colorizer-lua.lua);
            }
            aurora
            {
              plugin = catppuccin-nvim;
              type = "lua";
              config = builtins.readFile (./config/nvim/plugins/catppuccin-nvim.lua);
            }
            tokyonight-nvim
            kanagawa-nvim
            {
              plugin = styler-nvim;
              type = "lua";
              config = ''
                require("styler").setup({
                  themes = {
                    markdown = { colorscheme = "kanagawa", background = "dark" },
                    help = { colorscheme = "catppuccin-mocha", background = "dark" },
                    go = { colorscheme = "catppuccin-frappe", background = "dark" },
                  },
                })
              '';
            }
          ]; # Only loaded if programs.neovim.extraConfig is set
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = true;
        withPython3 = true;
        withRuby = true;
      };

      #xdg.configFile."nvim/init.lua".text = builtins.readFile ./config/nvim/lua/init.lua;
    };
}
