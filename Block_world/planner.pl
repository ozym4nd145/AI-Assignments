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
is_rule(unstack(_,_)).
is_rule(stack(_,_)).
is_rule(pickup(_)).
is_rule(putdown(_)).

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

%% PICKUP
in_post(holding(X),pickup(X)).

%% UNSTACK
in_post(clr(X),unstack(_,X)).
in_post(holding(X),unstack(X,_)).

%% STACK
in_post(armemp,stack(_,_)).
in_post(clr(X),stack(X,_)).
in_post(on(X,Y),stack(X,Y)).


%% PUTDOWN
in_post(armemp,putdown(_)).
in_post(ontable(X),putdown(X)).
in_post(clr(X),putdown(X)).


% Add_precond
add_precond(Lst,putdown(X),[[holding(X)],[holding(X)],[putdown(X)]|Lst]).
add_precond(Lst,pickup(X),[[armemp],[ontable(X)],[clr(X)],[armemp,ontable(X),clr(X)],[pickup(X)]|Lst]).
add_precond(Lst,unstack(X,Y),[[armemp],[on(X,Y)],[armemp,on(X,Y)],[unstack(X,Y)]|Lst]).
add_precond(Lst,stack(X,Y),[[holding(X)],[clr(Y)],[holding(X),clr(Y)],[stack(X,Y)]|Lst]).

% Add_postcond
add_postcond(Lst,unstack(X,Y),[clr(Y),holding(X)|Lst]).
add_postcond(Lst,stack(X,Y),[armemp,clr(X),on(X,Y)|Lst]).
add_postcond(Lst,pickup(X),[holding(X)|Lst]).
add_postcond(Lst,putdown(X),[armemp,ontable(X),clr(X)|Lst]).

% Remove proposition
rem_prop(_,[],[]).
rem_prop(unstack(X,Y),[on(X,Y)|Other],State):-rem_prop(unstack(X,Y),Other,State).
rem_prop(unstack(X,Y),[clr(X)|Other],State):-rem_prop(unstack(X,Y),Other,State).
rem_prop(unstack(X,Y),[armemp|Other],State):-rem_prop(unstack(X,Y),Other,State).

rem_prop(stack(X,Y),[clr(Y)|Other],State):-rem_prop(stack(X,Y),Other,State).
rem_prop(stack(X,Y),[holding(X)|Other],State):-rem_prop(stack(X,Y),Other,State).

rem_prop(pickup(X),[clr(X)|Other],State):-rem_prop(pickup(X),Other,State).
rem_prop(pickup(X),[armemp|Other],State):-rem_prop(pickup(X),Other,State).
rem_prop(pickup(X),[ontable(X)|Other],State):-rem_prop(pickup(X),Other,State).

rem_prop(putdown(X),[holding(X)|Other],State):-rem_prop(putdown(X),Other,State).

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

reverse([],Z,Z).
reverse([H|T],Ans,Acc) :- reverse(T,Ans,[H|Acc]).
solve(Goal,Start,Answer) :- process(Goal,Start,HL,[]), reverse(HL,Answer,[]).

%% TESTCASES
%solve([[on("A","B"),on("B","C"),clr("A"),ontable("C"),armemp]],[clr("A"),clr("B"),ontable("A"),ontable("C"),on("B","C")],X)
%solve([[on("A","B"),clr("A"),ontable("B"),armemp]],[clr("A"),clr("B"),ontable("A"),ontable("B"),armemp],X).