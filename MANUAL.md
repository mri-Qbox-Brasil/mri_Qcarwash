# mri_Qcarwash — Manual

Lava-jato com partículas e rolos animados sincronizados entre os jogadores próximos, cobrando um valor por lavagem.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Configuração](#configuração)
4. [Locais de lava-jato](#locais-de-lava-jato)
5. [Funcionamento](#funcionamento)
6. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
7. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `ox_lib` | Sim | `lib.showTextUI` e `lib.callback` |
| `qb-core` | Sim | Único framework realmente implementado em `framework.lua`. O bloco de ESX existe no arquivo, mas está inteiramente comentado |

---

## Instalação

1. Copie a pasta `mri_Qcarwash` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure mri_Qcarwash
   ```
3. Confirme `Config.Framework = 'qbcore'` no `config.lua`.
4. Não há SQL nem itens de inventário a cadastrar.

---

## Configuração

Arquivo: `config.lua`.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.Framework` | string | Sim | Framework usado. Na prática só `'qbcore'` funciona — o bloco `'esxlegacy'` do `framework.lua` está comentado |
| `Config.button` | tabela `{string, number, number}` | Sim | Texto do TextUI (o `%s` é substituído pelo custo), índice do pad e control key da tecla de interação. Padrão: tecla `E` (control `38`) |
| `Config.only_dirty_vehicles` | bool | Sim | Quando `true`, só permite lavar veículos com `GetVehicleDirtLevel` acima de `0.1` |
| `Config.cost` | number | Sim | Valor cobrado por lavagem. Padrão: `30` |
| `Config.cash_account_name` | string | Sim | Nome da conta de dinheiro vivo. Padrão: `cash` |
| `Config.bank_account_name` | string | Sim | Nome da conta bancária, usada como fallback quando não há dinheiro vivo suficiente. Padrão: `bank` |
| `Config.double_clean` | bool | Sim | Quando `true`, as partículas percorrem o veículo de ida e volta, dobrando a duração da lavagem |
| `Config.show_all_blips` | bool | Sim | Quando `true`, cria um blip fixo para cada local com `show_blip = true`. Quando `false`, mantém um único blip no lava-jato mais próximo, atualizado a cada 10s |
| `Config.locations` | array | Sim | Lista de lava-jatos. Ver abaixo |

---

## Locais de lava-jato

Cada entrada de `Config.locations` aceita:

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `name` | string | Sim | Nome exibido no blip. Locais com o mesmo `name` ficam empilhados na legenda do mapa |
| `location` | `vector3` | Sim | Coordenadas do ponto de lavagem |
| `use_props` | bool | Sim | Quando `true`, spawna os dois rolos giratórios (`prop_carwash_roller_vert`) nas laterais do veículo |
| `show_blip` | bool | Sim | Se este local gera blip. Depende também de `Config.show_all_blips` |

Os três locais que vêm no config são Strawberry, Little Seoul e Paleto — todos com `show_blip = false` por padrão, ou seja, sem blip no mapa.

---

## Funcionamento

1. O jogador precisa estar **no banco do motorista** de um veículo e a menos de 2 metros de um ponto de `Config.locations`.
2. O TextUI de `Config.button` aparece; ao pressionar a tecla configurada, o cliente pede ao servidor a cobrança via `lib.callback` (`carwash:CanPurchaseCarWash`).
3. O servidor tenta debitar `Config.cost` primeiro da conta `cash_account_name`, depois da `bank_account_name`. Se nenhuma tiver saldo, a lavagem é recusada.
4. Confirmado o pagamento, o veículo é congelado e o servidor faz broadcast das partículas para **todos os clientes**, de forma que quem estiver por perto veja a lavagem.
5. Ao terminar, apenas o cliente que pagou aplica `SetVehicleDirtLevel(veh, 0.0)` e `WashDecalsFromVehicle`, descongela o veículo e recebe a notificação de conclusão.

---

## Entrypoints para outros recursos

### Evento de servidor

Repassa as partículas de lavagem para todos os clientes. Não faz cobrança nem validação.

```lua
TriggerServerEvent('carwash:DoVehicleWashParticles', VehToNet(vehicle), use_props)
```

### Callback de servidor

Tenta debitar `Config.cost` do jogador (cash e depois bank) e retorna `true` em caso de sucesso.

```lua
local paid = lib.callback.await('carwash:CanPurchaseCarWash')
```

### Evento de cliente

Roda a animação de partículas e rolos sobre o veículo indicado. `washer` é o server id de quem pagou — só esse jogador tem o veículo efetivamente limpo ao final.

```lua
TriggerClientEvent('carwash:DoVehicleWashParticles', -1, vehNet, washer, use_props)
```

---

## Estrutura de arquivos

```
mri_Qcarwash/
├── client.lua        — detecção de proximidade, TextUI, partículas, rolos e blips
├── server.lua        — callback de cobrança e broadcast das partículas
├── framework.lua     — wrappers de notificação, callback e dinheiro (QBCore; bloco ESX comentado)
├── config.lua        — framework, custo, contas, comportamento e lista de locais
└── fxmanifest.lua
```
