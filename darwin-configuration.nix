{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = with pkgs; [
      vimHugeX
      hello
      neofetch
      inetutils
      gnumake
      hub
      jq
      wget
      curl
      ripgrep
      silver-searcher
      findutils
      universal-ctags
      fd
    ];
    variables = {
      EDITOR = "vim";
      LANG = "en_US.UTF-8";
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
    ];
    casks = [
      #{
      #  name = "docker";
      #}
      {
        name = "lulu"; # macOS firewall
      }
    ];
  };

  home-manager.users.sfwn = { pkgs, ... }: {

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
    programs.bash.enable = true;

    home.stateVersion = "22.05";

    home.packages = with pkgs; [
      httpie
      go_1_19
      gopls
      rnix-lsp
      htop
      fortune
      gitui
      git
      starship
      docker-client
      bat
      tailscale
      pkg-config
      libgit2_1_3_0
      colima
      pstree
      rust-analyzer
      nodejs-16_x
      lazygit
      code-minimap
    ];

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    programs.btop = {
      enable = true;
    };

    programs.kitty = {
      enable = true;
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
    };

    programs.gitui = {
      enable = true;
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
          PATH = "/run/current-system/sw/bin:$PATH:$GOPATH/bin:/usr/local/bin:/opt/homebrew/bin";
          PKG_CONFIG_PATH = "${pkgs.libgit2_1_3_0}/lib/pkgconfig";
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
      extraConfig = builtins.readFile (./config/nvim/init.vim);
      plugins = with pkgs.vimPlugins;
        let
          context-vim = pkgs.vimUtils.buildVimPlugin {
            name = "context-vim";
            src = pkgs.fetchFromGitHub {
              owner = "wellle";
              repo = "context.vim";
              rev = "e38496f1eb5bb52b1022e5c1f694e9be61c3714c";
              sha256 = "1iy614py9qz4rwk9p4pr1ci0m1lvxil0xiv3ymqzhqrw5l55n346";
            };
          };
          nvim-dap-go = pkgs.vimUtils.buildVimPlugin {
            name = "nvim-dap-go";
            src = pkgs.fetchFromGitHub {
              owner = "leoluz";
              repo = "nvim-dap-go";
              rev = "c2902bb96c45e872d947d7e174775e652439add4";
              sha256 = "sha256-N02snYCekDRv5+GB1ilTJuZfxzn5UheQtVFk4wjxjuc=";
            };
          };
          auto-save-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "auto-save-nvim";
            src = pkgs.fetchFromGitHub {
              owner = "Pocco81";
              repo = "auto-save.nvim";
              rev = "2c7a2943340ee2a36c6a61db812418fca1f57866";
              sha256 = "sha256-keK+IAnHTTA5uFkMivViMMAkYaBvouYqcR+wNPgN3n0=";
            };
            buildPhase = "echo build auto-save-nvim"; # cannot be empty string
          };
          leap-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "leap-nvim";
            src = pkgs.fetchFromGitHub {
              owner = "ggandor";
              repo = "leap.nvim";
              rev = "f20631a18be5ae56d3ec840f48d5a8d8c0ede06e";
              sha256 = "sha256-s+qXHlchPP8OtXfrcme7qX8rEiUOCp/No9DDcHc7YpE=";
            };
            buildPhase = "echo build leap-nvim"; # cannot be empty string
          };
          alpha-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "alpha";
            src = pkgs.fetchFromGitHub {
              owner = "goolord";
              repo = "alpha-nvim";
              rev = "0bb6fc0646bcd1cdb4639737a1cee8d6e08bcc31";
              sha256 = "sha256-tKXSFZusajLLsbQj6VKZG1TJB+i5i1H5e5Q5tbe+ojM=";
            };
            buildPhase = "echo build alpha-nvim"; # cannot be empty string
          };
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
        in
        [
          #context-vim
          editorconfig-vim
          #gruvbox-community
          #vim-elixi
          vim-nix

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
          #gitsigns-nvim
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
            plugin = aerial-nvim;
            type = "lua";
            config = builtins.readFile (./config/nvim/plugins/aerial-nvim.lua);
          }
          aerial-nvim

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

          # statusline
          #{
          #  plugin = feline-nvim;
          #  type = "lua";
          #  config = builtins.readFile (./config/nvim/plugins/feline-nvim.lua);
          #}
          {
            plugin = lualine-nvim;
            type = "lua";
            config = builtins.readFile (./config/nvim/plugins/lualine-nvim.lua);
          }
          {
            plugin = lualine-lsp-progress;
          }
          #vim-airline
          minimap-vim
          {
            plugin = minimap-vim;
            type = "viml";
            config = ''
              let g:minimap_width = 10
              let g:minimap_auto_start = 1
              let g:minimap_auto_start_win_enter = 1
              let g:minimap_highlight_range = 1
            '';
          }

          # go
          {
            plugin = vim-go;
            type = "viml";
            config = ''
              let g:go_gopls_enabled=1
              let g:go_gopls_options = ['-remote=auto', '-logfile=/tmp/gopls-vim-go.log']
              let g:go_imports_autosave = 0 " use coc-go editor.action.organizeImport
            '';
          }
          nvim-dap
          {
            plugin = nvim-dap-go;
            type = "viml";
            config = ''
              lua require('dap-go').setup()
            '';
          }
          #nvim-treesitter # depends by nvim-dap-go
          {
            plugin = (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars));
            type = "lua";
            config = builtins.readFile (./config/nvim/plugins/nvim-treesitter.lua);
          }
          #(nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
          {
            plugin = nvim-treesitter-context;
            type = "lua";
            config = builtins.readFile (./config/nvim/plugins/nvim-treesitter-context.lua);
          }

          # coc
          coc-go
          coc-rust-analyzer
          coc-snippets
          coc-json
          coc-git
          coc-highlight
          {
            plugin = vim-fugitive;
            type = "viml";
            config = ''
              " for :GBrowse
              command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)
            '';
          }
          vim-rhubarb

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

          # theme
          papercolor-theme
          dracula-vim
          palenight-vim
          aurora
          {
            plugin = catppuccin-nvim;
            type = "lua";
            config = ''
              vim.g.catppuccin_flavour = "frappe"; -- latte, frappe, macchiato, mocha
              require("catppuccin").setup()
              vim.api.nvim_command "colorscheme catppuccin"
            '';
          }
          {
            plugin = rose-pine;
            type = "lua";
            config = builtins.readFile (./config/nvim/plugins/rose-pine.lua);
          }
          rose-pine
        ]; # Only loaded if programs.neovim.extraConfig is set
      coc = {
        enable = true;
        pluginConfig = builtins.readFile (./config/nvim/plugins/coc.vim);
        settings = {
          "suggest.noselect" = true;
          "suggest.enablePreview" = true;
          "suggest.enablePreselect" = false;
          "suggest.disableKind" = true;
          "go.goplsArgs" = [ "-remote=auto" "-logfile" "/tmp/gopls-coc-go.log" ];
          "go.goplsPath" = "${pkgs.gopls}/bin/gopls";
          "go.goplsOptions" = {
            "local" = "github.com/erda-project/erda";
          };
          languageserver = {
            #go = {
            #   command = "gopls";
            #   rootPatterns = ["go.mod" ".git/"];
            #   "trace.server" = "verbose";
            #   filetypes = ["go"];
            #};
            nix = {
              command = "rnix-lsp";
              filetypes = [ "nix" ];
            };
            #rust = {
            #  command = "rust-analyzer";
            #  filetypes = ["nix"];
            #};
          };
        };
      };
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


