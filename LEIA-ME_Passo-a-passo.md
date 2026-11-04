# Configurar PJe com certificado A3 (token) no notebook

Pacote montado em 04/11/2026. Fontes: manual oficial do PJeOffice Pro (https://pjeoffice.trf3.jus.br/pjeoffice-pro/docs/userguide.html), TRT3 e orientações dos tribunais. Plano conferido em conjunto com o Codex.

## O que você precisa
1. **PJeOffice Pro 2.5.16u** (x64) — já está na pasta `Instaladores`. O Java vem embutido: **não instale Java separado**.
2. **Driver (middleware) do token** — depende do MODELO. Veja o nome impresso no token (SafeNet 5110, IDPrime, Watchdata, etc.) e baixe na certificadora que emitiu o certificado. SafeNet (TRT3): https://portal.trt3.jus.br/internet/servicos/pje/pje-em-casa-1/downloads/downloads?DownloadSafeNet
3. **Navegador atualizado** (Chrome, Edge ou Firefox).
4. Token com o certificado A3 e a senha (PIN).

## Passo a passo (nesta ordem)

### 0. Antes de começar
- Token **desconectado** do USB.
- Se houver PJeOffice antigo: desinstale (Configurações > Aplicativos). Guia: https://portal.trt3.jus.br/internet/servicos/pje/pje-em-casa-1/tutoriais-de-apoio-v2/pjeoffice-remover-versao-instalada
- Feche os navegadores.

### 1. Instalar o driver do token
1. Execute o instalador do middleware do SEU modelo (para SafeNet: `SafeNetAuthenticationClient-x64`).
2. Next > aceitar licença > Next > Install > Sim (UAC) > Finish. Reinicie se pedir.
3. **Só agora** conecte o token no USB e aguarde o Windows reconhecer.
4. Abra o gerenciador do driver (ex.: "SafeNet Authentication Client Tools") e confirme que o token e o certificado aparecem. **Se não aparecer aqui, não adianta seguir:** teste outra porta USB, veja o Gerenciador de Dispositivos, confira se o driver é x64.

### 2. Instalar o PJeOffice Pro
1. Duplo clique em `pjeoffice-pro-v2.5.16u-windows_x64.exe`, aceite o UAC.
2. Instalar > deixe marcado "Iniciar o PJeOffice Pro" > Concluir.
3. Confirme o ícone na bandeja (perto do relógio; clique na seta ^ se oculto).

### 3. Configurar o token no PJeOffice
1. Clique no ícone da bandeja > abra o PJeOffice Pro.
2. Menu **Configurar certificado A3** > **Busca automática**. Deve achar a biblioteca do driver.
3. Se não achar: **Localizar…** e aponte a biblioteca PKCS#11 do fabricante. Exemplos comuns:
   - SafeNet: `C:\Windows\System32\eToken.dll` ou `eTPKCS11.dll`
   - Outros: veja o manual do fabricante
   - A biblioteca precisa ser x64, igual ao PJeOffice.
4. Em **Segurança > Sites autorizados**, confirme que o domínio do tribunal está autorizado (aparece um pedido de autorização na primeira vez).

### 4. Navegador
- Ao entrar no PJe, se o Chrome pedir permissão de **acesso à rede local / dispositivos**, clique em **Permitir**.
- Permita pop-ups do site do PJe.
- Não é necessário liberar portas manualmente. (Testado: o PJeOffice Pro escuta localmente em 8800 e 8801; só precisa estar aberto.)
- Instalação silenciosa (opcional): `pjeoffice-pro-v2.5.16u-windows_x64.exe -q` instala em `C:\Program Files\PJeOffice Pro` e já abre o programa.

### 5. Testar (3 validações)
1. Token e certificado visíveis no gerenciador do driver.
2. Certificado listado no PJeOffice.
3. Login e assinatura de um ato no PJe do tribunal. Escolha "PJeOffice" como assinador quando houver a opção.

## Certificados raiz
- A cadeia do **seu certificado** (raiz + intermediárias da autoridade certificadora): normalmente o driver/certificadora instala. Se der erro de cadeia, baixe em https://www.gov.br/iti/pt-br/assuntos/repositorio/cadeias-da-icp-brasil
- **Não** instale ISRG Root X1 / R3 do aviso antigo do TJDFT: é de 2021 e o R3 expirou em set/2025. Só atualize o navegador.
- **Não** instale Java 8 nem Firefox 102 ESR (listas antigas do TRT3).

## Problemas comuns
| Sintoma | O que fazer |
|---|---|
| Token não aparece no gerenciador | Outra porta USB; Gerenciador de Dispositivos; driver correto para o modelo e x64 |
| Driver vê, PJeOffice não | Configurar certificado A3 > Busca automática / Localizar o `.dll` |
| Site diz PJeOffice indisponível | PJeOffice aberto? Permissão de rede local no navegador? Site autorizado? |
| Erro de cadeia / certificado inválido | Instalar cadeia ICP-Brasil; ver validade do certificado |
| Falha após atualização do Windows (a partir de out/2025) | Atualizar middleware/PJeOffice; não desinstalar update |
| Token com 2 certificados | Manter só 1 gravado no token (orientação do TJMG) |

## Diagnóstico
Se algo falhar, rode `Diagnostico-PJe.ps1` (botão direito > Executar com PowerShell) e envie o arquivo `diagnostico-pje.txt` gerado na área de trabalho.

## Download do instalador (não está no repositório por causa do tamanho)
- PJeOffice Pro 2.5.16u (Windows x64): https://pje-office.pje.jus.br/pro/pjeoffice-pro-v2.5.16u-windows_x64.exe
- SHA-256 esperado: `8237999EFF5313607DAF53558B4A0B8F3ABA4DA670C6438EE34EB25120B45BC4`
  (confira com `Get-FileHash .\pjeoffice-pro-v2.5.16u-windows_x64.exe`)

- Driver SafeNet Authentication Client 10.3 (x64): https://portal.trt3.jus.br/internet/servicos/pje/pje-em-casa-1/downloads/arquivos/safenet_authentication_client-x64-10-3.msi
  SHA-256: `18339FCC96C34225FF8E462908EA109F82487F8CF845B1473B0F7D56AF588CC0` (assinado digitalmente por GlobalSign/Thales — Status Valid)
  Precisa de administrador: dê duplo clique e aceite o UAC (a instalação silenciosa sem elevação falha com erro 1603).
  Biblioteca PKCS#11 instalada: `C:\Windows\System32\eTPKCS11.dll`
- Versão 32 bits do PJeOffice: https://pje-office.pje.jus.br/pro/pjeoffice-pro-v2.5.16u-windows_x32.exe
