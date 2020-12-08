split_list([H|T], H, T).

build_Vs_and_Ps([], []).
build_Vs_and_Ps([A|As], [[P]|Ps]) :-
    get_agent_position(A, P),
    build_Vs_and_Ps(As, Ps).


find_moves([], [], [], [], [], []).

find_moves([A|As], [_|Vs], [[P|_]|Ps], [_|NewVs], [_|NewPs], [_|Ms]) :-
    ailp_grid_size(N), P = p(N,N), leave_maze(A), !,
    find_moves(As, Vs, Ps, NewVs, NewPs, Ms).

find_moves([A|As], [V|Vs], [[P|RPath]|Ps], [[M|V]|NewVs], [[M,P|RPath]|NewPs], [M|Ms]) :-
    findall(X, (
        agent_adjacent(A, X, OID),
        OID \= t(_),
        \+ member(X, V)
    ), PosMs),
    random_member(M, PosMs),
    find_moves(As, Vs, Ps, NewVs, NewPs, Ms).

find_moves([_|As], [V|Vs], [[_|RPath]|Ps], [V|NewVs], [RPath|NewPs], [M|Ms]) :-
    split_list(RPath, M, _),
    find_moves(As, Vs, Ps, NewVs, NewPs, Ms).

solve_maze :-
    my_agents(As),
    ailp_grid_size(N),
    build_Vs_and_Ps(As, VsAndPs),
    solve_maze_multi_agent(As, VsAndPs, VsAndPs, p(N,N)).

solve_maze_multi_agent(As, Vs, Ps, Exit) :-
    find_moves(As, Vs, Ps, NewVs, NewPs, Moves),
    agents_do_moves(As, Moves),
    % Check if any are at the end!!!"!"£!£$%!$
    solve_maze_multi_agent(As, NewVs, NewPs, Exit).
