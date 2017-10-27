%%%% Submitted by:
%%%% Suyash Agrawal (2015CS10262)
%%%% Aman Agrawal (2015CS10210)

:- dynamic frame/2.
%% DATABASE %%
frame(university, [(phone,[default, 011686971]), (address,[default, "IIT Delhi"])]).
frame(department, [a_part_of(university), (programme,["Btech", "Mtech", "Ph.d"])]).
frame(hostel, [a_part_of(university),  (room,[default, 100])]).
frame(faculty, [a_part_of(department), (age,[range,25,60]), (nationality,[default, "Indian"]), (qual,[default, "postgraduate"])]).
frame(nilgiri, [is_a(hostel), (phone,[011686234])]).
frame(science_faculty, [ako(faculty),(qual,[default, "M.Sc."])]).
frame(renuka, [is_a(science_faculty), (qual,["Ph.D."]), (age,[45]), (address,["janakpuri"])]).

%% Searching a property in a list %%
search(_,[],_) :- fail.
search(A,[(A,X)|_],X) :- !.
search(A,[_|E],T) :- search(A,E,T).

%% find(frame_name,property_name, result) %%
find(X, Y, T) :- frame(X, Z), search(Y,Z,T), !.
find(X, Y, T) :- frame(X, [is_a(Z)|_]), find(Z, Y, T), !.
find(X, Y, T) :- frame(X, [ako(Z)| _]), find(Z, Y, T), !.
find(X, Y, T) :- frame(X, [a_part_of(Z)|_]), find(Z, Y, T).

%% delete(N) :- Delete frame with frame name N and all its derived classes
delete(N) :- var(N), writeln("Frame name should be a bound variable"),!. 
delete(N) :- frame(X, [is_a(N)|_]), delete(X), fail.
delete(N) :- frame(X, [ako(N)|_]), delete(X), fail.
delete(N) :- frame(X, [a_part_of(N)|_]), delete(X), fail.
delete(N) :- retractall(frame(N,_)).

%% delete_prop(X,A,[],R) :- Delete property X in list A and store the new list in R
delete_prop(_,[],A,A).
delete_prop(X,[(X,_)|T],A,R) :- delete_prop(X,T,A,R).
delete_prop(X,[Y|T],A,R) :- delete_prop(X,T,[Y|A],R).

%% exist_prop(X,A) :- Checks if propert X is present in list A
exist_prop(_,[]) :- fail,!.
exist_prop(X,[(X,_)|_]) :- !.
exist_prop(X,[_|T]) :- exist_prop(X,T).

%% update(F,P,M) :- update value of propert P to M in frame F
update(F,_,_) :- var(F), writeln("Frame name should be a bound variable"),!.
update(_,P,_) :- var(P), writeln("Property should be a bound variable"),!.
update(_,_,M) :- var(M), writeln("Value should be a bound variable"),!.
update(F,P,M) :- frame(F,V),exist_prop(P,V),delete_prop(P,V,[],NV), delete(F), asserta(frame(F,[(P,M)|NV])),!.
update(F,_,_) :- frame(F,_), writeln("Given property does not exist"),!.
update(_,_,_) :- writeln("Given frame does not exist"),!.

%% add(F,V) :- inserts a new frame F with data V
add(F,_) :- var(F), writeln("Frame name should be a bound variable"),!.
add(_,V) :- var(V), writeln("Frame value should be a bound variable"),!.
add(F,V) :- \+ frame(F,_) , asserta(frame(F,V)),!.
add(F,_) :- frame(F,_), writeln("Given frame already exists"), !.

%% insert_prop(F,P,M) :- inserts property P with value M in frame F
insert_prop(F,_,_) :- var(F), writeln("Frame name should be a bound variable"),!.
insert_prop(_,P,_) :- var(P), writeln("Property should be a bound variable"),!.
insert_prop(_,_,M) :- var(M), writeln("Value should be a bound variable"),!.
insert_prop(F,P,M) :- frame(F,V),\+ exist_prop(P,V), retractall(frame(F,_)), asserta(frame(F,[(P,M)|V])),!.
insert_prop(F,P,_) :- frame(F,V), exist_prop(P,V),writeln("Given property already exists"),!.
insert_prop(_,_,_) :- writeln("Given frame does not exist"),!.
