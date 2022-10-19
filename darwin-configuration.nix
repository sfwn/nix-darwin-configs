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
      fzf
      ripgrep
      silver-searcher
      findutils
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
      rnix-lsp
      htop
      fortune
      gitui
      git
      starship
      docker
      bat
      tailscale
      pkg-config
      libgit2_1_3_0
      colima
      pstree
      rust-analyzer
      nodejs-16_x
    ];

    programs.emacs = {
      enable = true;
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
        enableSyntaxHighlighting = true;
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
        in
        [
          #context-vim
          editorconfig-vim
          #gruvbox-community
          vim-airline
          #vim-elixir
          vim-nix

          vim-startify
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

          # go
          #vim-go # before coc-go
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

          # coc
          coc-go
          coc-rust-analyzer
          coc-snippets
          coc-json
          coc-git
          coc-highlight
          vim-fugitive

          {
            plugin = lsp_signature-nvim;
            type = "lua";
            config = builtins.readFile (./config/nvim/plugins/lsp_signature-nvim.lua);
          }

          # copilot
          copilot-vim

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
        settings = {
          "suggest.noselect" = true;
          "suggest.enablePreview" = true;
          "suggest.enablePreselect" = false;
          "suggest.disableKind" = true;
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


