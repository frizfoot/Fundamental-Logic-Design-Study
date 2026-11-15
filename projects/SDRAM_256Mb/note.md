# SDRAM_256Mb
> Samsung K4S561632E (256Mb SDR SDRAM, x16) 데이터시트 정리 및 SDR SDRAM 컨트롤러 설계 노트

---

## 1. 용어 정리

### LVTTL (Low Voltage Transistor-Transistor Logic)
0과 1을 구분하는 **전압 기준** (3.3V 규격)

| 기호 | 뜻 | 기준 | 의미 |
|---|---|---|---|
| VIL | Voltage Input Low | 0.8V | 이하로 들어오면 **0**으로 읽음 |
| VIH | Voltage Input High | 2.0V | 이상으로 들어오면 **1**로 읽음 |
| VOL | Voltage Output Low | 0.4V | 이하로 **0**을 내보냄 |
| VOH | Voltage Output High | 2.4V | 이상으로 **1**을 내보냄 |

### Bank
**독립된 메모리 덩어리.** 256Mb = 64Mb Bank × 4개

- Bank 1개 = 8192 Row × 512 Column × 16 Bit → 주소 하나당 Cell 16개
- Bank마다 Sense Amplifier가 따로 있음 → Bank 하나는 **한 번에 Row 하나만** Open
- Bank끼리는 **병렬 작업 가능** (Bank Interleaving)

### Burst
READ/WRITE **한 번에 연속된 Column 여러 개**를 자동으로 주고받음

- **BL (Burst Length):** 한 번에 주고받는 개수
- 시작 Column이 속한 **BL 크기 블록 안에서** 순환 (wrap)
  - 예: BL = 4, 시작 Column 3 → 3 → 0 → 1 → 2

---

## 2. 동작 명령

### 기본 시퀀스
​```
IDLE → (요청) → ACT → tRCD 대기 → READ / WRITE → ... → PRE → IDLE
​```

| 단계 | 보내는 주소 | 동작 |
|---|---|---|
| ACT | Bank + Row | Row 하나 열기 → 8192 Bit가 Sense Amp에 올라옴 |
| READ | Bank + Column | 그중 Column 1개 = 16 Bit 선택 |
| CL Clock 뒤 | — | DQ0~DQ15로 16 Bit 출력 |

### 명령 목록

| 명령 | 이름 | 동작 |
|---|---|---|
| **ACT** | Active | Row를 열어 읽을 준비 → 다음에 READ/WRITE |
| **READ** | Read | 데이터 읽기 |
| **WRITE** | Write | 데이터 쓰기 |
| **PRE** | Precharge | Page(열린 Row) 닫기 |
| **REF** | Refresh | Capacitor 전하 재충전 (64ms 안에 모든 Row를 한 번씩) |
| **MRS** | Mode Register Set | 동작 방식 사전 설정 |
| **NOP** | No Operation | 아무것도 안 함 (기본값) |

### ACT 상세
1. Capacitor 전하가 Bitline으로 흘러나가며 **원래 값이 깨짐** (파괴적 읽기)
2. Sense Amplifier가 값을 증폭해서 **Cell에 다시 Restore** → 이 시간이 **tRAS**
3. Row 하나 = 512 Column × 16 Bit = **8192 Bit (Page)** 를 Sense Amp가 전부 읽음
4. 이 중 **16 Bit만** DQ로 내보냄

### REF 상세: 센싱이 쉬운 조건
| 항목 | 방향 | 효과 |
|---|---|---|
| Cell Cap | ↑ | 누설을 오래 버팀 (Retention ↑) + 센싱 신호 ↑ |
| Bitline Parasitic Cap | ↓ | 센싱 신호 ↑ |

$$\Delta V = \frac{V_{DD}}{2} \times \frac{C_s}{C_s + C_b}$$

### MRS 상세
**어떻게 동작할지 적어 두는 설정 칸.** 전원 ON 후 Controller가 한 번 Write

- 비유: 새 핸드폰을 켜면 시계, 언어부터 설정하는 것

---

## 3. Pin

| Pin | 이름 | 역할 |
|---|---|---|
| **RAS** | Row Address Strobe | 지금 Address Pin에 **Row 주소**가 있다고 알림 |
| **CAS** | Column Address Strobe | 지금 Address Pin에 **Column 주소**가 있다고 알림 |
| **LDQM / UDQM** | Data Mask | 1이면 해당 Byte 무시 (Lower: DQ0~7 / Upper: DQ8~15) |

- **CAS Latency (CL):** READ 명령 후 데이터 출력까지의 Clock 수

---

## 4. 256Mb E-die SDRAM Specification Review

- **LVTTL compatible with Multiplexed Address**
  - Row, Column 주소를 **같은 핀으로 번갈아** 보냄
  - ACT → Row 주소 (Row를 열기 위해)
  - READ → Column 주소
- **Positive CLK Edge:** 클럭 상승 엣지 기준으로 동작
- **MRS로 설정 가능한 항목**
  - CAS Latency: 2, 3
  - Burst Length: 1, 2, 4, 8, Full page (Full page는 PRE 또는 BST(Burst Stop)로 멈춤)
  - Burst Type: Sequential, Interleave
- **LDQM, UDQM:** Data Masking → 해당 Byte 무시
- **Auto Refresh:** 64ms

<img width="2346" height="1568" alt="image" src="https://github.com/user-attachments/assets/224a0fc6-ccca-42f7-a819-07702d8c0686" />

---

## 5. 작업 내용 및 핵심 설계
-

## 6. 테스트 / 트러블슈팅 메모
-
