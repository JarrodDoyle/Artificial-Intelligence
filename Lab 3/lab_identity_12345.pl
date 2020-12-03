% eliminate(+As, +Ls, -A)
eliminate([], Ls, A) :-
  false.

eliminate([H | As], Ls, A) :-
  (find_links_by_actor(H, Ls2),
  Ls = Ls2,
  A is H,
  !) ; eliminate(As, Ls, A).

% This is the main predicate, and should be true only when A is your identity
% find_identity(-A)
find_identity(A) :-
  findall(A, actor(A), As),
  findall(L, agent_ask_oracle(oscar, o(1), link, L), Ls).
  eliminate(As, Ls, A).

% This is a helper predicate and should find all the links for a particular actor
% find_links_by_actor(+A,-L)
find_links_by_actor(A,Ls) :-
  wp(A, T),
  findall(L, wt_link(T, L), Ls).
  