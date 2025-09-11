source('R/dados.R')

# Testar direto a função
cat('=== TESTANDO FUNÇÃO ATUALIZADA ===\n')
dados <- carregar_dados_imasul()

cadmio_valores <- dados$cadmio_total_mg_L_Cd[!is.na(dados$cadmio_total_mg_L_Cd)]
valor_lq_sqrt2 <- 0.005/sqrt(2)

cat('Valor LQ/√2 esperado:', valor_lq_sqrt2, '\n')
count_lq_sqrt2 <- sum(abs(cadmio_valores - valor_lq_sqrt2) < 1e-6)
cat('Valores encontrados com LQ/√2:', count_lq_sqrt2, '\n')
cat('Mínimo valor de cádmio:', min(cadmio_valores), '\n')
cat('Máximo valor de cádmio:', max(cadmio_valores), '\n')

cat('\nValores únicos menores que 0.004:\n')
pequenos <- cadmio_valores[cadmio_valores < 0.004]
if(length(pequenos) > 0) {
  print(unique(pequenos))
} else {
  cat('Nenhum valor encontrado\n')
}

cat('\nPrimeiros 10 valores de cádmio:\n')
print(head(cadmio_valores, 10))

# Verificar outros metais também
cat('\n=== OUTROS METAIS ===\n')
metais <- c('ferro_total_mg_L_Fe', 'chumbo_total_mg_L_Pb', 'aluminio_total_mg_L_Al', 'manganes_total_mg_L_Mn')
limites_esperados <- c(0.1, 0.02, 0.1, 0.1)

for(i in 1:length(metais)) {
  metal <- metais[i]
  limite <- limites_esperados[i]
  valores <- dados[[metal]][!is.na(dados[[metal]])]
  if(length(valores) > 0) {
    valor_lq_sqrt2 <- limite / sqrt(2)
    count_lq <- sum(abs(valores - valor_lq_sqrt2) < 1e-6)
    cat(sprintf('%s: esperado %.6f, encontrados %d valores\n', metal, valor_lq_sqrt2, count_lq))
  }
}
