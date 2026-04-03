# 04 — Pseudo Instruction 教學

Pseudo instruction 是組譯器提供的「語法糖」，沒有對應的硬體 opcode，組譯時自動展開成一或兩條真實指令。

---

## `li` — Load Immediate（載入立即數）

**語法**：`li rd, imm`

| 情況 | 條件 | 展開 |
|------|------|------|
| 小值 | -2048 ≤ imm ≤ 2047 | `addi rd, x0, imm` |
| 大值 | 超出 12-bit | `lui rd, imm[31:12]` + `addi rd, rd, imm[11:0]` |

**範例**：

```asm
li t0, 5
# → addi t0, x0, 5         (12-bit 足夠)

li t0, 0xFFFFFFFF           # = -1
# → addi t0, x0, -1        (0xFFF 符號擴展 = -1，12-bit 足夠)

li t0, 0x12345678
# → lui  t0, 0x12345        (高 20 bits)
#   addi t0, t0, 0x678      (低 12 bits)
```

> **注意（符號補償）**：若 `imm[11] = 1`，`addi` 符號擴展後結果會比預期少 1，
> 組譯器自動將 `lui` 的值 +1 補償。
>
> ```asm
> li t0, 0x12345800
> # → lui  t0, 0x12346    ← 多加 1
> #   addi t0, t0, -0x800  ← 0x800 符號擴展 = -2048
> ```

---

## `la` — Load Address（載入符號位址）

**語法**：`la rd, symbol`

程式位址在 link 時才確定，`la` 用 PC-relative 計算：

```asm
la a0, _test_start
# → auipc a0, delta[31:12]    (PC + 高位偏移)
#   addi  a0, a0, delta[11:0] (再加低位偏移)
```

- `auipc`：`rd = PC + (imm << 12)`（PC-relative 上位載入）
- 組合後：`rd = PC + offset_to_symbol`

---

## `j` — Unconditional Jump（無條件跳轉，不存返回位址）

**語法**：`j label`

```asm
j fill_block
# → jal x0, fill_block    (rd = x0，丟棄返回位址)
```

- `jal x0, offset`：純粹 goto，不保存 PC+4

---

## `jal` — Jump and Link（跳轉並保存返回位址）

**語法**：`jal label`（省略 rd 時預設 rd = ra = x1）

```asm
jal fill_block
# → jal ra, fill_block    (ra = PC+4，然後跳到 fill_block)
```

- 呼叫函式時使用：返回位址存進 `ra`（x1），20-bit 有符號 PC-relative 偏移，範圍 ±1MB

---

## `ret` — Return（函式返回）

**語法**：`ret`

```asm
ret
# → jalr x0, ra, 0    (PC = ra，rd = x0 丟棄)
```

- `jalr`（I-type）：`PC = rs1 + imm`，`rd = PC+4`
- `ret` = `jalr x0, x1, 0`：跳回 `ra`，不儲存返回位址

---

## 其他常用 Pseudo Instructions

### `mv` — Move（複製暫存器值）

```asm
mv a0, t0
# → addi a0, t0, 0
```

### `nop` — No Operation

```asm
nop
# → addi x0, x0, 0    (寫入 x0 永遠無效)
```

### `not` / `neg` — 位元反轉 / 取負

```asm
not rd, rs
# → xori rd, rs, -1    (與全 1 做 XOR)

neg rd, rs
# → sub rd, x0, rs     (0 - rs)
```

---

## 完整對照表（setup.S 用到的）

| Pseudo | 展開 | 說明 |
|--------|------|------|
| `li rd, imm`  | `addi rd, x0, imm` 或 `lui+addi` | 載入任意常數 |
| `la rd, sym`  | `auipc rd, hi` + `addi rd, rd, lo` | 載入符號位址（PC-relative） |
| `j label`     | `jal x0, label` | 無條件跳轉，不存返回位址 |
| `jal label`   | `jal ra, label` | 呼叫函式，ra = PC+4 |
| `ret`         | `jalr x0, ra, 0` | 函式返回，跳回 ra |
| `mv rd, rs`   | `addi rd, rs, 0` | 複製暫存器 |
| `nop`         | `addi x0, x0, 0` | 空操作 |
| `not rd, rs`  | `xori rd, rs, -1` | 位元反轉 |
| `neg rd, rs`  | `sub rd, x0, rs` | 取負 |
