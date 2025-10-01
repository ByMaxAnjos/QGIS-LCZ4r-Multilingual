##LCZ4r Funções de Configuração=group
##Atualizar LCZ4r=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterBoolean|Upgrade|Atualizar o pacote R LCZ4r|False
##QgsProcessingParameterFile|in_folder|Selecione uma pasta para armazenar o seu script LCZ4r|1
##QgsProcessingParameterEnum|Select_Language|Selecione um idioma de sua preferência|Inglês;Português;Chinês;Espanhol;Alemão;Francês|-1|0|False

if(Upgrade){
    if(!require(remotes)) install.packages("remotes")
    options(timeout = 300)
    # Sempre use upgrade = "never" para evitar conflitos de dependências no QGIS
    remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
}

Languages <- c("English", "Portuguese", "Chinese", "Spanish", "Deutsch", "French")

# Obtém o idioma selecionado (o QGIS retorna o índice, então somamos 1)
if (!is.null(Select_Language) && Select_Language >= 0 && Select_Language < length(Languages)) {
    result_language <- Languages[Select_Language + 1]
} else {
    stop("Invalid language selection. Please choose the correct language")
}

# Define o nome da pasta com base no idioma
folder_name <- paste0(result_language, "_LCZ4r")
base_url <- "https://raw.githubusercontent.com/ByMaxAnjos/QGIS-LCZ4r-Multilingual/master/"

# --- 2. DEFINIÇÃO CENTRALIZADA DOS ARQUIVOS (MAIS EFETIVO) ---

# Define a lista de funções (.rsx) apenas UMA VEZ.
base_scripts <- c(
    "lcz_get_map.rsx", "lcz_get_map_euro.rsx", "lcz_get_map_usa.rsx", "lcz_get_map_generator.rsx",
    "lcz_cal_area.rsx", "lcz_plot_map.rsx", "lcz_get_parameters.rsx", "lcz_plot_parameters.rsx", "lcz_ts.rsx",
    "lcz_uhi_intensity.rsx", "lcz_anomaly.rsx", "lcz_interp_map.rsx", "lcz_anomaly_map.rsx", "lcz_plot_interp.rsx",
    "lcz_interp_eval.rsx", "lcz_upgrade.rsx", "lcz_install.rsx"
)

# Cria a lista completa, prefixando o idioma
script_files <- paste0(result_language, "_", base_scripts)

# --- 3. EXECUÇÃO ROBUSTA ---

# Cria o diretório se não existir
dir.create(in_folder, recursive = TRUE, showWarnings = FALSE)

for (script in script_files) {
    script_url <- paste0(base_url, folder_name, "/", script)
    dest_file <- file.path(in_folder, script)
    temp_dest_file <- file.path(in_folder, paste0("temp_", script))

    tryCatch({
        # 1. Tenta baixar o script para o arquivo temporário
        download.file(script_url, destfile = temp_dest_file, mode = "wb", quiet = TRUE)

        # 2. Se o download foi bem-sucedido, substitui o arquivo antigo (se necessário)
        if (file.exists(dest_file) && !grepl("upgrade.rsx", script, ignore.case = TRUE)) {
            file.remove(dest_file)
        }
        
        # Move o arquivo temporário para o destino final
        file.rename(temp_dest_file, dest_file) 
        
    }, error = function(e) {
        warning(paste("Falha ao baixar ou instalar o script:", script, "Erro:", conditionMessage(e)))
    }, finally = {
        # 3. Garante que o arquivo temporário seja removido, mesmo em caso de erro
        if (file.exists(temp_dest_file)) {
            file.remove(temp_dest_file)
        }
    })
}

#' Upgrade: Se a opção "Atualizar o pacote R LCZ4r" estiver selecionada, as Funções Gerais e Locais do pacote LCZ4r serão reinstaladas. Isso vai garantir que você esteja usando as versões mais recentes dessas funções, que podem incluir atualizações e melhorias importantes.</p><p>
#' in_folder: Especifique o diretório para onde os scripts serão baixados a partir do repositório oficial.</p><p>
#'          : Observe que este diretório específico deve ser o mesmo que a <b>pasta de scripts R</b> (Configurações > Opções... > Processamento > Provedores > R).
#' ALG_DESC: Esta função permite atualizar o pacote LCZ4r para a versão mais recente e escolher um Plugin de Idioma de sua preferência. Atualizações regulares garantem que você se beneficie dos recursos mais recentes, como correções de bugs e melhorias de desempenho.</p><p>
#'         : Para realizar a primeira instalação, siga os passos neste guia: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Instalando o LCZ4r no QGIS</a></p<p>
#'         : Para selecionar um idioma, consulte quais estão disponíveis em: <a href='https://bymaxanjos.github.io/LCZ4r/articles/examples.html#multilingual-plugins'>Plugin Multilíngue</a></p<p>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>
#' ALG_VERSION: 0.1.1


