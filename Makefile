.PHONY: full all cn en opencc flypy

all:
	bash plum/rime-install iDvel/rime-ice:others/recipes/all_dicts

full:
	bash plum/rime-install iDvel/rime-ice:others/recipes/full

cn:
	bash plum/rime-install iDvel/rime-ice:others/recipes/cn_dicts

en:
	bash plum/rime-install iDvel/rime-ice:others/recipes/en_dicts

opencc:
	bash plum/rime-install iDvel/rime-ice:others/recipes/opencc

flypy:
	bash plum/rime-install iDvel/rime-ice:others/recipes/config:schema=flypy
