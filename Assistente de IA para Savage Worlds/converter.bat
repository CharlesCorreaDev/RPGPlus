@echo off
setlocal enabledelayedexpansion

:: Garante que o script rode na pasta onde ele está localizado
cd /d "%~dp0"

:: Força o console do Windows a usar UTF-8 (Codepage 65001)
chcp 65001 >nul

:: Força o Python a usar UTF-8 para IO
set PYTHONIOENCODING=utf-8

:: Configuração de variáveis
set "PASTA_DESTINO=Markdown_Convertidos"

echo =======================================
echo    CONVERSOR DE PDF PARA MARKDOWN
echo =======================================
echo.

:: 1. Verifica se o Python está disponível no PATH
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] Python nao encontrado no sistema.
    goto :fim
)

:: 2. Atualiza o pip e instala o markitdown silenciosamente
echo [1/3] Verificando e instalando dependencias...
python -m pip install --upgrade pip >nul 2>nul
python -m pip install --upgrade markitdown >nul 2>nul

:: 3. Verifica se o modulo markitdown foi instalado corretamente (verificação rapida)
python -c "import markitdown" >nul 2>nul
if !errorlevel! neq 0 (
    echo [ERRO] Falha ao instalar o modulo 'markitdown'.
    goto :fim
)
echo       Dependencias OK!
echo.

:: 4. Verifica se existem arquivos PDF na pasta atual (onde o bat está)
dir /b /a-d *.pdf >nul 2>nul
if %errorlevel% neq 0 (
    echo [AVISO] Nenhum arquivo .pdf encontrado nesta pasta.
    goto :fim
)

:: 5. Cria a pasta de destino se ela não existir
if not exist "%PASTA_DESTINO%" (
    echo [2/3] Criando pasta de destino: %PASTA_DESTINO%
    mkdir "%PASTA_DESTINO%"
) else (
    echo [2/3] Pasta de destino ja existe.
)
echo.

:: 6. Varre a pasta e realiza a conversão imediatamente
echo [3/3] Iniciando a conversao dos PDFs...
echo ---------------------------------------

for %%f in (*.pdf) do (
    echo Convertendo: %%~nxf ...
    
    :: Executa a conversão redirecionando a saida para o arquivo .md
    python -m markitdown "%%f" > "%PASTA_DESTINO%\%%~nf.md"
    
    if !errorlevel! equ 0 (
        echo       [OK] %%~nf.md gerado com sucesso.
    ) else (
        echo       [FALHA] Erro ao converter %%~nxf.
    )
)

echo ---------------------------------------
echo Processo concluido com sucesso!

:fim
echo.
pause
