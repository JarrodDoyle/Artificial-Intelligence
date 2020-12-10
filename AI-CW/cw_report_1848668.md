# My Implementation
## Part 1
Part 1 of the coursework required the ability to perform two types of tasks in the form of `go(+Pos)` and `find(+Obj)`. In both cases a Breadth First Search (BFS) was used, with `go(+Pos)` tasks using an additional heuristic to turn them into A* searches. Calls to `map_adjacent(+Pos,-Adj,-Obj)` take the bulk of execution time and are made to find potential moves as well as to check if a `find(+Obj)` task has been achieved. Indirect cases where refueling is required are handled by first finding a path to an oracle, then determining whether the agent has enough fuel, pathfinding to a charging station first if not.
My BFS implementation generalises well, with different tasks affecting only what the `scoring` and `achieved` predicates return. This means any additional tasks would only need to update those predicates with the core BFS predicate remaining unchanged. In terms of improvements, precalculating and storing locations of grid objects could allow `find(+Obj)` tasks to be converted to a series of `go(+Pos)` tasks and potentially decrease execution time. However this would likely be slower on certain grid configurations and would not work at all if grid objects had the ability to move.

## Part 2
In part 2 I chose to use a simple greedy approach to pathfinding between oracles. Another option would be to precompute a graph representing the paths between oracles and approximate a solution to the Traveling Salesman Problem. However I felt that the benefits in terms of reduced moves and the possibility of reaching more nodes wasn't worth it due to the likely increased execution time and my greedy approach successfully visiting all oracles regularly. The inefficiencies of my implementation become more apparent at a larger grid size, where it is likely to put the agent in a position where it is far from the next oracle.
My recharging solution is also simple. If an agents energy is less than 25% of it's maximum it will recharge before attempting to path to an oracle. This threshold was chosen after numerous test runs as it seemed to strike a good balance between charging often enough that it rarely failed to reach an oracle and charging too often when not required to. There are multiple improvements that can be made here, one simple one would be to check that an agent will have enough energy to reach a charging station after asking at an oracle before pathing to said oracle. This would increase execution time as two path computations would be required, but it would mean the agent wouldn't put itself in a position where it can't recharge after asking at an oracle.

## Part 3
- Random intersections
- Marking deadends


# Extensions
