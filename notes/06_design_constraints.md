# 06 — Design Constraint 教學（SDC + Synthesis Flow）

## 為什麼需要 Design Constraint？

RTL 合成（Synthesis）不知道電路要跑多快、輸入訊號何時到達、驅動能力多強。
**Design Constraint（`.sdc`）** 就是把這些「設計意圖」告訴 Design Compiler（DC），讓它在滿足條件的前提下最佳化電路。

---

## 一、時脈約束（Clock Constraints）

對應本專案：`script/DC.sdc`

### `create_clock`

```tcl
create_clock -name clk -period 15.0 [get_ports clk]
```

- 宣告一個名叫 `clk` 的時脈，週期 15 ns（≈ 66.67 MHz）
- `[get_ports clk]`：套用到 top-level port `clk`
- **這是最核心的 constraint**，所有 timing 分析都以此週期為基準

> **為什麼是 15 ns？** 這是 timing closure 的目標。太緊 DC 放不進去，太鬆面積/功耗浪費。本專案可調至 20 ns（CLAUDE.md 有記載）。

---

### `set_dont_touch_network`

```tcl
set_dont_touch_network [all_clocks]
```

- 禁止 DC 對時脈網路做任何 buffer insertion 或邏輯轉換
- 保持時脈訊號「原樣」，讓 Place & Route 工具統一處理 clock tree

---

### `set_fix_hold`

```tcl
set_fix_hold [all_clocks]
```

- 命令 DC 插入 delay buffer 修復 **hold time violation**
- Hold violation 是「資料消失太快」（flip-flop 還沒 capture 就被下一個值覆蓋）
- Setup violation 是「資料來太慢」；DC 的 `compile` 預設只修 setup，hold 要明確指定

---

### `set_clock_uncertainty`

```tcl
set_clock_uncertainty 0.1 [all_clocks]
```

- 為時脈加上 **0.1 ns 的 jitter/skew margin**
- 實際電路中時脈邊緣不完美（電源雜訊、溫度漂移），DC 保守預留此空間
- 效果：有效 timing budget = 15 ns − 0.1 ns = 14.9 ns

---

### `set_clock_latency`

```tcl
set_clock_latency 1.0 [all_clocks]
```

- 模擬時脈從 source 傳到 FF clock pin 的傳播延遲（1 ns）
- 在 pre-layout 合成階段代替真實 clock tree（clock tree 在 P&R 才知道）

---

### `set_ideal_network`

```tcl
set_ideal_network [get_ports clk]
```

- 宣告 `clk` 是「理想」訊號，不計算其 propagation delay
- 搭配 `set_clock_latency` 一起用：latency 用參數模型，而非真實延遲計算

---

## 二、IO 延遲約束（Input/Output Delay）

### `set_input_delay`

```tcl
set_input_delay -max 5.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay -min 0.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
```

- **max delay（setup 分析用）**：告訴 DC，輸入訊號最晚在時脈邊緣前 5 ns 才穩定
  - 留給內部電路的 timing budget = 15 ns − 5 ns = 10 ns（本例）
- **min delay（hold 分析用）**：輸入最早在時脈邊緣同時到達（0 ns），用於 hold check
- `remove_from_collection ... clk`：排除時脈本身（clk 不是資料輸入）

> **設成 1/2 週期** 是常見做法（CLAUDE.md 有此說明）：假設輸入來自另一個同頻 FF，
> source FF 有半週期傳到這裡，所以留給本電路也剩半週期。

---

### `set_output_delay`（本專案已 comment out）

```tcl
#set_output_delay -max 5.0 -clock clk [all_outputs]
#set_output_delay -min 0.0 -clock clk [all_outputs]
```

- 告訴 DC，輸出訊號必須在時脈邊緣後多久才需要穩定
- 被 comment out 代表本設計的輸出（top-level 僅有 clk/rst）不需此約束

---

## 三、環境約束（Environment Constraints）

### `set_driving_cell`

```tcl
set_driving_cell -library fsa0m_a_t33_generic_io_ss1p62v125c -lib_cell XMD -pin {O} [all_inputs]
```

- 宣告所有輸入 port 是被 IO pad cell `XMD` 的 `O` pin 驅動
- DC 用此資訊計算輸入訊號的 transition time（rise/fall time）
- 比 `set_drive 0.1` 更精確（直接查 cell library）

---

### `set_operating_conditions`

```tcl
set_operating_conditions \
  -max_library fsa0m_a_generic_core_ss1p62v125c -max WCCOM \
  -min_library fsa0m_a_generic_core_ff1p98vm40c -min BCCOM
```

- **max（WCCOM）= Worst Case Commercial**：SS corner，1.62 V，125°C（最慢）
  - 用於 **setup timing** 分析（電路最慢的情況）
- **min（BCCOM）= Best Case Commercial**：FF corner，1.98 V，−40°C（最快）
  - 用於 **hold timing** 分析（電路最快的情況，hold violation 最容易發生）
- 本專案 library 是 UMC 0.18 µm

---

### `set_auto_wire_load_selection`

```tcl
set auto_wire_load_selection
```

- 讓 DC 根據 design 規模自動選擇 wire load model（估算繞線電阻/電容）
- 因為 pre-layout 看不到實際繞線，用統計模型近似

---

### `set_max_fanout`

```tcl
set_max_fanout 6 [all_inputs]
```

- 限制每個輸入 port 最多驅動 6 個 gate input
- 超過時 DC 自動插入 buffer 分擔負載（避免 timing degradation）

---

## 四、Synthesis Flow（synthesis.tcl）

```tcl
# 1. 讀進 RTL
read_file -autoread -top top {../src ../include}
current_design top
link        # 連結所有 sub-module
uniquify    # 把共用 module 複製成獨立實例（方便各自最佳化）

# 2. 修正多驅動 net（DC 合成常見問題）
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

# 3. 套用 timing constraint
source ../script/DC.sdc

# 4. 合成（技術映射）
compile -exact_map -map_effort high

# 5. 清理懸空 port
remove_unconnected_ports -blast_buses [get_cells * -hier]

# 6. 統一命名規則（方便後端工具讀取）
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "A-Z a-z 0-9 _" -max_length 255 -type cell
...
change_names -hierarchy -rules name_rule

# 7. 輸出結果
write_file -format verilog -hier -output ../syn/top_syn.v   # netlist
write_sdf  -version 2.1 -context verilog -load_delay net ../syn/top_syn.sdf  # 延遲標注
report_timing > ../syn/timing.log
report_area   > ../syn/area.log
report_power  > ../syn/power.log
```

---

## 五、Timing Report 解讀

### 關鍵術語

| 術語 | 意義 |
|------|------|
| **Data Arrival Time** | 資料從起始 FF 出發，歷經所有組合邏輯，到達目標 FF D pin 的時間 |
| **Data Required Time** | 目標 FF D pin 最晚要在什麼時間前穩定（由 clock period 倒推） |
| **Slack** | Required − Arrival：正值 = timing met；負值 = violation |
| **Critical Path** | Slack 最小的那條路徑，決定整個設計的最高頻率 |

### 本專案實際結果

**v0.1（Multiplier 在 EX stage）**：

```
Critical path:
DM read → LD_align → WB forwarding mux
       → Multiplier（組合 32×32，+4.13 ns）
       → ALU → Controller(jb_flush) → IF/ID → Decoder → RegFile → ID/EX

Clock period: 15 ns, Slack: 0.00 ns
Multiplier 佔用 ~27% 的 cycle budget（12.40 - 8.27 = 4.13 ns）
```

**v0.2（Multiplier 移到 MEM stage）**：

```
Critical path:
DM read → LD_align → WB forwarding mux
       → EX rs2 mux → ALU → Controller(jb_flush) → IF/ID → Decoder → RegFile → ID/EX
       （Multiplier 不再在 critical path 上）

Clock period: 12.4 ns, Slack: 0.00 ns（頻率提升 30%，66.7 → 80.6 MHz）
```

---

## 六、PPA 概念與本專案比較

PPA = **Performance**（速度）× **Power**（功耗）× **Area**（面積）  
三者往往相互 trade-off，設計目標是找到最佳平衡點。

### v0.1 vs v0.2 PPA 對照

| 指標 | v0.1（Mult 在 EX） | v0.2（Mult 在 MEM） | 變化 | 原因 |
|------|-------------------|---------------------|------|------|
| **Clock** | 15 ns (66.7 MHz) | 12.4 ns (80.6 MHz) | ↑ 21% 速度 | Multiplier 離開 critical path |
| **Logic Area** | 390,578 µm² | 394,740 µm² | +1.1%（略增）| 多一組 MEM stage pipeline reg |
| **Total Power** | 84.46 mW | 101.97 mW | +20.7% | 頻率高 → 動態功耗增加（P ∝ f·CV²） |
| **Seq. Cells** | 99,072 µm² | 103,337 µm² | +4.3%（增加 FF） | Multiplier 輸入/輸出需在 EX/MEM reg 多一拍 |

> **結論**：v0.2 以「略增面積 + 較高功耗」換取「更高頻率」，是 performance-first 的 trade-off。
> 實際選擇取決於 spec：若功耗受限（embedded / mobile）則不一定值得。

### 面積分類

```
Total Cell Area ≈ Logic Area + SRAM Macros

Logic Area = Combinational + Sequential
  Combinational: ALU, mux, decoder... （主要是 gate）
  Sequential:    FF（pipeline reg, register file...）

SRAM Macros (IM1 + DM1) ≈ 5.34 MB → 佔總面積 93%（macro 遠大於邏輯）
```

### 功耗分類

```
Total Power = Dynamic Power + Leakage Power

Dynamic = Switching（logic toggle） + Internal（cell 內部電流）
  P_dynamic ∝ α × C × V² × f
  → 頻率越高、電壓越高、活動率越高，功耗越大

Leakage = 電晶體次臨界電流（與溫度正相關，與 Vt 負相關）
  本專案 SRAM leakage 佔主導（macro 面積大）
```

---

## 七、SDC 命令速查

| 命令 | 用途 |
|------|------|
| `create_clock -period T [port]` | 定義時脈週期 |
| `set_dont_touch_network [clocks]` | 禁止 DC 修改時脈網路 |
| `set_fix_hold [clocks]` | 自動修復 hold violation |
| `set_clock_uncertainty U [clocks]` | 加入 jitter/skew margin |
| `set_clock_latency L [clocks]` | 模擬 clock tree 傳播延遲 |
| `set_ideal_network [port]` | 宣告為理想訊號（不計延遲） |
| `set_input_delay -max/-min D -clock C [ports]` | 設定輸入到達時間 |
| `set_output_delay -max/-min D -clock C [ports]` | 設定輸出需求時間 |
| `set_driving_cell -lib_cell X [ports]` | 設定輸入驅動強度 |
| `set_operating_conditions -max WC -min BC` | 設定 PVT corner |
| `set_max_fanout N [ports]` | 限制最大扇出 |
