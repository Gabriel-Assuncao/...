##########################################################################

# Limpando arquivos armazenados na memória
rm(list=ls(all=TRUE))

# Definindo limite de memória para compilação do programa
aviso <- getOption("warn")
options(warn=-1)
memory.limit(size=50000)
options(warn=aviso)
rm(aviso)

# Definindo tempo de espera para obtenção de resposta do servidor
aviso <- getOption("warn")
options(warn=-1)
options(timeout=600)
options(warn=aviso)
rm(aviso)

# Definindo opção de codificação dos caracteres e linguagem
aviso <- getOption("warn")
options(warn=-1)
options(encoding="latin1")
options(warn=aviso)
rm(aviso)

# Definindo opção de exibição de números sem representação em exponencial
aviso <- getOption("warn")
options(warn=-1)
options(scipen=999)
options(warn=aviso)
rm(aviso)

# Definindo opção de repositório para instalação dos pacotes necessários
aviso <- getOption("warn")
options(warn=-1)
options(repos=structure(c(CRAN="https://cran.r-project.org/")))
options(warn=aviso)
rm(aviso)

# Definindo diretório de trabalho
caminho <- getwd()
setwd(dir=caminho)

# Carregando pacotes necessários para obtenção da estimativa desejada
if("PNADcIBGE" %in% rownames(installed.packages())==FALSE)
{
  install.packages(pkgs="PNADcIBGE", dependencies=TRUE)
}
library(package="PNADcIBGE", verbose=TRUE)
if("survey" %in% rownames(installed.packages())==FALSE)
{
  install.packages(pkgs="survey", dependencies=TRUE)
}
library(package="survey", verbose=TRUE)

# Obtendo microdados do período de referência para cálculo da estimativa
variaveis_selecionadas <- c("V1022","V2005",sprintf("S170%02d", seq(1:14)),"SD17001")
pnadc_anual_trimestre <- PNADcIBGE::get_pnadc(year=2023, topic=4, vars=variaveis_selecionadas)

# Criando variáveis auxiliares para cálculo da estimativa
pnadc_anual_trimestre$variables <- transform(pnadc_anual_trimestre$variables, Pais=as.factor("Brasil"))
pnadc_anual_trimestre$variables$Pais <- factor(x=pnadc_anual_trimestre$variables$Pais, levels=c("Brasil"))
pnadc_anual_trimestre$variables <- transform(pnadc_anual_trimestre$variables, GR=as.factor(ifelse(substr(UPA, start=1, stop=1)=="1","Norte",ifelse(substr(UPA, start=1, stop=1)=="2","Nordeste",ifelse(substr(UPA, start=1, stop=1)=="3","Sudeste",ifelse(substr(UPA, start=1, stop=1)=="4","Sul",ifelse(substr(UPA, start=1, stop=1)=="5","Centro-Oeste",NA)))))))
pnadc_anual_trimestre$variables$GR <- factor(x=pnadc_anual_trimestre$variables$GR, levels=c("Norte","Nordeste","Sudeste","Sul","Centro-Oeste"))

# Calculando total e proporção de domicílios de acordo com segurança alimentar (SIDRA - Tabela 9552)
print(x=total_seguranca_alimentar <- survey::svybys(formula=~SD17001, bys=~Pais+GR+V1022, design=subset(pnadc_anual_trimestre, V2005=="Pessoa responsável pelo domicílio"), FUN=svytotal, vartype=c("se","cv"), keep.names=FALSE, na.rm=TRUE))
print(x=proporcao_seguranca_alimentar <- survey::svybys(formula=~SD17001, bys=~Pais+GR+V1022, design=subset(pnadc_anual_trimestre, V2005=="Pessoa responsável pelo domicílio"), FUN=svymean, vartype=c("se","cv"), keep.names=FALSE, na.rm=TRUE))

##########################################################################