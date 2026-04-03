# 01 — 記憶體佈局（link.ld）

## 整體分區

```
imem: 0x0000 ~ 0x7FFF  (32KB) ← 指令記憶體 (IM1)
dmem: 0x8000 ~ 0xFFFF  (32KB) ← 資料記憶體 (DM1)
```

- 指令與資料分開，`addr[15]` 為 0 = imem，為 1 = dmem
- SRAM word address 計算：`A = byte_addr[15:2]`（右移 2，取 14 bits）

---

## dmem 區段分布（由低到高）

| 符號 / 區段 | byte 位址 | SRAM word addr | 說明 |
|------------|-----------|----------------|------|
| `_test_start` | 0x8000 | DM[0x2000] | 測試結果寫入起點（256 bytes = 64 words） |
| `_test_end`   | 0x8100 | DM[0x2040] | 測試結果區結尾 |
| `.sbss`       | ~       | ~            | 小型未初始化全域變數 |
| `.sdata`      | ~       | ~            | 小型初始化全域變數 |
| `.data`       | ~       | ~            | 一般初始化全域變數 |
| `.bss`        | ~       | ~            | 未初始化全域變數 |
| `_stack_end`  | ~       | ~            | stack 底部（低位址） |
| `_stack`      | ~0xEFFF | ~            | stack 頂部（4KB，往低位址成長） |
| `_sim_end`    | **0xFFFC** | DM[0x3FFF] | 寫入 0xFFFFFFFF → 通知 testbench 結束模擬 |

---

## 重點觀念

- **`_sim_end` 在 dmem 最後 4 bytes（0xFFFC）**：testbench 持續監看，非零即停止模擬並比對結果。
- **`_test_start`**：prog 測試結果陣列的起始位址，testbench 從此讀出結果與 golden.hex 比對。
- **BSS 需手動清零**：硬體不保證記憶體初始值為 0，startup code 必須自行清零。
- **Stack 往低位址成長**：`sp` 初始化為 `_stack`（頂端），push 時遞減。
- **`_gp`（global pointer）**：link.ld 定義為 `.sdata` 起始 + 0x800，讓 gp-relative 存取範圍涵蓋 sdata/sbss。
