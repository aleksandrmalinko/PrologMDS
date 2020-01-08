:-dynamic entity/3.
:-dynamic d_access/2.
:-dynamic s_access/3.
:-dynamic owner/2.
:-dynamic grant/4.

entity(root, cd, use).
entity(admin, cd, use).
entity(user, cd, use).
entity(app1, upd, upd).
entity(app2, r, cd).
entity(file, use, cd).
entity(printer, use, use).

owner(root, admin).
owner(root, user).
owner(admin, app1).
owner(admin, printer).
owner(user, app2).
owner(user, file).

d_access(admin, user).
d_access(admin, file).
d_access(user, app2).
s_access(admin, app1, use).

grant(admin, app1, use, user).

s_right(use, 1).
s_right(r, 2).
s_right(upd, 3).
s_right(cd, 4).

help:-
    write('create_entity'), nl,
    write('create_child_entity'), nl,
    write('destroy_entity'), nl,
    write('change_max_active'), nl,
    write('change_max_passive'), nl,
    write('enter_static_right'), nl,
    write('check_right'), nl,
    write('grant'), nl,
    write('revoke'), nl,
    write('delegate'), nl,
    write('abrogate'), nl.
command:-
    write('0 - create entity'), nl,
    write('1 - create child entity'), nl,
    write('2 - destroy entity'), nl,
    write('3 - change max active right'), nl,
    write('4 - change max passive right'), nl,
    write('5 - enter static right'), nl,
    write('6 - check right'), nl,
    write('7 - grant right'), nl,
    write('8 - revoke right'), nl,
    write('9 - delegate right'), nl,
    write('10 - abrogate right'), nl,
    write('14 - display the tip again'), nl,
    write('15 - quit'), nl,
    read(N), redirect(N).
get_new:-
    read(N), redirect(N).
redirect(N):-
    N = 0, create_entity, nl, get_new;
    N = 1, create_child_entity, nl, get_new;
    N = 2, destroy_entity, nl, get_new;
    N = 3, change_max_active, nl, get_new;
    N = 4, change_max_passive, nl, get_new;
    N = 5, enter_static_right, nl, get_new;
    N = 6, check_right, nl, get_new;
    N = 7, grant, nl, get_new;
    N = 8, revoke, nl, get_new;
    N = 9, delegate, nl, get_new;
    N = 10, abrogate, nl, get_new;
    N = 11, nl, command;
    N = 12;
    write('Error'), nl.
create_entity:-
    write('Name: '), read(Ent_name),
    write('Active right: '), read(Act_right),
    write('Passive right: '), read(Pas_right),
    (
       entity(Ent_name, Act_right, Pas_right), write('Error'), nl;
       assert(entity(Ent_name, Act_right, Pas_right)), write('Entity created'), nl
    ).
create_child_entity:-
    write('Parent name: '), read(Par_name),
    write('Child name: '), read(Chil_name),
    (
       not(entity(Par_name, _, _)), write('Error'), nl;
       entity(Chil_name, _, _), write('Error'), nl;
       entity(Par_name, Act_right, Pas_right),
       assert(entity(Chil_name, Act_right, Pas_right)),
       assert(owner(Par_name, Chil_name)),
       assert(d_access(Par_name, Chil_name)), write('Child created'), nl
    ).
destroy_entity:-
    write('Name: '), read(Ent_name),
    (
       not(entity(Ent_name, _, _)), write('Error'), nl;
       retract(entity(Ent_name, _, _)),
       retract(owner(_, Ent_name)),
       retractall(s_access(Ent_name, _, _)),
       retractall(s_access(_, Ent_name, _)),
       retractall(d_access(Ent_name, _)),
       retractall(d_access(_, Ent_name)),
       retractall(grant(Ent_name, _, _, _)),
       retractall(grant(_, Ent_name, _, _)),
       retractall(grant(_, _, _, Ent_name)), write('Entity destroyed')
    ).
change_max_active:-
    write('Entity name: '), read(Ent_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent_name, _, _)), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       entity(Ent_name, Act_right, Pas_right),
       retract(entity(Ent_name, Act_right, Pas_right)),
       assert(entity(Ent_name, Right, Pas_right)), write('Active right entered'), nl
    ).
change_max_passive:-
    write('Entity name: '), read(Ent_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent_name, _, _)), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       entity(Ent_name, Act_right, Pas_right),
       retract(entity(Ent_name, Act_right, Pas_right)),
       assert(entity(Ent_name, Act_right, Right)), write('Passive right entered'), nl
    ).
enter_static_right:-
    write('Entity1 name: '), read(Ent1_name),
    write('Entity2 name: '), read(Ent2_name),
    write('Owner name: '), read(Own_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent1_name, _, _)), write('Error'), nl;
       not(entity(Ent2_name, _, _)), write('Error'), nl;
       not(Own_name == root), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       s_right(Right, Right_prior),
       entity(Ent1_name, Act_pot, _),
       entity(Ent2_name, _, Pas_pot),
       s_right(Act_pot, Act_prior),
       s_right(Pas_pot, Pas_prior),
       (
          Right_prior < Act_prior;
          Right_prior < Pas_prior
       ), write('Error'), nl;
       s_access(Ent1_name, Ent2_name, Right), write('Error'), nl;
       assert(s_access(Ent1_name, Ent2_name, Right)), write('Static right entered'), nl
    ).
check_right:-
    write('Entity1 name: '), read(Ent1_name),
    write('Entity2 name: '), read(Ent2_name),
    write('Right: '), read(Right),
    (
       s_access(Ent1_name, Ent2_name, Right), write('Access granted'), nl;
       write('Access denied'), nl
    ).
grant:-
    write('Entity1 name: '), read(Ent1_name),
    write('Entity2 name: '), read(Ent2_name),
    write('Entity3 name: '), read(Ent3_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent1_name, _, _)), write('Error'), nl;
       not(entity(Ent2_name, _, _)), write('Error'), nl;
       not(entity(Ent3_name, _, _)), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       not(s_access(Ent1_name, Ent3_name, Right)), write('Error'), nl;
       not(grant(Ent1_name, Ent3_name, Right, Ent2_name)), write('Error'), nl;
       s_access(Ent2_name, Ent3_name, Right), write('Error'), nl;
       s_right(Right, Right_prior),
       entity(Ent2_name, Act_pot, _),
       s_right(Act_pot, Act_prior),
       Right_prior > Act_prior, write('Error'), nl;
       assert(s_access(Ent2_name, Ent3_name, Right)), write('Static right granted'), nl
    ).
revoke:-
    write('Entity1 name: '), read(Ent1_name),
    write('Entity2 name: '), read(Ent2_name),
    write('Entity3 name: '), read(Ent3_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent1_name, _, _)), write('Error'), nl;
       not(entity(Ent2_name, _, _)), write('Error'), nl;
       not(entity(Ent3_name, _, _)), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       not(grant(Ent1_name, Ent3_name, Right, Ent2_name)), write('Error'), nl;
       not(s_access(Ent2_name, Ent3_name, Right)), write('Error'), nl;
       retract(s_access(Ent2_name, Ent3_name, Right)), write('Static right revoked'), nl
    ).
delegate:-
    write('Entity1 name (who delegates): '), read(Ent1_name),
    write('Entity2 name (who recieves): '), read(Ent2_name),
    write('Entity3 name (object entity): '), read(Ent3_name),
    write('Entity4 name (entity to which 3 can grant): '), read(Ent4_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent1_name, _, _)), write('Error'), nl;
       not(entity(Ent2_name, _, _)), write('Error'), nl;
       not(entity(Ent3_name, _, _)), write('Error'), nl;
       not(entity(Ent4_name, _, _)), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       not(d_access(Ent1_name, Ent2_name)), write('Error'), nl;
       not(grant(Ent1_name, Ent3_name, Right, Ent2_name)), write('Error'), nl;
       grant(Ent2_name, Ent3_name, Right, Ent4_name), write('Error'), nl;
       assert(s_access(Ent2_name, Ent3_name, Right)),
       assert(grant(Ent2_name, Ent3_name, Right, Ent4_name)), write('Dynamic right delegated'), nl
    ).
abrogate:-
    write('Entity1 name: '), read(Ent1_name),
    write('Entity2 name: '), read(Ent2_name),
    write('Entity3 name: '), read(Ent3_name),
    write('Entity4 name: '), read(Ent4_name),
    write('Right: '), read(Right),
    (
       not(entity(Ent1_name, _, _)), write('Error'), nl;
       not(entity(Ent2_name, _, _)), write('Error'), nl;
       not(entity(Ent3_name, _, _)), write('Error'), nl;
       not(entity(Ent4_name, _, _)), write('Error'), nl;
       not(s_right(Right, _)), write('Error'), nl;
       not(d_access(Ent1_name, Ent2_name)), write('Error'), nl;
       not(grant(Ent1_name, Ent3_name, Right, Ent2_name)), write('Error'), nl;
       not(grant(Ent2_name, Ent3_name, Right, Ent4_name)), write('Error'), nl;
       retract(grant(Ent2_name, Ent3_name, Right, Ent4_name)), write('Dynamic right abrogated'), nl
    ).





