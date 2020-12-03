% Test if the objective has been completed at a given position
complete(P) :- 
    map_adjacent(P, _, o(_)).

% Perform a BFS to find the nearest oracle
search_bf :-
    my_agent(A), get_agent_position(A,P),
    search_bf([P:[]],[],[P|Path]), !,
    agent_do_moves(A,Path).

search_bf([Pos:RPath|Queue],Visited,Path) :-
    complete(Pos), reverse([Pos|RPath],Path)
    ;
    findall(NewPos:[Pos|RPath], (
            map_adjacent(Pos,NewPos,empty),
            \+ member(NewPos,Visited),
            \+ member(NewPos:_,Queue)
    ),Children),
    append(Queue,Children,NewQueue),
    search_bf(NewQueue,[Pos|Visited],Path).
