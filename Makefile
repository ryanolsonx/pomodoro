.PHONY: make prod s fmt

make:
	elm make src/Main.elm --output=elm.js

prod:
	elm make src/Main.elm --output=elm.js --optimize

fmt:
	elm-format src/Main.elm --yes

s: make
	npx serve
