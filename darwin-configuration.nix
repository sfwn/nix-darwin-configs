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
      colima
      pstree
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
      extraConfig = ''
        set mouse=a
        "set relativenumber
        set number
        set showmatch
        set termguicolors
        let g:ctrlp_map = '<c-p>'
        set showtabline=2
        colorscheme PaperColor
        set background=light

        let mapleader = ";"

        """ fzf
        nnoremap <Leader>o :FZF<CR>
        nnoremap <Leader>f :Rg<CR>

        """ coc
        " Some servers have issues with backup files, see #649.
        set nobackup
        set nowritebackup
        
        " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
        " delays and poor user experience.
        set updatetime=300
        
        " Always show the signcolumn, otherwise it would shift the text each time
        " diagnostics appear/become resolved.
        set signcolumn=yes

        " Use tab for trigger completion with characters ahead and navigate.
        " NOTE: There's always complete item selected by default, you may want to enable
        " no select by `"suggest.noselect": true` in your configuration file.
        " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
        " other plugin before putting this into your config.
        inoremap <silent><expr> <TAB>
              \ coc#pum#visible() ? coc#pum#next(1) :
              \ CheckBackspace() ? "\<Tab>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
        
        " Make <CR> to accept selected completion item or notify coc.nvim to format
        " <C-g>u breaks current undo, please make your own choice.
        inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
        
        function! CheckBackspace() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        if has('nvim')
          inoremap <silent><expr> <c-space> coc#refresh()
        else
          inoremap <silent><expr> <c-@> coc#refresh()
        endif

        " Use `[g` and `]g` to navigate diagnostics
        " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
        nmap <silent> [g <Plug>(coc-diagnostic-prev)
        nmap <silent> ]g <Plug>(coc-diagnostic-next)

        " GoTo code navigation.
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> <c-]> <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        " Use K to show documentation in preview window.
        nnoremap <silent> K :call ShowDocumentation()<CR>
        
        function! ShowDocumentation()
          if CocAction('hasProvider', 'hover')
            call CocActionAsync('doHover')
          else
            call feedkeys('K', 'in')
          endif
        endfunction

        " Highlight the symbol and its references when holding the cursor.
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Symbol renaming.
        nmap <leader>rn <Plug>(coc-rename)

        " Formatting selected code.
        xmap <leader>F  :Format
        nmap <leader>F  :Format

        augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Applying codeAction to the selected region.
        " Example: `<leader>aap` for current paragraph
        xmap <leader>a  <Plug>(coc-codeaction-selected)
        nmap <leader>a  <Plug>(coc-codeaction-selected)
        
        " Remap keys for applying codeAction to the current buffer.
        nmap <leader>ac  <Plug>(coc-codeaction)
        " Apply AutoFix to problem on the current line.
        nmap <leader>qf  <Plug>(coc-fix-current)
        
        " Run the Code Lens action on the current line.
        nmap <leader>cl  <Plug>(coc-codelens-action)

        " Map function and class text objects
        " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
        xmap if <Plug>(coc-funcobj-i)
        omap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap af <Plug>(coc-funcobj-a)
        xmap ic <Plug>(coc-classobj-i)
        omap ic <Plug>(coc-classobj-i)
        xmap ac <Plug>(coc-classobj-a)
        omap ac <Plug>(coc-classobj-a)

        " Remap <C-f> and <C-b> for scroll float windows/popups.
        if has('nvim-0.4.0') || has('patch-8.2.0750')
          nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
          nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
          inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
          inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
          vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
          vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        endif
        
        " Use CTRL-S for selections ranges.
        " Requires 'textDocument/selectionRange' support of language server.
        nmap <silent> <C-s> <Plug>(coc-range-select)
        xmap <silent> <C-s> <Plug>(coc-range-select)

        " Add `:Format` command to format current buffer.
        command! -nargs=0 Format :call CocActionAsync('format')
        
        " Add `:Fold` command to fold current buffer.
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)
        
        " Add `:OR` command for organize imports of the current buffer.
        command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
        
        " Add (Neo)Vim's native statusline support.
        " NOTE: Please see `:h coc-status` for integrations with external plugins that
        " provide custom statusline: lightline.vim, vim-airline.
        "set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\'\')}

        " Mappings for CoCList
        " Show all diagnostics.
        nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
        " Manage extensions.
        nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
        " Show commands.
        nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
        " Find symbol of current document.
        nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
        " Search workspace symbols.
        nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
        " Do default action for next item.
        nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
        " Do default action for previous item.
        nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
        " Resume latest coc list.
        nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
      '';
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
        in [
          #context-vim
          editorconfig-vim
          #gruvbox-community
          #vim-airline
          #vim-elixir
          vim-nix

          vim-startify
          #nvim-tree-lua
          #nvim-web-devicons
          #gitsigns-nvim
          nerdtree
          fzf-vim

          # theme
          papercolor-theme
        ]; # Only loaded if programs.neovim.extraConfig is set
      coc = {
        enable = true;
        settings = {
          "suggest.noselect" = true;
          "suggest.enablePreview" = true;
          "suggest.enablePreselect" = false;
          "suggest.disableKind" = true;
          languageserver = {
            go = {
               command = "gopls";
               rootPatterns = ["go.mod" ".git/"];
               "trace.server" = "verbose";
               filetypes = ["go"];
            };
            nix = {
              command = "rnix-lsp";
              filetypes = ["nix"];
            };
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


  };
}


