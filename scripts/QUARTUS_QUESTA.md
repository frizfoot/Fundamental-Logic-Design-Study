# Quartus / Questa + GitHub 사용법 (PC 2대 공용)

Vivado 버튼과 같은 원칙: **원본은 `projects/<작업명>/` 에만**, 툴이 만드는 생성물은 Git 제외.

## 폴더 구조
```
projects/<작업명>/
  project.tcl        # quartus_family, quartus_device, top_module, sim_top
  src/               # 설계 RTL (.sv .v) → Quartus 합성 + Questa
  sim/               # 테스트벤치 (+ wave.do) → Questa 전용
  sdc/               # 타이밍 제약 (.sdc) → Quartus
  quartus/<작업명>.qpf/.qsf   # 커밋됨 (디바이스, 핀 배정, 파일 목록)
  quartus/db, output_files/  # Git 제외
  questa_work/               # Git 제외 (Questa 컴파일 결과)
```

## Quartus
- 프로젝트 열기: `File > Open Project > projects/<작업명>/quartus/<작업명>.qpf`
- 새 작업: `project.tcl` 에 `quartus_device` 를 넣고 Pull 을 한 번 실행하면 `.qpf` 가 생김
  (또는 `quartus_sh -t scripts/quartus_proj.tcl projects/<작업명>`)
- 새 파일은 **`src/` 나 `sdc/` 에 만들기**. Push/Pull 할 때 `.qsf` 파일 목록에 자동으로 추가/삭제됨
- Pin Planner 로 바꾼 핀 배정은 `.qsf` 에 저장되므로 같이 올라감
- **GitHub 올리기:** `Tools > Tcl Scripts...` → `scripts/q_git_push.tcl` → Run
- **GitHub 받기:** `Tools > Tcl Scripts...` → `scripts/q_git_pull.tcl` → Run (열린 프로젝트를 다시 열어 받은 설정 반영)

## Questa
- 시뮬레이션 (Transcript 창):
  ```
  do C:/Users/<사용자>/Vivado/scripts/questa_sim.do C:/Users/<사용자>/Vivado/projects/<작업명>
  ```
  다시 돌릴 때는 Transcript 에서 ↑ 키로 같은 명령 재실행
- 파형 창 설정을 저장하려면 `File > Save Format...` → `projects/<작업명>/sim/wave.do`
- **GitHub 올리기 / 받기:** Transcript 에서
  `source C:/Users/<사용자>/Vivado/scripts/q_git_push.tcl` / `q_git_pull.tcl`

## 주의
- 무료 Questa 라이선스는 **PC 한 대에 고정**, **동시에 Questa 1개만** 실행 가능
- 다른 PC 로 옮기기 전에 **Push**, 다른 PC 에서 시작할 때 **Pull** 먼저
- Quartus 가 그 프로젝트를 열고 있는 동안에는 다른 방법(터미널 git 등)으로 `.qsf` 를 바꾸지 말 것
