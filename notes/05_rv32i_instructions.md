# 05 — RV32I 指令彙整與關鍵觀念

## prog0 涉及的指令（依類型）

| 類型 | 指令 | 說明 |
|------|------|------|
| R-type | ADD, SUB, SLL, SLT, SLTU, XOR | 暫存器對暫存器運算 |
| I-type | ADDI, LW, JALR | 立即數運算、載入 word、間接跳轉 |
| U-type | LUI, AUIPC | 上位立即數（高 20 bits） |
| S-type | SW | 儲存 word |
| J-type | JAL | 直接跳轉並連結（呼叫函式） |
| B-type | BGEU | 條件分支（無符號大於等於） |

---

## 指令格式快速查表

| 指令 | 格式 | 計算 |
|------|------|------|
| ADD  | R | rd = rs1 + rs2 |
| SUB  | R | rd = rs1 - rs2 |
| SLL  | R | rd = rs1 << rs2[4:0] |
| SLT  | R | rd = (rs1 < rs2) ? 1 : 0（signed） |
| SLTU | R | rd = (rs1 < rs2) ? 1 : 0（unsigned） |
| XOR  | R | rd = rs1 ^ rs2 |
| ADDI | I | rd = rs1 + imm（sign-ext 12-bit） |
| LW   | I | rd = Memory[rs1 + imm]（32-bit） |
| JALR | I | PC = rs1 + imm; rd = PC+4 |
| LUI  | U | rd = imm << 12 |
| AUIPC | U | rd = PC + (imm << 12) |
| SW   | S | Memory[rs1 + imm] = rs2 |
| JAL  | J | rd = PC+4; PC = PC + offset（±1MB） |
| BGEU | B | if (rs1 >= rs2, unsigned) PC += offset |

---

## 關鍵觀念

### 1. `li` 是 pseudo-instruction
- 小值 → `addi rd, x0, imm`
- 大值 → `lui + addi`
- 若低 12-bit MSB 為 1，組譯器自動將 `lui` 的值 +1 補償符號擴展

### 2. `la` 是 pseudo-instruction
- 載入 symbol 位址 → `auipc + addi`（PC-relative）
- 位址在 link 階段才確定，因此用相對方式計算

### 3. `ret` = `jalr x0, ra, 0`
- 跳回 `ra` 所指位址
- `rd = x0`：丟棄返回位址（不保存）

### 4. BSS 需手動清零
- C 語言規範：未初始化全域變數初始值為 0
- 硬體不保證記憶體初始值，startup code 必須在進 `main` 前清零

### 5. `_sim_end` 在 dmem 最後 4 bytes（0xFFFC）
- testbench 以此位址判斷模擬結束
- 寫入 `0xFFFFFFFF`（= li rd, -1）即可觸發

### 6. fill_block 用 BGEU（無符號比較）
- 記憶體位址是無符號整數
- 有符號比較（BGE）在位址 > 0x7FFFFFFF 時結果錯誤
- BGEU 確保比較永遠正確

---

## main.S — prog0 測試概要

main 依序測試各指令，每組最後用 `sw t0, 0(s0); addi s0, s0, 4` 將結果存入 `_test_start` 陣列：

| 測試段 | 指令 | 說明 |
|--------|------|------|
| `add`  | ADD  | 整數加法 |
| `sub`  | SUB  | 整數減法 |
| `sll`  | SLL  | 邏輯左移 |
| `slt`  | SLT  | 有符號比較 |
| `sltu` | SLTU | 無符號比較 |
| ...    | XOR, LUI, AUIPC, LW/SW, JALR 等 | ... |

Pass 條件：`result_rtl.txt` 內容 = `golden.hex`（prog0 預期輸出 `51,51`）
