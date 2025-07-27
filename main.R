rm(list = ls())

if (!require(ggplot2)) install.packages("ggplot2")
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(ggthemes)) install.packages("ggthemes")
if (!require(car)) install.packages("car")
if (!require(ggpubr)) install.packages("ggpubr")
if (!require(kableExtra)) install.packages("kableExtra")
if (!require(usethis)) install.packages("usethis")

library(ggplot2)
library(tidyverse)
library(ggthemes)
library(car)
library(ggpubr)
library(kableExtra)
library(usethis)


mu <- seq(7,13,.2) 
sig <- 1          
n <- 25          
num_simulacoes <- 1000 

# Matrizes para armazenar os p-valores
p_t_test <- matrix(0, num_simulacoes, length(mu))
p_wilcox_test <- matrix(0, num_simulacoes, length(mu))

# Loop para cada valor de mu (cenários de diferença de média)
for(j in 1:length(mu)){
  mu_aux <- mu[j] # Média do grupo a ser testado
  for(i in 1:num_simulacoes) {
    # Cenário 1: Dados normais, homocedasticidade (ideal para t-test)
    # Grupo de controle (hipótese nula mu=10)
    # Grupo de teste (com média mu_aux))
    x_test <- rnorm(n, mu_aux, sig) # Dados para o grupo de teste
    
    # Teste t de Student (comparando x_test com um valor mu=10, ou com x_control)
    # Se for um teste t de uma amostra (comparando x_test com mu=10):
    p_t_test[i,j] <- as.numeric(t.test(x_test, mu=10, var.equal = TRUE)$p.value)
    
    # Teste de Wilcoxon (Mann-Whitney)
    # Se for um teste de Wilcoxon de uma amostra (comparando x_test com mu=10):
    p_wilcox_test[i,j] = as.numeric(wilcox.test(x_test, mu=10, exact=TRUE)$p.value)
  }
}

# Calcular o poder empírico (proporção de rejeições da hipótese nula)
poder_t_test <- apply(p_t_test < .05, 2, mean)
poder_wilcox_test <- apply(p_wilcox_test < .05, 2, mean)

# Plotar os resultados
plot(mu, poder_t_test, type = "b", col = "blue",
     xlab = "Média do Grupo de Teste (mu)",
     ylab = "Poder Empírico",
     main = "Poder dos Testes t e Wilcoxon sob Normalidade",
     ylim = c(0, 1))
lines(mu, poder_wilcox_test, type = "b", col = "red")
legend("topleft", legend = c("Teste t de Student", "Teste de Wilcoxon"),
       col = c("blue", "red"), lty = 1, pch = 1)
grid()



sdlog_control <- 0.4
sdlog_test <- 0.8  # maior variabilidade (heterocedasticidade)

# p-valor para cada simulação
p_t_test_outlier <- matrix(0, num_simulacoes, length(mu))
p_wilcox_test_outlier <- matrix(0, num_simulacoes, length(mu))

for(j in 1:length(mu)) {
  mu_j <- log(mu[j])  # mediana = exp(mu_j)
  
  for(i in 1:num_simulacoes) {
    # Grupo controle (mediana = 10)
    x_control <- rlnorm(n, meanlog = log(10), sdlog = sdlog_control)
    
    # Grupo teste com assimetria maior (heterocedasticidade)
    x_test <- rlnorm(n, meanlog = mu_j, sdlog = sdlog_test)
    
    # Adiciona outliers ao grupo de teste (ex: 2 valores muito altos)
    x_test[sample(1:n, 2)] <- x_test[sample(1:n, 2)] * 10
    
    # Teste t para duas amostras com variâncias diferentes (Welch)
    p_t_test_outlier[i, j] <- t.test(x_test, x_control, var.equal = TRUE)$p.value
    
    # Teste de Wilcoxon para duas amostras
    p_wilcox_test_outlier[i, j] <- wilcox.test(x_test, x_control)$p.value
  }
}

# Calcular o poder empírico (proporção de p-valores < 0.05)
poder_t_outlier <- apply(p_t_test_outlier < 0.05, 2, mean)
poder_wilcox_outlier <- apply(p_wilcox_test_outlier < 0.05, 2, mean)

# Plotar os resultados
plot(mu, poder_t_outlier, type = "b", col = "blue",
     xlab = "Mediana Real do Grupo de Teste",
     ylab = "Poder Empírico",
     main = "Poder dos Testes t e Wilcoxon com Outliers e Heterocedasticidade",
     ylim = c(0, 1))
lines(mu, poder_wilcox_outlier, type = "b", col = "red")
legend("topleft", legend = c("Teste t de Student", "Teste de Wilcoxon"),
       col = c("blue", "red"), lty = 1, pch = 1)
grid()

# Vamos para os dados reais

dados <- read.csv("train.csv")

dados |> 
  filter(Sex != "I") |>
  ggplot(aes(x = Weight, fill = Sex)) +
  geom_density(alpha = .7, linewidth = .7) +
  theme_fivethirtyeight() +
  labs(
    title = "Distribuição dos dados de peso pelo sexo",
    x = "Peso"
  ) +
  scale_fill_manual(values = c("F" = "#780000", "M" = "#003049")) +
  theme(
    axis.title.x = element_text()
  )

dados |>
  filter(Sex == "F") |> 
  select(Weight) |> 
  qqPlot(
    xlab = "Quantis do Peso Feminino",
    main = "Q-Q Plot para Peso Feminino"
  )

dados |>
  filter(Sex != "M") |> 
  select(Weight) |> 
  qqPlot(
    xlab = "Quantis do Peso Masculino",
    main = "Q-Q Plot para Peso Masculino"
  )

dados <- dados |> 
  filter(Sex != "I") 

bartlett.test(dados$Weight, dados$Sex)

# Os dados não atendem aos cenários ideais do teste t

t.test(dados$Weight[dados$Sex == "M"], dados$Weight[dados$Sex == "F"], var.equal = T)

wilcox.test(dados$Weight[dados$Sex == "M"], dados$Weight[dados$Sex == "F"])

ggviolin(dados, x = "Sex", y = "Weight", fill = "Sex",
         palette = c("F" = "#780000", "M" = "#003049"), alpha = .9, width = .3, trim = F, add = "boxplot") +
  stat_compare_means(method = "t.test", label.x =  .6, label.y = 69) +
  stat_compare_means(method = "wilcox.test", label.x = .6, label.y = 65) +
  labs(title = "Peso dos caranguejos por sexo") +
  theme_fivethirtyeight()

tabela_descr <- dados |>
  group_by(Sex) |>
  summarise(
    Média = mean(Weight),
    Mediana = median(Weight),
    `Desvio Padrão` = sd(Weight),
    Total = n(),
    .groups = "drop"
  )

# Gerar saída em LaTeX com kableExtra
tabela_descr |>
  kable("latex", booktabs = TRUE, caption = "Estatísticas descritivas do peso por sexo dos caranguejos.") |>
  kable_styling(latex_options = c("hold_position", "striped", "scale_down"))
