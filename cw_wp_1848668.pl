% True if link L appears on A's wikipedia page
actor_has_link(L,A) :- 
    actor(A), wp(A,WT), wt_link(WT,L).

% Attempt to solve by visiting each oracle in ID order
eliminate(As,A) :-
    % If there's only 1 actor/actress left it must be them
    As=[A], !
    ;
    my_agent(Agent), get_agent_energy(Agent, Energy), ailp_grid_size(Size),
    (
        % Energy threshhold of 25% max. If the agent is below this they will attempt to
        % top up first. If the agent has no energy just fail and return `unknown`.
        Energy >= ((Size * Size) / 4) / 4
        ;
        Energy > 0,
        get_agent_position(Agent, P1),
        solve_task_bfs(find(c(Station)), [_:P1:[]],[],[P1|Path]), !,
        agent_do_moves(Agent, Path), agent_topup_energy(Agent, c(Station))
    ),
    % Get the first valid (pathable and unquestioned) oracle
    get_agent_position(Agent, P),
    solve_task_bfs(find(o(Oracle)), [_:P:[]], [], [P | _]),
    \+ agent_check_oracle(Agent, o(Oracle)), !,
    solve_task(find(o(Oracle)),_),
    agent_ask_oracle(Agent,o(Oracle),link,L), 
    include(actor_has_link(L),As,ViableAs), 
    eliminate(ViableAs,A).

% Deduce the identity of the secret actor A
find_identity(A) :- 
    findall(A,actor(A),As), eliminate(As,A)
    ;
    A = unknown.