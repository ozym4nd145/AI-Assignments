# Block World Planner

### To Run
In prolog interpreter, first import the definition file:
`['planner.pl'].`
Then run the solve method by using the template:
`solve([<GOAL STATE>],<START_STATE>,Answer).`

Example:
solve([[on("Z","X"),on("Y","W"),clr("Y"),clr("Z"),ontable("X"),ontable("W")]],[on("Y","X"),on("W","Z"),clr("Y"),clr("W"),ontable("X"),ontable("Z")],X).


