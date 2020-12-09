build_agent_infos([], []).
build_agent_infos([A|As], [[A, [P], [P]]|AgentInfos]) :-
    get_agent_position(A, P),
    build_agent_infos(As, AgentInfos).

find_moves([], []).
find_moves([AgentInfo|As], [NewAgentInfo|NewAs]) :-
    AgentInfo = [Agent, [Position|RPath], Visited],
    findall(P, (
        agent_adjacent(Agent, P, OID),
        OID = empty,
        \+ member(P, Visited)
    ), PossibleMoves),
    (
        random_member(Move, PossibleMoves),
        agent_do_moves(Agent, [Move]),
        NewAgentInfo = [Agent, [Move, Position|RPath], [Move|Visited]]
        ;
        RPath = [Move|_],
        lookup_pos(Move, empty),
        agent_do_moves(Agent, [Move]),
        NewAgentInfo = [Agent, RPath, Visited]
        ;
        NewAgentInfo = [Agent, [Position|RPath], Visited]
    ),
    find_moves(As, NewAs).

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
    build_agent_infos(As, AgentInfos),
    solve_maze_multi_agent(As, AgentInfos, p(N,N)).

solve_maze_multi_agent(As, AgentInfos, Exit) :-
    find_moves(AgentInfos, NewAgentInfos),
    (agent_at_end(As, Exit) ->
        agents_leave_maze(As, Exit)
        ;
        solve_maze_multi_agent(As, NewAgentInfos, Exit)
    ).
