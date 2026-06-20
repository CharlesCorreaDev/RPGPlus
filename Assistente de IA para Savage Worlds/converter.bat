@echo off
setlocal enabledelayedexpansion

:: Força o console do Windows a usar UTF-8 (Codepage 65001)
chcp 65001 >nul

:: Força o Python a usar UTF-8 para IO, mesmo no Windows
set PYTHONIOENCODING=utf-8

:: Configuração de variáveis
set "PASTA_DESTINO=Markdown_Convertidos"

:: 1. Verifica se o Python está disponível no PATH
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] Python nao encontrado no sistema.
    goto :fim
)

:: 2. Atualiza o pip em background
python -m pip install --upgrade pip >nul 2>nul

:: 3. Verifica se o modulo markitdown funciona
python -m markitdown --version >nul 2>nul
if %errorlevel% neq 0 (
    echo [AVISO] 'markitdown' nao encontrado. Tentando instalar via pip...
    python -m pip install markitdown
    
    python -m markitdown --version >nul 2>nul
    if !errorlevel! neq 0 (
        echo [ERRO] Nao foi possivel executar o 'markitdown'.
        goto :fim
    )
)

:: 4. Verifica se existem arquivos PDF na pasta atual
dir *.pdf >nul 2>nul
if %errorlevel% neq 0 (
    echo [AVISO] Nenhum arquivo .pdf encontrado na pasta atual.
    goto :fim
)

:: 5. Cria a pasta de destino se ela não existir
if not exist "%PASTA_DESTINO%" (
    echo Criando pasta %PASTA_DESTINO%...
    mkdir "%PASTA_DESTINO%"
)

:: 6. Varre a pasta e realiza a conversão
echo.
echo Iniciando a conversao dos PDFs com suporte a UTF-8...
echo ---------------------------------------

for %%f in (*.pdf) do (
    echo Convertendo: %%f ...
    
    :: Executa chamando o modulo com encoding garantido
    python -m markitdown "%%f" > "%PASTA_DESTINO%\%%~nf.md"
    
    if !errorlevel! equ 0 (
        echo [OK] %%~nf.md gerado com sucesso.
    ) else (
        echo [FALHA] Erro ao converter %%f.
    )
    echo ---------------------------------------
)

echo Processo concluido!

:fim
pause
