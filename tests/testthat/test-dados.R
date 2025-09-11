library(testthat)
library(imasul)

# Testes básicos do pacote imasul

test_that("carregar_dados_imasul funciona corretamente", {
  
  # Testar carregamento básico (pode falhar se dados não estiverem disponíveis)
  skip_if_not(file.exists("../../inst/csv/resultados_metais_2011_2022.csv"))
  
  dados <- carregar_dados_imasul()
  
  expect_s3_class(dados, "data.frame")
  expect_true(nrow(dados) > 0)
  expect_true("codigo_imasul" %in% colnames(dados))
  expect_true("data_coleta" %in% colnames(dados))
  expect_s3_class(dados$data_coleta, "Date")
})

test_that("carregar_dados_imasul com coordenadas funciona", {
  
  skip_if_not(file.exists("../../inst/csv/resultados_metais_2011_2022.csv"))
  skip_if_not(file.exists("../../inst/csv/pontos_resultados_metais.csv"))
  
  dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)
  
  expect_s3_class(dados, "data.frame")
  expect_true("LATITUDE" %in% colnames(dados))
  expect_true("LONGITUDE" %in% colnames(dados))
  expect_true("DESCRICAO_DO_LOCAL" %in% colnames(dados))
})

test_that("limites_conama retorna dados corretos", {
  
  limites <- limites_conama()
  
  expect_s3_class(limites, "data.frame")
  expect_equal(nrow(limites), 11)
  expect_true(all(c("metal", "coluna_dados", "limite_mg_L") %in% colnames(limites)))
  expect_true(all(limites$limite_mg_L > 0))
})

test_that("listar_metais funciona corretamente", {
  
  metais <- listar_metais()
  
  expect_s3_class(metais, "data.frame")
  expect_equal(nrow(metais), 11)
  expect_true(all(c("simbolo", "nome", "coluna_dados") %in% colnames(metais)))
  expect_true("Al" %in% metais$simbolo)
  expect_true("Alumínio" %in% metais$nome)
})

test_that("resumo_metal funciona com metal válido", {
  dados <- carregar_dados_imasul()
  metal <- "cadmio_total_mg_L_Cd"

  if (metal %in% colnames(dados)) {
    resumo <- resumo_metal(dados, metal)
    expect_type(resumo, "list")
    expect_true("media" %in% names(resumo))
    expect_true("n_amostras" %in% names(resumo))
  }
})

test_that("verificar_conformidade adiciona colunas", {
  dados <- carregar_dados_imasul()
  metal <- "cadmio_total_mg_L_Cd"

  if (metal %in% colnames(dados)) {
    dados_conforme <- verificar_conformidade(dados, metal)
    expect_true(nrow(dados_conforme) == nrow(dados))
    expect_true(any(grepl("status_", colnames(dados_conforme))))
  }
})

test_that("mapear_pontos retorna coordenadas", {
  dados <- carregar_dados_imasul()
  pontos <- mapear_pontos(dados)

  expect_s3_class(pontos, "data.frame")
  expect_true("latitude" %in% colnames(pontos))
  expect_true("longitude" %in% colnames(pontos))
  expect_true(all(!is.na(pontos$latitude) & !is.na(pontos$longitude)))
})
