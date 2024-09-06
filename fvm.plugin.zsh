if zstyle -T ':omz:plugins:fvm' auto-shell; then
  _useFlutterVersion() {
    if [ -f "$PWD/.fvmrc" ] && [ -z "${VSCODE_INJECTION}" ]; then
      flutter_version=$(jq '.flutter' .fvmrc -r)
      flutter_path=$HOME/fvm/versions/$flutter_version/bin

      if fvm use; then
        if [[ $PATH != *$flutter_path* ]]; then export PATH=$flutter_path:$PATH; fi
      fi
    fi
  }
  
  autoload -U add-zsh-hook
  add-zsh-hook chpwd _useFlutterVersion
fi
