# Contexto do Projeto: Pipeline End-to-End de Engenharia de Dados (DataSUS)

## Objetivo Geral

Construir um pipeline de engenharia de dados robusto, moderno e automatizado para extrair, tratar, transformar, testar e disponibilizar dados públicos de saúde do Brasil (DataSUS / SIH-SUS - Sistema de Informações Hospitalares) utilizando boas práticas de arquitetura em nuvem, governança e engenharia de software.

## Stack Tecnológica

- **Armazenamento / Data Lake**: AWS S3 (Bucket particionado) e AWS IAM (Gestão de Acessos).
- **Ingestão & Validação Inicial**: Python (PySUS, boto3, pandas).
- **Processamento**: Databricks Community ou AWS Databricks (Engine Spark).
- **Transformação & Modelagem**: dbt Core (dbt-databricks, dbt-expectations).
- **Orquestração**: Apache Airflow rodando via Docker (Astro CLI) + Astronomer Cosmos (integração Airflow-dbt).
- **Versionamento & DataOps**: Git, GitHub, GitHub Actions (CI/CD com sqlfluff e flake8).
- **Infraestrutura como Código (IaC)**: Terraform (opcional/diferencial para provisionar S3 e IAM).

## Arquitetura de Dados (Medallion Architecture)

- **Bronze** (`s3://.../bronze/`): Dados brutos extraídos do DataSUS via script Python, convertidos para formato Parquet de alta performance.
- **Silver** (`s3://.../silver/`): Dados limpos, desduplicados, com schemas padronizados e colunas convertidas (realizado via dbt no Databricks).
- **Gold** (`s3://.../gold/`): Modelagem dimensional (tabelas fato e dimensão, como `fato_internacoes`, `dim_municipio`, `dim_tempo`) e agregações prontas para análise de negócios.

## Qualidade de Dados (Multi-camadas)

- **Validação na Ingestão (Bronze)**: Função Python executada pelo Airflow checando volume mínimo (evita tabelas vazias) e presença de colunas obrigatórias da fonte.
- **Validação na Transformação (Silver/Gold)**: Testes declarativos no dbt (`unique`, `not_null`) e regras de domínio via `dbt-expectations` (ex: garantir que custos de internação são ≥ 0 e UFs são válidas). A falha em qualquer teste interrompe o pipeline.

## Governança, CI/CD e Visualização

- **Linhagem e Dicionário de Dados**: Geração automática da documentação interativa e do grafo visual de linhagem (`dbt docs generate`), publicável no GitHub Pages.
- **CI/CD no GitHub**: Workflow no GitHub Actions validando a formatação do SQL (`sqlfluff`) e a sintaxe do Python a cada Pull Request na branch principal.

## Roteiro Sequencial de Execução

1. **Setup AWS & Git**: Criar repositório Git, bucket S3 com as pastas `bronze/`, `silver/`, `gold/` e usuário IAM.
2. **Ingestão Python**: Desenvolver o script de extração usando PySUS e envio para o S3 com boto3.
3. **Orquestração Airflow**: Configurar projeto Airflow com Astro CLI e criar a DAG controlando a extração e a validação inicial.
4. **Setup Databricks & dbt**: Configurar cluster no Databricks, montar os caminhos do S3 e inicializar o projeto dbt local conectado ao Databricks.
5. **Modelagem dbt**: Escrever os modelos SQL para as camadas Silver e Gold, adicionando a camada de testes em arquivos `.yml`.
6. **Integração Airflow + dbt**: Usar o `astronomer-cosmos` na DAG para executar o dbt diretamente pelo Airflow.
7. **CI/CD e Docs**: Adicionar as Actions do GitHub e gerar a documentação estática do dbt.
