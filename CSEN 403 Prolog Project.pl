build_kb:- write("Please enter a word and its category on separate lines:"),
	nl,
	read(X),
	X \= done,
	read(Y),
	Y \= done,
	assert(word(X, Y)),
	build_kb.
build_kb:- nl, write("Done building the words database...").

is_category(C):- word(_, C).

categories(L):- setof(C, is_category(C), L).

available_length(L):- word(X, _), atom_length(X, L).

pick_word(W, L, C):- word(W, C), atom_length(W, L).

correct_letters([],_,[]).
correct_letters([H|T],L2,CL):- \+member(H, L2), correct_letters(T,L2,CL).
correct_letters([H|T],L2,[H|T2]):- member(H, L2), delete(L2, H, R2), correct_letters(T,R2,T2).

correct_positions([],[],[]).
correct_positions([H|T],[X|T1],PL):- H \= X, correct_positions(T,T1,PL).
correct_positions([H|T],[H|T1],[H|T2]):- correct_positions(T,T1,T2).

chosen_category(C):- categories(L),
	write("The available categories are: "),
	write(L), nl,
	read(X),
	(
		is_category(X),
		member(X, L),
		C = X, !;
		\+is_category(X),
		write("This category does not exist."), nl, nl,
		chosen_category(C)
	), !.
chosen_length(Category, Length):- write("Choose a length:"), nl,
	read(L),
	(
		available_length(L),
		pick_word(_, L, Category), Length = L, !;
		write("There are no words of this length."), nl,
		chosen_length(Category, Length)
	), !.
play:- nl, nl,
	chosen_category(C),
	chosen_length(C, L),
	pick_word(R, L, C),
	G is L + 1,
	write("Game Started. You have "),
	write(G),
	write(" guesses."), nl, nl,
	play(R, C, L, G).
play(_, _, _, 0):- write("You Lost.").
play(Result, Category, Length, Guesses):- Guesses > 0,
	write("Enter a word composed of "),
	write(Length),
	write(" letters"), nl,
	read(Answer),
	(
		pick_word(Answer, Length, Category),
		Answer = Result,
		retract(word(Result, Category)),
		write("You Won.");
		(
			atom_length(Answer, Length),
			Answer \= Result,
			atom_chars(Answer, AL),
			atom_chars(Result, RL),
			correct_letters(AL, RL, CL),
			correct_positions(AL, RL, PL),
			NewGuesses is Guesses - 1,
			write("Correct letters are: "),
			write(CL), nl,
			write("Correct letters in correct positions are: "),
			write(PL), nl,
			write("Remaining guesses are "),
			write(NewGuesses), nl, nl,
			play(Result, Category, Length, NewGuesses);
			\+atom_length(Answer, Length),
			write("Word is not composed of "),
			write(Length),
			write(" letters. Try again."), nl,
			write("Remaining Guesses are "),
			write(Guesses), nl, nl,
			play(Result, Category, Length, Guesses)
		)
	).
main:- build_kb, !,
	play.