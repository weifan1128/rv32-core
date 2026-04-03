# 03 — fill_block 副函式

## 功能

用給定的值（`a2`）填充一段記憶體範圍（`a0` 到 `a1`，以 word 為單位）。

---

## 原始碼

```asm
fill_block:
  bgeu a0, a1, fb_end   # if (a0 >= a1) goto end  ← 終止條件
  sw   a2, 0(a0)        # Memory[a0] = a2
  addi a0, a0, 4        # a0 += 4（word 步進）
  j    fill_block        # 繼續迴圈
fb_end:
  ret                   # return（= jalr x0, ra, 0）
```

---

## 呼叫慣例（呼叫前設定的暫存器）

| 暫存器 | 意義 |
|--------|------|
| `a0`  | 起始位址（inclusive） |
| `a1`  | 結束位址 - 4（最後一個合法 word 的位址） |
| `a2`  | 填充值 |

---

## 為什麼 a1 = end - 4？

`fill_block` 的終止條件是 `bgeu a0, a1`（無符號大於等於）：
- 當 `a0 == a1` 時迴圈停止，所以 **a0 = a1 的那個 word 不會被寫入**
- 因此 a1 要設成最後一個**要寫入**的 word 的位址

```
想填充 [0x8000, 0x8100) 共 64 words：
  a0 = 0x8000  ← 起始（含）
  a1 = 0x8100 - 4 = 0x80FC  ← 最後一個合法 word
```

---

## 為什麼用 BGEU（無符號）？

記憶體位址本質上是**無符號**整數。若用有符號比較（BGE），當位址超過 0x7FFFFFFF 時 MSB 為 1，有符號解讀變成負數，比較結果錯誤。

使用 BGEU 確保位址比較永遠正確。

---

## 涉及的指令

| 指令 | 類型 | 說明 |
|------|------|------|
| `BGEU` | B-type | Branch if ≥（unsigned），控制迴圈終止 |
| `SW`   | S-type | Store word，寫入記憶體 |
| `ADDI` | I-type | 加立即數，遞增指標（+4） |
| `JAL`（j） | J-type | 無條件跳回迴圈頭（`jal x0, offset`） |
| `JALR`（ret） | I-type | 函式返回（`jalr x0, ra, 0`） |
