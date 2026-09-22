{pkgs, ...}: let
  # tmux configuration
  config = pkgs.writeText "tmux.conf" ''
    # egeres kezeles: panelvalasztas, keret-huzas atmeretezeshez, gorgetes
    set -g mouse on

    # ertelmes alapok
    set -g base-index 1
    setw -g pane-base-index 1
    set -g renumber-windows on
    set -g history-limit 10000
    set -sg escape-time 10
    set -g default-terminal "tmux-256color"

    # opcionalis prefix-alapu panelnavigacio (az eger mellett)
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R
  '';

  # becsomagolt tmux, ami inditaskor felepiti a 2x2 elrendezest (also sor kisebb)
  package = pkgs.writeShellApplication {
    name = "tmux-4pane";
    runtimeInputs = [pkgs.tmux];
    text = ''
      CONF="${config}"
      SESSION="main"

      # ha mar letezik a session, csatlakozzunk ujra-osztas nelkul
      if tmux -f "$CONF" has-session -t "$SESSION" 2>/dev/null; then
        exec tmux -f "$CONF" attach -t "$SESSION"
      fi

      # 2x2 elrendezes felepitese pane_id alapon (index-fuggetlen)
      first=$(tmux -f "$CONF" new-session -d -s "$SESSION" -P -F '#{pane_id}')
      bottom=$(tmux split-window -v -l 10% -t "$first" -P -F '#{pane_id}')  # also sor 10% -> kisebb
      tmux split-window -h -l 50% -t "$first"     # felso sor ket felre
      tmux split-window -h -l 50% -t "$bottom"    # also sor ket felre
      tmux select-pane -t "$first"

      exec tmux -f "$CONF" attach -t "$SESSION"
    '';
  };
in {
  inherit config package;
}
