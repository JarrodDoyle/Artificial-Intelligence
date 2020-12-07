% True if link L appears on A's wikipedia page
actor_has_link(L,A) :- 
    actor(A), wp(A,WT), wt_link(WT,L).

% Attempt to solve by visiting each oracle in ID order
eliminate(As,A) :-
    As=[A], !
    ;
    my_agent(N), get_agent_position(N, P),
    findall(K, (
        solve_task_bfs(find(o(K)), [_:P:[]], [], [P | Path]),
        \+ agent_check_oracle(N, o(K)), !
        ), [K | _]),
    solve_task(find(o(K)),_),
    agent_ask_oracle(N,o(K),link,L), 
    include(actor_has_link(L),As,ViableAs), 
    eliminate(ViableAs,A).

% Deduce the identity of the secret actor A
find_identity(A) :- 
    findall(A,actor(A),As), eliminate(As,A)
    ;
    A = unknown.