% Builds initial starting "Info" for each agent [AgentID, [Moves], [RPath] [VisitedCells]]
build_agent_infos([], []).
build_agent_infos([Agent|Agents], [[Agent, Path, Path, Path]|AgentInfos]) :-
    get_agent_position(Agent, Position),
    solve_task_bfs(go(p(1,1)), [0:Position:[]],[],Path), !,
    build_agent_infos(Agents, AgentInfos).

% Finds a move for each agent
find_moves([], _, [], [], []).
find_moves([AgentInfo|As], DeadEnds, [NewAgentInfo|NewAs], NewDeadEnds, [Move|Ms]) :-
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
            PreviousMoves = [LastLastMove|_],
            (member(LastLastMove, DeadEnds) ->
                Move = LastMove, NewAgentInfo = AgentInfo
                ;
                PreviousMoves = [Move|_], NewAgentInfo = [Agent, PreviousMoves, RPath, Visited]
            )
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

% Checks if any agent is at the end. Fails if none are.
% If an agent is at the end it leaves the maze and the predicate returns early.
agent_at_end([A|As], Exit) :-
    get_agent_position(A, P),
    P = Exit -> leave_maze(A) ; agent_at_end(As, Exit).

% Builds some "Agent Infos" in form [AgentID, PathToEnd, Moves]
get_exit_infos([], _, []).
get_exit_infos([Agent|As], Exit, [[Agent, Path, [Position]]|Infos]) :-
    get_agent_position(Agent, Position),
    solve_task_bfs(go(Exit), [0:Position:[]], [], [Position|Path]), !,
    get_exit_infos(As, Exit, Infos).

% Get the move for each agent based on the passed in AgentInfos
get_exit_moves([], [], []).
get_exit_moves([[Agent, Path, [LastMove|PreviousMoves]]|As], [NewA|NewAs], [Move|Moves]) :-
    get_agent_position(Agent, Position),
    (LastMove = Position ->
        Path = [Move|NewPath],
        NewA = [Agent, NewPath, [Move,LastMove|PreviousMoves]]
        ;
        Move = LastMove,
        NewA = [Agent, Path, [LastMove|PreviousMoves]]
    ),
    get_exit_moves(As, NewAs, Moves).

% Recursive function that paths each agent to the end of the maze and exits.
agents_leave_maze([], [], _).
agents_leave_maze(As, Infos, Exit) :-
    get_exit_moves(Infos, NewInfos, Moves),
    agents_do_moves(As, Moves),
    agents_leave_maze(As, NewInfos, Exit).

% Main predicate to implement for Part 3
solve_maze :-
    my_agents(As),
    ailp_grid_size(N),
    build_agent_infos(As, AgentInfos),
    solve_maze_multi_agent(As, [], AgentInfos, p(N,N)), !.

solve_maze_multi_agent(As, DeadEnds, AgentInfos, Exit) :-
    find_moves(AgentInfos, DeadEnds, NewAgentInfos, ChildDeadEnds, Moves),
    append(DeadEnds, ChildDeadEnds, NewDeadEnds),
    agents_do_moves(As, Moves),
    (agent_at_end(As, Exit) ->
        my_agents(NewAs),
        get_exit_infos(NewAs, Exit, Infos),
        agents_leave_maze(NewAs, Infos, Exit), !
        ;
        solve_maze_multi_agent(As, NewDeadEnds, NewAgentInfos, Exit)
    ).
