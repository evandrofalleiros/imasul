# Changelog - Pacote imasul

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [1.1.0] - 2025-10-06

### Adicionado
- Função `preparar_dados_multivariados()` para preparar matriz de metais e vetor de grupos (tratamento de "<LQ", conversão numérica, agregação por ponto, filtro de NAs, imputação).
- Vinheta "Análise multivariada com o pacote imasul" demonstrando PCA e MANOVA.
- Export da nova função no NAMESPACE.

## [1.0.0] - 2025-09-11

### Adicionado
- Função `carregar_dados_imasul()` com suporte a integração de coordenadas geográficas
- Datasets integrados: `resultados_metais`, `pontos_metais`, `dados_imasul`
- Função `resumo_metal()` para análise estatística completa
- Função `limites_conama()` com padrões da Resolução CONAMA 357/2005
- Função `verificar_conformidade()` para análise de conformidade
- Função `analisar_temporal()` para análises temporais (anual, mensal, semestral)
- Função `mapear_pontos()` para preparação de dados espaciais
- Função `relatorio_conformidade()` para relatórios completos
- Função `listar_metais()` para consulta dos metais disponíveis
- Função `estatisticas_por_regiao()` para comparações regionais
- Função `identificar_pontos_criticos()` para detecção de pontos problemáticos
- Função `exportar_para_excel()` para exportação de relatórios
- Vinheta completa com exemplos práticos
- Testes automatizados para principais funções
- Documentação completa com roxygen2
- Configuração para GitHub Actions (CI/CD)
- Suporte aos limites CONAMA para 11 metais pesados
- Integração de dados geográficos de 65 pontos de monitoramento
- Dados de monitoramento de 2011-2022 (1.299 registros)

### Características Principais
- **Dados Integrados**: Monitoramento de metais com coordenadas geográficas
- **Conformidade CONAMA**: Verificação automática com limites normativos
- **Análises Temporais**: Detecção de tendências e sazonalidade
- **Análises Espaciais**: Mapeamento e análises por região hidrográfica
- **Relatórios Automatizados**: Geração de relatórios em Excel
- **Identificação de Criticidade**: Detecção de pontos com alta não conformidade
- **Visualizações**: Suporte para ggplot2, leaflet e plotly

### Metais Monitorados
- Alumínio (Al) - Limite: 0,1 mg/L
- Bário (Ba) - Limite: 0,7 mg/L
- Cádmio (Cd) - Limite: 0,001 mg/L
- Chumbo (Pb) - Limite: 0,01 mg/L
- Cobre (Cu) - Limite: 0,009 mg/L
- Cromo (Cr) - Limite: 0,05 mg/L
- Ferro (Fe) - Limite: 0,3 mg/L
- Manganês (Mn) - Limite: 0,1 mg/L
- Mercúrio (Hg) - Limite: 0,0002 mg/L
- Níquel (Ni) - Limite: 0,025 mg/L
- Zinco (Zn) - Limite: 0,18 mg/L

### Regiões Hidrográficas
- **Bacia do Paraná**: 35 pontos de monitoramento
- **Bacia do Paraguai**: 30 pontos de monitoramento

### Documentação
- README.md completo com exemplos
- Vinheta detalhada (`vignette("introducao", package = "imasul")`)
- Documentação de todas as funções
- Código de conduta para contribuidores
- Configuração para integração contínua

### Dependências
- **Imports**: readr, dplyr, lubridate, tidyr, magrittr, moments, stats, utils
- **Suggests**: ggplot2, plotly, sf, leaflet, openxlsx, knitr, rmarkdown, testthat, devtools

### Instalação
```r
# Do GitHub (recomendado)
devtools::install_github("SEU_USERNAME/imasul")

# Carregar
library(imasul)
```
