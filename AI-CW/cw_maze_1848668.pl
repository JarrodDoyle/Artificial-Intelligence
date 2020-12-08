split_list([H|T], H, T).

build_Vs_and_Ps([], []).
build_Vs_and_Ps([A|As], [[P]|Ps]) :-
    get_agent_position(A, P),
    build_Vs_and_Ps(As, Ps).


find_moves([], [], [], [], []).

find_moves([A|As], [V|Vs], [[P|RPath]|Ps], [[M|V]|NewVs], [[M,P|RPath]|NewPs]) :-
    findall(X, (
        agent_adjacent(A, X, OID),
        OID = empty,
        \+ member(X, V)
    ), PosMs),
    random_member(M, PosMs),
    agent_do_moves(A, [M]),
    find_moves(As, Vs, Ps, NewVs, NewPs).

find_moves([A|As], [V|Vs], [[_|RPath]|Ps], [V|NewVs], [RPath|NewPs]) :-
    split_list(RPath, M, _),
    lookup_pos(M, empty),
    agent_do_moves(A, [M]),
    find_moves(As, Vs, Ps, NewVs, NewPs).

find_moves([_|As], [V|Vs], [P|Ps], [V|NewVs], [P|NewPs]) :-
    find_moves(As, Vs, Ps, NewVs, NewPs).

agent_at_end([], _) :-
    false.

agent_at_end([A|As], Exit) :-
    get_agent_position(A, P),
    P = Exit -> true ; agent_at_end(As, Exit).

agents_leave_maze([], _).
agents_leave_maze([A|As], Exit) :-
    get_agent_position(A, P),
    (P = Exit ->
        say("At end!", A),
        true
        ;
        say("Pathing to end!", A),
        solve_task_bfs(go(Exit), [0:P:[]],[],[P|Path]), !,
        agent_do_moves(A, Path)
    ),
    leave_maze(A),
    agents_leave_maze(As, Exit).

solve_maze :-
    my_agents(As),
    ailp_grid_size(N),
    build_Vs_and_Ps(As, VsAndPs),
    solve_maze_multi_agent(As, VsAndPs, VsAndPs, p(N,N)).

solve_maze_multi_agent(As, Vs, Ps, Exit) :-
    find_moves(As, Vs, Ps, NewVs, NewPs),
    (agent_at_end(As, Exit) ->
        agents_leave_maze(As, Exit)
        ;
        solve_maze_multi_agent(As, NewVs, NewPs, Exit)
    ).
