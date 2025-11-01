# GeoTests Project Instructions

Este é um projeto Julia para testes geoespaciais. O projeto segue a estrutura padrão de pacotes Julia.

## Estrutura do Projeto

- `src/`: Código fonte principal
- `test/`: Testes unitários
- `Project.toml`: Arquivo de configuração do projeto
- `README.md`: Documentação principal

## Desenvolvimento

- Use Julia 1.6 ou superior
- Mantenha os testes atualizados em `test/runtests.jl`
- Documente novas funcionalidades no README.md
- Siga o estilo de código Julia

## Tasks Comuns

- Para executar testes: `using Pkg; Pkg.test()`
- Para adicionar dependências: `using Pkg; Pkg.add("PacoteName")`