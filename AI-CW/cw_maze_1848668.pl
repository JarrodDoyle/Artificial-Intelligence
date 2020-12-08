solve_maze :-
    my_agents([A]),
    get_agent_position(A, P),
    solve_maze_single_agent(A, [P], [P]).

solve_maze_single_agent(A, Visited, [P|RPath]) :-
    ailp_grid_size(N), P = p(N,N), leave_maze(A), !
    ;
    findall(NewP, (
        agent_adjacent(A, NewP, OID),
        OID \= t(_),
        \+ member(NewP, Visited)
    ), Ms),
    (
        random_member(M, Ms),
        agents_do_moves([A], [M]),
        solve_maze_single_agent(A, [M|Visited], [M,P|RPath])
        ;
        split_list(RPath, H, _),
        agents_do_moves([A], [H]),
        solve_maze_single_agent(A, Visited, RPath)
    ).

split_list([H|T], H, T).