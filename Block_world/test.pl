is_rule(pop(_)).
checklist([]) :- false.
checklist([P|_]) :- is_rule(P),
                    is_rule(P).
checklist([_|Other]) :- checklist(Other).
