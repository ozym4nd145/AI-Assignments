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
% process \///

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

process([],_,Z,Z) :- true.
process([[P]|Other],State,RuleList,Acc) :-     is_rule(P),rem_prop(P,State,StateN),
                                               add_postcond(StateN,P,StateM),
                                               process(Other,StateM,RuleList,[P|Acc]).

process([P|Other],State,RuleList,Acc) :-       is_sat(P,State),
                                               process(Other,State,RuleList,Acc).

process([[Prop]|Other],State,RuleList,Acc) :-  in_post(Prop,Rule),
                                               add_precond(Other,Rule,OtherNew),
                                               process(OtherNew,State,RuleList,Acc).

process([AndProp|Other],State,RuleList,Acc) :- append(AndProp,[AndProp|Other],NewL),
                                               process(NewL,State,RuleList,Acc).

convert([],[]).
convert([mvFtbl(X,Y)|HL],[stack(X,Y),pickup(X)|Ans]) :- convert(HL,Ans).
convert([mvTtbl(X,Y)|HL],[putdown(X),unstack(X,Y)|Ans]) :- convert(HL,Ans).
convert([mvFT(X,Z,Y)|HL],[stack(X,Y),unstack(X,Z)|Ans]) :- convert(HL,Ans).

reverse([],Z,Z).
reverse([H|T],Ans,Acc) :- reverse(T,Ans,[H|Acc]).

solve(Goal,Start,Answer) :- process(Goal,Start,HL,[]), convert(HL,AnswerRev), reverse(AnswerRev,Answer,[]).


%% TESTCASES
% solve([[on("Z","X"),on("Y","W"),clr("Y"),clr("Z"),ontable("X"),ontable("W")]],[on("Y","X"),on("W","Z"),clr("Y"),clr("W"),ontable("X"),ontable("Z")],X).
% solve([[on("X","Z"),on("Y","W"),clr("Y"),clr("X"),ontable("Z"),ontable("W")]],[on("Y","X"),on("Z","W"),clr("Y"),clr("Z"),ontable("X"),ontable("W")],X).
% solve([[on("X","Z"),on("W","Y"),clr("X"),clr("W"),ontable("Z"),ontable("Y")]],[on("Y","X"),ontable("Z"),ontable("W"),clr("Y"),clr("Z"),clr("W"),ontable("X")],X).
% solve([[on("A","C"),on("D","B"),ontable("E"),clr("E"),clr("D"),clr("A"),ontable("B"),ontable("C")]],[on("E","C"),on("D","B"),ontable("A"),clr("E"),clr("D"),clr("A"),ontable("B"),ontable("C")],X).