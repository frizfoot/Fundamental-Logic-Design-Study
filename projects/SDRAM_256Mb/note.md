# SDRAM_256Mb
> (한 줄 요약을 작성하세요)


### 테스트 / 트러블슈팅 메모
**용어 정리**

LVTTL (Low Voltage Transistor-Transistor Logic): 0,1이 되는 Voltage 기준
  
  ->규격: 3.3V기준
  
  ->VIL(0.8V),VOL(2.0V): Voltage Input Low, High의 기준, VIL이하는 0으로 읽, VIL이상은 1으로 읽음
  
  ->VOL,VOH: Voltage Output Low, High의 기준, VOL이하는 0으로 내보냄, VOH이상은 1로 내보냄

Bank:메모리 덩어리, 256Mb의 경우 4개의 64Mb Bank
  
  ->256Mb 메모리는 8192 Row X 512 Column X 16 Bit, 주소 하나 당 Cell 16가 있다는 뜻
  
  -> Bank has each Sense Amplifier, Bank는 한번에 한번의 Row Open
  
  -> Bank는 각각 병렬 작업 가능

BURST: READ WRITE 한번에 연속된 컬럼 여러 개를 자동으로 주고 받음

  -> BL(Burst Length)
  -> BL 크기의 블록으로 시작 컬럼이 속한 블록 안에서 신호가 돎

**동작 명령**

시퀀스: IDLE → (요청 옴) → ACT 보내기 → tRCD 기다리기 → READ 또는 WRITE → ... → PRE → IDLE
  
  ACT (뱅크 + 로우 주소)   → 로우 하나 열기: 8192비트가 센스앰프에 올라옴

  READ (뱅크 + 컬럼 주소)  → 그중 컬럼 1개 = 16비트 선택

  CL 클럭 뒤               → DQ0~DQ15로 16비트 출력

ACT(Active): Row를 열어 읽을 준비-> 다음에 Read/Write가 나옴

  ->Capacitor의 전하가 Bitline으로 들어가며 원래 값이 깨짐->Sense Amplifier가 다시 Cell에 Data Restore 시켜줌(tRAs가 이게 걸리는 시간)

  -> ACT가 Row를 열면, 512(Column 갯수) X 16Bit = 8192 비트(Page) 를 Sense Amplifier가 다 읽음->이 중 16 비트만 DQ로 보냄

READ:데이터를 읽음

WRITE: 데이터를 씀

PRE: 페이지를 닫는다

REF(Refresh): 64ms에 한번씩 ACT->PRE로 Capcitor 전류 Reset (Cell Cap이 클수록(누설이 잘 버팀), Bit Line Parasite Cap이 작을수록(Sensing이 잘됨), Sense Amp 쉬움)

MRS: Presetting

(Mode Register Set):  어떻게 동작할지 적어두는 설정 칸, 전원 ON 순간 Controller가 Write

  -> Example: 새 핸드폰 킬 때 시계 언어 설정.

NOP: No Operation (Default 값)

**Pin**
CAS(Column Address Strobe): 현재 Address Pin에 Column 주소가 있다고 Notice 해줌

  ->CAS Latency: Read명령 후 데이터 출력 까지 CLK수

RAS(Row Address Strobe): 현재 Address Pin에 Row 주소가 있다고 Notice

### 256Mb e-die SDRAM Specification Review
-LVTTL Compatible with Multiplexed Address
  
  -Row, Column 주소를 같은 핀으로 번갈아 보냄
  
  ->ACT->Row 보냄(Row를 열기 위함)
  
  ->Read-> Column 보냄

- Positive CLK Edge

- MRS

  ->CAS Latency 2&3

  ->Burst Length: 1,2,4,8 & Full page 선택 가능 (PRE, BST(Burst Stop)에서 동작이 멈춤

  ->Burst Type (Sequential, Interleave)

- LQDM, UDQM Masking->데이터 무시

- Auto Refresh 64ms
<img width="2346" height="1568" alt="image" src="https://github.com/user-attachments/assets/224a0fc6-ccca-42f7-a819-07702d8c0686" />

### 작업 내용 및 핵심 설계
- 

### 테스트 / 트러블슈팅 메모
- 
