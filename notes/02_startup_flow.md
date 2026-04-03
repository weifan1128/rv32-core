# 02 — 啟動流程（setup.S → _start）

## 流程總覽

```
_start (setup.S)
  ├── 1. 清零所有暫存器 x1~x31
  ├── 2. 設定 gp (global pointer)
  ├── 3. 清零 BSS 區段      → fill_block(__bss_start,  __bss_end-4,  0)
  ├── 4. 清零 SBSS 區段     → fill_block(__sbss_start, __sbss_end-4, 0)
  ├── 5. 清零 Stack 區段    → fill_block(_stack_end,   __stack-4,    0)
  ├── 6. 設定 sp (stack pointer)
  ├── 7. 清零測試結果區      → fill_block(_test_start,  _test_end-4,  0)
  ├── jal main             ← 跳進測試程式
  └── SystemExit:
      sw -1, _sim_end      ← 寫 0xFFFFFFFF，通知 testbench 結束模擬
      j dead_loop          ← 無限迴圈防止繼續執行
```

---

## 各步驟說明

### 1. 清零所有暫存器（x1~x31）

```asm
li x1, 0
li x2, 0
...
li x31, 0
```

- `x0` 永遠為 0（硬體連接），不需清零
- 硬體 reset 不一定清暫存器，startup 必須手動清零，確保 pipeline 啟動無垃圾值
- `li` 是 pseudo-instruction，展開見 `04_pseudo_instructions.md`

---

### 2. 設定 Global Pointer

```asm
la gp, _gp
```

- `gp`（x3）讓編譯器以 gp-relative 定址存取 sdata/sbss（小型全域變數）
- `_gp` = `.sdata` 起始 + 0x800，使 ±2048 範圍涵蓋整個 sdata/sbss 區

---

### 3~5. 清零各記憶體區段

```asm
la a0, <起始位址>
la a1, <結束位址> - 4    ← end-4，原因見 fill_block 說明
li a2, 0x0
jal fill_block
```

| 清零目標 | 清零範圍 | 用途 |
|---------|----------|------|
| BSS     | `__bss_start` ~ `__bss_end-4`   | 未初始化全域變數（C 語言保證初始為 0） |
| SBSS    | `__sbss_start` ~ `__sbss_end-4` | 小型未初始化全域變數 |
| Stack   | `_stack_end` ~ `__stack-4`      | 清零 stack 空間 |
| Test    | `_test_start` ~ `_test_end-4`   | 清零測試結果區（防止舊值殘留） |

---

### 6. 設定 Stack Pointer

```asm
la sp, _stack
```

- Stack 往低位址成長，`sp` 指向 stack 頂端
- 設定完才能進入 `main`（C 函式需要 stack frame）

---

### 7. 模擬結束信號

```asm
SystemExit:
  la t0, _sim_end        # t0 = 0xFFFC
  li t1, -1              # t1 = 0xFFFFFFFF（-1 符號擴展）
  sw t1, 0(t0)           # DM[0x3FFF] = 0xFFFFFFFF
dead_loop:
  j dead_loop            # 無限迴圈，防止 PC 繼續執行亂碼
```

- testbench 每個 cycle 監看 `DM[0x3FFF]`，非零則停止模擬並開始比對結果
