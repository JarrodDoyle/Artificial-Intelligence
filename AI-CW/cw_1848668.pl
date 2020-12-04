% Accomplish a given Task and return the energy Cost
solve_task(Task,Cost) :-
    (
        % Check validity of target position
        Task = go(Pos),
        lookup_pos(Pos, empty)
        ;
        Task = find(_)
    ),
    my_agent(A), get_agent_position(A,P),
    get_agent_energy(A, Energy),
    score_function(Task, P, 0, S),
    (
        % Assume a perfect path with manhattan distance. If the agent doesn' have enough
        % energy for that then it definitely needs to attempt to top up.
        Energy >= S,
        solve_task_bfs(Task, [S:P:[]],[],[P|Path]), !,
        length(Path,Cost),
        % Do we have enough energy to perform this path?
        % If not we need to attempt to top up!
        Energy >= Cost,
        agent_do_moves(A,Path)
        ;
        % If we're here we need to try and top up, unless our current task is already
        % to try and top up. In that case the agent is doomed to run out of energy and
        % should just not move.
        Task \= find(c(N)),
        solve_task(find(c(N)), Cost1),
        Cost1 > 0,
        agent_topup_energy(A, c(N)),
        solve_task(Task, Cost2),
        Cost is Cost1 + Cost2
    ).

% Calculate the path required to achieve a Task
solve_task_bfs(_, [], _, _) :-
    % Base case to fail if no path can be found e.g. target is in an unconnected region
    % TODO: Currently doesn't seem to work :)))
    !, false.

solve_task_bfs(Task, [_:Pos:RPath|Queue],Visited,Path) :-
    achieved(Task, Pos), reverse([Pos|RPath],Path)
    ;
    findall(S:NewPos:[Pos|RPath], (
            map_adjacent(Pos,NewPos,empty),
            \+ member(NewPos,Visited),
            \+ member(NewPos:_,Queue),
            length([Pos|RPath], D),
            score_function(Task, NewPos, D, S)
    ),Children),
    append(Queue,Children,IntermediateQueue),
    sort(IntermediateQueue, NewQueue),
    solve_task_bfs(Task, NewQueue,[Pos|Visited],Path).

% True if the Task is achieved with the agent at Pos
achieved(Task,Pos) :- 
    % TODO: map_adjacent calls can be reduced by calling only if the length of the path is >= manhattan distance
    Task=find(Obj), map_adjacent(Pos,_,Obj)
    ;
    Task=go(Pos).

% Score function for a given cell.
score_function(Task, Pos, D, S) :-
    Task=find(_), S is D
    ;
    Task=go(TargetPos), map_distance(Pos, TargetPos, H), S is D + H.