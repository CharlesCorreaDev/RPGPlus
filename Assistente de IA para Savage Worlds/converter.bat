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

:: 2. Instala o markitdown COM SUPORTE A PDF (agora com a saida visivel para debug)
echo [1/3] Instalando dependencias (incluindo suporte a PDF)...
echo Isso pode levar alguns segundos. Aguarde...
echo.

python -m pip install --upgrade pip
python -m pip install --upgrade "markitdown[pdf]"

:: Se a instalacao com [pdf] falhar (comum no Python 3.14), tenta instalar as libs de PDF manualmente
if !errorlevel! neq 0 (
    echo.
    echo [AVISO] A instalacao com [pdf] falhou. Tentando instalar as dependencias de PDF manualmente...
    python -m pip install pypdf pdfminer.six pdfplumber
)

:: 3. Verifica se o modulo markitdown foi instalado corretamente
python -c "import markitdown" >nul 2>nul
if !errorlevel! neq 0 (
    echo [ERRO] Falha ao instalar o modulo 'markitdown'.
    goto :fim
)
echo.
echo       Dependencias OK!
echo.

:: 4. Verifica se existem arquivos PDF na pasta atual
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

:: 6. Varre a pasta e realiza a conversão
echo [3/3] Iniciando a conversao dos PDFs...
echo ---------------------------------------

for %%f in (*.pdf) do (
    echo Convertendo: %%~nxf ...
    
    python -m markitdown "%%f" > "%PASTA_DESTINO%\%%~nf.md"
    
    if !errorlevel! equ 0 (
        echo       [OK] %%~nf.md gerado com sucesso.
    ) else (
        echo       [FALHA] Erro ao converter %%~nxf.
    )
)

echo ---------------------------------------
echo Processo concluido!

:fim
echo.
pause
