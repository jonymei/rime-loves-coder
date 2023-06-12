.PHONY: full all cn en opencc

full:
	bash plum/rime-install iDvel/rime-ice:others/recipes/full

all:
	bash plum/rime-install iDvel/rime-ice:others/recipes/all_dicts

cn:
	bash plum/rime-install iDvel/rime-ice:others/recipes/cn_dicts

en:
	bash plum/rime-install iDvel/rime-ice:others/recipes/en_dicts

opencc:
	bash plum/rime-install iDvel/rime-ice:others/recipes/opencc
