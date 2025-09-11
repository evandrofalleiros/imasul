library(imasul)
dados <- carregar_dados_imasul()

# Buscar especificamente o valor '2e-04' que você mencionou
cat('=== BUSCA PELO VALOR 2e-04 ===\n')
metals <- c('ferro', 'cadmio', 'chumbo', 'aluminio', 'manganes')
for(metal in metals) {
  valores <- dados[[metal]]
  # Buscar valores muito próximos de 2e-04 (0.0002)
  near_2e4 <- which(abs(valores - 0.0002) < 1e-6 & !is.na(valores))
  if(length(near_2e4) > 0) {
    cat(sprintf('Metal %s: Encontrado valor 2e-04 em %d posições\n', metal, length(near_2e4)))
    cat('Valores exatos:', valores[near_2e4], '\n')
  }
}

cat('\n=== ANÁLISE DE VALORES EM NOTAÇÃO CIENTÍFICA ===\n')
for(metal in metals) {
  valores <- dados[[metal]]
  valores_validos <- valores[!is.na(valores)]
  
  # Buscar valores muito pequenos que poderiam ter sido <LQ
  pequenos <- valores_validos[valores_validos > 0 & valores_validos < 0.001]
  if(length(pequenos) > 0) {
    cat(sprintf('\nMetal %s - Valores < 0.001:\n', metal))
    cat('Quantidade:', length(pequenos), '\n')
    cat('Valores únicos:', paste(unique(pequenos), collapse=', '), '\n')
  }
}

# Verificar se há algum padrão específico
cat('\n=== VERIFICAÇÃO DE PADRÕES ESPECÍFICOS ===\n')
dados_brutos <- read.csv('inst/csv/resultados_metais_2011_2022.csv', stringsAsFactors = FALSE)
for(col in names(dados_brutos)) {
  if(grepl('mg_L', col)) {
    valores_2e04 <- grepl('2e-04|2e-4|2E-04|2E-4', dados_brutos[[col]], ignore.case = TRUE)
    if(any(valores_2e04)) {
      cat(sprintf('Coluna %s: Encontrados %d valores com padrão 2e-04\n', col, sum(valores_2e04)))
      valores_unicos <- unique(dados_brutos[[col]][valores_2e04])
      cat('Valores encontrados:', paste(valores_unicos, collapse=', '), '\n')
    }
  }
}
