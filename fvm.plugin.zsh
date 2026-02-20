if zstyle -T ':omz:plugins:fvm' auto-shell; then
  # Ensure required dependencies are available
  if ! (( $+commands[fvm] )); then
    echo "[zsh-fvm] fvm not found in PATH. Please install FVM: https://fvm.app" >&2
    return
  fi

  if ! (( $+commands[jq] )); then
    echo "[zsh-fvm] jq not found in PATH. Please install jq: https://jqlang.github.io/jq" >&2
    return
  fi

  # Tracks the flutter bin path currently injected into $PATH so it can be removed later
  _FVM_ACTIVE_FLUTTER_PATH=""

  _fvm_deactivate() {
    if [[ -n "$_FVM_ACTIVE_FLUTTER_PATH" ]]; then
      PATH="${PATH//$_FVM_ACTIVE_FLUTTER_PATH:/}"
      PATH="${PATH//:$_FVM_ACTIVE_FLUTTER_PATH/}"
      PATH="${PATH//$_FVM_ACTIVE_FLUTTER_PATH/}"
      export PATH
      _FVM_ACTIVE_FLUTTER_PATH=""
    fi
  }

  _useFlutterVersion() {
    if [ -f "$PWD/.fvmrc" ] && [ -z "${VSCODE_INJECTION}" ]; then
      local flutter_version
      flutter_version=$(jq -r '.flutter' "$PWD/.fvmrc" 2>/dev/null)

      if [[ -z "$flutter_version" || "$flutter_version" == "null" ]]; then
        echo "[zsh-fvm] Could not read flutter version from $PWD/.fvmrc" >&2
        return 1
      fi

      local fvm_home="${FVM_HOME:-$HOME/fvm}"
      local flutter_path="$fvm_home/versions/$flutter_version/bin"

      if [[ ! -d "$flutter_path" ]]; then
        echo "[zsh-fvm] Flutter version '$flutter_version' not found at $flutter_path. Run: fvm install $flutter_version" >&2
        return 1
      fi

      # Only update PATH if switching to a different version
      if [[ "$_FVM_ACTIVE_FLUTTER_PATH" != "$flutter_path" ]]; then
        _fvm_deactivate
        export PATH="$flutter_path:$PATH"
        _FVM_ACTIVE_FLUTTER_PATH="$flutter_path"
      fi
    else
      # Not in an fvm-managed project — remove any previously activated version
      _fvm_deactivate
    fi
  }

  autoload -U add-zsh-hook
  add-zsh-hook chpwd _useFlutterVersion

  # Activate on shell startup in case we're already inside a project directory
  _useFlutterVersion
fi
