# Instruções de Instalação e Publicação - Pacote imasul

## Pré-requisitos

Antes de instalar e usar o pacote, certifique-se de ter:

1. **R versão 4.0.0 ou superior**
2. **RStudio** (recomendado)
3. **Git** instalado no sistema
4. **Conta no GitHub**

## Dependências Obrigatórias

O pacote requer os seguintes pacotes R:

```r
# Pacotes obrigatórios (instalados automaticamente)
install.packages(c(
  "readr", "dplyr", "lubridate", "tidyr", 
  "magrittr", "moments", "devtools"
))

# Pacotes opcionais (para funcionalidades avançadas)
install.packages(c(
  "ggplot2", "plotly", "sf", "leaflet", 
  "openxlsx", "knitr", "rmarkdown"
))
```

## Publicação no GitHub

### 1. Inicializar Repositório Git

```bash
cd /Users/evandrofalleiros/Desktop/Doutorado/workspace/imasul
git init
git add .
git commit -m "Initial commit - Pacote imasul v1.0.0"
```

### 2. Criar Repositório no GitHub

1. Acesse [github.com](https://github.com)
2. Clique em "New repository"
3. Nome: `imasul`
4. Descrição: "Dados de Monitoramento de Metais em Águas - Mato Grosso do Sul"
5. Público ou Privado (sua escolha)
6. NÃO inicialize com README (já temos um)
7. Clique "Create repository"

### 3. Conectar ao GitHub

```bash
# Substitua SEU_USERNAME pelo seu usuário do GitHub
git remote add origin https://github.com/SEU_USERNAME/imasul.git
git branch -M main
git push -u origin main
```

### 4. Configurar GitHub Pages (Opcional)

Para documentação online:
1. Vá nas configurações do repositório
2. Seção "Pages"
3. Source: "Deploy from a branch"
4. Branch: main, folder: /docs

## Instalação do Pacote

### Para Desenvolvedores

```r
# Instalar diretamente do GitHub
devtools::install_github("SEU_USERNAME/imasul")

# Carregar o pacote
library(imasul)

# Verificar instalação
?carregar_dados_imasul
```

### Para Usuários Finais

```r
# Instalar devtools se não tiver
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Instalar o pacote imasul
devtools::install_github("SEU_USERNAME/imasul", 
                        build_vignettes = TRUE)

# Carregar
library(imasul)

# Ver vinheta
vignette("introducao", package = "imasul")
```

## Teste de Instalação

Execute este código para testar se tudo está funcionando:

```r
library(imasul)

# Teste básico
metais <- listar_metais()
print(metais)

limites <- limites_conama()
print(limites)

# Se os datasets estiverem incluídos
if (file.exists(system.file("csv", "resultados_metais_2011_2022.csv", package = "imasul"))) {
  dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)
  cat("Dados carregados com sucesso:", nrow(dados), "registros\n")
} else {
  cat("Datasets não encontrados. Use carregar_dados_imasul() com caminho específico.\n")
}
```

## Estrutura Final do Projeto

```
imasul/
├── DESCRIPTION          # Metadados do pacote
├── NAMESPACE           # Exportações (gerado automaticamente)
├── NEWS.md             # Changelog
├── README.md           # Documentação principal
├── LICENSE             # Licença MIT
├── CODE_OF_CONDUCT.md  # Código de conduta
├── .gitignore          # Arquivos ignorados pelo Git
├── .github/
│   └── workflows/
│       └── R-CMD-check.yaml  # CI/CD
├── R/
│   ├── dados.R         # Funções principais
│   ├── uteis.R         # Funções auxiliares
│   └── data.R          # Documentação dos datasets
├── data/
│   ├── resultados_metais.rda    # Dataset processado
│   ├── pontos_metais.rda        # Dataset de pontos
│   └── dados_imasul.rda         # Dataset integrado
├── data-raw/
│   └── processar_dados.R        # Script de processamento
├── inst/
│   └── csv/
│       ├── resultados_metais_2011_2022.csv
│       └── pontos_resultados_metais.csv
├── man/                # Documentação (gerada automaticamente)
├── tests/
│   ├── testthat.R
│   └── testthat/
│       └── test-dados.R
├── vignettes/
│   └── introducao.Rmd  # Tutorial detalhado
└── examples/
    └── exemplo_completo.R       # Script de exemplo
```

## Comandos Úteis para Desenvolvimento

```r
# Verificar pacote completo
devtools::check()

# Instalar localmente para teste
devtools::install()

# Gerar documentação
devtools::document()

# Executar testes
devtools::test()

# Construir vinhetas
devtools::build_vignettes()

# Verificar spelling
devtools::spell_check()
```

## Comandos Git Úteis

```bash
# Status do repositório
git status

# Adicionar mudanças
git add .
git commit -m "Descrição da mudança"
git push origin main

# Criar release/tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Ver histórico
git log --oneline
```

## Criando Releases no GitHub

1. Vá no repositório no GitHub
2. Clique em "Releases"
3. "Create a new release"
4. Tag: v1.0.0
5. Title: "imasul v1.0.0 - Release Inicial"
6. Descrição: Copie do NEWS.md
7. "Publish release"

## Próximos Passos

1. **Publicar no GitHub** seguindo os passos acima
2. **Atualizar README.md** com o link correto do repositório
3. **Criar documentação online** com pkgdown
4. **Submeter ao CRAN** (se desejar distribuição oficial)
5. **Criar apresentação** ou artigo sobre o pacote

## Suporte e Contribuições

- **Issues**: Reporte bugs em github.com/SEU_USERNAME/imasul/issues
- **Contribuições**: Faça fork e submeta pull requests
- **Discussões**: Use as Discussions do GitHub

## Citação

```r
citation("imasul")
```

Para citar este pacote em publicações acadêmicas, use a saída do comando acima.
