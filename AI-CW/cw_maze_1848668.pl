build_agent_infos([], []).
build_agent_infos([A|As], [[A, [P], [P], Path]|AgentInfos]) :-
    get_agent_position(A, P),
    solve_task_bfs(go(P), [0:p(1,1):[]],[],Path), !,
    build_agent_infos(As, AgentInfos).

find_moves([], _, [], [], []).
find_moves([AgentInfo|As], DeadEnds, [NewAgentInfo|NewAs], NewDeadEnds, [Move|Ms]) :-
    % Branches:
    % - Fresh
    %   - Deadend, Blocked by agent
    % - Backtracking
    AgentInfo = [Agent, [LastMove|PreviousMoves], [Position|RPath], Visited],
    get_agent_position(Agent, TruePosition),
    (Position = TruePosition ->
        % Doing a "new" move
        findall(P, (
            agent_adjacent(Agent, P, OID),
            (OID = empty ; OID = a(_)),
            \+ member(P, Visited),
            \+ member(P, DeadEnds)
        ), PossibleMoves),
        (
            % There is a move that the agent hasn't previously visited and isn't marked as a deadend
            random_member(Move, PossibleMoves),
            NewAgentInfo = [Agent, [Move, LastMove|PreviousMoves], [Move, Position|RPath], [Move|Visited]],
            DeadEnd = []
            ;
            % No unvisited, non-deadend moves. Lets start backtracking and mark this as a deadend
            RPath = [Move|_],
            NewAgentInfo = [Agent, [Move, LastMove|PreviousMoves], RPath, Visited],
            DeadEnd = [Position]
            ;
            % This is a a backup that's here so it doesn't fail if there are no moves that can be made when RPath is []
            Move = LastMove, NewAgentInfo = AgentInfo, DeadEnd = []
        )
        ;
        % Retrying previous move
        % If the previous move is now a deadend, update agent info and don't try it again
        (member(LastMove, DeadEnds) ->
            PreviousMoves = [Move|_], NewAgentInfo = [Agent, PreviousMoves, RPath, Visited]
            ;
            Move = LastMove, NewAgentInfo = AgentInfo
        ),
        DeadEnd = []
    ),
    find_moves(As, DeadEnds, NewAs, ChildDeadEnds, Ms),
    (
        DeadEnd = [DE], NewDeadEnds = [DE|ChildDeadEnds]
        ;
        NewDeadEnds = ChildDeadEnds
    ).

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
    solve_maze_multi_agent(As, [], AgentInfos, p(N,N)), !.

solve_maze_multi_agent(As, DeadEnds, AgentInfos, Exit) :-
    find_moves(AgentInfos, DeadEnds, NewAgentInfos, ChildDeadEnds, Moves),
    append(DeadEnds, ChildDeadEnds, NewDeadEnds),
    writeln(Moves),
    % writeln(NewDeadEnds),
    agents_do_moves(As, Moves),
    (agent_at_end(As, Exit) ->
        agents_leave_maze(As, Exit), !
        ;
        solve_maze_multi_agent(As, NewDeadEnds, NewAgentInfos, Exit)
    ).
