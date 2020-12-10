% Accomplish a given Task and return the energy Cost
solve_task(Task,Cost) :-
    % Check target position is "empty" if required
    (
        Task = go(Pos),
        lookup_pos(Pos, empty)
        ;
        Task = find(_)
    ),

    % Attempt to find a path, "solve_task_bfs" fails if no valid path exists
    my_agent(A), get_agent_position(A, P),
    solve_task_bfs(Task, [S:P:[]],[],[P|Path]), !,
    length(Path, PathCost), get_agent_energy(A, Energy),
    (
        % If we have enough energy, do the path
        Energy >= PathCost,
        agent_do_moves(A, Path),
        Cost is PathCost
        ;
        % If we don't, top up then perform the task (unless you're already being tasked to top up)
        Task \= find(c(_)),
        solve_task(find(c(N)), TopUpCost), agent_topup_energy(A, c(N)),
        get_agent_energy(A, NewEnergy), get_agent_position(A, NewP),
        solve_task_bfs(Task, [S:NewP:[]],[],[NewP|NewPath]), !,
        length(NewPath, NewPathCost), NewEnergy >= NewPathCost,
        agent_do_moves(A, NewPath),
        Cost is TopUpCost + NewPathCost - (NewEnergy - (Energy - TopUpCost))
    ).

% Attempt to calculate the path required to achieve a Task using a BFS with heuristic
solve_task_bfs(_, [], _, _) :-
    false.

solve_task_bfs(Task, [_:Pos:RPath|Queue],Visited,Path) :-
    achieved(Task, Pos), reverse([Pos|RPath],Path)
    ;
    findall(S:NewPos:[Pos|RPath], (
            map_adjacent(Pos,NewPos,OID),
            (OID = empty ; OID = a(_)),
            \+ member(NewPos,Visited),
            \+ member(_:NewPos:_,Queue),
            length([Pos|RPath], D),
            score_function(Task, NewPos, D, S)
    ),Children),
    append(Queue,Children,IntermediateQueue),
    sort(IntermediateQueue, NewQueue),
    solve_task_bfs(Task, NewQueue,[Pos|Visited],Path).

% True if the Task is achieved with the agent at Pos
achieved(Task,Pos) :- 
    Task=find(Obj), map_adjacent(Pos,_,Obj)
    ;
    Task=go(Pos).

% Score function for a given cell.
score_function(Task, Pos, D, S) :-
    Task=find(_), S is D
    ;
    Task=go(TargetPos), map_distance(Pos, TargetPos, H), S is D + H.