.PHONY: instantiate build test format

define pkg
	julia --project='@.' -e 'using Pkg; ${1}'
endef

instantiate:
	$(call pkg, Pkg.instantiate())

build:
	$(call pkg, Pkg.build())

test:
	$(call pkg, Pkg.test())

add:
	$(call pkg, Pkg.add("${PKG}"))

remove:
	$(call pkg, Pkg.rm("${PKG}"))

format:
	julia --project='@.' -e 'using JuliaFormatter; format(".", verbose=true)'

docbuild:
	julia --project=docs -e ' \
			using Pkg; \
			Pkg.develop(PackageSpec(path=pwd())); \
			Pkg.instantiate();'

doctests:
	julia --project=docs -e '\
			using Documenter: doctest;\
			using Pidoh;\
			doctest(Pidoh);'
docgen:
	julia --project=docs docs/make.jl 

