% True if A is a possible movement direction
m(north).
m(east).
m(south).
m(west).

% True if p(X,Y) is on the board
on_board(p(X,Y)) :- 
    ailp_grid_size(N),
    between(1, N, X),
    between(1, N, Y).

% True if p(X1,Y1) is one step in direction M from p(X,Y) (no bounds check)
pos_step(p(X,Y), M, p(X1,Y1)) :-
    (M = north, X1 is X,     Y1 is Y - 1);
    (M = east,  X1 is X + 1, Y1 is Y    );
    (M = south, X1 is X,     Y1 is Y + 1);
    (M = west,  X1 is X - 1, Y1 is Y    ).

% True if NPos is one step in direction M from Pos (with bounds check)
new_pos(Pos,M,NPos) :-
    m(M),
    on_board(Pos),
    pos_step(Pos, M, NPos),
    on_board(NPos).

% True if a L has the same length as the number of squares on the board
complete(L) :-
    ailp_grid_size(N),
    N2 is N * N,
    length(L, N2).

% Perform a sequence of moves creating a spiral pattern, return the moves as L
turn(south, east).
turn(east, north).
turn(north, west).
turn(west, south).

spiral(Ps, L, _) :-
    complete(Ps),
    !,
    reverse(Ps, L).

spiral([P | Ps], L, D) :-
    ((E = D, new_pos(P, E, Q), \+ member(Q, [P | Ps]));
    (turn(D, E), new_pos(P, E, Q))),
    spiral([Q, P | Ps], L, E).

spiral(L) :-
    my_agent(A),
    get_agent_position(A, P),
    new_pos(P, D, Q),
    spiral([Q, P], L, D).
