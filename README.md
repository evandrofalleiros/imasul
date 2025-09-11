# Pacote IMASUL

## Dados de Monitoramento de Metais em Águas - Mato Grosso do Sul

Este pacote R fornece acesso aos dados de monitoramento de metais em águas superficiais coletados pelo Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL). O pacote inclui ferramentas para análise estatística, verificação de conformidade com padrões ambientais e visualização dos dados.

[![R-CMD-check](https://github.com/evandrofalleiros/imasul/workflows/R-CMD-check/badge.svg)](https://github.com/evandrofalleiros/imasul/actions)

## Dados Disponíveis

O pacote inclui três datasets principais:

- **`resultados_metais`**: Concentrações de metais em amostras de água (2011-2022)
- **`pontos_metais`**: Coordenadas geográficas e descrições dos pontos de monitoramento  
- **`dados_imasul`**: Dataset integrado com dados de monitoramento e coordenadas

### Metais Monitorados

- Alumínio (Al)
- Bário (Ba) 
- Cádmio (Cd)
- Chumbo (Pb)
- Cobre (Cu)
- Cromo (Cr)
- Ferro (Fe)
- Manganês (Mn)
- Mercúrio (Hg)
- Níquel (Ni)
- Zinco (Zn)

## Instalação

```r
# Instalar do GitHub
devtools::install_github("evandrofalleiros/imasul")

# Carregar o pacote
library(imasul)
```

## Funcionalidades Principais

### Carregamento de Dados

```r
# Carregar dados incluídos no pacote (sem coordenadas)
dados <- carregar_dados_imasul(incluir_coordenadas = FALSE)

# Carregar dados com coordenadas geográficas dos pontos
dados_completos <- carregar_dados_imasul(incluir_coordenadas = TRUE)

# Carregar de arquivo externo
dados_externos <- carregar_dados_imasul("caminho/para/arquivo.csv")
```

### Análise Estatística

```r
# Resumo estatístico de um metal
resumo <- resumo_metal(dados, "cadmio_total_mg_L_Cd")
print(resumo)

# Estatísticas básicas incluem:
# - Medidas de tendência central (média, mediana)
# - Dispersão (desvio padrão, quartis)
# - Assimetria e curtose
# - Análise de conformidade com CONAMA
```

### Verificação de Conformidade com CONAMA

```r
# Consultar limites CONAMA 357/2005
limites <- limites_conama()
View(limites)

# Verificar conformidade para um metal específico
dados_conforme <- verificar_conformidade(dados, "cadmio_total_mg_L_Cd")
table(dados_conforme$status_cadmio_total_mg_L_Cd)

# Relatório completo de conformidade
relatorio <- relatorio_conformidade(dados)
print(relatorio$resumo_geral)
```

### Análise Temporal

```r
# Análise temporal por ano
temporal_ano <- analisar_temporal(dados, "ferro_total_mg_L_Fe", "ano")

# Análise temporal por mês
temporal_mes <- analisar_temporal(dados, "ferro_total_mg_L_Fe", "mes")

# Visualizar tendência temporal
plot(temporal_ano$data_agrupada, temporal_ano$media, 
     type = "l", main = "Concentração de Ferro ao Longo do Tempo")
```

### Mapeamento e Análise Espacial

```r
# Preparar dados para mapeamento
pontos <- mapear_pontos(dados_completos, "cadmio_total_mg_L_Cd")

# Usar com leaflet para mapa interativo
library(leaflet)
mapa <- leaflet(pontos)
mapa <- addTiles(mapa)
mapa <- addCircleMarkers(
  mapa,
  lng = ~longitude, 
  lat = ~latitude,
  radius = ~sqrt(media_cadmio_total_mg_L_Cd) * 10,
  popup = ~paste(codigo_imasul, "<br>", DESCRICAO_DO_LOCAL)
)
```

## Exemplo de Uso Completo

```r
library(imasul)
library(dplyr)
library(ggplot2)

# 1. Carregar dados
dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)

# 2. Análise exploratória
summary(dados)
str(dados)

# 3. Verificar conformidade para cádmio
dados_cd <- verificar_conformidade(dados, "cadmio_total_mg_L_Cd")
table(dados_cd$status_cadmio_total_mg_L_Cd)

# 4. Análise temporal
temporal <- analisar_temporal(dados, "cadmio_total_mg_L_Cd", "ano")

# 5. Visualização
ggplot(temporal, aes(x = data_agrupada, y = media)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Concentração Média de Cádmio ao Longo dos Anos",
    x = "Ano", 
    y = "Concentração (mg/L)",
    caption = "Fonte: IMASUL"
  ) +
  theme_minimal()

# 6. Relatório de conformidade
relatorio <- relatorio_conformidade(dados)
print(relatorio$resumo_geral)
```

## Estrutura dos Dados

### Códigos dos Pontos

Os códigos seguem o padrão IMASUL: `00MS[região][rio][sequencial]`

- **Região**: 13 (Bacia do Paraná), 21/22 (Bacia do Paraguai), 24 (Sub-bacia)
- **Rio**: AB (Água Boa), BR (Brilhante), DR (Dourados), PA (Paraguai), etc.

### Regiões Hidrográficas

- **PARANÁ**: Bacia do Rio Paraná
- **PARAGUAI**: Bacia do Rio Paraguai

## Padrões de Qualidade

O pacote utiliza os limites estabelecidos pela **Resolução CONAMA nº 357/2005** para águas doces classe 1:

| Metal | Limite (mg/L) |
|-------|---------------|
| Alumínio | 0,1 |
| Bário | 0,7 |
| Cádmio | 0,001 |
| Chumbo | 0,01 |
| Cobre | 0,009 |
| Cromo | 0,05 |
| Ferro | 0,3 |
| Manganês | 0,1 |
| Mercúrio | 0,0002 |
| Níquel | 0,025 |
| Zinco | 0,18 |

## Contribuições

Contribuições são bem-vindas! Por favor:

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este pacote está licenciado sob GPL-3. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## Citação

```r
citation("imasul")
```

## Contato

- **Autor**: Evandro Falleiros
- **Email**: evandro.falleiros@ifms.edu.br
- **GitHub**: [https://github.com/evandrofalleiros/imasul](https://github.com/evandrofalleiros/imasul)

## Referências

- **Fonte dos dados:** IMASUL - Instituto de Meio Ambiente de Mato Grosso do Sul
- **Referência normativa:** Resolução CONAMA nº 357/2005
- **Classe de água:** Doce Classe 1

## Contribuição

Contribuições são bem-vindas! Reporte bugs e sugestões em: https://github.com/evandrofalleiros/imasul/issues
