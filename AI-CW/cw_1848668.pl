% Accomplish a given Task and return the Cost
solve_task(Task,Cost) :-
    my_agent(A), get_agent_position(A,P),
    score_function(Task, P, 0, S),
    solve_task_bfs(Task, [S:P:[]],[],[P|Path]), !,
    length(Path,PotentialCost), get_agent_energy(A, Energy),
    Energy >= PotentialCost,
    agent_do_moves(A,Path), Cost is PotentialCost.

% Calculate the path required to achieve a Task
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

score_function(Task, Pos, D, S) :-
    Task=find(_), S is D
    ;
    Task=go(TargetPos), map_distance(Pos, TargetPos, H), S is D + H.