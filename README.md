# Comparação entre Testes Paramétricos e Não Paramétricos

Este projeto tem como objetivo **avaliar e comparar a eficiência do teste t de Student e do teste de Wilcoxon** (Mann-Whitney), por meio de **simulações e aplicação em dados reais**.

---

## ✳️ Objetivos

- Investigar o desempenho dos testes t e Wilcoxon em diferentes cenários.
- Avaliar o comportamento dos testes quando as suposições paramétricas são satisfeitas ou violadas.
- Aplicar os testes em dados reais e comparar os resultados.

---

## 🧪 Metodologia

### Simulações

- Foram geradas **1000 amostras aleatórias** para diferentes cenários:
  - Dados com distribuição normal e variâncias iguais.
  - Dados com assimetria, outliers e/ou heterocedasticidade.
- Ambos os testes foram aplicados a cada amostra.
- Foi estimada a **proporção de rejeição da hipótese nula** (poder empírico).
- Os resultados foram apresentados por meio de gráficos.

### Dados Reais

- Utilizou-se uma base de dados contendo pesos de caranguejos classificados por sexo (`F` e `M`).
- Verificou-se a normalidade e homogeneidade das variâncias com:
  - Teste de Shapiro-Wilk.
  - Teste de Bartlett.
- Aplicação dos testes t e Wilcoxon.
- Visualização dos resultados com boxplots e valores-p anotados.

---

## 📊 Resultados

- **Simulações** mostraram que o teste t é mais poderoso quando suas suposições são atendidas.
- **Teste de Wilcoxon** mostrou-se mais robusto quando há violações das suposições paramétricas.
- Nos dados reais, ambos os testes indicaram diferença significativa no peso entre sexos, mas o teste t violou pressupostos importantes.

Gráficos e tabelas descritivas estão incluídos no relatório final (`relatorio.pdf`).

---

## ✍️ Autor
Kauã Dias

Projeto para a disciplina de Inferência Estatística (2025)