build_agent_infos([], []).
build_agent_infos([A|As], [[A, [P], [P], [P]]|AgentInfos]) :-
    get_agent_position(A, P),
    build_agent_infos(As, AgentInfos).

find_moves([], [], []).
find_moves([AgentInfo|As], [NewAgentInfo|NewAs], [Move|Ms]) :-
    AgentInfo = [Agent, [LastMove|PreviousMoves], [Position|RPath], Visited],
    get_agent_position(Agent, TruePosition),
    (Position = TruePosition ->
        findall(P, (
            agent_adjacent(Agent, P, OID),
            OID = empty,
            \+ member(P, Visited)
        ), PossibleMoves),
        (
            random_member(Move, PossibleMoves),
            NewAgentInfo = [Agent, [Move, LastMove|PreviousMoves], [Move, Position|RPath], [Move|Visited]]
            ;
            RPath = [Move|_],
            NewAgentInfo = [Agent, [Move, LastMove|PreviousMoves], RPath, Visited]
            ;
            Move = LastMove,
            NewAgentInfo = AgentInfo
        )
        ;
        Move = LastMove,
        NewAgentInfo = AgentInfo
    ),
    find_moves(As, NewAs, Ms).

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
    find_moves(AgentInfos, NewAgentInfos, Moves),
    writeln(Moves),
    agents_do_moves(As, Moves),
    (agent_at_end(As, Exit) ->
        agents_leave_maze(As, Exit)
        ;
        solve_maze_multi_agent(As, NewAgentInfos, Exit)
    ).
