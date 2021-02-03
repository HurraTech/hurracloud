#!/bin/bash

if ! command -v tmux &> /dev/null
then
    echo "'tmux' is not installed, please install tmux (e.g. brew install tmux)"
    exit
fi

if [ ! "$TMUX" ]; then
        echo "You are not in a tmux session; please start session by running 'tmux' first";
        exit -1;
fi

echo "Enter sudo password (used for hagent only)"
sudo --validate; # pre-auth sudo for hagent command
tmux send-keys "cd src/hagent; sudo go run server.go" C-m; 
tmux split-window -v; 
tmux split-window -h; 
tmux split-window -h; 
tmux select-pane -t 2;
tmux resize-pane -L 18;
tmux select-pane -t 1; 
tmux split-window -h;
tmux select-pane -t 1; 
tmux select-pane -t 2; 
tmux send-keys "cd src/jawhar; air -c .air.toml" C-m;
tmux select-pane -t 3; 
tmux send-keys "cd src/samaa; docker-compose up" C-m; 
tmux select-pane -t 4; 
tmux send-keys "cd src/zahif; air -c .air.toml" C-m;
tmux select-pane -t 5;
tmux send-keys "cd src/souq; air -c .air.toml" C-m;
