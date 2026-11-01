# FPGA & Vivado 작업 아카이브

> 여러 PC(Vivado 2025.2 / 2026.1)에서 동기화되는 HDL 작업 저장소입니다. 푸시하면 각 프로젝트의 `note.md`와 RTL 모듈 구조가 아래에 자동으로 정리됩니다. (이 파일은 `scripts/update_readme.py`가 생성하므로 직접 수정하지 마세요.)

## 사용법

```tcl
# Vivado Tcl Console (어느 버전이든)
cd C:/경로/리포지토리/projects/<작업명>
source ../../scripts/create_proj.tcl
```

## 전체 작업 목록

| 프로젝트 | 한 줄 요약 | 포함 모듈 | 최근 업데이트 |
| :--- | :--- | :--- | :--- |
| [**13.11**](#1311) | - | `master` | 2026-11-01 |
| [**13.25**](#1325) | - | `dff`, `main` | 2026-11-01 |
| [**13.26**](#1326) | - | `jkff`, `main` | 2026-11-01 |
| [**13.262**](#13262) | - | `main` | 2026-11-01 |
| [**14.43a**](#1443a) | - | `master` | 2026-11-01 |
| [**14.44**](#1444) | - | `master` | 2026-11-01 |
| [**14.6**](#146) | - | `master` | 2026-11-01 |
| [**16.29**](#1629) | - | `main` | 2026-11-01 |
| [**counter2421**](#counter2421) | - | `counter2421` | 커밋 전 |
| [**counter_12prac**](#counter_12prac) | - | `counter`, `counter_tb` | 2026-11-01 |
| [**full adder**](#full-adder-full_adder) | - | `fullAdder` | 2026-11-01 |
| [**P10D**](#p10d) | - | `count`, `decod38` | 2026-11-01 |
| [**P10E**](#p10e) | - | `bcdconv`, `decod4to16`, `Master` | 2026-11-01 |
| [**P10I**](#p10i) | - | `master`, `mux21`, `pEnc` | 2026-11-01 |
| [**P10J**](#p10j) | - | `adder`, `adder2`, `mas` | 2026-11-01 |
| [**P10K**](#p10k) | - | `buff3`, `decod24`, `mas` | 2026-11-01 |
| [**P10K_desktop2**](#p10k_desktop2) | - | `buffer3`, `decod24`, `master` | 2026-11-01 |
| [**P10N**](#p10n) | - | `mEnc`, `pEnc` | 2026-11-01 |
| [**P1232**](#p1232) | - | `SRff`, `Ucount` | 2026-11-01 |
| [**practice_1**](#practice_1) | - | `ad2`, `ad42`, `wires`, `simple_gates` | 2026-11-01 |
| [**project_1**](#project_1) | - | `wires` | 2026-11-01 |
| [**project_1_desktop2**](#project_1_desktop2) | - | `F101`, `ANDP`, `CLKP`, `P10C`, `P1014`, `P1017`, `P10172`, `P1018`, `P10A`, `P10AR`, `P10C` | 2026-11-01 |
| [**project_2**](#project_2) | - | `P1010`, `P1011`, `P104`, `P10B` | 2026-11-01 |
| [**project_2_desktop2**](#project_2_desktop2) | - | `fulladder`, `P10C` | 2026-11-01 |
| [**project_3**](#project_3) | - | `bcdconv`, `decod4to16`, `Master` | 2026-11-01 |
| [**project_4**](#project_4) | - | `qw` | 2026-11-01 |
| [**thermostat**](#thermostat) | - | `thermostat` | 2026-11-01 |

## 프로젝트별 상세 노트 및 모듈 명세

### 13.11

- **폴더**: [`projects/13.11`](projects/13.11) · [note.md](projects/13.11/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `tb_1411.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `master.sv` | **`master`** | `input` | `1` | `clk` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `input` | `1` | `x` |
|  |  | `output` | `1` | `z` |

</details>

### 13.25

- **폴더**: [`projects/13.25`](projects/13.25) · [note.md](projects/13.25/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `sim1.sv`, `tb_13_25.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `dff.sv` | **`dff`** | `input` | `1` | `d` |
|  |  | `input` | `1` | `clk` |
|  |  | `output` | `1` | `q` |
| `main.sv` | **`main`** | `input` | `1` | `x` |
|  |  | `input` | `1` | `clk` |
|  |  | `output` | `1` | `z` |

</details>

### 13.26

- **폴더**: [`projects/13.26`](projects/13.26) · [note.md](projects/13.26/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `sim.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `jkff.sv` | **`jkff`** | `input` | `1` | `j` |
|  |  | `input` | `1` | `k` |
|  |  | `input` | `1` | `clk` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `output` | `1` | `o` |
|  |  | `output` | `1` | `o2` |
| `main.sv` | **`main`** | `input` | `1` | `x` |
|  |  | `input` | `1` | `clk` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `output` | `1` | `z` |

</details>

### 13.262

- **폴더**: [`projects/13.262`](projects/13.262) · [note.md](projects/13.262/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `tb_13_26_2.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `main.sv` | **`main`** | `input` | `1` | `x1` |
|  |  | `input` | `1` | `x2` |
|  |  | `input` | `1` | `clk` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `output` | `1` | `z1` |
|  |  | `output` | `1` | `z2` |

</details>

### 14.43a

- **폴더**: [`projects/14.43a`](projects/14.43a) · [note.md](projects/14.43a/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `tb_master_seq.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `master.sv` | **`master`** | `input` | `1` | `x` |
|  |  | `input` | `1` | `clk` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `output` | `1` | `z` |

</details>

### 14.44

- **폴더**: [`projects/14.44`](projects/14.44) · [note.md](projects/14.44/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `master.sv` | **`master`** | `input` | `1` | `r` |
|  |  | `input` | `1` | `a` |
|  |  | `input` | `1` | `s` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `input` | `1` | `clk` |
|  |  | `output` | `1` | `z` |

</details>

### 14.6

- **폴더**: [`projects/14.6`](projects/14.6) · [note.md](projects/14.6/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `master.sv` | **`master`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### 16.29

- **폴더**: [`projects/16.29`](projects/16.29) · [note.md](projects/16.29/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `simul.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `main.sv` | **`main`** | `input` | `1` | `fb1` |
|  |  | `input` | `1` | `fb2` |
|  |  | `input` | `1` | `call1` |
|  |  | `input` | `1` | `call2` |
|  |  | `input` | `1` | `fs1` |
|  |  | `input` | `1` | `fs2` |
|  |  | `input` | `1` | `clk` |
|  |  | `input` | `1` | `rst_n` |
|  |  | `output` | `1` | `up` |
|  |  | `output` | `1` | `down` |

</details>

### counter2421

- **폴더**: [`projects/counter2421`](projects/counter2421) · [note.md](projects/counter2421/note.md)
- **요약**: -
- **최근 업데이트**: 커밋 전
- **시뮬레이션 파일**: `counter2421_tb.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `counter2421.sv` | **`counter2421`** | `input` | `1` | `ClrN` |
|  |  | `output` | `[3:0]` | `q` |
|  |  | `input` | `1` | `clk` |

</details>

### counter_12prac

- **폴더**: [`projects/counter_12prac`](projects/counter_12prac) · [note.md](projects/counter_12prac/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `counter.sv` | **`counter`** | `input` | `1` | `clk` |
|  |  | `input` | `1` | `reset_n` |
|  |  | `output` | `[2:0]` | `cba` |
| `counter_tb.sv` | **`counter_tb`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### full adder (full_adder)

- **폴더**: [`projects/full_adder`](projects/full_adder) · [note.md](projects/full_adder/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `fullAdder.sv` | **`fullAdder`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `input` | `1` | `ci` |
|  |  | `output` | `1` | `s` |
|  |  | `output` | `1` | `co` |

</details>

### P10D

- **폴더**: [`projects/P10D`](projects/P10D) · [note.md](projects/P10D/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `count.sv` | **`count`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `input` | `1` | `c` |
|  |  | `output` | `[1:0]` | `count` |
| `decod38.sv` | **`decod38`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `input` | `1` | `c` |
|  |  | `output` | `[7:0]` | `y` |

</details>

### P10E

- **폴더**: [`projects/P10E`](projects/P10E) · [note.md](projects/P10E/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `bcdconv.sv` | **`bcdconv`** | `input` | `[3:0]` | `a` |
|  |  | `output` | `[6:0]` | `f` |
| `decod4to16.sv` | **`decod4to16`** | `input` | `[3:0]` | `a` |
|  |  | `output` | `[15:0]` | `f` |
| `Master.sv` | **`Master`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### P10I

- **폴더**: [`projects/P10I`](projects/P10I) · [note.md](projects/P10I/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `simul.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `master.sv` | **`master`** | `input` | `[7:0]` | `y` |
|  |  | `output` | `1` | `a` |
|  |  | `output` | `1` | `b` |
|  |  | `output` | `1` | `c` |
|  |  | `output` | `1` | `d` |
| `mux21.sv` | **`mux21`** | `input` | `1` | `I0` |
|  |  | `input` | `1` | `I1` |
|  |  | `input` | `1` | `e` |
|  |  | `output` | `1` | `f` |
| `pEnc.sv` | **`pEnc`** | `input` | `[3:0]` | `y` |
|  |  | `output` | `1` | `a` |
|  |  | `output` | `1` | `b` |
|  |  | `output` | `1` | `c` |

</details>

### P10J

- **폴더**: [`projects/P10J`](projects/P10J) · [note.md](projects/P10J/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `simul.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `adder.sv` | **`adder`** | `input` | `[3:0]` | `a` |
|  |  | `input` | `[3:0]` | `b` |
|  |  | `input` | `1` | `ci` |
|  |  | `output` | `[3:0]` | `s` |
|  |  | `output` | `1` | `co` |
| `adder2.sv` | **`adder2`** | `input` | `[3:0]` | `a` |
|  |  | `input` | `[3:0]` | `b` |
|  |  | `input` | `1` | `cin` |
|  |  | `output` | `[3:0]` | `s` |
|  |  | `output` | `1` | `co` |
| `mas.sv` | **`mas`** | `input` | `[7:0]` | `a` |
|  |  | `input` | `[7:0]` | `b` |
|  |  | `output` | `[7:0]` | `c` |
|  |  | `output` | `1` | `bo` |

</details>

### P10K

- **폴더**: [`projects/P10K`](projects/P10K) · [note.md](projects/P10K/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `buff3.sv` | **`buff3`** | `input` | `[5:0]` | `a` |
|  |  | `input` | `1` | `e` |
|  |  | `output` | `[5:0]` | `b` |
| `decod24.sv` | **`decod24`** | - | - | _포트 없음 (테스트벤치 등)_ |
| `mas.sv` | **`mas`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### P10K_desktop2

- **폴더**: [`projects/P10K_desktop2`](projects/P10K_desktop2) · [note.md](projects/P10K_desktop2/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `simul.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `buffer3.sv` | **`buffer3`** | `input` | `[5:0]` | `a` |
|  |  | `input` | `1` | `e` |
|  |  | `output` | `[5:0]` | `b` |
| `decod24.sv` | **`decod24`** | `input` | `[1:0]` | `a` |
|  |  | `output` | `[3:0]` | `b` |
| `master.sv` | **`master`** | `input` | `[5:0]` | `i0` |
|  |  | `input` | `[5:0]` | `i1` |
|  |  | `input` | `[5:0]` | `i2` |
|  |  | `input` | `[5:0]` | `i3` |
|  |  | `input` | `[1:0]` | `e` |
|  |  | `output` | `[5:0]` | `f` |

</details>

### P10N

- **폴더**: [`projects/P10N`](projects/P10N) · [note.md](projects/P10N/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `simul.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `mEnc.sv` | **`mEnc`** | `input` | `[7:0]` | `y` |
|  |  | `input` | `1` | `e` |
|  |  | `output` | `1` | `a` |
|  |  | `output` | `1` | `b` |
|  |  | `output` | `1` | `c` |
|  |  | `output` | `1` | `d` |
| `pEnc.sv` | **`pEnc`** | `input` | `1` | `i0` |
|  |  | `input` | `1` | `i1` |
|  |  | `input` | `1` | `i2` |
|  |  | `input` | `1` | `i3` |
|  |  | `input` | `1` | `e` |
|  |  | `output` | `1` | `a` |
|  |  | `output` | `1` | `b` |
|  |  | `output` | `1` | `c` |

</details>

### P1232

- **폴더**: [`projects/P1232`](projects/P1232) · [note.md](projects/P1232/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `SRff.sv` | **`SRff`** | - | - | _포트 없음 (테스트벤치 등)_ |
| `Ucount.sv` | **`Ucount`** | `input` | `1` | `rst_n` |
|  |  | `input` | `1` | `clk` |
|  |  | `output` | `[2:0]` | `q` |

</details>

### practice_1

- **폴더**: [`projects/practice_1`](projects/practice_1) · [note.md](projects/practice_1/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `ad42_tb.sv`, `ad42_tbvcd.sv`, `simple_gates_tb.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `ad2.sv` | **`ad2`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `output` | `1` | `y` |
| `ad42.sv` | **`ad42`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `output` | `1` | `Y` |
| `datatype_wires.sv` | **`wires`** | - | - | _포트 없음 (테스트벤치 등)_ |
| `simple_gates.sv` | **`simple_gates`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `output` | `1` | `and_out` |
|  |  | `output` | `1` | `or_out` |

</details>

### project_1

- **폴더**: [`projects/project_1`](projects/project_1) · [note.md](projects/project_1/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `wires.sv` | **`wires`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### project_1_desktop2

- **폴더**: [`projects/project_1_desktop2`](projects/project_1_desktop2) · [note.md](projects/project_1_desktop2/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `101.vhd` | **`F101`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `input` | `1` | `E` |
|  |  | `output` | `1` | `I` |
| `ANDP.vhd` | **`ANDP`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `inout` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `output` | `1` | `E` |
| `CLKP.vhd` | **`CLKP`** | - | - | _포트 없음 (테스트벤치 등)_ |
| `Fullader10cm.sv` | **`P10C`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `input` | `1` | `cin` |
|  |  | `output` | `1` | `s` |
|  |  | `output` | `1` | `co` |
| `P1014.sv` | **`P1014`** | `input` | `[5:0]` | `D` |
|  |  | `input` | `[2:0]` | `E` |
|  |  | `output` | `1` | `F` |
| `P1017.sv` | **`P1017`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `output` | `1` | `F` |
| `P10172.sv` | **`P10172`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `output` | `1` | `F` |
| `P1018.sv` | **`P1018`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `output` | `1` | `E` |
| `P10A.sv` | **`P10A`** | `input` | `1` | `I0` |
|  |  | `input` | `1` | `I1` |
|  |  | `input` | `1` | `E` |
|  |  | `output` | `1` | `F` |
| `P10AR.sv` | **`P10AR`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `I0` |
|  |  | `input` | `1` | `I1` |
|  |  | `input` | `1` | `I2` |
|  |  | `input` | `1` | `I3` |
|  |  | `output` | `1` | `F` |
| `P10C.sv` | **`P10C`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `output` | `1` | `s` |
|  |  | `output` | `1` | `co` |

</details>

### project_2

- **폴더**: [`projects/project_2`](projects/project_2) · [note.md](projects/project_2/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `P1010s.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `P1010.sv` | **`P1010`** | `input` | `1` | `P` |
|  |  | `input` | `1` | `Q` |
|  |  | `input` | `1` | `N` |
|  |  | `output` | `1` | `R` |
| `P1011.sv` | **`P1011`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `D` |
|  |  | `input` | `1` | `E` |
|  |  | `output` | `1` | `H` |
| `P104.sv` | **`P104`** | `input` | `1` | `A` |
|  |  | `input` | `1` | `B` |
|  |  | `input` | `1` | `C` |
|  |  | `input` | `1` | `D` |
|  |  | `input` | `1` | `E` |
|  |  | `output` | `1` | `I` |
| `P10B.sv` | **`P10B`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### project_2_desktop2

- **폴더**: [`projects/project_2_desktop2`](projects/project_2_desktop2) · [note.md](projects/project_2_desktop2/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `fulladder.sv` | **`fulladder`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `input` | `1` | `cin` |
|  |  | `output` | `1` | `sum` |
|  |  | `output` | `1` | `co` |
| `P10C.sv` | **`P10C`** | `input` | `1` | `a` |
|  |  | `input` | `1` | `b` |
|  |  | `output` | `1` | `s` |
|  |  | `output` | `1` | `co` |

</details>

### project_3

- **폴더**: [`projects/project_3`](projects/project_3) · [note.md](projects/project_3/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `bcdconv.sv` | **`bcdconv`** | `input` | `[3:0]` | `a` |
|  |  | `output` | `[6:0]` | `f` |
| `decod4to16.sv` | **`decod4to16`** | `input` | `[3:0]` | `a` |
|  |  | `output` | `[15:0]` | `f` |
| `Master.sv` | **`Master`** | - | - | _포트 없음 (테스트벤치 등)_ |

</details>

### project_4

- **폴더**: [`projects/project_4`](projects/project_4) · [note.md](projects/project_4/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `qw.sv` | **`qw`** | `input` | `1` | `a` |
|  |  | `output` | `1` | `b` |

</details>

### thermostat

- **폴더**: [`projects/thermostat`](projects/thermostat) · [note.md](projects/thermostat/note.md)
- **요약**: -
- **최근 업데이트**: 2026-11-01
- **시뮬레이션 파일**: `thermostat.sv`

#### 작업 노트

_상세 노트 없음_

<details><summary>RTL 모듈 및 포트 요약</summary>

| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |
| :--- | :--- | :--- | :--- | :--- |
| `thermostat.sv` | **`thermostat`** | `input` | `[2:0]` | `presetTemp` |
|  |  | `input` | `[2:0]` | `currentTemp` |
|  |  | `input` | `1` | `switch` |
|  |  | `output` | `1` | `fanOn` |

</details>

