:- module(lambda, [
    is_lam/1,
    lamstep/2,
    lamcall/2,
    n_lam/2,
    t_lam/1,
    f_lam/1,
    if_lam/1,
    eq0_lam/1,
    add_lam/1,
    multi_lam/1,
    pred_lam/1,
    fact_lam/1,
    y_lam/1
]).

:- discontiguous test/1.
:- op(950, fx, test).
testing :-
    test X,
    \+ call(X),
    !,
    format('test FAILED.~n'),
    format('at ~w.~n', [X]);
    true.

is_lam(lam(_,_)).
is_lam(_-_).

test lamstep(lam([x, y], x-y)-lam([a], a), lam([y], lam([a], a)-y)).
test lamstep((lam([x], x)-a)-(lam([x], x)-b), a-(lam([x], x)-b)).
test lamstep(a-(lam([x], b)-y), a-b).
test lamstep(lam([x], lam([y], y-y)-x), lam([x], x-x)).
test lamstep(a-b, a-b).
lamstep(lam(A, B)-C, Res) :-
    !,
    replam(lam(A, B), C, Res).
lamstep(A-B, A2-B) :-
    lamstep(A, A2),
    A \= A2, !.
lamstep(A-B, A-B2) :-
    !,
    lamstep(B, B2).
lamstep(lam(A, B), lam(A, B2)) :-
    !,
    lamstep(B, B2).
lamstep(A, A).

test lamcall(lam([x], x-x)-lam([x], x), lam([x], x)).
lamcall(A, A3) :-
    lamstep(A, A2),
    A \= A2, !,
    lamcall(A2, A3).
lamcall(A, A).

test replam(lam(x, x-x), b, b-b).
test replam(lam([x], x-x), b, b-b).
test replam(lam([x, y], x-y-x), b, lam([y], b-y-b)).
replam(lam(A, B), To, Res) :-
    \+ is_list(A), !,
    replam(lam([A], B), To, Res).
replam(lam([A], B), To, B2) :-
    !,
    replam(B, A, To, B2).
replam(lam([A|As], B), To, lam(As, B2)) :-
    !,
    replam(B, A, To, B2).

test replam(X, a, b, X).
test replam(c, a, b, c).
test replam(a-c, a, b, b-c).
test replam(lam(a, a), a, b, lam(a, a)). % NOTE
test \+ replam(lam(a, a), a, b, lam(a, b)). % NOTE
test replam(lam([a], a), a, b, lam([a], a)). % NOTE
test replam(lam([c], a), a, b, lam([c], b)).
replam(A, _, _, A) :-
    var(A), !.
replam(From, From, To, To) :-
    !.
replam(A-B, From, To, A2-B2) :-
    !,
    replam(A, From, To, A2),
    replam(B, From, To, B2).
replam(lam(From, B), From, _, lam(From, B)) :-
    !.
replam(lam(A, B), From, To, lam(A, B2)) :-
    \+ is_list(A),
    A \= From, !,
    replam(B, From, To, B2).
replam(lam(As, B), From, _, lam(As, B)) :-
    member(From, As), !.
replam(lam(As, B), From, To, lam(As, B2)) :-
    is_list(As),
    \+ member(From, As), !,
    replam(B, From, To, B2).
replam(A, _, _, A).


test n_lam(3, lam([f, x], f-(f-(f-x)))).
n_lam(N, lam([f, x], T)) :-
    get_nlam2(N, T).
get_nlam2(0, x) :- !.
get_nlam2(N, f-X) :-
    integer(N), !,
    N > 0,
    N1 is N - 1,
    get_nlam2(N1, X).
get_nlam2(N, f-X) :-
    var(N),
    get_nlam2(N1, X),
    N is N1 + 1.

t_lam(lam([x, y], x)).
f_lam(lam([x, y], y)).
if_lam(lam([x, y, z], x-y-z)).
eq0_lam(Lam) :-
    t_lam(T), f_lam(F),
    Lam = lam([a], a-(lam([b], F))-T).

add_lam(lam([a, b], lam([f, x], a-f-(b-f-x)))).
multi_lam(lam([a, b], lam([f, x], a-(b-f)-x)))
.
pred_lam(lam([n, f, x], n-lam([g, h], h-(g-f))-lam([u], x)-lam([u], u))).

fact_lam(Lam) :-
    eq0_lam(Eq0),
    if_lam(If),
    n_lam(1, One),
    multi_lam(Multi),
    pred_lam(Pred),
    y_lam(Y),
    Fact = lam([fact, n], If-(Eq0-n)-One-(Multi-n-(fact-(Pred-n)))),
    Lam = Y-Fact.
y_lam(lam([f], lam([x], (f-(x-x)))-(lam([x], f-(x-x))))).

:- testing.
