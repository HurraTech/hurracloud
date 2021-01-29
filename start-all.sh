#!/bin/bash

if ! command -v tmux &> /dev/null
then
    echo "'tmux' is not installed, please install tmux (e.g. brew install tmux)"
    exit
fi

if [ ! "$TMUX" ]; then
        tmux attach -t main || tmux new -s main
fi

echo "Enter sudo password (used for hagent only)"
sudo --validate; # pre-auth sudo for hagent command
tmux send-keys "src/hagent; sudo go run server.go" C-m; 
tmux split-window -v; 
tmux split-window -h; 
tmux split-window -h; 
tmux select-pane -t 2;
tmux resize-pane -L 18;
tmux select-pane -t 1; 
tmux split-window -h;
tmux select-pane -t 1; 
tmux select-pane -t 2; 
tmux send-keys "src/jawhar; go run cmd/jawhar/jawhar.go -S http://127.0.0.1:5060" C-m; 
tmux select-pane -t 3; 
tmux send-keys "src/samaa; docker-compose up" C-m; 
tmux select-pane -t 4; 
tmux send-keys "src/zahif; go run cmd/zahif/zahif.go" C-m;
tmux select-pane -t 5;
tmux send-keys "src/souq; go run cmd/souq/souq.go" C-m;
