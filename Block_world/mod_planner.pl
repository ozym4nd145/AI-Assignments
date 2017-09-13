%% RULES
% UNSTACK(A,B)
% --	pick up clear block A from block B;
% STACK(A,B)
% --	place block A using the arm onto clear block B;
% PICKUP(A)
% --	lift clear block A with the empty arm;
% PUTDOWN(A)
% --	place the held block A onto a free space on the table.
%%

%TODO:
% is_rule \///
% append \///
% exists \///
% is_sat \///
% rem_prop \///
% add_postcond \///
% in_post \///
% add_precond \///
% solve \///

%Defining Rules
is_rule(mvTtbl(_,_)).
is_rule(mvFtbl(_,_)).
is_rule(mvFT(_,_,_)).

% Defining Satisfiability
exists(_,[]) :- false.
exists(A,[A|_]) :- true.
exists(A,[_|O]) :- exists(A,O).

is_sat([],_).
is_sat([P|Other],State):- exists(P,State),is_sat(Other,State).

% Append Operation
append([],L,L).
append([X|Y],R,[[X]|O]) :- append(Y,R,O).


% In post condition

%% Move to table
in_post(ontable(X),mvTtbl(X,_)).
in_post(clr(Y),mvTtbl(_,Y)).
in_post(clr(X),mvTtbl(X,_)).

%% Move from table
in_post(on(X,Y),mvFtbl(X,Y)).
in_post(clr(X),mvFtbl(X,_)).

%% Move from * to *
in_post(on(X,Y),mvFT(X,_,Y)).
in_post(clr(Z),mvFT(_,Z,_)).
in_post(clr(X),mvFT(X,_,_)).

% Add_precond
add_precond(Lst,mvFT(X,Z,Y),[[on(X,Z)],[clr(X)],[clr(Y)],[on(X,Z),clr(X),clr(Y)],[mvFT(X,Z,Y)]|Lst]).
add_precond(Lst,mvTtbl(X,Y),[[on(X,Y)],[clr(X)],[on(X,Y),clr(X)],[mvTtbl(X,Y)]|Lst]).
add_precond(Lst,mvFtbl(X,Y),[[ontable(X)],[clr(Y)],[clr(X)],[ontable(X),clr(Y),clr(X)],[mvFtbl(X,Y)]|Lst]).

% Add_postcond
add_postcond(Lst,mvFT(X,Z,Y),[clr(X),clr(Z),on(X,Y)|Lst]).
add_postcond(Lst,mvTtbl(X,Y),[ontable(X),clr(Y),clr(X)|Lst]).
add_postcond(Lst,mvFtbl(X,Y),[clr(X),on(X,Y)|Lst]).

% Remove proposition
rem_prop(_,[],[]).
rem_prop(mvFT(X,Z,Y),[on(X,Z)|Other],State) :- rem_prop(mvFT(X,Y,Z),Other,State).
rem_prop(mvFT(X,Z,Y),[clr(X)|Other],State) :- rem_prop(mvFT(X,Y,Z),Other,State).
rem_prop(mvFT(X,Z,Y),[clr(Y)|Other],State) :- rem_prop(mvFT(X,Y,Z),Other,State).

rem_prop(mvTtbl(X,Y),[on(X,Y)|Other],State) :- rem_prop(mvTtbl(X,Y),Other,State).
rem_prop(mvTtbl(X,Y),[clr(X)|Other],State) :- rem_prop(mvTtbl(X,Y),Other,State).

rem_prop(mvFtbl(X,Y),[ontable(X)|Other],State) :- rem_prop(mvFtbl(X,Y),Other,State).
rem_prop(mvFtbl(X,Y),[clr(X)|Other],State) :- rem_prop(mvFtbl(X,Y),Other,State).
rem_prop(mvFtbl(X,Y),[clr(Y)|Other],State) :- rem_prop(mvFtbl(X,Y),Other,State).

rem_prop(P,[Q|Other],[Q|State]):-rem_prop(P,Other,State).

solve([],_,_) :- true.
solve([[P]|Other],State,RuleList) :- is_rule(P),rem_prop(P,State,StateN),
                                   add_postcond(StateN,P,StateM),
                                   solve(Other,StateM,RuleList).
solve([P|Other],State,RuleList) :- is_sat(P,State),solve(Other,State,RuleList).
solve([[Prop]|Other],State,[Rule|RuleList]) :- in_post(Prop,Rule),
                                               add_precond(Other,Rule,OtherNew),
                                               solve(OtherNew,State,RuleList).
solve([AndProp|Other],State,RuleList) :- append(AndProp,[AndProp|Other],NewL),
                                          solve(NewL,State,RuleList).

%% TESTCASES
%solve([[on("A","B"),on("B","C"),clr("A"),ontable("C")]],[clr("A"),clr("B"),ontable("A"),ontable("C"),on("B","C")],X).
%solve([[on("A","B"),clr("A"),ontable("B"),armemp]],[clr("A"),clr("B"),ontable("A"),ontable("B"),armemp],X).