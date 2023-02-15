.PHONY: make prod

make:
	elm make src/Main.elm

prod:
	elm make src/Main.elm --optimize

fmt:
	elm-format src/Main.elm --yes
