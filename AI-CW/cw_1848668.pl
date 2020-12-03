% Accomplish a given Task and return the Cost
solve_task(Task,Cost) :-
    my_agent(A), get_agent_position(A,P),
    solve_task_bfs(Task, [P:[]],[],[P|Path]), !,
    agent_do_moves(A,Path), length(Path,Cost).

% Calculate the path required to achieve a Task
solve_task_bfs(Task, [Pos:RPath|Queue],Visited,Path) :-
    achieved(Task, Pos), reverse([Pos|RPath],Path)
    ;
    findall(NewPos:[Pos|RPath], (
            map_adjacent(Pos,NewPos,empty),
            \+ member(NewPos,Visited),
            \+ member(NewPos:_,Queue)
    ),Children),
    append(Queue,Children,NewQueue),
    solve_task_bfs(Task, NewQueue,[Pos|Visited],Path).

% True if the Task is achieved with the agent at Pos
achieved(Task,Pos) :- 
    Task=find(Obj), map_adjacent(Pos,_,Obj)
    ;
    Task=go(Pos).